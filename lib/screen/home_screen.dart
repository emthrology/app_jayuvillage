import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_ex/screen/login_screen.dart';
import 'package:webview_ex/screen/contents/audio_screen.dart';
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

import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/scheduler.dart';

import '../service/api_service.dart';
import '../service/dependency_injecter.dart';
import '../store/store_service.dart';

class HomeScreen extends StatefulWidget {
  Uri homeUrl;

  final String pageId;
  final int navIndex;

  HomeScreen({super.key, required this.homeUrl, required this.pageId, this.navIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storeService = getIt<StoreService>();
  final ApiService _apiService = ApiService();
  bool isTarget = false;
  late TabController tabController;
  late final WebViewController _controller;
  late Uri _currentUrl;
  String pushedUrl = '';
  late int _currentIndex;
  bool _showCreatePostNav = false;
  bool _showBottomNav = true;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final UrlLaunchService urlService = UrlLaunchService();
  final secureStorage = getIt<SecureStorage>();
  String storedValue = '';
  bool sessionValid = false;
  final List<String> _tabUrls = [
    // "https://jayuvillage.com",
    "https://jayuvillage.com",
    "https://jayuvillage.com/contents",
    "https://jayuvillage.com/organization",
    "https://jayuvillage.com/posts",
    // "https://jayuvillage.com/chat",\
    // TODO 내 정보 url 웹뷰 사이드메뉴에 만들기 (플러터 로그인했을때만 보이도록)
    "https://jayuvillage.com/mypage",
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
  var logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage rm) async {
    await Firebase.initializeApp();
  }

  Future<void> _firebaseSubscribe() async {
    await FirebaseMessaging.instance.subscribeToTopic("jayuvillage");
    await FirebaseMessaging.instance.subscribeToTopic("notice");
    await FirebaseMessaging.instance.subscribeToTopic("post");
    // await FirebaseMessaging.instance.subscribeToTopic("video"); //TODO check here
    await FirebaseMessaging.instance.subscribeToTopic("webtoon");
  }

  Future<void> setBadgeCount(int count) async {
    final bool isAppBadge = await FlutterAppBadger.isAppBadgeSupported();
    if (isAppBadge == true) {
      await FlutterAppBadger.updateBadgeCount(count);
    }
  }

  // 배지 숫자를 0으로 초기화하는 함수
  Future<void> resetBadgeCount() async {
    final bool isAppBadge = await FlutterAppBadger.isAppBadgeSupported();
    if (isAppBadge == true) {
      await FlutterAppBadger.removeBadge();
    }
  }

  String shareUrlPath = '';

  void _onShareWithResult(uri) async {
    //TODO kakao share
    // final kakaoAvail = await ShareClient.instance.isKakaoTalkSharingAvailable();
    // if(kakaoAvail) {
    //   final FeedTemplate defaultFeed = FeedTemplate(
    //     content: Content(
    //       title:'자유마을',
    //       description: '3506개의 희망',
    //       imageUrl: Uri.parse(''),
    //       link:Link(webUrl: Uri.parse(uri), mobileWebUrl: Uri.parse(uri))
    //     ),
    //     buttonTitle: '열기',
    //   );
    //   Uri kakaoUri = await ShareClient.instance.shareDefault(template: defaultFeed);
    //   await ShareClient.instance.launchKakaoTalk(kakaoUri);
    // }
    final context = _scaffoldKey.currentContext;
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context?.findRenderObject() as RenderBox?;

    final scaffoldMessenger = ScaffoldMessenger.of(context!);
    ShareResult shareResult;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      shareResult = await Share.shareUri(
        Uri.parse(uri),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ).catchError((error) {
        return error;
      });
      bool result = shareResult.status == ShareResultStatus.success;
      if (result) {
        scaffoldMessenger.showSnackBar(getResultSnackBar(shareResult));
      }
    });
    }

  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("공유 성공"),
          // if (result.status == ShareResultStatus.success)
          //   Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    // await getValue('phone');
    // await getValue('password');
    await getValue('session');
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isValidJson(storedValue)) {
        Map<String, dynamic> json = jsonDecode(storedValue);
        _storeService.setPrefs('XSRF_TOKEN', json['success']?['token']);
        setState(() {
          sessionValid = json.containsKey('success') ? true : false;
          isTarget = json['success']?['id'] == 11;
          _setComponents(_currentUrl.toString());
          storedValue = '';
        });
      }
    });
  }

  void _setComponents(String url) {
    url.endsWith("posts/create")
        ? _showBottomNav = false
        : _showBottomNav = true;
    url.endsWith("posts/create")
        ? _showCreatePostNav = true
        : _showCreatePostNav = false;
  }

  Future<void> writeValue(String key, String value) async {
    await secureStorage.writeSecureData(key, value);
  }

  void _getFCMToken(userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    _apiService.storeToken(token, userId);
    // print("FCM Token: $token");
  }
  Future<void> handleKakaoScheme() async {
    String? url = await receiveKakaoScheme();
    if (url != null) {
      // url에 커스텀 URL 스킴이 할당됩니다.
      // 여기서 url을 파싱하고 필요한 작업을 수행합니다.
      print('Received Kakao scheme: $url');
      // 예: 특정 화면으로 이동하거나 데이터를 처리
    }
  }
  void listenToKakaoScheme() {
    print('called kakao');
    kakaoSchemeStream.listen((url) {
      // url에 커스텀 URL 스킴이 할당됩니다.
      print('Received Kakao scheme: $url');
      // 여기서 url을 파싱하고 필요한 작업을 수행합니다.
      Uri uri = Uri.parse(url!);
      // 쿼리 파라미터 추출
      Map<String, String> params = uri.queryParameters;

      // 파라미터 사용
      String? value1 = params['key1'];
      String? value2 = params['key2'];

      print('Received parameters:');
      print('key1: $value1');
      print('key2: $value2');

    }, onError: (error) {
      print('Error receiving Kakao scheme: $error');
    });
  }
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.navIndex;
    // handleKakaoScheme(); // 앱이 시작될 때 한 번 호출
    // listenToKakaoScheme(); // 스트림 리스너 설정
    _loadData();
    _firebaseSubscribe();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          logger.e(message.notification!.title);
          logger.e(message.notification!.body);
          logger.e(message.data["url"]);
          pushedUrl = message.data["url"];
          if (pushedUrl != '') {
            _controller.loadRequest(Uri.parse(pushedUrl));
          }
          resetBadgeCount();
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          logger.e(message.notification!.title);
          logger.e(message.notification!.body);
          logger.e(message.data["url"]);
          pushedUrl = message.data["url"];
          if (pushedUrl != '') {
            _controller.loadRequest(Uri.parse(pushedUrl));
          }
          resetBadgeCount();
        }
      }
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          logger.e(message.notification!.title);
          logger.e(message.notification!.body);
          logger.e(message.data["url"]);
          pushedUrl = message.data["url"];
          if (pushedUrl != '') {
            _controller.loadRequest(Uri.parse(pushedUrl));
          }
          resetBadgeCount();
        }
      }
    });
    if (pushedUrl == '') {
      _currentUrl = widget.homeUrl;
    } else {
      _currentUrl = Uri.parse(pushedUrl);
    }
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
    // TODO 이거 커밋하면 큰일난다
    // if (controller.platform is WebKitWebViewController) {
    //   (controller.platform as WebKitWebViewController).setInspectable(true);
    // }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (externalPages.any((e) => request.url.contains(e))) {
            _launchURL(request.url);
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith('tel:')) {
            debugPrint('TelRequest: ${request.url}');
            if (Platform.isAndroid) {
              _launchURL(request.url);
            } else if (Platform.isIOS) {
              makeSupportCall(request.url);
            }

            return NavigationDecision.prevent;
          }
          if (isAppLink(request.url)) {
            String pUrl = request.url.replaceAll('intent:', '');
            _launchURL(pUrl);
            // handleAppLink(url);
            return NavigationDecision.prevent;
          }
          if (request.url.endsWith('audioplayer')) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => AudioScreen()));
            return NavigationDecision.prevent;
          }
          if (request.url.endsWith('login')) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginScreen(webController: controller)));
            return NavigationDecision.prevent;
          }
          if (request.url.startsWith('https://jayuvillage.com/auth/login')) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginScreen(webController: controller)));
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
        onUrlChange: (UrlChange change) {
          var url = change.url.toString();
          _currentUrl = Uri.parse(url);
          _setComponents(url);
        },
        onPageFinished: (url) {
          if (url.startsWith('https://jayuvillage.com/auth/login')) {
            // 컨트롤러를 초기화
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginScreen(webController: controller)));
          }
        },
      ))
      ..addJavaScriptChannel('loginChannel',
          onMessageReceived: (JavaScriptMessage ms) {
        Map<String, dynamic> session = jsonDecode(ms.message);
        print("session:$session");
        if (session.containsKey('success')) {
          setState(() {
            // writeValue('phone',_phoneController.text);
            // writeValue('password',_passwordController.text);
            writeValue('session', jsonEncode(session));
          });
          //send fcm token to server;
          _getFCMToken(session['success']['id']);

          sessionValid = session.containsKey('success') ? true : false;

        } else if (session.containsKey('error')) {
          Fluttertoast.showToast(
              msg: "오류가 발생하였습니다.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Color(0xff0baf00),
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          print(ms.message);
        }
      })
      ..addJavaScriptChannel('thruFlutter',
          onMessageReceived: (JavaScriptMessage ms) {
        // String value = ms.message;
        // Fluttertoast.showToast(
        //   msg: 'isFlutter:$value',
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.TOP,
        //   timeInSecForIosWeb: 5,
        //   backgroundColor: Color(0xff8bf05d),
        //   textColor: Colors.black,
        //   fontSize: 24.0,
        //
        // );
      })
      ..addJavaScriptChannel('alertChannel',
          onMessageReceived: (JavaScriptMessage ms) {
        Fluttertoast.showToast(
          msg: ms.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Color(0xff8bf05d),
          textColor: Colors.black,
          fontSize: 24.0,
        );
      })
      ..addJavaScriptChannel('logoutChannel',
          onMessageReceived: (JavaScriptMessage ms) {
        print('logout');
        if (ms.message == 'logout') {
          // deleteData('session');
          // deleteData('phone');
          // deleteData('password');
          secureStorage.deleteAllData();
          setState(() {
            storedValue = '';
            sessionValid = false;
          });
        }
      })
      ..addJavaScriptChannel('getImageFromFlutter',
          onMessageReceived: (JavaScriptMessage ms) {
        ms.message.contains('camera') ? _getImage(true) : _getImage(false);
      })
      ..addJavaScriptChannel('launchUrl',
          onMessageReceived: (JavaScriptMessage ms) {
        _launchURL(ms.message);
      })
      ..addJavaScriptChannel('flutterSetComponents',
          onMessageReceived: (JavaScriptMessage ms) {
        _setComponents(ms.message);
      })
      ..addJavaScriptChannel('flutterShareBtn',
          onMessageReceived: (JavaScriptMessage ms) {
        final decodedParams = jsonDecode(ms.message);
        var path = decodedParams['path'];
        var id = decodedParams['id'];
        shareUrlPath = '$path/$id';
      })
      ..addJavaScriptChannel('routeManagerScreenChannel',
          onMessageReceived: (JavaScriptMessage ms) {
        context.go('/organization/manager');
      })
      ..loadRequest(_currentUrl);
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageId != oldWidget.pageId) {
      setState(() {
        _currentUrl = widget.homeUrl;
        _controller.loadRequest(_currentUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(children: [
            WebViewWidget(
              controller: _controller,
            ),
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
                  //         uri: 'https://jayuvillage.com/organization',
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
                    items: POSTTABS
                        .map(
                          (e) => BottomNavigationBarItem(
                              icon: Icon(e.icon), label: e.label),
                        )
                        .toList(),
                  )
                : null,
      ),
    );
  }

  void _onBtnTapped(url) {
    if (url == 'top') {
      scrollToTop();
    } else if (url == 'share') {
      _onShareWithResult('https://jayuvillage.com/$shareUrlPath');
    } else if (url == 'audio_player') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => AudioScreen()));
    } else {
      setState(() {
        _controller.loadRequest(Uri.parse(url));
      });
    }
  }

  void _onNavTapped(index) async {
    String sessionData = await getSessionValue('session');
    if (index == 1) {
      sessionData != 'No such data'
          ? context.go('/contents')
          // ? Navigator.of(context)
          // .push(MaterialPageRoute(builder: (_) => ContentsIndexScreen()))
          : Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LoginScreen(webController: _controller)));
    } else {
      _controller.loadRequest(Uri.parse(_tabUrls[index]));
      setState(() {
        _currentUrl = Uri.parse(_tabUrls[index]);
        _currentIndex = index;
      });
    }
  }

  void _onPostNavTapped(index) {
    if (index == 0) {
      _getImage(true);
    }
    if (index == 1) {
      _controller.runJavaScript('openLinkModal()');
    }
    if (index == 2) {
      _getImage(false);
    }
  }

  void scrollToTop() {
    _controller.scrollTo(0, 0);
  }

  bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isAppLink(String url) {
    final appScheme = Uri.parse(url).scheme;
    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data';
  }

  Future<void> getValue(key) async {
    String value = await secureStorage.readSecureData(key);
    setState(() {
      storedValue = value;
    });
  }
  Future<dynamic> getSessionValue(key) async {
    String value = await secureStorage.readSecureData(key);
    return value;
  }

  Future<void> deleteData(String key) async {
    await secureStorage.deleteSecureData(key);
    if (key == 'session') {
      sessionValid = false;
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('cannot launch url');
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
          'imageFromFlutter("data:image/png;base64,$base64Image")');
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
