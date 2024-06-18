import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/component/quick_btns.dart';
import 'package:webview_ex/const/quick_btns_data.dart';
import 'package:webview_ex/screen/login_screen.dart';
import 'package:webview_ex/service/image_picker_service.dart';
import 'package:webview_ex/service/url_launch_service.dart';
import 'package:webview_ex/store/secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../const/tabs.dart';
import '../const/create_post_tabs.dart';

class HomeScreen extends StatefulWidget {
  Uri homeUrl;

  HomeScreen({super.key, required this.homeUrl});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  late final WebViewController _controller;
  late Uri _currentUrl;
  int _currentIndex = 0;
  bool _showCreatePostNav = false;
  bool _showBottomNav = true;
  bool _showQuickBtns = false;
  bool _hideBtnsFromWeb = false;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final UrlLaunchService urlService = UrlLaunchService();
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
    "ihappynanum",
  ];
  List<Map<String, dynamic>> btnData = BTNDATA['BEFORELOGIN']!;

  @override
  void initState() {
    super.initState();
    _loadData();
    setInitialBtnState();
    _currentUrl = widget.homeUrl;
    tabController = TabController(length: TABS.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);


    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (externalPages.any((e) => request.url.contains(e))) {
            _launchURL(request.url);
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith('tel:')) {
            if (Platform.isAndroid) {
              _launchURL(request.url);
            } else if (Platform.isIOS) {
              makeSupportCall(request.url);
            }

            return NavigationDecision.prevent;
          }
          if (request.url.endsWith('login')) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginScreen(webController: controller)));
            return NavigationDecision.prevent;
          }
          if (request.url
              .startsWith('https://app.jayuvillage.com/auth/login')) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginScreen(webController: controller)));
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
          if (session) {
            setQuickBtns('AFTERLOGIN');
          } else {
            setQuickBtns('BEFORELOGIN');
          }
          if (_quickBtnPages.any((e) => url.contains(e))) {
            url.endsWith('create')
                ? _showQuickBtns = false
                : _showQuickBtns = true;
            if (url.endsWith('mypage')) {
              setQuickBtns('MYPAGE');
            }
          } else {
            _showQuickBtns = false;
          }
          url.endsWith("posts/create")
              ? _showBottomNav = false
              : _showBottomNav = true;
          url.endsWith("posts/create")
              ? _showCreatePostNav = true
              : _showCreatePostNav = false;
          if (url.endsWith("posts/create")) {
            setState(() {
              _showQuickBtns = false;
            });
          }

          if (url.startsWith('https://app.jayuvillage.com/auth/login')) {
            // 컨트롤러를 초기화
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginScreen(webController: controller)));
          }
        },
      ))
      ..addJavaScriptChannel('logoutChannel',
          onMessageReceived: (JavaScriptMessage ms) {
            if (ms.message == 'logout') {
              deleteData('session');
              deleteData('phone');
              deleteData('password');
              setState(() {
                storedValue = '';
                session = false;
              });
              setQuickBtns('BEFORELOGIN');
            }
          })
      ..addJavaScriptChannel('hideBtn',
          onMessageReceived: (JavaScriptMessage ms) {
            setState(() {
              ms.message.contains('hide')
                  ? _hideBtnsFromWeb = true
                  : _hideBtnsFromWeb = false;
            });
            print('_hideBtnsFromWeb:$_hideBtnsFromWeb');
          })
      ..addJavaScriptChannel('getImageFromFlutter',
          onMessageReceived: (JavaScriptMessage ms) {
            print(ms.message);
            ms.message.contains('camera') ? _getImage(true) : _getImage(false);
          })
      ..addJavaScriptChannel('launchUrl', onMessageReceived: (JavaScriptMessage ms){
        _launchURL(ms.message);
      })
      ..loadRequest(_currentUrl);
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
      _controller = controller;
  }

  // @override
  // void didUpdateWidget(covariant HomeScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.homeUrl != oldWidget.homeUrl) {
  //     setState(() {
  //       _currentUrl = widget.homeUrl;
  //     });
  //   }
  //   if (_quickBtnPages.any((e) => _currentUrl.toString().contains(e))) {
  //     _showQuickBtns = true;
  //   } else {
  //     _showQuickBtns = false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(children: [
            WebViewWidget(
              controller: _controller,
            ),
            _showQuickBtns && !_hideBtnsFromWeb
                ? Positioned(
                bottom: 20,
                right: 20,
                child: QuickBtns(
                  onTap: _onBtnTapped,
                  btnData: btnData,
                ))
                : _currentUrl.toString() == 'https://app.jayuvillage.com' &&
                !_hideBtnsFromWeb
                ? Positioned(
                bottom: 20,
                right: 20,
                child: QuickBtns(
                  onTap: _onBtnTapped,
                  btnData: btnData,
                ))
                : Container()
          ]),
        ),
        bottomNavigationBar: _showBottomNav
            ? Stack(
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
              items: TABS
                  .map(
                    (e) =>
                    BottomNavigationBarItem(
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
            : _showCreatePostNav
            ? BottomNavigationBar(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xff0baf00),
                unselectedItemColor: Colors.black,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                currentIndex: 1,
                type: BottomNavigationBarType.fixed,
                onTap: _onPostNavTapped,
                items: POSTTABS.map(
                  (e) =>
                  BottomNavigationBarItem(
                    icon: Icon(e.icon), label: e.label),
                  ).toList(),
              )
            : null,
      ),
    );
  }

  void _onBtnTapped(url) {
    if (url == 'top') {
      scrollToTop();
    } else {
      setState(() {
        _controller.loadRequest(Uri.parse(url));
      });
    }
  }

  void _onNavTapped(index) {
    setState(() {
      _currentIndex = index;
      _currentUrl = Uri.parse(_tabUrls[index]);
      _controller.loadRequest(Uri.parse(_tabUrls[index]));
    });
  }
  void _onPostNavTapped(index) {
    if(index == 0) {
      _getImage(true);
    }
    if(index == 1) {
      _controller.runJavaScript('openLinkModal()');
    }
    if(index == 2) {
      _getImage(false);
    }
  }

  void scrollToTop() {
    _controller.scrollTo(0, 0);
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


  Future<void> getValue(key) async {
    String value = await secureStorage.readSecureData(key);
    setState(() {
      storedValue = value;
    });
  }

  Future<void> deleteData(String key) async {
    await secureStorage.deleteSecureData(key);
    if (key == 'session') {
      session = false;
    }
  }

  Future<void> _loadData() async {
    await getValue('phone');
    await getValue('password');
    await getValue('session');
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isValidJson(storedValue)) {
        Map<String, dynamic> json = jsonDecode(storedValue);
        setState(() {
          session = json.containsKey('success') ? true : false;
          storedValue = '';
        });
      }
    });
  }

  Future<void> _launchURL(String url) async {
    print(url);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> makeSupportCall(String url) async {
    final regex = RegExp(r'^tel:(\d{3})(\d{4})(\d{4})$');
    if (regex.hasMatch(url)) {
      final match = regex.firstMatch(url);
      if (match != null) {
        url = '${match.group(1)}${match.group(2)}${match.group(3)}';
      }
    }
    try {
      await FlutterPhoneDirectCaller.callNumber(url);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _getImage(bool fromCamera) async {
    File? imageFile;
    if (fromCamera) {
      imageFile = await _imagePickerService.pickImageFromCamera();
    } else {
      imageFile = await _imagePickerService.pickImageFromGallery();
    }

    if (imageFile != null) {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      //
      _controller.runJavaScript(
          'imageFromFlutter("data:image/png;base64,$base64Image")'
      );
    } else {
      Fluttertoast.showToast(
        msg: "이미지 등록 실패",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 4,
        backgroundColor: Color(0xff0baf00),
        textColor: Colors.white,
        fontSize: 20.0,
      );
    }
  }
}
