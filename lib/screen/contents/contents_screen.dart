import 'package:flutter/material.dart';
import 'package:webview_ex/component/white_button.dart';
import 'package:webview_ex/screen/contents/type_selected_contents_screen.dart';

import '../../component/contents/music_item.dart';
import '../../component/contents/news_item.dart';
import '../../component/contents/podcast_item.dart';
import '../../component/contents/video_item.dart';
import '../../const/contents/content_type.dart';
import '../../service/player_manager.dart';
import '../../service/api_service.dart';
import '../../service/contents/mapping_service.dart';
import '../../service/dependency_injecter.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  final _playerManager = getIt<PlayerManager>();
  final ApiService _apiService = ApiService();
  final MappingService _mappingService = MappingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> videoItems = [];
  List<Map<String, dynamic>> podcastItems = [];
  List<Map<String, dynamic>> musicItems = [];
  List<Map<String, dynamic>> newsItems = [];

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final videoData = await _apiService
          .fetchItems(endpoint: 'audios', queries: {'category': 'video'});
      final podcastData = await _apiService
          .fetchItems(endpoint: 'audios', queries: {'category': 'podcast'});
      final musicData = await _apiService
          .fetchItems(endpoint: 'audios', queries: {'category': 'music'});
      // final newsData = await _apiService.fetchItems(endpoint: 'audios',queries:{'category':'news'});
      setState(() {
        videoItems = _mappingService.mapItems(videoData, ContentType.video);
        podcastItems =
            _mappingService.mapItems(podcastData, ContentType.podcast);
        musicItems = _mappingService.mapItems(musicData, ContentType.music);
        // newsItems = _mapItems(newsData, ContentType.news);
        _isLoading = false;
        // PlaylistRepository 업데이트
      }); // UI 업데이트를 위해 setState 호출
      // await _pageManager.updatePlaylist(podcastItems);
      await _playerManager.setLastMusicItem(musicItems[0]);
    } catch (e) {
      print('Error loading items: $e');
      // 에러 처리 로직 추가 (예: 사용자에게 알림 표시)
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(
                  top: 32.0, left: 8.0, right: 8.0, bottom: 24.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '컨텐츠',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView(
                                children: [
                                  _buildSection('뮤직비디오', ContentType.video),
                                  _buildSection('팟케스트', ContentType.podcast),
                                  _buildSection('추천음악', ContentType.music),
                                  // _buildSection('정치·시사·뉴스', ContentType.news)
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              )),
                  ]))),
    );
  }

  Widget _buildSection(
    String title,
    ContentType type,
  ) {
    List<Map<String, dynamic>> items;

    switch (type) {
      case ContentType.video:
        items = videoItems;
        break;
      case ContentType.music:
        items = musicItems;
        break;
      case ContentType.podcast:
        items = podcastItems;
        break;
      case ContentType.news:
        items = newsItems;
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        ...items.map((item) {
          switch (type) {
            case ContentType.video:
              return VideoItem(item: item);
            case ContentType.podcast:
              return PodcastItem(item: item);
            case ContentType.music:
              return MusicItem(item: item);
            case ContentType.news:
              return NewsItem(item: item);
            default:
              return SizedBox.shrink();
          }
        }),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
                child: WhiteButton(
              size: Size(MediaQuery.of(context).size.width - 100, 50),
              onTap: () {
                onTapMore(type);
              },
              title: '$title 더보기',
            )),
          ),
        SizedBox(height: 32), // 섹션 간 여백
      ],
    );
  }

  void onTapMore(ContentType type) {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (_) => TypeSelectedContentsScreen(contentType: type)));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TypeSelectedContentsScreen(contentType: type)));
  }
}
