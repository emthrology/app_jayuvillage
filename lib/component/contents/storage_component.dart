import 'package:flutter/material.dart';

class StorageComponent extends StatefulWidget {
  const StorageComponent({super.key});

  @override
  State<StorageComponent> createState() => _StorageComponentState();
}

class _StorageComponentState extends State<StorageComponent>  {


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
                child: Text('보관함 스크린'),
              ),
            ],
          )
      ),
    );
  }
}
