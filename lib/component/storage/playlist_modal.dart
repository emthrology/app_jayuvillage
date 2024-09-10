import 'package:flutter/material.dart';
import 'package:webview_ex/component/storage/list_item.dart';

import '../contents/music_item.dart';
import '../contents/news_item.dart';
import '../contents/podcast_item.dart';
import '../contents/video_item.dart';
import '../../const/contents/content_type.dart';

class PlaylistModal extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(String) onCreate;

  const PlaylistModal({super.key, required this.item, required this.onCreate});

  @override
  _PlaylistModalState createState() => _PlaylistModalState();
}

class _PlaylistModalState extends State<PlaylistModal> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _editMode = false;
  bool _isButtonEnabled = false;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  // TODO delete demo
  final List<Map<String,dynamic>> playlistItems = [
    {
      'type': ContentType.podcast,
      'imageUrl':'asset/images/pngegg.png',
      'title':'첫번째',
      'subtitle':'자유마을과 함께하는 라디오타임',
      'isLive':true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },
    {
      'type': ContentType.podcast,
      'imageUrl':'asset/images/pngegg.png',
      'title':'두번째',
      'subtitle':'자유마을과 함께하는 라디오타임',
      'isLive':true,
      'listerCount': 1700,
      'startTime': '14:00',
      'endTime': ''
    },

    {
      'type': ContentType.music,
      'imageUrl':'asset/images/music_jacket.png',
      'title':'광화문애가',
      'album':'광화문애가',
      'viewCount': 170000000,
      'shareCount': 23000,
      'subtitle':'눈물주의, 광화문에 한번이라도 나온 국민에게 위로가 되는 노래',
    },
    {
      'type': ContentType.news,
      'imageUrl': 'asset/images/music_jacket.png',
      'title':'[걸리면 죽는다] 문재인 수사 문재인 수사',
      'subtitle':'눈물주의, 광화문에 한번이라도 나온 국민에게 위로가 되는 노래',
      'channel':'고성국TV',
      'viewCount':170000,
      'shareCount':23000
    }
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _controller.text = widget.item['title'] ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(_animationController);
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _controller.text.isNotEmpty;
    });
  }
  void _moveItem(int oldIndex, int newIndex) {
    setState(() {
      final item = playlistItems.removeAt(oldIndex);
      playlistItems.insert(newIndex, item);
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        padding: const EdgeInsets.only(top:16.0),
        child: Stack(
          children:[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        if(_editMode) {
                          _animationController.reverse();

                          setState(() {
                            //TODO cancel edit

                            _editMode = false;
                          });
                        }else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(_editMode ? '취소' : '닫기', style: TextStyle(fontSize: 18.0)),
                    ),
                    Text(
                      widget.item['title'] ?? '새 재생목록',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editMode = !_editMode;
                          if (_editMode) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                          }
                        });
                      },
                      child: Text(_editMode ? '완료' : '수정', style: TextStyle(fontSize: 18.0)),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _editMode
                      ? SlideTransition(
                    position: _offsetAnimation,
                    child: TextField(
                      key: ValueKey('TextField'),
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '재생목록 제목',
                      ),
                    ),
                  )
                      : SizedBox.shrink(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: playlistItems.length,
                    itemBuilder: (context, index) {
                      return ListItem(
                        item: playlistItems[index],
                        onMoveUp: index > 0 ? () => _moveItem(index, index - 1) : null,
                        onMoveDown: index < playlistItems.length - 1 ? () => _moveItem(index, index + 1) : null,
                      );
                    },
                  ),
                ),

              ],
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 선택 재생 로직
                      },
                      child: Text('선택 재생'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 전체 재생 로직
                      },
                      child: Text('전체 재생'),
                    ),
                  ],
                ),
              ),
            ),
          ]

        ),
      ),
    );
  }
}