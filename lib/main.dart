import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_ex/screen/home_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false, // 디버깅 모드 배너 끄기
        home: HomeScreen(homeUrl: Uri.parse('https://app.jayuvillage.com'))
        // home: FutureBuilder(
        //   future: Future.delayed(const Duration(seconds: 1), () => "Intro Completed."),
        //   builder: (context, snapshot) {
        //     return AnimatedSwitcher(
        //         duration: const Duration(milliseconds: 1000),
        //         child: _splashLoadingWidget(snapshot)
        //     );
        //   },
        // )
    ),
  );
}
// Widget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
//   if(snapshot.hasError) {
//     return const Text("Error!!");
//   } else if(snapshot.hasData) {
//     return HomeScreen(homeUrl: Uri.parse('https://app.jayuvillage.com'));
//   } else {
//     return const IntroScreen();
//   }
// }
