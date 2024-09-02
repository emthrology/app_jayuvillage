import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';

import '../service/audio_play_service.dart';
import 'home_screen.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  // final AudioPlayer player = AudioPlayer();
  late AudioPlayer player;
  String currentTitle = '';

  @override
  void initState() {
    super.initState();
    setupAudioPlayer();
  }

  void setupAudioPlayer() {
    MyAudioHandler audioHandler = MyAudioHandler();
    player = audioHandler.player;

    // 현재 재생 중인 트랙의 제목을 업데이트
    player.currentIndexStream.listen((index) {
      if (index != null) {
        final currentItem = player.sequence?[index];
        if (currentItem != null) {
          setState(() {
            currentTitle = (currentItem.tag as MediaItem).title;
          });
        }
      }
    });
  }
  @override
  void dispose() {
    // player.dispose();
    super.dispose();
  }

  void _play() async {
    try {
      await player.play();
    } catch (error, stackTrace) {
      // Handle error
    }
  }

  void _pause() async {
    try {
      await player.pause();
    } catch (error, stackTrace) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.topCenter,
                                child: Image.asset('asset/images/default_thumbnail.png',
                                  width: MediaQuery.of(context).size.width,
                                )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(currentTitle)

                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                StreamBuilder<bool>(
                                  stream: player.shuffleModeEnabledStream,
                                  builder: (context, snapshot) {
                                    return _shuffleButton(context, snapshot.data ?? false);
                                  },
                                ),
                                StreamBuilder<SequenceState?>(
                                  stream: player.sequenceStateStream,
                                  builder: (_, __) {
                                    return _previousButton();
                                  },
                                ),
                                StreamBuilder<PlayerState>(
                                  stream: player.playerStateStream,
                                  builder: (_, snapshot) {
                                    final playerState = snapshot.data;
                                    return _playPauseButton(playerState!);
                                  },
                                ),
                                StreamBuilder<SequenceState?>(
                                  stream: player.sequenceStateStream,
                                  builder: (_, __) {
                                    return _nextButton();
                                  },
                                ),
                                StreamBuilder<LoopMode>(
                                  stream: player.loopModeStream,
                                  builder: (context, snapshot) {
                                    return _repeatButton(context, snapshot.data ?? LoopMode.off);
                                  },
                                ),
                              ],
                            ),

                          ],
                        )
                    )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Semantics(
                        label: '뒤로가기',
                        hint: '이전 화면으로 가기 위해 누르세요',
                        child: GestureDetector(
                          onTap: _onTapped,
                          child: Row(
                              children:[
                                Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 32.0,
                                ),
                              ]),),)],),
                ),
              ],
            )
        )
    );
  }
  void _onTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'))));
  }
  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () => player.seek(Duration.zero,
            index: player.effectiveIndices?.first),
      );
    }
  }
  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(Icons.shuffle, color: Theme.of(context).primaryColor)
          : Icon(Icons.shuffle),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await player.shuffle();
        }
        await player.setShuffleModeEnabled(enable);
      },
    );
  }
  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: player.hasPrevious ? player.seekToPrevious : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: player.hasNext ? player.seekToNext : null,
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat),
      Icon(Icons.repeat, color: Theme.of(context).primaryColor),
      Icon(Icons.repeat_one, color: Theme.of(context).primaryColor),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        player.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }
}