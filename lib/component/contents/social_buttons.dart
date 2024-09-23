import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/component/contents/storage/list_playlist_modal.dart';

import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';

class SocialButtons extends StatefulWidget {
  final List bags;
  final MediaItem mediaItem;


  SocialButtons({Key? key, required this.bags, required this.mediaItem}) : super(key: key);

  @override
  _SocialButtonsState createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<SocialButtons> {
  final playerManager = getIt<PlayerManager>();
  late int likeCount;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    likeCount = widget.mediaItem.extras?['likeCount'] ?? 0;
  }

  void _toggleLike() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
      }
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconText(Icons.remove_red_eye_outlined, '조회${widget.mediaItem.extras?['viewCount']}', () {
          }),
          _buildIconText(
              isLiked ? Icons.favorite : Icons.favorite_border,
              '좋아요$likeCount',
              _toggleLike
          ),
          _buildIconText(Icons.share, '공유', () {
            print('공유 클릭됨');
          }),
          if(widget.bags.isNotEmpty)
            _buildIconText(Icons.library_music_rounded, '보관함', () {
              addToPlaylist(context, widget.bags);
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