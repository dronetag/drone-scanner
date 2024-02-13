import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class ShowcaseStartWidget extends StatelessWidget {
  final String heading;
  final String text;
  final VoidCallback? startCallback;
  final VoidCallback? skipCallback;
  const ShowcaseStartWidget({
    required this.heading,
    required this.text,
    this.startCallback,
    this.skipCallback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(
              Sizes.showcaseMargin,
            ),
            child: Column(
              children: [
                Text(
                  heading,
                  textScaler: const TextScaler.linear(1.5),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: startCallback,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                AppColors.blue,
              ),
            ),
            child: const Text('Start Tutorial'),
          ),
          const SizedBox(
            width: 10,
          ),
          ElevatedButton(
            onPressed: skipCallback,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.white,
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
