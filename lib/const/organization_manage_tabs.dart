import 'package:flutter/material.dart';

class TabInfo {
  final Widget icon;
  final String label;

  const TabInfo({
    required this.icon,
    required this.label,
  });
}

final MANAGETABS = [
  TabInfo(
    icon: Icon(
        Icons.home_outlined
    ),
    label: '관리자 홈',
  ),
  TabInfo(
    icon: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person),
        Text('|'),
        Icon(Icons.person_outline_sharp)
      ]),
    label: '접속·미접속자 상세 명단',
  ),
  TabInfo(
    icon: Icon(Icons.chat),
    label: '분석',
  ),
];
