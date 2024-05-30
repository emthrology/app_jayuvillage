import 'package:flutter/material.dart';

class TabInfo {
  final IconData icon;
  final String label;

  const TabInfo({
    required this.icon,
    required this.label,
  });
}

final POSTTABS = [
  TabInfo(
    icon: Icons.camera_alt_outlined,
    label: '사진 촬영',
  ),
  TabInfo(
    icon: Icons.link_outlined,
    label: '링크 추가',
  ),
  TabInfo(
    icon: Icons.image_outlined,
    label: '사진이미지',
  ),
];
