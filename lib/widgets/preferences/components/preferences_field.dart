import 'package:flutter/material.dart';

class PreferencesField extends StatelessWidget {
  final Widget icon;
  final String label;
  final String text;
  final Color color;

  const PreferencesField({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Text(
            label,
          ),
          const Spacer(),
          icon,
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
