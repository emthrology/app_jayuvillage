import 'package:flutter/foundation.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'service/playlist_repository.dart';
import 'service/dependency_injecter.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  // 현재 곡의 artUri를 위한 새로운 ValueNotifier 추가
  final currentSongArtUriNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final playlistLengthNotifier = ValueNotifier<int>(0);

  final _audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  void init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    // LoopMode를 all로 초기화
    _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
    repeatButtonNotifier.value = RepeatState.repeatPlaylist;
  }
  Map<String, dynamic>? _lastMusicItem;
  Future<void> setLastMusicItem(Map<String, dynamic> item) async {
    _lastMusicItem = item;
  }
  Future<void> _loadPlaylist() async {
    final songRepository = getIt<PlaylistRepository>();
    final playlist = await songRepository.fetchInitialPlaylist();
    final mediaItems = playlist
        .map((song) => MediaItem(
      id: song['id'] ?? 0,
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      artUri: Uri.parse(song['artUri'] ?? ''),
      extras: {'url': song['url']},
    ))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }
  //TODO 보관함 불러올 때 사용
  Future<void> updatePlaylist(List<Map<String, dynamic>> musicItems) async {
    // 기존 큐 비우기
    final currentQueue = _audioHandler.queue.value;
    for (var i = currentQueue.length - 1; i >= 0; i--) {
      await _audioHandler.removeQueueItemAt(i);
    }

    // 새로운 아이템 추가
    final mediaItems = musicItems.map((song) => MediaItem(
      id: song['id'].toString(),
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      artUri: Uri.parse(song['imageUrl'] ?? ''),
      extras: {'url': song['file']},
    )).toList();

    await _audioHandler.addQueueItems(mediaItems);

    // 플레이리스트 업데이트 후 필요한 추가 작업
    _updateSkipButtons();
    if (mediaItems.isNotEmpty) {
      currentSongTitleNotifier.value = mediaItems.first.title;
    }
  }
  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
        playlistLengthNotifier.value = 0;
      } else {
        final newList = playlist.map((item) => item.title).toList();
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
  Future<void> addAndPlayItem(Map<String, dynamic> item) async {
    final mediaItem = MediaItem(
      id: item['id'].toString(),
      album: item['album'] ?? '',
      title: item['title'] ?? '',
      artUri: Uri.parse(item['imageUrl'] ?? ''),
      extras: {'url': item['file']},
    );

    await _audioHandler.addQueueItem(mediaItem);
    final queue = _audioHandler.queue.value;
    final index = queue.indexOf(mediaItem);
    if (index != -1) {
      await _audioHandler.skipToQueueItem(index);
      await _audioHandler.play();
    }
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
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '재생중이 아님';
      currentSongArtUriNotifier.value = mediaItem?.artUri?.toString() ?? '';
      _updateSkipButtons();
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

  void play() {
    if (playlistLengthNotifier.value == 0 && _lastMusicItem != null) {
      addAndPlayItem(_lastMusicItem!);
    } else if (playlistLengthNotifier.value > 0) {
      _audioHandler.play();
    }
  }
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() {
    if(playlistLengthNotifier.value > 0)
      _audioHandler.skipToPrevious();
  }
  void next() {
    if(playlistLengthNotifier.value > 0)
      _audioHandler.skipToNext();
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

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}