import 'package:flutter/material.dart';
import 'package:webview_ex/service/youtube_audio_url_extractor.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'contents_index_screen.dart';

class VideoScreen extends StatefulWidget {
  final Map<String,dynamic> item;

  const VideoScreen({super.key, required this.item});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late YoutubePlayerController _controller;
  String? _audioUrl;
  final _extractor = YoutubeAudioUrlExtractor();
  bool _isFullScreen = false;
  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async {
    final videoId = YoutubePlayer.convertUrlToId(widget.item['audioUrl']);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _controller.addListener(_onPlayerStateChange);
    _audioUrl = await _extractor.getAudioUrl('NLnqdFfEm9s');
  }
  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: _isFullScreen ? 0 : 108.0),
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Color(0xff0baf00),
                progressColors: const ProgressBarColors(
                  playedColor: Color(0xff0baf00),
                  handleColor: Color(0xff0baf00),
                ),
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    // some widgets
                    player,
                    //some other widgets
                    Center(
                      child: Text(_audioUrl?? ''),
                    )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 60.0,left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Semantics(
                  label: '뒤로가기',
                  hint: '이전 화면으로 가기 위해 누르세요',
                  child: GestureDetector(
                    onTap: _onTapped,
                    child: Row(children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 32.0,
                      ),
                    ]),
                  ),
                )
              ],
            ),
          ),
        ]
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    super.dispose();
  }
  void _onTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ContentsIndexScreen()
    ));
    // Navigator.of(context).pop(); //
  }
}