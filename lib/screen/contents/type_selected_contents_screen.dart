import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../component/contents/music_item.dart';
import '../../component/contents/news_item.dart';
import '../../component/contents/podcast_item.dart';
import '../../component/contents/video_item.dart';
import '../../component/contents/player/mini_audio_player.dart';
import '../../const/contents/content_type.dart';
import '../../service/api_service.dart';
import '../../service/contents/mapping_service.dart';

class TypeSelectedContentsScreen extends StatefulWidget {
  const TypeSelectedContentsScreen({super.key, required this.contentType});

  final ContentType contentType;

  @override
  State<TypeSelectedContentsScreen> createState() =>
      _TypeSelectedContentsScreenState();
}

class _TypeSelectedContentsScreenState
    extends State<TypeSelectedContentsScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final MappingService _mappingService = MappingService();
  late List<dynamic> subcategory = [];
  List<dynamic> sortings =[{'desc':'최신순'},{'like':'인기순'},{'asc':'날짜순'}];
  List<dynamic> subList = [];
  String selectedSubcategory = '애국가요';
  Map<String,String> selectedSorting = {'desc':'최신순'};
  bool reloadFetch = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isPlayerVisible = true;
  Offset _playerOffset = Offset.zero;
  final double _maxHideRatio = 0.83;

  @override
  void initState() {
    super.initState();
    if (widget.contentType == ContentType.music) {
      _loadSubcategory();
    } else {
      _loadList({'category': _getContentTypeValue(widget.contentType), 'sorts': 'desc'});
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 32.0, left: 8.0, right: 8.0, bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.contentType == ContentType.music
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                            subcategory.isEmpty ? [] :
                            subcategory.map((item) {
                              String name = item['name'];
                              bool selected = selectedSubcategory == name;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSubcategory = item['name'];
                                    reloadFetch = true;
                                    _loadList({'category':_getContentTypeValue(widget.contentType),'sub_category': selectedSubcategory, 'sorts': selectedSorting.keys.first});
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: selected ? Colors.black : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: selected ? Colors.black : Colors.grey,
                                      fontWeight:
                                      selected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                        ))
                    : Container(),
                // Padding(
                //         padding: const EdgeInsets.only(bottom: 12.0),
                //         child: Text(
                //           _getContentTypeLabel(widget.contentType),
                //           style: TextStyle(
                //             fontSize: 36,
                //             fontWeight: FontWeight.w900,
                //           ),
                //         ),
                //       ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: sortings.map((item) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSorting = item;
                          reloadFetch = true;
                          _loadList({'category':_getContentTypeValue(widget.contentType),'sub_category': selectedSubcategory, 'sorts': selectedSorting.keys.first});
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(color: selectedSorting.keys.first == item.keys.first ? Colors.black : Colors.grey),
                        ),
                        child: Text(
                          item.values.first,
                          style:
                          TextStyle(color: selectedSorting.keys.first == item.keys.first ? Colors.black : Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32),
                Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children: [
                              _buildSection(widget.contentType),

                            ],
                          )
                ),
              ],
            ),
          ),
          if(widget.contentType != ContentType.video)
            Positioned(
              bottom:0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: _updatePlayerVisibility,
                onHorizontalDragEnd: _finishDrag,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _slideAnimation.value * constraints.maxWidth,
                          child: child,
                        );
                      },
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2)
                              )
                            ]
                        ),
                        child: MiniAudioPlayer(),
                      ),
                    );
                  },
                ),
              )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Semantics(
                  label: '뒤로가기',
                  hint: '이전 화면으로 가기 위해 누르세요',
                  child: GestureDetector(
                    onTap: _onBackTapped,
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
        ]),
      ),
    );
  }
  Future<void> _loadSubcategory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _apiService.fetchItems(endpoint: 'audios-category');
      print('subcategory:$data');
      setState(() {
        subcategory = data;
        if (subcategory.isNotEmpty) {
          selectedSubcategory = subcategory.first['name'];
          _loadList({'category':_getContentTypeValue(widget.contentType),'sub_category': selectedSubcategory, 'sorts': selectedSorting.keys.first});
        }
      });
    }catch(e) {
      Fluttertoast.showToast(
        msg: "카테고리 로드 중 오류 발생",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Color(0xffff0000),
        textColor: Colors.white,
        fontSize: 24.0,
      );
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _loadList(Map<String, String> queryParams) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if(queryParams['category'] != 'music') {
        //TODO delete subcategory
        queryParams.remove('sub_category');
      }
      final data = await _apiService.fetchItems(
          endpoint: 'audios-list', queries: queryParams);
      // print('data:$data');
      if(subList.isEmpty || reloadFetch) {
        subList = _mappingService.mapItems(data, widget.contentType);
        reloadFetch = false;
      } else {
        List<dynamic> iterable = _mappingService.mapItems(data, widget.contentType);
        subList.addAll(iterable);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "로드 중 오류 발생",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Color(0xffff0000),
        textColor: Colors.white,
        fontSize: 24.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onBackTapped() {
    Navigator.of(context).pop();
  }

  String _getContentTypeValue(ContentType type) {
    switch (type) {
      case ContentType.video:
        return 'video';
      case ContentType.podcast:
        return 'podcast';
      case ContentType.music:
        return 'music';
      case ContentType.news:
        return 'news';
      default:
        return '';
    }
  }
  void _updatePlayerVisibility(DragUpdateDetails details) {
    setState(() {
      if (_isPlayerVisible) {
        _playerOffset += Offset(details.delta.dx / MediaQuery.of(context).size.width, 0);
        _playerOffset = Offset(
          _playerOffset.dx.clamp(-_maxHideRatio, _maxHideRatio),
          0,
        );
      } else {
        // 이미 숨겨진 상태에서는 반대 방향으로만 드래그 가능
        if ((_playerOffset.dx < 0 && details.delta.dx > 0) ||
            (_playerOffset.dx > 0 && details.delta.dx < 0)) {
          _playerOffset += Offset(details.delta.dx / MediaQuery.of(context).size.width, 0);
          _playerOffset = Offset(
            _playerOffset.dx.clamp(-1.0, 1.0),
            0,
          );
        }
      }
    });
  }
  void _finishDrag(DragEndDetails details) {
    if (_playerOffset.dx.abs() > 0.5) {
      // 절반 이상 드래그되면 숨김
      setState(() {
        _isPlayerVisible = false;
        _animationController.duration = Duration(milliseconds: 150);
        _slideAnimation = Tween<Offset>(
          begin: _playerOffset,
          end: Offset(_playerOffset.dx > 0 ? _maxHideRatio : -_maxHideRatio, 0),
        ).animate(_animationController);
        _animationController.forward(from: 0);
      });
    } else {
      // 그렇지 않으면 원위치
      setState(() {
        _isPlayerVisible = true;
        _animationController.duration = Duration(milliseconds: 150);
        _slideAnimation = Tween<Offset>(
          begin: _playerOffset,
          end: Offset.zero,
        ).animate(_animationController);
        _animationController.forward(from: 0);
      });
    }
  }
  Widget _buildSection(
    ContentType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...subList.map((item) {
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
        if(subList.length > 30)
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                },
                child: Text('더보기'),
              ),
            ),
          ),
        // SizedBox(height: 32), // 섹션 간 여백
      ],
    );
  }
}
