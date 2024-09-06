import 'package:flutter/material.dart';

import '../../component/contents/music_item.dart';
import '../../component/contents/podcast_item.dart';
import '../../component/contents/video_item.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

enum ContentType { video, podcast, music, news }

class _ContentsScreenState extends State<ContentsScreen>  {
  Map<ContentType, int> itemCounts = {
    ContentType.video: 3,
    ContentType.podcast: 5,
    ContentType.music: 5,
    ContentType.news: 5,
  };
  final List<Map<String, dynamic>> videoItems = List.generate(
    3,
    (index) => {
      'imageUrl': 'asset/images/upset.png',
      'title': '광화문애가'
    },
  );
  final List<Map<String, dynamic>> podcastItems = List.generate(
    5,
    (index) => {
      'imageUrl':'asset/images/pngegg.png',
      'title':'[날짜] 오늘의 이슈',
      'subtitle':'자유마을과 함께하는 라디오타임',
      'isLive':true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },
  );
  final List<Map<String, dynamic>> musicItems = List.generate(
    5,
    (index) => {
      'imageUrl':'asset/images/music_jacket.png',
      'title':'광화문애가',
      'album':'광화문애가',
      'viewCount': 170000000,
      'shareCount': 23000,
      'subtitle':'눈물주의, 광화문에 한번이라도 나온 국민에게 위로가 되는 노래',
    }
  );
  @override
  void initState() {
    super.initState();

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
                child: ListView(
                  children: [
                    _buildSection('뮤직비디오', ContentType.video),
                    _buildSection('팟케스트', ContentType.podcast),
                    _buildSection('추천음악', ContentType.music),
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
        items = podcastItems;
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
            default:
              return SizedBox.shrink();
          }
        }).toList(),
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

