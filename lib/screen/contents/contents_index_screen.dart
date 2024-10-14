import 'package:flutter/material.dart';
import 'package:webview_ex/screen/contents/contents_screen.dart';
import 'package:webview_ex/screen/contents/search_screen.dart';
import 'package:webview_ex/screen/contents/storage_screen.dart';

import '../../component/contents/player/mini_audio_player.dart';
import '../../const/contents_tabs.dart';
import '../home_screen.dart';

class ContentsIndexScreen extends StatefulWidget {
  const ContentsIndexScreen({super.key});

  @override
  State<ContentsIndexScreen> createState() => _ContentsIndexScreenState();
}

class _ContentsIndexScreenState extends State<ContentsIndexScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  int _currentIndex = 1;
  final List<int> _navigationStack = [1];
  final List<Widget> _pages = [
    HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com')),
    ContentsScreen(),
    StorageScreen(),
    SearchScreen(),
  ];

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isPlayerVisible = true;
  Offset _playerOffset = Offset.zero;
  final double _maxHideRatio = 0.83;

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
  void initState() {
    super.initState();
    tabController = TabController(length: CONTENTSTABS.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
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
          _pages[_currentIndex],
          Positioned(
              bottom: 0,
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ]),
                        child: MiniAudioPlayer(),
                      ),
                    );
                  },
                ),
              )),
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
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xff0baf00),
            unselectedItemColor: Colors.black,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: _onNavTapped,
            items: CONTENTSTABS
                .map(
                  (e) => BottomNavigationBarItem(
                      icon: Icon(e.icon), label: e.label),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void _onBackTapped() {
    if(_currentIndex == 1) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'))));
    } else if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      setState(() {
        _currentIndex = _navigationStack.last;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => _pages[index]));
    }
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _navigationStack.add(index);
      });
    }
  }
}
