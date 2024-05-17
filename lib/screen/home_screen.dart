import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:webview_ex/component/quick_btns.dart';
import 'package:webview_ex/component/round_btn.dart';
import 'package:webview_ex/const/quick_btns_data.dart';
import 'package:webview_ex/screen/login_iscreen_inapp.dart';
import 'package:webview_ex/screen/sample_screen.dart';
import 'package:webview_ex/screen/login_screen.dart';
import 'package:webview_ex/store/login_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../const/tabs.dart';

// final homeUrl = Uri.parse('https://app.jayuvillage.com');

class HomeScreen extends StatefulWidget {
  Uri homeUrl;

  HomeScreen({super.key, required this.homeUrl});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  late WebViewController controller;

  late Uri _currentUrl;
  int _currentIndex = 0;
  int loadingPercentage = 0;
  bool _showBottomNav = true;
  bool _showQuickBtns = false;

  final FormController _formController = Get.put(FormController());
  // final FormController loginController = Get.find<FormController>();
  final List<String> _tabUrls = [
    "https://app.jayuvillage.com",
    "https://app.jayuvillage.com/posts",
    "https://app.jayuvillage.com/organization",
    "https://app.jayuvillage.com/chat",
    "https://app.jayuvillage.com/mypage",
  ];
  final List<String> _quickBtnPages = [
    "/contents",
    "/fav",
    "/infos",
    "/mypage",
    "/posts",
    "/rank",
    "/somoim",
    "/staffs"
  ];
  List<Map<String, dynamic>> btnData = BTNDATA['BEFORELOGIN']!;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.homeUrl;
    tabController = TabController(length: TABS.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url
              .startsWith('https://app.jayuvillage.com/auth/login')) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LoginScreen(webController : controller)));
                // .push(MaterialPageRoute(builder: (_) => LoginScreenInapp()));
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
        onPageStarted: (url) {
          // print('finished uri is: ${url}');
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          // print('finished uri is: ${url}');
          // print('_currentUri.toString(): ${_currentUrl.toString()}');
          if(_formController.phone != null && _formController.password != null) {
            setQuickBtns('AFTERLOGIN');
          }else {
            setQuickBtns('BEFORELOGIN');
          }
          if (_quickBtnPages.any((e) => url.contains(e))) {
            url.endsWith('create') ? _showQuickBtns = false : _showQuickBtns = true;
            if(url.endsWith('mypage')) {
              setQuickBtns('MYPAGE');
            }
          } else {
            _showQuickBtns = false;
          }

          url.endsWith("posts/create") ?  _showBottomNav = false : _showBottomNav = true;

          if (url.startsWith('https://app.jayuvillage.com/auth/login')) {

            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LoginScreen(webController: controller)));
                // .push(MaterialPageRoute(builder: (_) => LoginScreenInapp()));
          }
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      ..loadRequest(_currentUrl);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.homeUrl != oldWidget.homeUrl) {
      setState(() {
        _currentUrl = widget.homeUrl;
      });
    }
    if (_quickBtnPages.any((e) => _currentUrl.toString().contains(e))) {
      _showQuickBtns = true;
    } else {
      _showQuickBtns = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     // title: Text('login_screen'),
      //     bottom: PreferredSize(
      //         preferredSize: Size.fromHeight(20),
      //         child: Row(
      //           mainAxisSize: MainAxisSize.min,
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Expanded(
      //               child: TabBar(
      //                 controller: tabController,
      //                 indicatorColor: Color(0xff0baf00),
      //                 indicatorWeight: 4.0,
      //                 indicatorSize: TabBarIndicatorSize.tab,
      //                 labelColor: Color(0xff0baf00),
      //                 labelStyle: TextStyle(
      //                   fontWeight: FontWeight.w700,
      //                 ),
      //                 unselectedLabelStyle:
      //                     TextStyle(fontWeight: FontWeight.w500),
      //                 // unselectedLabelColor: Colors.grey,
      //                 tabs: TABS
      //                     .map((e) => Tab(
      //                           icon: Icon(e.icon),
      //                           child: Text(e.label),
      //                         ))
      //                     .toList(),
      //               ),
      //             ),
      //           ],
      //         ))),
      body: SafeArea(
        child: Stack(children: [
          WebViewWidget(
            controller: controller,
          ),
          loadingPercentage < 100
              ? LinearProgressIndicator(
                  color: Colors.black, value: loadingPercentage / 100.0)
              : Container(),
          _showQuickBtns
              ? Positioned(
                  bottom: 20, right: 20, child: QuickBtns(onTap: _onBtnTapped, btnData: btnData,))
              : _currentUrl.toString() == 'https://app.jayuvillage.com'
                  ? Positioned(
                      bottom: 20,
                      right: 20,
                      child: QuickBtns(onTap: _onBtnTapped, btnData: btnData,))
                  : Container()
        ]),
      ),
      bottomNavigationBar: _showBottomNav
          ? Stack(
              children: [
                BottomNavigationBar(
                  selectedItemColor: Color(0xff0baf00),
                  unselectedItemColor: Colors.black,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  currentIndex: _currentIndex,
                  type: BottomNavigationBarType.fixed,
                  onTap: _onItemTapped,
                  items: TABS
                      .map(
                        (e) => BottomNavigationBarItem(
                            icon: Icon(e.icon), label: e.label),
                      )
                      .toList(),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     RoundBtn(
                //         color: Color(0xff0baf00),
                //         borderColor: Color(0xff0baf00),
                //         text: '조직활동',
                //         uri: 'https://app.jayuvillage.com/organization',
                //         onTap: _onBtnTapped),
                //   ],
                // )
              ],
            )
          : null,
    );
  }

  void _onBtnTapped(url) {
    if(url == 'top') {
      scrollToTop();
    }else {
      setState(() {
        controller.loadRequest(Uri.parse(url));
      });
    }

  }

  void _onItemTapped(index) {
    setState(() {
      _currentIndex = index;
      _currentUrl = Uri.parse(_tabUrls[index]);
      controller.loadRequest(Uri.parse(_tabUrls[index]));
    });
  }

  void scrollToTop() {
    controller.scrollTo(0, 0);
  }
  void setQuickBtns(type) {
    btnData = BTNDATA[type]!;
  }
}
