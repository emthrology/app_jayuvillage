import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/component/quick_btns.dart';
import 'package:webview_ex/const/quick_btns_data.dart';
import 'package:webview_ex/screen/login_screen.dart';
import 'package:webview_ex/store/secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../const/tabs.dart';

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
  bool _showBottomNav = true;
  bool _showQuickBtns = false;
  bool _hideBtnsFromWeb = false;
  final SecureStorage secureStorage = SecureStorage();
  String storedValue = '';
  bool session = false;
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
  final List<String> externalPages = [
    "jayupress",
    "junacademy",
    "khmon",
    "wkoreaf",
    "ghmons",
    "firstmobile",
    "jayuwatch",
  ];
  List<Map<String, dynamic>> btnData = BTNDATA['BEFORELOGIN']!;

  Future<void> getValue(key) async {
    String value = await secureStorage.readSecureData(key);
    setState(() {
      storedValue = value;
    });
  }

  // Future<void> writeValue(String key,String value) async {
  //   await secureStorage.writeSecureData(key, value);
  // }

  Future<void> deleteData(String key) async {
    await secureStorage.deleteSecureData(key);
  }
  Future<void> _loadData() async {
    await getValue('session');
    print('storedValue:$storedValue');
    if(isValidJson(storedValue)) {
      Map<String,dynamic> json = jsonDecode(storedValue);
      setState(() {

        session = json.containsKey('success') ? true : false;
        storedValue = '';
      });
    }
  }
  Future<void> _launchURL(String url) async {
    // print('url:$url');
    // print('uri:${Uri.parse(url)}');
    // bool result = await canLaunchUrl(Uri.parse(url));
    // print('result:$result');
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
  Future<void> makeSupportCall(String url) async {
    final regex = RegExp(r'^tel:(\d{3})(\d{4})(\d{4})$');
    if(regex.hasMatch(url)) {
      final match = regex.firstMatch(url);
      if(match != null) {
        url = '${match.group(1)}${match.group(2)}${match.group(3)}';
      }
      // print('makeSptCall:$url');
    }
    try {
      await FlutterPhoneDirectCaller.callNumber(url);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    // _formController.session['session'] == false ? setQuickBtns('AFTERLOGIN') : setQuickBtns('BEFORELOGIN');

    setInitialBtnState();
    _currentUrl = widget.homeUrl;
    tabController = TabController(length: TABS.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          // print(request.url);
          if(externalPages.any((e) => request.url.contains(e))) {
            _launchURL(request.url);
            return NavigationDecision.prevent;
          }
          if(request.url.startsWith('tel:')) {
            if(Platform.isAndroid) {
              _launchURL(request.url);
            }else if(Platform.isIOS) {
              makeSupportCall(request.url);
            }

            return NavigationDecision.prevent;
          }
          if(request.url.endsWith('login')) {
            print('url caught:$request.url');
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LoginScreen(webController : controller)));
            return NavigationDecision.prevent;
          }
          if (request.url
              .startsWith('https://app.jayuvillage.com/auth/login')) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LoginScreen(webController : controller)));
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }

        },
        onPageStarted: (url) {
          setState(() {
            _hideBtnsFromWeb = false;
          });
        },
        onPageFinished: (url) {
          // print(url);
          if (session) {
            setQuickBtns('AFTERLOGIN');
          } else {
            setQuickBtns('BEFORELOGIN');
          }
          if (_quickBtnPages.any((e) => url.contains(e)) ) {
            url.endsWith('create') ? _showQuickBtns = false : _showQuickBtns = true;
            if(url.endsWith('mypage')) {
              setQuickBtns('MYPAGE');
            }
          } else {
            _showQuickBtns = false;
          }

          url.endsWith("posts/create") ?  _showBottomNav = false : _showBottomNav = true;

          if (url.startsWith('https://app.jayuvillage.com/auth/login')) {
            // 컨트롤러를 초기화
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LoginScreen(webController: controller)));
          }
        },
      ))
      ..addJavaScriptChannel('logoutChannel', onMessageReceived: (JavaScriptMessage ms) {
        if(ms.message == 'logout') {
          deleteData('session');
          deleteData('phone');
          deleteData('password');
          setQuickBtns('BEFORELOGIN');
        }
      })
      ..addJavaScriptChannel('hideBtn', onMessageReceived: (JavaScriptMessage ms) {
        setState(() {
          ms.message.contains('hide') ? _hideBtnsFromWeb = true : _hideBtnsFromWeb = false;
        });
        // print('_hideBtnsFromWeb:$_hideBtnsFromWeb');
      })
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
    return PopScope(
      canPop: false,
      child: Scaffold(
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
            // loadingPercentage < 100
            //     ? LinearProgressIndicator(
            //     color: Colors.black, value: loadingPercentage / 100.0)
            //     : Container(),
            _showQuickBtns && !_hideBtnsFromWeb
                ? Positioned(
                bottom: 20, right: 20, child: QuickBtns(onTap: _onBtnTapped, btnData: btnData,))
                : _currentUrl.toString() == 'https://app.jayuvillage.com' && !_hideBtnsFromWeb
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
      ),
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
    setState(() {
      btnData = BTNDATA[type]!;

    });
  }
  void setInitialBtnState() {
    session ? setQuickBtns('AFTERLOGIN') : setQuickBtns('BEFORELOGIN');

  }
  bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
