import UIKit
import Flutter
import KakaoSDKCommon // 추가
import KakaoSDKAuth

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // 카카오 SDK 초기화 추가
    KakaoSDK.initSDK(appKey: "f768fc3addb5a2941abe952ea7ba8ca7")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if let url = userInfo["url"] as? String {
      NotificationCenter.default.post(name: Notification.Name("openURL"), object: nil, userInfo: ["url": url])
    }
    completionHandler(.newData)
  }

//   // 카카오톡 URL 처리를 위한 메서드 추가
//   override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//     if (AuthApi.isKakaoTalkLoginUrl(url)) {
//       return AuthController.handleOpenUrl(url: url)
//     }
//     return false
//   }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      return handleDeepLink(url: url)
  }

  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      if let incomingURL = userActivity.webpageURL {
          return handleDeepLink(url: incomingURL)
      }
      return false
  }

  private func handleDeepLink(url: URL) -> Bool {
      print("Received deep link: \(url.absoluteString)")

      // 여기서 Flutter 엔진에 딥링크 정보를 전달합니다
      let flutterViewController = window?.rootViewController as? FlutterViewController
      let channel = FlutterMethodChannel(name: "com.puritech.jayuvillage/deeplink", binaryMessenger: flutterViewController!.binaryMessenger)

      channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)

      return true
  }
}