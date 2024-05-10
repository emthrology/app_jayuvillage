import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/screen/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../const/tabs.dart';

final homeUrl = Uri.parse('https://app.jayuvillage.com');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  late WebViewController wc;
  bool autoLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    wc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('authWebView',
          onMessageReceived: (JavaScriptMessage ms) {
        print('login channel response');
        print(ms);
      })
      ..loadRequest(Uri.parse('https://app.jayuvillage.com/auth/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
      children: [
        Opacity(
            opacity: 0.0,
            child: WebViewWidget(
              controller: wc,
            )),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                alignment: Alignment.center,
                child: Image.asset('asset/images/logo_big.png',
                    width: MediaQuery.of(context).size.width / 2.0)),
            Container(
              padding: EdgeInsets.only(top: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '환영합니다!',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '휴대폰 번호로 로그인 해주세요.',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color(0xff0baf00),
                            width: 1.0,
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color(0xff0baf00),
                            width: 1.0,
                          )),
                          labelText: '연락처 11자리(-없이 숫자만 입력)',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color(0xff0baf00),
                            width: 1.0,
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color(0xff0baf00),
                            width: 1.0,
                          )),
                          labelText: '비밀번호(초기번호: 생년월일6자리)',
                        ),
                      ),
                    )
                  ]),
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                          value: autoLoginEnabled,
                          onChanged: _onCheckboxTapped,
                          activeColor: Color(0xff0baf00),
                          checkColor: Colors.white),
                      const Text(
                        '자동로그인',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 30)
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('로그인 버튼');
                callApi();
              },
              child: Text('로그인'),
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width - 50, 50),
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff0baf00),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _onRegisterTapped,
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _onTapped,
                child: (Icon(
                  Icons.arrow_back_ios_new,
                  size: 32.0,
                )),
              )
            ],
          ),
        ),
      ],
    )));
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
            homeUrl: Uri.parse('https://app.jayuvillage.com/auth/register'))));
  }

  void callApi() async {
    if(validateData()) {
      final String phone = _phoneController.text;
      final String password = _passwordController.text;
      // final String jsCode = """
      //   window.$nuxt.$auth.loginWith('laravelSanctum', {
      //     data: {
      //       username: '${phone}',
      //       password: '${password}'
      //     }
      //   }).then(response => {
      //     console.log('Login successful', response);
      //   }).catch(error => {
      //     console.error('Login failed', error);
      //   });
      // """;
      // wc.runJavaScriptReturningResult(jsCode);
      Fluttertoast.showToast(
          msg: "연락처:${phone}, 비밀번호:${password}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xff0baf00),
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('응 아니야'))
      );
    }
  }

  bool validateData() {
    if(_formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }
}
