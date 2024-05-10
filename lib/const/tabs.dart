import 'package:flutter/material.dart';

class TabInfo {
  final IconData icon;
  final String label;

  const TabInfo({
    required this.icon,
    required this.label,
  });
}

final TABS = [
  TabInfo(
    icon: Icons.home_outlined,
    label: '홈',
  ),
  TabInfo(
    icon: Icons.maps_home_work_outlined,
    label: '마을소식',
  ),
  TabInfo(
    icon: Icons.important_devices,
    label: '조직활동',
  ),
  TabInfo(
    icon: Icons.chat,
    label: '채팅',
  ),
  TabInfo(
    icon: Icons.person_outline,
    label: '내 정보',
  ),
];
