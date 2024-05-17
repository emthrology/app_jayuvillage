import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'home_screen.dart';

class LoginScreenInapp extends StatefulWidget {
  const LoginScreenInapp({super.key});

  @override
  State<LoginScreenInapp> createState() => _LoginScreenInappState();
}

class _LoginScreenInappState extends State<LoginScreenInapp> {
  final GlobalKey webViewKey = GlobalKey();
  final String _logoDir = 'asset/images/logo_big.png';
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool autoLoginEnabled = false;

  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
    isInspectable: kDebugMode,
    // useShouldOverrideUrlLoading: true, // URL 로딩 제어
    mediaPlaybackRequiresUserGesture: false, // 미디어 자동 재생
    javaScriptEnabled: true, // 자바스크립트 실행 여부
    javaScriptCanOpenWindowsAutomatically: true, // 팝업 여부
    useHybridComposition: true, // 하이브리드 사용을 위한 안드로이드 웹뷰 최적화
    supportMultipleWindows: true, // 멀티 윈도우 허용
    allowsInlineMediaPlayback: true, // 웹뷰 내 미디어 재생 허용
  );

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Opacity(opacity: 1.0,
                child: InAppWebView(
                  key: webViewKey,
                  initialSettings: options,
                  initialUrlRequest: URLRequest(url:WebUri('https://app.jayuvillage.com/auth/login')),
                  onWebViewCreated: (controller){
                    // controller.addJavaScriptHandler(handlerName: 'test', callback: (args) {
                    //   print(args);
                    // });
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      print("started $url");
                    });
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      print("stopped $url");
                    });
                    await controller.evaluateJavascript(source: """
                      if (window.MyApp) {
                        window.MyApp.receiveMessage('Initial message from Flutter');
                      }
                    """);
                  },

                ),
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Container(
              //       alignment: Alignment.center,
              //       child: Image.asset(
              //         _logoDir,
              //         width: _deviceWidth / 2.0,
              //       ),
              //     ),
              //     Container(
              //       padding: EdgeInsets.only(top: 32.0),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             '환영합니다',
              //             style: TextStyle(
              //               fontSize: 24.0,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.black,
              //             ),
              //           ),
              //           Text(
              //             '휴대폰 번호로 로그인 해주세요.',
              //             style: TextStyle(
              //               fontSize: 24.0,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     Padding(padding: EdgeInsets.all(16.0),
              //       child: Column(
              //         children: [
              //           Padding(padding: EdgeInsets.all(4.0),
              //             child: TextField(
              //               controller: _phoneController,
              //               decoration: InputDecoration(
              //                 enabledBorder: OutlineInputBorder(
              //                     borderSide: BorderSide(
              //                       color: Color(0xff0baf00),
              //                       width: 1.0,
              //                     )),
              //                 focusedBorder: OutlineInputBorder(
              //                     borderSide: BorderSide(
              //                       color: Color(0xff0baf00),
              //                       width: 1.0,
              //                     )),
              //                 labelText: '연락처 11자리(-없이 숫자만 입력)',
              //               ),
              //             ),
              //           ),
              //           Padding(padding: EdgeInsets.all(4.0),
              //             child: TextField(
              //               controller: _passwordController,
              //               obscureText: true,
              //               decoration: InputDecoration(
              //                 enabledBorder: OutlineInputBorder(
              //                     borderSide: BorderSide(
              //                       color: Color(0xff0baf00),
              //                       width: 1.0,
              //                     )),
              //                 focusedBorder: OutlineInputBorder(
              //                     borderSide: BorderSide(
              //                       color: Color(0xff0baf00),
              //                       width: 1.0,
              //                     )),
              //                 labelText: '비밀번호(초기번호: 생년월일6자리)',
              //               ),
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //     // Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
              //     //   child: Row(
              //     //     mainAxisAlignment: MainAxisAlignment.start,
              //     //     children: [
              //     //       Checkbox(
              //     //           value: autoLoginEnabled,
              //     //           onChanged: _onCheckboxTapped,
              //     //           activeColor: Color(0xff0baf00),
              //     //           checkColor: Colors.white),
              //     //       const Text(
              //     //         '자동로그인',
              //     //         style: TextStyle(
              //     //           fontSize: 24,
              //     //           fontWeight: FontWeight.w500,
              //     //           color: Colors.grey,
              //     //         ),
              //     //       ),
              //     //     ],
              //     //   ),
              //     // ),
              //     ElevatedButton(
              //       onPressed: () {
              //         print('로그인 버튼');
              //       },
              //       style: ElevatedButton.styleFrom(
              //           textStyle: const TextStyle(
              //             fontSize: 24,
              //           ),
              //           minimumSize: Size(_deviceWidth - 50, 50),
              //           foregroundColor: Colors.white,
              //           backgroundColor: Color(0xff0baf00),
              //           shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(5.0))),
              //       child: Text('로그인'),
              //     ),
              //     Padding(padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: [
              //           GestureDetector(
              //             onTap: _onRegisterTapped,
              //             child: Text(
              //               '회원가입',
              //               style: TextStyle(
              //                 fontSize: 24,
              //                 fontWeight: FontWeight.w500,
              //                 color: Colors.black,
              //               ),
              //             ),
              //           )
              //         ],
              //       ),
              //     )
              //   ],
              // ),
              // Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       GestureDetector(
              //         onTap: _onTapped,
              //         child: (Icon(
              //           Icons.arrow_back_ios_new,
              //           size: 32.0,
              //         )),
              //       )
              //     ],
              //   ),
              // ),
            ],
          ),
        )
    );
  }
  void _onTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            HomeScreen(homeUrl: Uri.parse('https://app.jayuvillage.com'))));
  }
  void _onCheckboxTapped(newVal) {
    setState(() {
      autoLoginEnabled = newVal;
    });
  }
  void _onRegisterTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HomeScreen(
            homeUrl: Uri.parse('https://app.jayuvillage.com/auth/register')
        )
    )
    );
  }
}
