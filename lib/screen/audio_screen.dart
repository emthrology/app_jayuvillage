import 'package:audio_service/audio_service.dart';


import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../service/audio_play_service.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  // final AudioPlayer player = AudioPlayer();
  late AudioPlayer player;
  @override
  void initState() {
    super.initState();
    someFunction();
  }

  void someFunction() {
    MyAudioHandler audioHandler = MyAudioHandler();
    player = audioHandler.player;

    // 이제 player를 사용하여 작업할 수 있습니다.
  }

  void _initialize() async {
    // Set the audio url
    // await player.setAsset('assets/ex.mp3');
    // player.setAudioSource(AudioSource.uri(
    //   Uri.parse('https://ccrma.stanford.edu/~jos/mp3/harpsi-cs.mp3'),
    //   tag: const MediaItem(
    //     // Specify a unique ID for each media item:
    //     id: '1',
    //     // Metadata to display in the notification:
    //     album: "Album name",
    //     title: "Song name",
    //   ),
    // ));
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
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Column(
            children: [
              AppBar(
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                title: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text('오디오 테스트'),
                      Positioned(
                        left: -13,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: SvgPicture.asset('asset/images/backBtn.svg'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _play,
                child: const Text(
                  'Play',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: _pause,
                child: const Text(
                  'Stop',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
