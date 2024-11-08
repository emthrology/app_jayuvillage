import 'package:flutter/services.dart';
import 'package:webview_ex/service/app_router.dart';

class IosDeeplinkService {
  static const platform = MethodChannel('com.puritech.jayuvillage/deeplink');

  static void initialize() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'handleDeepLink') {
        final String deepLink = call.arguments;
        // print('Received deep link in Flutter: $deepLink');
        handleDeepLink(deepLink);
      }
    });
  }
  static void handleDeepLink(String deepLink) {
    String url = deepLink.split('://').last;
    goRouter.go('/$url');

  }
}