import 'package:flutter/material.dart';

import '../../constants/sizes.dart';

class MapButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final double size;
  final EdgeInsets? margin;

  const MapButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.size,
    this.margin = const EdgeInsets.symmetric(vertical: Sizes.half),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(Sizes.mapButtonBorderRadius),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: Sizes.mapButtonBorderRadius,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          )
        ],
      ),
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(Sizes.half),
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}
