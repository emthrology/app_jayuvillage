import 'package:flutter/material.dart';
import 'package:webview_ex/component/contents/contents_component.dart';
import 'package:webview_ex/component/contents/search_component.dart';
import 'package:webview_ex/component/contents/storage_component.dart';

import '../../const/contents_tabs.dart';
import '../home_screen.dart';

class ContentsIndexScreen extends StatefulWidget {
  const ContentsIndexScreen({super.key});

  @override
  State<ContentsIndexScreen> createState() => _ContentsIndexScreenState();
}

class _ContentsIndexScreenState extends State<ContentsIndexScreen> with TickerProviderStateMixin {
  late TabController tabController;
  int _currentIndex = 1;
  final List<int> _navigationStack = [1];
  final List<Widget> _pages = [
    HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com')),
    ContentsComponent(),
    StorageComponent(),
    SearchComponent(),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: CONTENTSTABS.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Stack(
            children: [
              _pages[_currentIndex],
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
                        child: Row(
                            children:[
                              Icon(
                                Icons.arrow_back_ios_new,
                                size: 32.0,
                              ),
                            ]),),)],),
              ),
            ],
          )
      ),
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
                  (e) =>
                  BottomNavigationBarItem(
                      icon: Icon(e.icon), label: e.label),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
  void _onBackTapped() {
    if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      setState(() {
        _currentIndex = _navigationStack.last;
      });
    } else {
      Navigator.of(context).pop();
    }
  }
  void _onNavTapped(int index) {
    if(index == 0) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _pages[index]));
    }
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _navigationStack.add(index);
      });
    }
  }
}
