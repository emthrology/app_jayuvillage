import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_ex/component/rounded_inkwell_button.dart';

import '../../component/contents/storage/new_playlist_modal.dart';
import '../../component/contents/storage/playlist_modal.dart';
import '../../service/api_service.dart';
import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';
import '../../store/secure_storage.dart';
import '../../../const/contents/content_type.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});
  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final ApiService _apiService = ApiService();
  final secureStorage = getIt<SecureStorage>();
  final _playerManager = getIt<PlayerManager>();
  bool _isLoading = true;
  List<dynamic> bags = [];
  final double titleSize = 24.0;
  final double fontSize = 18.0;
  final String endpoint = 'bagitems';

  Future<void> _loadBags() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final bagsData = await _apiService.fetchItems(
          endpoint: endpoint,

      );
      bags = bagsData;
    } catch (e) {
      print('Error loading bags: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewPlaylist(String title) async {
    await _apiService.postItem(endpoint:endpoint, completeWord: '재생목록 등록', body: {'title': title});
    await _loadBags();
  }

  Future<void> _deletePlaylist(int index) async {
    int id = bags[index]['id'];
    await _apiService.deleteItem(endpoint: endpoint, id: '$id');
    await _loadBags();
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('삭제 확인'),
          content: Text(
            '정말 삭제하시겠습니까?',
            style: TextStyle(fontSize: fontSize),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(fontSize: fontSize),
              ),
            ),
            TextButton(
              onPressed: () {
                _deletePlaylist(index);
                Navigator.of(context).pop();
              },
              child: Text('삭제',
                  style: TextStyle(fontSize: fontSize, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> getValue(key) async {
    String value = await secureStorage.readSecureData(key);
    return value;
  }
  Future<void> _loadPlayList(String bagId) async {
    setState(() {
      _isLoading = true;
    });
    String sessionData = await getValue('session');
    Map<String, dynamic> json = jsonDecode(sessionData);
    int user_id = json['success']?['id'];
    try {
      final playlistData = await _apiService.fetchItems(
          endpoint: 'bags',
          queries: {'bag_item_id':'$bagId','user_id':'$user_id'}
      );
      print('playlistData:$playlistData');
      List<dynamic> playlistItems = _mapItems(playlistData);
      print('playlistItems:$playlistItems');
      await _playerManager.updatePlaylist(playlistItems);
    } catch(e) {
      print('Error loading bags: $e');
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  T? getEnumFromString<T extends Enum>(String str, List<T> values) {
    try {
      return values.firstWhere((e) => e.name.toLowerCase() == str.toLowerCase());
    } on StateError {
      return null; // 일치하는 enum 값이 없을 경우
    }
  }
  List<Map<String, dynamic>> _mapItems(List<dynamic> apiData) {
    return apiData.map((item) => {
      'type': getEnumFromString(item['category'], ContentType.values),
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
  void initState() {
    super.initState();
    _loadBags();
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
                '보관함',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 48.0, left: 4.0, right: 4.0),
              child: RoundedInkwellButton(
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => NewPlaylistModal(
                      onCreate: _addNewPlaylist,
                    ),
                  );
                },
                child: Text(
                  '+ 새 재생목록 만들기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: bags.length,
                      itemBuilder: (context, index) {
                        return _buildListItem(index);
                      }),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildListItem(int index) {
    String title = bags[index]['title']!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.play_arrow, size: 32.0),
            onPressed: () {
              print('재생: ${bags[index]['id']}');
              _loadPlayList('${bags[index]['id']}');
            },
          ),
          title: InkWell(
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Colors.white,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PlaylistModal(
                    item: bags[index],
                    onCreate: _addNewPlaylist,
                    onTitleChanged: _loadBags,
                  ),
                );
              },
              child: Text(title, style: TextStyle(fontSize: titleSize))),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline_outlined,
                size: 32.0, color: Colors.red),
            onPressed: () {
              _confirmDelete(index);
            },
          ),
        ),
      ),
    );
  }
}
