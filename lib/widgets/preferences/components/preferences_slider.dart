import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class PreferencesSlider extends StatefulWidget {
  final Function(bool c) setValue;
  final bool Function() getValue;
  final bool enabled;
  const PreferencesSlider({
    Key? key,
    required this.setValue,
    required this.getValue,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PreferencesSlider> createState() => _CleanPacksCheckboxState();
}

class _CleanPacksCheckboxState extends State<PreferencesSlider> {
  bool _value = false;
  @override
  Widget build(BuildContext context) {
    _value = widget.getValue();
    return SizedBox(
      width: 40,
      child: Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        inactiveThumbColor: widget.enabled
            ? AppColors.preferencesButtonColor
            : AppColors.lightGray.withOpacity(0.75),
        activeColor: AppColors.highlightBlue,
        trackColor: MaterialStateProperty.all<Color>(
          widget.enabled
              ? AppColors.lightGray
              : AppColors.lightGray.withOpacity(0.25),
        ),
        value: widget.enabled ? _value : false,
        onChanged: widget.enabled
            ? (c) {
                setState(() {
                  _value = c;
                  widget.setValue(c);
                });
              }
            : null,
      ),
    );
  }
}
