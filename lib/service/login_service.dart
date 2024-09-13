import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_ex/service/api_service.dart';

import '../store/secure_storage.dart';

class LoginService {
  final ApiService _apiService = ApiService();
  final SecureStorage secureStorage = SecureStorage();

  Future<void> writeValue(String key,String value) async {
    await secureStorage.writeSecureData(key, value);
  }
  void getFCMToken(userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    await _apiService.storeToken(token,userId);
    // print("FCM Token: $token");
  }
}