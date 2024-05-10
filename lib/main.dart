import 'package:flutter/material.dart';
import 'package:webview_ex/screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
        home: HomeScreen(homeUrl: Uri.parse('https://app.jayuvillage.com'))
    ),
  );
}