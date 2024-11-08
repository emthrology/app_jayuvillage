import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_ex/const/organization_manage_tabs.dart';
import 'package:webview_ex/screen/organization_manage/calendar_screen.dart';
import 'package:webview_ex/screen/organization_manage/manage_home_screen.dart';
import 'package:webview_ex/screen/organization_manage/name_list_screen.dart';
import 'package:webview_ex/screen/organization_manage/statistics_screen.dart';

import '../../service/app_router.dart';
import '../../service/dependency_injecter.dart';
import '../../store/secure_storage.dart';
import 'event_list_screen.dart';

class OrganizationManageIndexScreen extends StatefulWidget {
  final int pageIndex;

  const OrganizationManageIndexScreen({super.key, required this.pageIndex});

  @override
  State<OrganizationManageIndexScreen> createState() =>
      _OrganizationManageIndexScreenState();
}

class _OrganizationManageIndexScreenState
    extends State<OrganizationManageIndexScreen> {
  final secureStorage = getIt<SecureStorage>();
  late Map<String, dynamic> sessionData;
  int _currentPageIndex = 0;
  int _navIndex = 0;
  final List<int> _navigationStack = [0];
  late List<Widget> _pages;

  void getSession() async {
    String jsonString = await getSessionValue('session');
    // JSON 문자열을 Map으로 디코딩
    Map<String, dynamic> decodedJson = jsonDecode(jsonString);

    // 'success' 키의 값을 가져오기
    Map<String, dynamic> successData = decodedJson['success'];
    sessionData = successData;
    setState(() {
      _pages = [
        ManageHomeScreen(
            sessionData: sessionData, onEventScreenTap: () => _onNavTapped(1)),
        EventListScreen(
            title: '집회 및 모임 참석률',
            type: 'eventList',
            onCalendarCalled: () => _onNavTapped(3)),
        StatisticsScreen(title: '분석 화면'),
        CalendarScreen(title: '달력 화면'),
        EventListScreen(
            title: '설문조사 및 공지사항 확인',
            type: 'checkList',
            onCalendarCalled: () => _onNavTapped(3)),
        NameListScreen(type: 'eventList', title: '접속·미접속자 상세 명단'),
        NameListScreen(type: 'checkList', title: '상세 명단')
      ];
    });
  }

  Future<dynamic> getSessionValue(key) async {
    String value = await secureStorage.readSecureData(key);
    return value;
  }

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.pageIndex;
    _navIndex = widget.pageIndex;
    getSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Stack(
        children: [
          _pages[_currentPageIndex],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xff0baf00),
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTapped,
        items: MANAGETABS
            .map(
              (e) => BottomNavigationBarItem(icon: e.icon, label: e.label),
            )
            .toList(),
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index != _currentPageIndex) {
      setState(() {
        if (index >= 0 && index <= 2) {
          _currentPageIndex = index;
          _navIndex = index;
        }else if(index > 2) {
          _currentPageIndex = index;
        }
        _navigationStack.add(index);
      });
    }
  }

  void _onBackTapped() {
    if (_currentPageIndex == 0) {
      goRouter.go('/organization');
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (_) => HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'), pageId: '0',)));
    } else if (_navigationStack.length > 1) {
      _navigationStack.removeLast();
      setState(() {
        if (_navigationStack.last >= 0 || _navigationStack.last <= 2) {
          _currentPageIndex = _navigationStack.last;
        }
      });
    } else {
      goRouter.pop();
    }
  }
}
