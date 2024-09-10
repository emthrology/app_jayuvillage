import 'package:flutter/material.dart';

import '../../component/contents/music_item.dart';
import '../../component/contents/news_item.dart';
import '../../component/contents/podcast_item.dart';
import '../../component/contents/video_item.dart';
import '../../const/contents/content_type.dart';
import '../../page_manager.dart';
import '../../service/api_service.dart';
import '../../service/dependency_injecter.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}


class _ContentsScreenState extends State<ContentsScreen>  {
  final _pageManager = getIt<PageManager>();
  final ApiService _apiService = ApiService();
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
      final videoData = await _apiService.fetchItems(endpoint:'audios',query:'category',value:'video');
      final podcastData = await _apiService.fetchItems(endpoint:'audios',query:'category',value:'podcast');
      final musicData = await _apiService.fetchItems(endpoint: 'audios',query: 'category',value: 'music');
      final newsData = await _apiService.fetchItems(endpoint: 'audios',query: 'category',value: 'news');
      setState(() {
        videoItems = _mapItems(videoData, ContentType.video);
        podcastItems = _mapItems(podcastData, ContentType.podcast);
        musicItems = _mapItems(musicData, ContentType.music);
        newsItems = _mapItems(newsData, ContentType.news);
        _isLoading = false;
        // PlaylistRepository 업데이트
      }); // UI 업데이트를 위해 setState 호출
      // await _pageManager.updatePlaylist(podcastItems);
      await _pageManager.setLastMusicItem(musicItems[0]);
    } catch (e) {
      print('Error loading items: $e');
      // 에러 처리 로직 추가 (예: 사용자에게 알림 표시)
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  List<Map<String, dynamic>> _mapItems(List<dynamic> apiData, ContentType type) {
    return apiData.map((item) => {
      'type': type,
      'id': item['id'] ?? 0,
      'opening': item['openinig'] ?? 0,
      'imageUrl': item['audio_thumbnail'] ?? 'asset/images/upset.png',
      'title': item['title'] ?? '',
      'subtitle': item['content'] ?? '',
      'listerCount': item['view_count'] ?? '',
      'viewCount': item['view_count'] ?? 0,
      'shareCount': item['share_count'] ?? 0,
      'likeCount': item['like_count'] ?? 0,
      'isLike': item['is_like'] == 1,
      'audioUrl': item['audio_url'] ?? '',
      'file': item['file'] ?? '',

      'isLive': item['live_status'] == 1 ? true : false,
      'startTime' : item['startTime'] ?? '14:00',
      'endTime' : item['endTime'] ?? '',

      'album': item['title'] ?? '',

      'createdAt': item['created_at'] ?? '',
      'diffAt': item['diff_at'] ?? '',
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0, left:8.0, right:8.0,bottom:24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:12.0),
                child: Text(
                  '컨텐츠',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  :ListView(
                    children: [
                      _buildSection('뮤직비디오', ContentType.video),
                      _buildSection('팟케스트', ContentType.podcast),
                      _buildSection('추천음악', ContentType.music),
                      _buildSection('정치·시사·뉴스', ContentType.news)
                    ],
                )
              ),
            ] 
          )
        )
      ),
    );
  }
  Widget _buildSection(String title, ContentType type, ) {
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900
          ),
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
        if(items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // 더보기 버튼 클릭 시 로직 추가
                },
                child: Text('$title 더보기'),
              ),
            ),
          ),
        SizedBox(height: 32), // 섹션 간 여백
      ],
    );
  }
}

