import 'package:flutter/material.dart';

class SmallCircularProgressIndicator extends StatelessWidget {
  final EdgeInsets margin;
  final double size;
  final Color? color;

  const SmallCircularProgressIndicator({
    super.key,
    this.margin = EdgeInsets.zero,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: color ?? Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
