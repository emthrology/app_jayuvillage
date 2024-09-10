import 'package:flutter/material.dart';

class RoundedInkwellButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color splashColor;
  final Color backgroundColor;

  const RoundedInkwellButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.splashColor = Colors.blue,
    this.backgroundColor = const Color(0xff0baf00),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: InkWell(
        splashColor: splashColor.withOpacity(0.3),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: child,
        ),
      ),
    );
  }
}