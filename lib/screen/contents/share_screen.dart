import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_ex/const/contents/content_type.dart';
import 'package:webview_ex/screen/contents/contents_index_screen.dart';

import '../../component/contents/player/mini_audio_player.dart';
import '../../component/contents/storage/list_item.dart';
import '../../service/api_service.dart';
import '../../service/contents/mapping_service.dart';
import '../../service/dependency_injecter.dart';
import '../../service/player_manager.dart';
import 'audio_screen.dart';

class ShareScreen extends StatefulWidget {
  final String itemId;

  const ShareScreen({super.key, required this.itemId});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen>
    with TickerProviderStateMixin {
  final playerManager = getIt<PlayerManager>();
  final ApiService _apiService = ApiService();
  final MappingService mappingService = MappingService();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isPlayerVisible = true;
  Offset _playerOffset = Offset.zero;
  final double _maxHideRatio = 0.83;
  final double _titleSize = 24.0;
  final double _fontSize = 18.0;
  bool _isLoading = true;
  Map<String, dynamic> item = {};

  Future<void> _loadSharedItem() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data =
          await _apiService.fetchItems(endpoint: 'audios/${widget.itemId}');
      ContentType? type = mappingService.getEnumFromString(
          data[0]['category'], ContentType.values);
      Map<String, dynamic> mappedData = mappingService.mapItems(data, type!)[0];
      setState(() {
        debugPrint('_loadSharedItem:$data');
        item = mappedData;
      });
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: "공유항목 불러오기 중 오류 발생",
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

  void _updatePlayerVisibility(DragUpdateDetails details) {
    setState(() {
      if (_isPlayerVisible) {
        _playerOffset +=
            Offset(details.delta.dx / MediaQuery.of(context).size.width, 0);
        _playerOffset = Offset(
          _playerOffset.dx.clamp(-_maxHideRatio, _maxHideRatio),
          0,
        );
      } else {
        // 이미 숨겨진 상태에서는 반대 방향으로만 드래그 가능
        if ((_playerOffset.dx < 0 && details.delta.dx > 0) ||
            (_playerOffset.dx > 0 && details.delta.dx < 0)) {
          _playerOffset +=
              Offset(details.delta.dx / MediaQuery.of(context).size.width, 0);
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  void didUpdateWidget(ShareScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemId != oldWidget.itemId) {
      // 새로운 itemId로 데이터를 다시 로드하거나 상태를 업데이트
      _loadSharedItem();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSharedItem();
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
          child: Stack(
        children: [
          // TODO change component
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: GestureDetector(
                    onTap: () => handlePlay(context),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 120),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item['imageUrl'] == null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    'asset/images/default_thumbnail.png',
                                    fit: BoxFit.cover,
                                    width: 96.0,
                                  ),
                                )
                              else
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    item['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: 84.0,
                                  ),
                                ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                            fontFamily: 'NotoSans',
                                            fontSize: _titleSize,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(
                                        _getContentTypeLabel(item),
                                        style: TextStyle(
                                          fontFamily: 'NotoSans',
                                          fontSize: _fontSize,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

          // Positioned(
          //     bottom: 0,
          //     left: 0,
          //     right: 0,
          //     child: GestureDetector(
          //       onHorizontalDragUpdate: _updatePlayerVisibility,
          //       onHorizontalDragEnd: _finishDrag,
          //       child: LayoutBuilder(
          //         builder: (context, constraints) {
          //           return AnimatedBuilder(
          //             animation: _slideAnimation,
          //             builder: (context, child) {
          //               return Transform.translate(
          //                 offset: _slideAnimation.value * constraints.maxWidth,
          //                 child: child,
          //               );
          //             },
          //             child: Container(
          //               height: 60,
          //               margin:
          //                   EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //               padding: EdgeInsets.all(8),
          //               decoration: BoxDecoration(
          //                   color: Colors.white,
          //                   borderRadius: BorderRadius.circular(8),
          //                   boxShadow: [
          //                     BoxShadow(
          //                         color: Colors.black.withOpacity(0.1),
          //                         blurRadius: 4,
          //                         offset: Offset(0, 2))
          //                   ]),
          //               child: MiniAudioPlayer(),
          //             ),
          //           );
          //         },
          //       ),
          //     )),
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
        ],
      )),
    );
  }

  void _onBackTapped() {
    context.go('/contents');
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (_) => ContentsIndexScreen()));
  }

  void handlePlay(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try{
      await playerManager.addAndPlayItem(item);
      await navigateToAudioScreen(context);
    }catch(e) {
      Fluttertoast.showToast(
        msg: "공유항목 재생 중 오류 발생",
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
  Future<void> navigateToAudioScreen(BuildContext context) async {
    if (playerManager.currentMediaItemNotifier.value != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => AudioScreen()),
      );
    } else {
      // 미디어 아이템이 없을 때 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('미디어 정보를 불러올 수 업습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getContentTypeLabel(Map<String, dynamic> item) {
    switch (item['type']) {
      case ContentType.video:
        return '비디오';
      case ContentType.podcast:
        return '팟캐스트';
      case ContentType.music:
        return '음악';
      case ContentType.news:
        return '뉴스';
      default:
        return '';
    }
  }
}
