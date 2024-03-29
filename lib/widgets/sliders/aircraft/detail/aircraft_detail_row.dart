import 'package:flutter/material.dart';

class AircraftDetailRow extends StatelessWidget {
  final List<Widget> children;

  const AircraftDetailRow({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLandscape ? 0 : 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children.map((e) => Expanded(child: e)).toList(),
      ),
    );
  }
}
