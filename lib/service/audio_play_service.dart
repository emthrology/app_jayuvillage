import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId:
            "com.codeforany.music_player.channel.audio",
        androidNotificationChannelName: "music_player",
        androidNotificationIcon: "drawable/ic_stat_music_note",
        androidShowNotificationBadge: true,
        androidStopForegroundOnPause: true,
      ));
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();

  MyAudioHandler() {
    loadEmptyPlaylist();
    notifyAudioHandlerAboutPlaybackEvents();
    listenForDurationChanges();
    listenForCurrentSongIndexChanges();
    listenForSequenceStateChanges();
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  Future<void> loadEmptyPlaylist() async {
    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse('https://ccrma.stanford.edu/~jos/mp3/harpsi-cs.mp3'),
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: '1',
          // Metadata to display in the notification:
          album: "Album name",
          title: "Song name",
          artUri: Uri.parse(
              'https://c.saavncdn.com/408/Rockstar-Hindi-2011-20221212023139-500x500.jpg'),
        ),
      ));
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> notifyAudioHandlerAboutPlaybackEvents() async {
    player.playbackEventStream.listen((event) {
      final playing = player.playing;
      playbackState.add(PlaybackState(
        // Which buttons should appear in the notification now
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.pause,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        // Which other actions should be enabled in the notification
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        // Which controls to show in Android's compact view.
        androidCompactActionIndices: const [0, 1, 3],
        // Whether audio is ready, buffering, ...
        processingState: AudioProcessingState.ready,
        // Whether audio is playing
        playing: true,
        // The current position as of this update. You should not broadcast
        // position changes continuously because listeners will be able to
        // project the current position after any elapsed time based on the
        // current speed and whether audio is playing and ready. Instead, only
        // broadcast position updates when they are different from expected (e.g.
        // buffering, or seeking).
        updatePosition: const Duration(milliseconds: 54321),
        // The current buffered position as of this update
        bufferedPosition: const Duration(milliseconds: 65432),
        // The current speed
        speed: 1.0,
        // The current queue position
        queueIndex: 0,
      ));
    });
  }

  Future<void> listenForDurationChanges() async {
    player.durationStream.listen((duration) {
      var index = player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty || newQueue.length < index) return;
      if (player.shuffleModeEnabled) {
        index = player.shuffleIndices!.indexOf(index);
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  Future<void> listenForCurrentSongIndexChanges() async {
    player.currentIndexStream.listen((index) {
      final pPlaylist = queue.value;
      if (index == null || pPlaylist.isEmpty) return;
      if (player.shuffleModeEnabled) {
        index = player.shuffleIndices!.indexOf(index);
      }
      mediaItem.add(pPlaylist[index]);
    });
  }

  Future<void> listenForSequenceStateChanges() async {
    player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }
}