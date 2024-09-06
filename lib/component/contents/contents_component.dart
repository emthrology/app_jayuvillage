import 'package:flutter/material.dart';

class ContentsComponent extends StatefulWidget {
  const ContentsComponent({super.key});

  @override
  State<ContentsComponent> createState() => _ContentsComponentState();
}

class _ContentsComponentState extends State<ContentsComponent>  {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text('콘텐츠 스크린'),
            ),
          ],
        )
      ),
    );
  }
}
