import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../constants/colors.dart';

class CleanPacksCheckbox extends StatefulWidget {
  const CleanPacksCheckbox({
    Key? key,
  }) : super(key: key);

  @override
  State<CleanPacksCheckbox> createState() => _CleanPacksCheckboxState();
}

class _CleanPacksCheckboxState extends State<CleanPacksCheckbox> {
  bool _cleanPacks = false;
  @override
  Widget build(BuildContext context) {
    _cleanPacks = context.read<AircraftCubit>().state.cleanOldPacks;
    return Switch(
      activeColor: AppColors.highlightBlue,
      trackColor: MaterialStateProperty.all<Color>(AppColors.lightGray),
      thumbColor: MaterialStateProperty.all<Color>(
        AppColors.preferencesButtonColor,
      ),
      value: _cleanPacks,
      onChanged: (c) {
        setState(() {
          _cleanPacks = c;
          context.read<AircraftCubit>().setCleanOldPacks(clean: c);
        });
      },
    );
  }
}
