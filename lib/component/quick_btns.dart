import 'package:flutter/material.dart';
import 'package:webview_ex/component/round_btn.dart';

class QuickBtns extends StatelessWidget {
  final Function(String) onTap;
  final List<Map<String, dynamic>> btnData;
  const QuickBtns({super.key, required this.onTap, required this.btnData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: btnData.map((e) =>
          RoundBtn(
            text:e['text'],
            uri: e['uri'],
            onTap:onTap,
            color: e['color']?? Colors.orange,
            textColor: e['textColor']?? Colors.white,
            borderColor: e['borderColor']?? Colors.orange,
            fontSize: e['fontSize']?? 18.0,
          )
      ).toList()
      // [
      //   RoundBtn(text: '글쓰기', uri: 'https://app.jayuvillage.com/posts/create', onTap: onTap,),
      //   RoundBtn(text: '가입하기', uri: 'https://app.jayuvillage.com/auth/register', onTap: onTap),
      //   RoundBtn(color: Colors.white, textColor: Colors.orange, text: '↑', uri: 'top', onTap: onTap),
      // ],
    );
  }
}