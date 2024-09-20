
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class FirebaseService {
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage rm) async {
    await Firebase.initializeApp();
  }
  Future<void> firebaseSubscribe() async {
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
}