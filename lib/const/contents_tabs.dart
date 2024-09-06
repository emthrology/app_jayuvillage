import 'package:flutter/material.dart';

class TabInfo {
  final IconData icon;
  final String label;

  const TabInfo({
    required this.icon,
    required this.label,
  });
}

final CONTENTSTABS = [
  TabInfo(
    icon: Icons.home_outlined,
    label: '홈',
  ),
  TabInfo(
    icon: Icons.play_circle_outline_outlined,
    label: '컨텐츠',
  ),
  TabInfo(
    icon: Icons.folder_copy_sharp,
    label: '보관함',
  ),
  TabInfo(
    icon: Icons.search,
    label: '검색',
  ),
];
