import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:webview_ex/screen/contents/audio_screen.dart';
import 'package:webview_ex/screen/contents/contents_index_screen.dart';
import 'package:webview_ex/screen/contents/share_screen.dart';
import 'package:webview_ex/screen/error_screen.dart';

import 'service/dependency_injecter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_ex/screen/home_screen.dart';
import 'firebase_options.dart';

import 'package:go_router/go_router.dart';

import 'service/player_manager.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage rm) async {
  await Firebase.initializeApp();
}
void permission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // headsup notification in IOS
      badge: false,
      sound: true,
    );
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // headsup notification in IOS
      badge: false,
      sound: true,
    );
  } else {
    print('User declined or has not accepted permission');
  }
}

void handleDeepLink(Uri uri) {
  final context = _navigatorKey.currentContext;
  if (context != null) {
    try {
      final String path = uri.path;
      if (path.startsWith('/posts/') || path.startsWith('/notices/') || path.startsWith('/audio/')) {
        // GoRouter.of(context).push(path, extra: queryParams);
        context.go(path);
      } else {
        // 알 수 없는 경로의 경우 홈 화면으로 이동
        GoRouter.of(context).go('/');
      }
    } catch (e) {
      print('Deep link handling error: $e');
      // 오류 발생 시 홈 화면으로 이동
      GoRouter.of(context).go('/');
    }
  }
}
Future<void> initDeepLinks() async {
  _appLinks = AppLinks();

  // Handle links
  _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
    debugPrint('onAppLink: $uri');
    handleDeepLink(uri);
  });
}

late PlayerManager pageManager;
final _navigatorKey = GlobalKey<NavigatorState>();
late AppLinks _appLinks;
StreamSubscription<Uri>? _linkSubscription;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  getIt<PlayerManager>().init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  // if(Platform.isIOS) {
  if(true) {
    permission();
  }
  final goRouter = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path:'/',
        builder: (context, state){
          debugPrint('routed here');
          return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'), pageId:'0');
        }
      ),
      GoRoute(
        path:'/chat/:id',
        builder: (context,state) {
          debugPrint(state.uri.toString());
          return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com/chat/live?groupId=${state.pathParameters['id']!}'), pageId: '0');
        }
      ),
      GoRoute(
        path:'/contents',
        builder:(context, state) {
          return ContentsIndexScreen(pageIndex:'1');
        }
      ),
      GoRoute(
        path:'/contents/:index',
        builder:(context,state) {
          return ContentsIndexScreen(pageIndex:state.pathParameters['index']!);
        }
      ),
      GoRoute(
        path:'/posts/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return HomeScreen(homeUrl: state.uri, pageId:'$id');
        },
      ),
      GoRoute(
        path:'/notices/:id',
        builder:(context, state) {
          final id = state.pathParameters['id'];
          return HomeScreen(homeUrl: state.uri, pageId:'$id');
        }
      ),
      GoRoute(
        path:'/audio/player',
        builder:(context,state) {
          return AudioScreen();
        }
      ),
      GoRoute(
        path:'/audio/:id',
        builder:(context, state) {
          return ShareScreen(itemId:state.pathParameters['id']!);
        }
      )
    ],
    errorBuilder: (context, state) {
      return ErrorScreen(error: state.error.toString());
    },
    redirect: (BuildContext context, GoRouterState state) {
      // 딥링크 처리 로직
      debugPrint('redirect-state:$state');
      final deepLink = state.uri.toString();
      debugPrint('deepLink:$deepLink');
      if (deepLink.isNotEmpty) {
        // 딥링크에 따른 리다이렉션 로직
        return deepLink;
      }
      return null; // 리다이렉션이 필요 없는 경우
    },
    debugLogDiagnostics: true,
  );
  // 앱이 실행 중일 때 들어오는 링크 처리
  initDeepLinks();
  KakaoSdk.init(
    nativeAppKey: 'f768fc3addb5a2941abe952ea7ba8ca7',
    javaScriptAppKey: '0b676e15765c46418fa53c1333910c0a',
  );
  runApp(
    // MaterialApp(
    //     debugShowCheckedModeBanner: false, // 디버깅 모드 배너 끄기
    //     home: HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'))
    // ),
    MaterialApp.router(
      routerConfig: goRouter,
    )
  );
}
