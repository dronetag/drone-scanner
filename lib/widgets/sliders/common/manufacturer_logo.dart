import 'package:flutter/material.dart';

class ManufacturerLogo extends StatelessWidget {
  final String manufacturer;
  final Color color;

  static const _manufacturerLogoMapping = {
    'Dronetag': 'assets/images/dronetag.png',
    'DJI': 'assets/images/dji_logo.png'
  };

  const ManufacturerLogo(
      {super.key, required this.manufacturer, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    final path = _manufacturerLogoMapping[manufacturer];

    if (path == null) return const SizedBox.shrink();

    return Image.asset(
      path,
      height: 16,
      width: 20,
      alignment: Alignment.centerLeft,
      color: color,
    );
  }
}
