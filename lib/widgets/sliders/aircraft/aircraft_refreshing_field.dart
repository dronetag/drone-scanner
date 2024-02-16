import 'package:flutter/material.dart';
import 'package:flutter_opendroneid/models/message_container.dart';

import '../../../constants/colors.dart';
import '../common/refreshing_text.dart';

class AircraftRefresingField extends StatelessWidget {
  final String label;
  final MessageContainer pack;
  final bool showExpiryWarning;

  const AircraftRefresingField({
    super.key,
    required this.pack,
    required this.label,
    this.showExpiryWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.detailFieldHeaderColor,
          ),
        ),
        RefreshingText(
          pack: pack,
          showExpiryWarning: showExpiryWarning,
        ),
      ],
    );
  }
}
