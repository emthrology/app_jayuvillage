import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/service/contents/mapping_service.dart';
import 'package:webview_ex/service/youtube_audio_url_extractor.dart';
import 'package:webview_ex/const/contents/content_type.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import '../store/store_service.dart';
import 'api_service.dart';
import 'playlist_repository.dart';
import 'dependency_injecter.dart';

class PlayerManager {
final _storeService = getIt<StoreService>();
final MappingService _mappingService = MappingService();
final ApiService _apiService = ApiService();
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');

  // 현재 곡의 artUri를 위한 새로운 ValueNotifier 추가
  final currentSongArtUriNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<MediaItem>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final playlistLengthNotifier = ValueNotifier<int>(0);
  final currentMediaItemNotifier = ValueNotifier<MediaItem?>(null);
  final isLiveStreamNotifier = ValueNotifier<bool>(false);
  final _audioHandler = getIt<AudioHandler>();
  final _extractor = YoutubeAudioUrlExtractor();

  // MediaItem? _currentMediaItem; //deprecated
  // Events: Calls coming from the UI
  void init() async {
    currentMediaItemNotifier.addListener(addUpVisit);
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToChangesInSong();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();

    _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
    repeatButtonNotifier.value = RepeatState.repeatPlaylist;
  }
  void addUpVisit() async {
    String? audioId = currentMediaItemNotifier.value?.id;
    if(audioId != null) {
      try {
        Response res = await _apiService.postItemWithResponse(endpoint: 'audios-count/$audioId', body: {});
        if ((res.statusCode == 200 || res.statusCode == 201) && res.data is! String) {
          _storeService.clearCache();
        }
      }catch(e) {
        throw Exception("API 요청 실패");
      }
    }
  }
  Map<String, dynamic>? _lastMusicItem;

  void updateCurrentMediaItem(MediaItem? mediaItem) {
    currentMediaItemNotifier.value = mediaItem;
  }

  Future<void> setLastMusicItem(Map<String, dynamic> item) async {
    _lastMusicItem = item;
  }

  Future<void> _loadPlaylist() async {
    final songRepository = getIt<PlaylistRepository>();
    final playlist = await songRepository.fetchInitialPlaylist();
    // 새로운 아이템 추가
    final mediaItems =
        await Future.wait(playlist.map((song) => _createMediaItem(song)));
    _audioHandler.addQueueItems(mediaItems);
  }

  //TODO 보관함 불러올 때 사용
  Future<void> updatePlaylist(List musicItems) async {
    // 기존 큐 비우기
    final currentQueue = _audioHandler.queue.value;
    for (var i = currentQueue.length - 1; i >= 0; i--) {
      await _audioHandler.removeQueueItemAt(i);
    }

    // 새로운 아이템 추가
    final mediaItems =
        await Future.wait(musicItems.map((song) => _createMediaItem(song)));
    await _audioHandler.addQueueItems(mediaItems);

    // 플레이리스트 업데이트 후 필요한 추가 작업
    _updateSkipButtons();
    if (mediaItems.isNotEmpty) {
      currentSongTitleNotifier.value = mediaItems.first.title;
      _audioHandler.play();
    }
  }

  Future<void> waitForMediaItem() async {
    if (_audioHandler.mediaItem.value != null) return;

    await for (final mediaItem in _audioHandler.mediaItem) {
      if (mediaItem != null) break;
    }
  }

  void _updateLiveStreamStatus() {
    final currentItem = _audioHandler.mediaItem.value;
    if (currentItem != null) {
      isLiveStreamNotifier.value = currentItem.extras?['isLive'] == true;
    }
  }

  Future<void> addAndPlayItem(Map item) async {
    // 라이브 스트림 상태 업데이트
    isLiveStreamNotifier.value = item['isLive'] == true;
    final mediaItem = await _createMediaItem(item);
    await _audioHandler.addQueueItem(mediaItem);
    final queue = _audioHandler.queue.value;
    final index = queue.indexOf(mediaItem);
    if (mediaItem.extras?['url'].contains('webm')) {
      Fluttertoast.showToast(
        msg: "실행할 수 없는 미디어입니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 4,
        backgroundColor: Color(0xff0baf00),
        textColor: Colors.white,
        fontSize: 20.0,
      );
      return;
    }
    if (index != -1) {
      Future.delayed(Duration(milliseconds: 500), () {
        waitForMediaItem();
        _updateLiveStreamState(mediaItem);
        _audioHandler.skipToQueueItem(index);
        _audioHandler.play();
      });
      // mediaItem이 생성되지 않았을 경우를 대비한 추가 로직
      if (_audioHandler.mediaItem.value == null) {
        await Future.delayed(Duration(seconds: 2)); // HLS 초기화를 위한 대기
        if (_audioHandler.mediaItem.value == null) {
          // 여전히 mediaItem이 없다면 수동으로 생성
          // _currentMediaItem = mediaItem;
          currentMediaItemNotifier.value = mediaItem;
        }
      }
    }
  }

  void _updateLiveStreamState(MediaItem mediaItem) {
    currentSongTitleNotifier.value = mediaItem.title;
    currentSongArtUriNotifier.value = mediaItem.artUri?.toString() ?? '';
    // 필요한 경우 다른 상태 업데이트
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '재생중이 아님';
        playlistLengthNotifier.value = 0;
      } else {
        final newList = playlist.toList();
        playlistNotifier.value = newList;
        playlistLengthNotifier.value = newList.length;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void skipToQueueItem(int index) {
    _audioHandler.skipToQueueItem(index);
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      Duration? d = mediaItem?.duration;
      bool fromGoogle;
      if(mediaItem != null) {
         fromGoogle = mediaItem.extras?['url'].contains('googlevideo.com');
      }else {
        fromGoogle = false;
      }
      Duration totalValue =
        d != null
          ? Platform.isIOS && fromGoogle
            ? d ~/ 2
            : d
          : Duration.zero;
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalValue
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        currentMediaItemNotifier.value = mediaItem;
        updateCurrentMediaItem(mediaItem);

        final isLive = mediaItem.extras?['isLive'] ?? false;
        if (isLive) {
          currentSongTitleNotifier.value = '${mediaItem.title} (라이브)';
          currentSongArtUriNotifier.value = mediaItem.artUri?.toString() ?? '';
        } else {
          currentSongTitleNotifier.value = mediaItem.title;
          currentSongArtUriNotifier.value = mediaItem.artUri?.toString() ?? '';
        }
      } else {
        currentSongTitleNotifier.value = '재생중이 아님';
        currentSongArtUriNotifier.value = '';
      }

      _updateSkipButtons();
    });

    // 추가: 재생 상태 변경 감지
    _audioHandler.playbackState.listen((playbackState) {
      if (playbackState.playing) {
        final currentItem = _audioHandler.mediaItem.value;
        if (currentItem != null && currentItem.extras?['isLive'] == true) {
          _updateLiveStreamState(currentItem);
        }
      }
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    final playbackState = _audioHandler.playbackState.value;
    if (playlist.isEmpty || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }

    // 반복 모드가 'all'일 때는 마지막 곡에서도 다음 곡 버튼을 활성화
    if (playbackState.repeatMode == AudioServiceRepeatMode.all) {
      isLastSongNotifier.value = false;
    }
  }

  void play() async {
    try {
      if (playlistLengthNotifier.value == 0 && _lastMusicItem != null) {
        await addAndPlayItem(_lastMusicItem!);
      } else if (playlistLengthNotifier.value > 0) {
        await _audioHandler.play();
      }
    } catch (e, stackTrace) {
      print('Error playing audio: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() async {
    if (playlistLengthNotifier.value > 0) {
      await _audioHandler.skipToPrevious();
      _updateLiveStreamStatus();
    }
  }

  void next() async {
    if (playlistLengthNotifier.value > 0) {
      await _audioHandler.skipToNext();
      _updateLiveStreamStatus();
      updateCurrentMediaItem(currentMediaItemNotifier.value);
    }
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add() async {
    final songRepository = getIt<PlaylistRepository>();
    final song = await songRepository.fetchAnotherSong();
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void removeAt(int index) {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if(index > lastIndex) return;
    _audioHandler.removeQueueItemAt(index);
    if(_audioHandler.queue.value.isEmpty) {
      currentSongArtUriNotifier.value = '';
      currentSongTitleNotifier.value = '재생중이 아님';
      stop();
    }
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  Future<MediaItem> _createMediaItem(Map song) async {
    return MediaItem(
      id: song['id'].toString(),
      album: song['album'] ?? '',
      title: song['isLive'] ? '${song['title']} (라이브)' : (song['title'] ?? ''),
      artUri: Uri.parse(song['imageUrl'] ?? ''),
      extras: {
        'type':_mappingService.getStringFromEnum(song['type'] as ContentType),
        'author': song['author'] ?? '',
        'url': await _getAudioUrl(song['audioUrl']),
        'subtitle': song['subtitle'] ?? '',
        'listerCount': song['listerCount'] ?? '',
        'viewCount': song['viewCount'] ?? 0,
        'shareCount': song['shareCount'] ?? 0,
        'likeCount': song['likeCount'] ?? 0,
        'isLike': song['isLike'] ?? false,
        'isLive': song['isLive'] ?? false,
        'startTime': song['startTime'] ?? '',
        'endTime': song['endTime'] ?? '',
        'createdAt': song['createdAt'] ?? '',
        'diffAt': song['diffAt'] ?? '',
      },
    );
  }

  Future<String> _getAudioUrl(String url) async {
    // print('before:$url');
    if (url.contains('youtube')) {
      url = await _extractor.getAudioUrl(url);
    }
    // print('audioUrl:$url');
    return url;
  }
}
