import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  final String title;
  const StatisticsScreen({super.key, required this.title});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Text('관리자모드 통계 페이지'),
        ),
      ),
    );
  }
}
