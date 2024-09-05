import 'package:flutter/material.dart';
final Map<String, List<Map<String, dynamic>>>  BTNDATA = {
  'BEFORELOGIN': [
    {'text': '로그인', 'uri': 'https://jayuvillage.com/auth/login'},
    {'text': '가입하기', 'uri': 'https://jayuvillage.com/auth/register'},
    {
      'color': Colors.white,
      'textColor': Colors.orange,
      'text': '↑',
      'fontSize': 26.0,
      'uri': 'top'
    },
  ],

  'AFTERLOGIN': [
    {'text': '글쓰기', 'uri': 'https://jayuvillage.com/posts/create'},
    {
      'color': Colors.orange,
      'textColor': Colors.white,
      'text': '광화문레코드',
      // 'fontSize': 26.0,
      'uri': 'audio_player'
    },
    {
      'color': Colors.white,
      'textColor': Colors.orange,
      'text': '↑',
      'fontSize': 26.0,
      'uri': 'top'
    },
  ],
  'MYPAGE': [
    {'text': '고객센터', 'uri': 'https://jayuvillage.com/qnas'},
    {
      'color': Colors.white,
      'textColor': Colors.orange,
      'text': '↑',
      'fontSize': 26.0,
      'uri': 'top'
    },
  ],
  'SHARE': [
    {'text':'공유', 'uri': 'share'}
  ]
};