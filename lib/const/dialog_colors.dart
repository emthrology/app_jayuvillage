import 'package:flutter/material.dart';

class DialogColors {
  final Color backgroundColor;
  final int color;

  const DialogColors({
    required this.backgroundColor,
    required this.color
  });
}

final ERROR_DIALOG_COLORS = DialogColors(
  backgroundColor: Colors.pink[100]!,
  color: 0xffEB5F8C
);

final SUCCESS_DIALOG_COLORS = DialogColors(
  backgroundColor:  Colors.green[100]!,
  color: 0xff0baf00
);

