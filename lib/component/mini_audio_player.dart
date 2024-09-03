import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../service/audio_play_service.dart';

class MiniAudioPlayer extends StatefulWidget {
  const MiniAudioPlayer({super.key});

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {

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
    player.setLoopMode(LoopMode.all);
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
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Image.asset('asset/images/default_thumbnail.png',
              // width: 40
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            alignment: Alignment.centerLeft,
            // width: 160,
            child: Text(currentTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (_, snapshot) {
              if(snapshot.hasData) {
                final playerState = snapshot.data;
                return _playPauseButton(playerState!);
              }else {
                return Center(
                  child: SizedBox(
                    width: 36.0,
                    height: 36.0,
                    child: CircularProgressIndicator(),
                  )
                );
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (_, __) {
              return _nextButton();
            },
          ),
        ),
      ],
    );
  }
  Widget _playPauseButton(PlayerState playerState) {
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        width: 36.0,
        height: 36.0,
        child: CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      return IconButton(
        padding: EdgeInsets.only(bottom:2.0),
        icon: Icon(Icons.play_arrow),
        iconSize: 36.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        padding: EdgeInsets.only(bottom: 2.0),
        icon: Icon(Icons.pause),
        iconSize: 36.0,
        onPressed: player.pause,
      );
    } else {
      return IconButton(
        padding: EdgeInsets.only(bottom: 2.0),
        icon: Icon(Icons.replay),
        iconSize: 36.0,
        onPressed: () => player.seek(Duration.zero,
            index: player.effectiveIndices?.first),
      );
    }
  }
  Widget _nextButton() {
    return IconButton(
      padding: EdgeInsets.only(bottom: 2.0),
      icon: Icon(Icons.fast_forward),
      iconSize: 36.0,
      onPressed: player.hasNext ? player.seekToNext : null,
    );
  }
}
