import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_ex/screen/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../store/secure_storage.dart';

final homeUrl = Uri.parse('https://app.jayuvillage.com');

class LoginScreen extends StatefulWidget {
  final WebViewController webController;

  const LoginScreen({super.key, required this.webController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final dio = Dio();
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late WebViewController webController;
  final SecureStorage secureStorage = SecureStorage();
  bool autoLoginEnabled = false;
  String storedValue = '';
  String authToken = '';

  void storeToken(token, userId) async {
    final response = await dio.post('https://api.jayuvillage.com/api/store-token',
        data: {
          'token': token,
          'user_id': userId
        },

        options: Options(
          validateStatus: (statusCode) {
            if (statusCode == null) {
              return false;
            } else {
              return statusCode >= 200 && statusCode <= 500;
            }
          }
        )
    );
    print(response.data.toString());
  }
  void _getFCMToken(userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    // setState(() {
    //   _fcmToken = token;
    // });
    storeToken(token,userId);
    print("FCM Token: $token");
  }

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

  Future<void> readValue(key) async {
    String value = await secureStorage.readSecureData(key);
    setState(() {
      storedValue = value;
    });
  }

  Future<void> writeValue(String key,String value) async {
    await secureStorage.writeSecureData(key, value);
  }


  @override
  void initState() {
    super.initState();
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('loginChannel',
          onMessageReceived: (JavaScriptMessage ms) {
        Map<String, dynamic> session = jsonDecode(ms.message);
        print("session:$session");
        if (session.containsKey('success')) {
          setState(() {
            writeValue('phone',_phoneController.text);
            writeValue('password',_passwordController.text);
            writeValue('session', jsonEncode(session));
          });
          //send fcm token to server;
          _getFCMToken(session['success']['id']);

          Navigator.of(context).pushReplacement(
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
      resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Stack(
      children: [
        Opacity(
            opacity: 0.0,
            child: WebViewWidget(
              controller: webController,
            )),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    alignment: Alignment.center,
                    child: Image.asset('asset/images/logo_big.png',
                        width: MediaQuery.of(context).size.width / 2.0)),
                Container(
                  padding: EdgeInsets.only(top: 24.0),
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
                    padding: EdgeInsets.symmetric(vertical: 8.0),
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
                              labelText: '비밀번호',
                            ),),
                        )
                      ]),
                    )
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Checkbox(
                //               value: autoLoginEnabled,
                //               onChanged: _onCheckboxTapped,
                //               activeColor: Color(0xff0baf00),
                //               checkColor: Colors.white),
                //           const Text(
                //             '자동로그인',
                //             style: TextStyle(
                //               fontSize: 24,
                //               fontWeight: FontWeight.w500,
                //               color: Colors.grey,
                //             ),
                //           ),
                //         ],
                //       ),
                //       const SizedBox(width: 30)
                //     ],
                //   ),
                // ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _onRegisterTapped,
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),),),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '|',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _onPasswordChangeTapped,
                        child: Text(
                          '비밀번호 변경',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),),),
                    ],),
                )
              ],
            ),),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Semantics(
                label: '뒤로가기',
                hint: '이전 화면으로 가기 위해 누르세요',
                child: GestureDetector(
                  onTap: _onTapped,
                  child: Row(
                    children:[
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 32.0,
                      ),
                      Text('뒤로가기',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),)]),),)],),
        ),
      ],)));
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
  void _onPasswordChangeTapped() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HomeScreen(
            homeUrl: Uri.parse('https://app.jayuvillage.com/auth/password'))));
  }

  void callApi() async {
    if (validateParams()) {
      final String phone = _phoneController.text;
      final String password = _passwordController.text;
      Map<String, dynamic> payload = {"phone": phone, "password": password};
      String payloadEncoded = json.encode(payload);
      await webController
          .runJavaScript('loginFromFlutter($payloadEncoded)');
    }else {
      Fluttertoast.showToast(
          msg: "연락처를 올바르게 입력해주세요.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 4,
          backgroundColor: Color(0xff0baf00),
          textColor: Colors.white,
          fontSize: 20.0,
      );
    }
  }

  bool validateParams() {
    final RegExp phoneRegExp = RegExp(r'^010\d{8}$');
    return phoneRegExp.hasMatch(_phoneController.text);
  }

  bool validateData() {
    if (_formKey.currentState?.validate() ?? false) {
      // 폼이 유효한 경우
      _formKey.currentState?.save();
    }
    return false;
  }

}
