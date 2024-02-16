import 'package:flutter/material.dart';

class PreferencesField extends StatelessWidget {
  final Widget icon;
  final String label;
  final String text;
  final Color color;

  const PreferencesField({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              icon,
              const SizedBox(
                width: 5,
              ),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
