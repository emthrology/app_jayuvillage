
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_ex/page_manager.dart';
import '../service/dependency_injecter.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';

class MiniAudioPlayer extends StatefulWidget {
  const MiniAudioPlayer({super.key});

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}
final pageManager = getIt<PageManager>();

class _MiniAudioPlayerState extends State<MiniAudioPlayer> {
  late AudioPlayer player;
  String currentTitle = '';
  @override
  void initState() {
    super.initState();
    // _pageManager = PageManager();
    // pageManager.setLoopMode(LoopMode.all);
  }
  @override
  void dispose() {
    // _pageManager.dispose();
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
            child: ValueListenableBuilder<String>(
                valueListenable: pageManager.currentSongTitleNotifier,
                builder: (_, title,__) {return Text(title);}
            )
          ),
        ),
        Expanded(
          flex: 1,
          child: PlayButton()
        ),
        Expanded(
          flex: 1,
          child:
            NextSongButton()
        ),
      ],
    );
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

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed:  pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}