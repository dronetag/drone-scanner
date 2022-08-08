import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class AircraftCardTitle extends StatelessWidget {
  final String uasId;
  final String? givenLabel;
  const AircraftCardTitle({
    Key? key,
    required this.uasId,
    required this.givenLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (uasId.startsWith('1596') == true)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: givenLabel == null
                  ? Image.asset('assets/images/dronetag.png',
                      height: 16,
                      width: 24,
                      alignment: Alignment.topRight,
                      color: Colors.black)
                  : Icon(Icons.label_outline,
                      size: Sizes.textIconSize, color: Colors.black),
            ),
          TextSpan(
            text: givenLabel == null ? ' $uasId' : ' $givenLabel',
          ),
        ],
      ),
    );
  }
}
