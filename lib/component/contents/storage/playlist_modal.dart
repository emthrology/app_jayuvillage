import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/component/contents/storage/list_item.dart';
import 'package:webview_ex/component/white_button.dart';
import '../../../service/api_service.dart';
import '../../../service/contents/mapping_service.dart';
import '../../../service/dependency_injecter.dart';
import '../../../service/player_manager.dart';
import '../../../store/secure_storage.dart';
import '../../../const/contents/content_type.dart';
import '../../../store/store_service.dart';


class PlaylistModal extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(String) onCreate;
  final Function onTitleChanged; // 추가된 콜백
  const PlaylistModal({super.key, required this.item, required this.onCreate, required this.onTitleChanged});

  @override
  _PlaylistModalState createState() => _PlaylistModalState();
}

class _PlaylistModalState extends State<PlaylistModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final MappingService _mappingService = MappingService();
  final secureStorage = getIt<SecureStorage>();
  final _storeService = getIt<StoreService>();
  final _playerManager = getIt<PlayerManager>();
  bool _editMode = false;
  bool _isButtonEnabled = false;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isLoading = true;
  final String endpoint = 'bags';
  List<dynamic> playlistItems = [];
  List<dynamic> tempPlaylistItems = [];
  List<bool> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _loadPlayList();
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

  Future<dynamic> getValue(key) async {
    String value = await secureStorage.readSecureData(key);
    return value;
  }
  Future<void> _loadPlayList() async {
    setState(() {
      _isLoading = true;
    });
    String sessionData = await getValue('session');
    Map<String, dynamic> json = jsonDecode(sessionData);
    int user_id = json['success']?['id'];
    try {
      final playlistData = await _apiService.fetchItems(
        endpoint: endpoint,
        queries: {'bag_item_id':'${widget.item['id']}','user_id':'$user_id'}
      );
      print('playlistData:$playlistData');
      setState(() {
        playlistItems = _mappingService.mapItemsFromStoreList(playlistData);
        selectedItems = List.generate(playlistItems.length, (_) => false);
      });
    } catch(e) {
      print('Error loading bags: $e');
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveChanges() async {
    // 1. tempPlaylistItem에만 있는 아이템의 id를 모아 list로 만든다 (이름은 delete).
    List<int> delete = tempPlaylistItems
        .where((item) => !playlistItems.contains(item))
        .map((item) => item['id'] as int)
        .toList();

    // 2. playlistItem에 있는 '현재 순서'에 따라 id를 모아 list로 만든다 (이름은 update).
    List<int> update = playlistItems
        .map((item) => item['id'] as int)
        .toList();

    // 3. widget.item['id'] (이름은 bag_item_id)
    int bagItemId = widget.item['id'];

    // 4. _controller.value (제목 값, 이름은 title)
    String title = _controller.text;

    // 5. 위 값들을 가지고 Map으로 만든다 (이름은 items)
    Map<String, dynamic> items = {
      'delete': delete,
      'update': update,
      'bag_item_id': bagItemId,
      'title': title,
    };

    // 6. apiService의 postItem 템플릿을 구성한다
    // (endpoint: '$endpoint/reorder', body: {'items': items})
    String completeWord = '수정작업이 ';
    try {
      Response res = await _apiService.postItemWithResponse(
        endpoint: '$endpoint/reorder',
        body: {'items': items},
      );
      if((res.statusCode == 200 || res.statusCode == 201) && res.data is! String) {
        _storeService.clearCache();
        Fluttertoast.showToast(
            msg: "$completeWord 완료되었습니다.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xff0baf00),
            textColor: Colors.white,
            fontSize: 16.0
        );
        setState(() {
          widget.item['title'] = title;
        });
        _loadPlayList();
        widget.onTitleChanged(); // 콜백 호출
      }else {
        Fluttertoast.showToast(
            msg: "$completeWord 실패하였습니다.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Color(0xffff0000),
            textColor: Colors.white,
            fontSize: 16.0
        );
        _cancelEditMode(); // 오류
      }
    } catch(e) {
      Fluttertoast.showToast(
          msg: "$completeWord 실패하였습니다.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Color(0xffff0000),
          textColor: Colors.white,
          fontSize: 16.0
      );
      _cancelEditMode();
    }
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
  void _deleteItem(int index) {
    setState(() {
      playlistItems.removeAt(index);
    });
  }

  void _enterEditMode() {
    setState(() {
      _editMode = true;
      tempPlaylistItems = List.from(playlistItems); // Store original data
      _animationController.forward();
    });
  }

  void _cancelEditMode() {
    setState(() {
      _editMode = false;
      playlistItems = List.from(tempPlaylistItems); // Revert to original data
      tempPlaylistItems = [];
      _animationController.reverse();
    });
  }
  void _playSelected() {
    List<Map<String, dynamic>> selectedPlaylist = [];
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        selectedPlaylist.add(playlistItems[i]);
      }
    }
    if(selectedPlaylist.isEmpty) {
      Fluttertoast.showToast(
          msg: "최소 한 곡 이상 선택해주세요",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Color(0xff0baf00),
          textColor: Colors.white,
          fontSize: 22.0
      );
    }
    _playerManager.updatePlaylist(selectedPlaylist);
    Navigator.pop(context);
  }

  void _playAll() {
    _playerManager.updatePlaylist(playlistItems);
    Navigator.pop(context);
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
        padding: const EdgeInsets.only(top: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_editMode) {
                        _cancelEditMode();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(_editMode ? '취소' : '닫기',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: _editMode ? Colors.red : Colors.black
                        )),
                  ),
                  SizedBox(
                    width: 250,
                    child: Center(
                      child: Text(
                        widget.item['title'] ?? '새 재생목록',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_editMode) {
                        setState(() {
                          //TODO delete demo
                          _editMode = false;
                          _animationController.reverse();

                          saveChanges();
                        });
                      } else {
                        _enterEditMode();
                      }
                    },
                    child: Text(_editMode ? '완료' : '수정',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: _editMode ? Color(0xff0baf00) : Colors.black
                        )),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _editMode
                    ? SlideTransition(
                  position: _offsetAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      key: ValueKey('TextField'),
                      controller: _controller,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        labelText: '재생목록 제목',
                        labelStyle: TextStyle(
                          fontSize: 20.0,
                        )
                      ),
                    ),
                  ),
                )
                    : SizedBox.shrink(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9 - 180,
                child: ListView.builder(
                  itemCount: playlistItems.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        if (!_editMode)
                          Checkbox(
                            value: selectedItems[index],
                            activeColor: Color(0xff0abf00),
                            onChanged: (bool? value) {
                              setState(() {
                                selectedItems[index] = value!;
                              });
                            },
                          ),
                        Expanded(
                          child: ListItem(
                            isEditMode: _editMode,
                            item: playlistItems[index],
                            onMoveUp: index > 0
                                ? () => _moveItem(index, index - 1)
                                : null,
                            onMoveDown: index < playlistItems.length - 1
                                ? () => _moveItem(index, index + 1)
                                : null,
                            onDelete: () => _deleteItem(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: _editMode
                      ? null
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WhiteButton(
                          onTap: () {_playSelected();},
                          size: Size(50, 50),
                          title: '선택 재생'
                      ),
                      WhiteButton(
                          onTap: () {_playAll();},
                          size: Size(50, 50),
                          title: '전체 재생'
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
