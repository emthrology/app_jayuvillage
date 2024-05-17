import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:webview_ex/screen/home_screen.dart';
import 'package:webview_ex/store/login_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

final homeUrl = Uri.parse('https://app.jayuvillage.com');

class LoginScreen extends StatefulWidget {
  final WebViewController webController;

  const LoginScreen({super.key, required this.webController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FormController _formController = Get.put(FormController());
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late WebViewController webController;
  bool autoLoginEnabled = false;

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '연락처를 입력해주세요';
    }
    final phoneRegExp = RegExp(r'^01[0-9]?[0-9]{3,4}?[0-9]{4}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '연락처를 올바르게 입력해주세요';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }



  @override
  void initState() {
    super.initState();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('loginChannel',
          onMessageReceived: (JavaScriptMessage ms) {
        Map<String, dynamic> session = jsonDecode(ms.message);
        if (session.containsKey('success')) {
          _formController.setPhone(_phoneController.text);
          _formController.setPassword(_passwordController.text);
          _formController.setSession(session);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HomeScreen(homeUrl: homeUrl)));
        }else if(session.containsKey('error')) {
          Fluttertoast.showToast(
              msg: "오류가 발생하였습니다.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Color(0xff0baf00),
              textColor: Colors.white,
              fontSize: 16.0
          );
        }else {
          print(ms.message);
        }
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
              controller: webController,
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
                      child: TextFormField(
                        controller: _phoneController,
                        validator: _validatePhone,
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
                      child: TextFormField(
                        controller: _passwordController,
                        validator: _validatePassword,
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
                callApi();
              },
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 24,
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width - 50, 50),
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff0baf00),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              child: Text('로그인'),
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
    if (true) {
      final String phone = _phoneController.text;
      final String password = _passwordController.text;
      Map<String, dynamic> payload = {"phone": phone, "password": password};
      String payloadEncoded = json.encode(payload);
      await webController
          .runJavaScript('loginFromFlutter($payloadEncoded)');
    }
  }

  bool validateData() {
    if (_formKey.currentState?.validate() ?? false) {
      // 폼이 유효한 경우
      _formKey.currentState?.save();
    }
    return false;
  }

}