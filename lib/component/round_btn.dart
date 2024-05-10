import 'package:flutter/material.dart';

class RoundBtn extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Color textColor;
  final String text;
  final String uri;
  final double fontSize;
  final Function(String) onTap;

  const RoundBtn(
      {super.key,
      this.color = Colors.orange,
      this.borderColor = Colors.orange,
      this.textColor = Colors.white,
      this.fontSize = 18.0,
      required this.text,
      required this.uri,
      required this.onTap});

  String _formatText(String text) {
    if (text.length > 3) {
      return text.substring(0, 2) + '\n' + text.substring(2);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(uri),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 1,
                )),
            child: Center(
              child: Text(
                _formatText(text),
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
      ),
    );
  }
}
