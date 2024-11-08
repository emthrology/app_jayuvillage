
import 'package:flutter/material.dart';
class WhiteButton extends StatelessWidget {
  final VoidCallback onTap;
  final Size size;
  final String title;
  const WhiteButton({super.key, required this.onTap, required this.size, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: size,
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
          )

      ),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.black,
            fontFamily: 'NotoSans',
            fontSize: 24,
            fontWeight: FontWeight.w700

        ),
      ),
    );
  }
}
