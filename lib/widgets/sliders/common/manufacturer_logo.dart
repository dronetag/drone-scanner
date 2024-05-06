import 'package:flutter/material.dart';

class ManufacturerLogo extends StatelessWidget {
  final String manufacturer;
  final Color color;

  const ManufacturerLogo(
      {super.key, required this.manufacturer, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    String? path;
    if (manufacturer == 'Dronetag') path = 'assets/images/dronetag.png';
    if (manufacturer == 'DJI') path = 'assets/images/dji_logo.png';

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
