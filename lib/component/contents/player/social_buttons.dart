import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/component/contents/player/player_playlist_modal.dart';
import 'package:webview_ex/component/contents/storage/list_playlist_modal.dart';
import 'package:webview_ex/const/contents/content_type.dart';
import 'package:webview_ex/service/api_service.dart';
import 'package:webview_ex/store/store_service.dart';

import '../../../service/dependency_injecter.dart';
import '../../../service/player_manager.dart';
import '../../../store/secure_storage.dart';

class SocialButtons extends StatefulWidget {
  final List bags;
  final MediaItem mediaItem;

  final ContentType contentType;

  SocialButtons({Key? key, required this.bags, required this.mediaItem, required this.contentType}) : super(key: key);

  @override
  _SocialButtonsState createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  final playerManager = getIt<PlayerManager>();
  final _storeService = getIt<StoreService>();
  final secureStorage = getIt<SecureStorage>();
  final ApiService _apiService = ApiService();
  String userId = '';
  late String sessionData;
  late int likeCount;
  late int viewCount;
  bool isLiked = false;

  @override
  void initState() {
    _getSessionValue();
    getLikeStatus();
    super.initState();
    likeCount = widget.mediaItem.extras?['likeCount'] ?? 0;
    viewCount = widget.mediaItem.extras?['viewCount'] ?? 0;
    // isLiked = widget.mediaItem.extras?['isLike'] ?? false;
    _loadMediaInfo();

  }
  Future<String> _getSessionValue() async {
    sessionData = await secureStorage.readSecureData('session');
    Map<String, dynamic> sessionObject = jsonDecode(sessionData);
    setState(() {
      userId = sessionObject['success']['id'].toString();
    });
    return userId;

  }
  Future<void> getLikeStatus() async {
    final result = await _apiService.fetchItems(
      endpoint: 'islike',
      queries:{
        'user_id': await _getSessionValue(),
        'audio_id': widget.mediaItem.id.toString(),
      },
      useCache: false,
    );
    setState(() {
      isLiked = result[0]['result'];
    });
  }
  Future<void> _loadMediaInfo() async {
    final String cacheKey = 'audios/${widget.mediaItem.id}';
    try {
      final infoData = await _apiService.fetchItems(
        endpoint: 'audios/${widget.mediaItem.id}',
        useCache: false,
      );
      print ('infodata:$infoData');
      // print(infoData[0]['is_like']);
      // print(infoData[0]['is_like'] is int);
      setState(() {
        likeCount = infoData[0]['like_count'];
        viewCount = infoData[0]['view_count'];
        // isLiked = infoData[0]['is_like'] == 0 ? false : true;
        _storeService.removeCache(cacheKey);
      });
    } catch(e) {
      print('eerr loadInfodata');
    }
  }
  void _toggleLike() async {
    try{

      Response res = await _apiService.putItemWithResponse(endpoint:'likes/audios/${widget.mediaItem.id}', body:{});
      print('toggleLike:$res');
      if ((res.statusCode == 200 || res.statusCode == 201) && res.data is! String) {
        setState(() {
          if (isLiked) {
            likeCount--;
          } else {
            likeCount++;
          }
          isLiked = !isLiked;
        });
        await _loadMediaInfo();
        // getLikeStatus();
      }
    }catch(e) {
      throw Exception('social_buttons: 좋아요 작업 오류 발생');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconText(Icons.remove_red_eye_outlined, '조회$viewCount', () {}),
          _buildIconText(
              isLiked ? Icons.favorite : Icons.favorite_border,
              '좋아요$likeCount',
              _toggleLike
          ),
          // _buildIconText(Icons.share, '공유', () {
          //   print('공유 클릭됨');
          // }),
          if(widget.bags.isNotEmpty)
            _buildIconText(Icons.library_music_rounded, '보관함', () {
              addToPlaylist(context, widget.bags);
            }),
          if(widget.contentType != ContentType.video)
            _buildIconText(Icons.list, '목록', () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                builder: (context) => PlayerPlaylistModal(),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: icon == Icons.favorite && isLiked ? Colors.red : null),
          SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }

  void addToPlaylist(BuildContext context, List<dynamic> bags) {
    final mediaItem = playerManager.currentMediaItemNotifier.value;
    // print('mediaItem:$mediaItem');
    if (mediaItem == null) {
      Fluttertoast.showToast(
        msg: "곡 정보가 없습니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Color(0xffff0000),
        textColor: Colors.white,
        fontSize: 24.0,
      );
      return;
    }
    // print('mediaItem.id:${mediaItem!.id}');
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          ListPlaylistModal(playlists: bags, audio_id: mediaItem.id),
    );
  }
}