import 'package:flutter/material.dart';
import 'package:webview_ex/component/rounded_inkwell_button.dart';
import 'package:webview_ex/component/storage/new_playlist_modal.dart';

import '../../component/storage/playlist_modal.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>  {
  final double titleSize = 24.0;
  final double fontSize = 18.0;
  final List<Map<String, dynamic>> playlistItems = List.generate(
    5,
    (index) => {
      'title': '[날짜$index]재생목록',
    },
  );

  void _addNewPlaylist(String title) {
    setState(() {
      //TODO api
      playlistItems.insert(0, {'title': title});
    });
  }

  void _deletePlaylist(int index) {
    setState(() {
      //TODO api
      playlistItems.removeAt(index);
    });
  }
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('삭제 확인'),
          content: Text('정말 삭제하시겠습니까?', style: TextStyle(fontSize: fontSize),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소', style: TextStyle(fontSize: fontSize),),
            ),
            TextButton(
              onPressed: () {
                _deletePlaylist(index);
                Navigator.of(context).pop();
              },
              child: Text('삭제', style: TextStyle(fontSize: fontSize, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
                  '보관함',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0,left: 4.0,right:4.0),
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
                child: ListView.builder(
                  itemCount: playlistItems.length,
                  itemBuilder: (context, index) {
                    return _buildListItem(index);
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
  Widget _buildListItem(int index) {
    String title = playlistItems[index]['title']!;
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
              print('재생: $title');
            },
          ),
          title: InkWell(
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                context: context,
                isScrollControlled: true,
                builder: (context) => PlaylistModal (
                  item: playlistItems[index],
                  onCreate: _addNewPlaylist,
                ),
              );
            },
            child: Text(title, style: TextStyle(fontSize: titleSize))
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline_outlined, size: 32.0, color: Colors.red),
            onPressed: () {
              _confirmDelete(index);
            },
          ),
        ),
      ),
    );
  }
}
