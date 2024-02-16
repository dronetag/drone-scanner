import 'package:flutter/material.dart';

// scaffold inside safe area with bottom padding and white background
// used as root of all pages
class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Scaffold(
        // ensure the keyboard does not move the content up
        resizeToAvoidBottomInset: true,
        body: child,
      ),
    );
  }
}
