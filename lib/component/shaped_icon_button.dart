import 'package:flutter/material.dart';
class ShapedIconButton extends StatelessWidget {
  final double width;
  final Icon icon;
  final VoidCallback? onPressed;
  const ShapedIconButton({super.key, required this.icon, required this.width, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IconButton(
        padding: EdgeInsets.all(0),
        icon: icon,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.black, width: 1)
          ),
        ),
      ),
    );
  }
}
