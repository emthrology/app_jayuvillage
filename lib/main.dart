import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_ex/screen/home_screen.dart';
import 'firebase_options.dart';

import 'package:go_router/go_router.dart';

var logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
);

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // KakaoSdk.init(nativeAppKey: 'f768fc3addb5a2941abe952ea7ba8ca7');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  // if(Platform.isIOS) {
  if(true) {
    permission();
  }
  final goRouter = GoRouter(
    routes: [
      GoRoute(
        path:'/',

        builder: (context, state){
          print('routed here');
          return HomeScreen(homeUrl: Uri.parse('https://jayuvillage.com'));
        }
      ),
      GoRoute(
        path:'/posts/:id',
        builder: (context, state) {
          print('$state.');
          final id = state.uri.queryParameters['id'];
          print('id:$id');
          return HomeScreen(homeUrl: state.uri);
        }
      ),
      GoRoute(
        path:'/notices/:id',
        builder:(context, state) {
          final id = state.uri.queryParameters['id'];
          print(id);
          return HomeScreen(homeUrl: state.uri);
        }
      )
    ]
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
