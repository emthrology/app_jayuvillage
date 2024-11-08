import 'package:dio/dio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_ex/const/contents/content_type.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../component/comments_section.dart';
import '../../component/contents/player/detail_section.dart';
import '../../component/contents/player/social_buttons.dart';
import '../../service/api_service.dart';
import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';
import '../../store/store_service.dart';
import 'contents_index_screen.dart';

class VideoScreen extends StatefulWidget {
  final Map<String,dynamic> item;

  const VideoScreen({super.key, required this.item});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final playerManager = getIt<PlayerManager>();
  final _storeService = getIt<StoreService>();
  final ApiService _apiService = ApiService();
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  @override
  void initState() {
    addUp();
    super.initState();
    _init();
    playerManager.stop();
    makeMediaItem(widget.item);
  }
  Future<void> addUp() async {
    try {
      Response res = await _apiService.postItemWithResponse(endpoint: 'audios-count/${widget.item['id']}', body: {});
      if ((res.statusCode == 200 || res.statusCode == 201) && res.data is! String) {
        _storeService.clearCache();
      }
    }catch(e) {
      throw Exception("API 요청 실패");
    }
  }

  Future<void> _init() async {
    final videoId = YoutubePlayer.convertUrlToId(widget.item['audioUrl']);
    // print('videoId:$videoId');
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _controller.addListener(_onPlayerStateChange);
    // _audioUrl = await _extractor.getAudioUrl('IBh2rLADsoI');
  }
  void _onPlayerStateChange() {
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }

  MediaItem makeMediaItem(Map<String, dynamic> item) {
    print('vodeoScreenMakeMediaItem:$item');
    final mediaItem = MediaItem(
      id: item['id'].toString(),
      album: item['album'] ?? '',
      title: item['title'] ?? '',
      artUri: Uri.parse(item['imageUrl'] ?? ''),
      extras: {
        'url': (item['audioUrl']),
        'subtitle': item['subtitle'] ?? '',
        'listerCount': item['listerCount'] ?? '',
        'viewCount': item['viewCount'] ?? 0,
        'shareCount': item['shareCount'] ?? 0,
        'likeCount': item['likeCount'] ?? 0,
        'isLike': item['isLike'] ?? false,
        'isLive': item['isLive'] ?? false,
        'startTime': item['startTime'] ?? '',
        'endTime': item['endTime'] ?? '',
        'createdAt': item['createdAt'] ?? '',
        'diffAt': item['diffAt'] ?? '',
      },
    );
    return mediaItem;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // some widgets
                      player,
                      //some other widgets
                      SocialButtons(bags: [], mediaItem: makeMediaItem(widget.item), contentType:ContentType.video),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: DetailSection(mediaItem: makeMediaItem(widget.item))),
                      SizedBox(height: 10,),
                      CommentsSection(contentType: ContentType.video, commentableId: widget.item['id'].toString(),)
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
        builder: (_) => ContentsIndexScreen(pageIndex: '1',)
    ));
    // Navigator.of(context).pop(); //
  }
}