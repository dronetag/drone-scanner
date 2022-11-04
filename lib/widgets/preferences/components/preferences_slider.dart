import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/aircraft_expiration_cubit.dart';
import '../../../constants/colors.dart';

class PreferencesSlider extends StatefulWidget {
  final Function(bool c) setValue;
  final bool Function() getValue;
  const PreferencesSlider({
    Key? key,
    required this.setValue,
    required this.getValue,
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
        inactiveThumbColor: AppColors.preferencesButtonColor,
        activeColor: AppColors.highlightBlue,
        trackColor: MaterialStateProperty.all<Color>(
          AppColors.lightGray,
        ),
        value: _value,
        onChanged: (c) {
          setState(() {
            _value = c;
            widget.setValue(c);
          });
        },
      ),
    );
  }
}
