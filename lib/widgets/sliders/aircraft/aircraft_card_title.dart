import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';
import '../../../utils/uasid_prefix_reader.dart';
import '../../../utils/utils.dart';

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
    String? manufacturer;
    Image? logo;

    manufacturer = UASIDPrefixReader.getManufacturerFromUASID(uasId);
    logo = getManufacturerLogo(manufacturer: manufacturer);

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
        ),
        children: [
          if (givenLabel == null && manufacturer != null && logo != null) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: logo,
            ),
            TextSpan(text: ' '),
          ],
          if (givenLabel != null) ...[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.label_outline,
                size: Sizes.textIconSize,
                color: Colors.black,
              ),
            ),
            TextSpan(text: ' '),
          ],
          TextSpan(
            text: givenLabel == null ? '$uasId' : '$givenLabel',
          ),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }
}
