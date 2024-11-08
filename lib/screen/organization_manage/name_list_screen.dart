import 'package:flutter/material.dart';

class NameListScreen extends StatefulWidget {
  final String type;
  final String title;
  const NameListScreen({super.key, required this.type, required this.title});

  @override
  State<NameListScreen> createState() => _NameListScreenState();
}

class _NameListScreenState extends State<NameListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Text('관리자모드 ${widget.type} 페이지'),
        ),
      ),
    );
  }
}
