import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../constants/colors.dart';
import '../common/refreshing_text.dart';

class AircraftRefresingField extends StatelessWidget {
  final String label;
  final MessagePack pack;

  const AircraftRefresingField({
    Key? key,
    required this.pack,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.droneScannerDetailFieldHeaderColor,
          ),
        ),
        RefreshingText(
          pack: pack,
        ),
      ],
    );
  }
}
