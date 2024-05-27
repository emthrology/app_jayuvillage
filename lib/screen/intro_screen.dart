import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: Image.asset('asset/images/logo_ios.png',
            width: MediaQuery.of(context).size.width / 3.5)
          ),
        ),
      );
  }
}