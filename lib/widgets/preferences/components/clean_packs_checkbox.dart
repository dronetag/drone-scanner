import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../bloc/aircraft/aircraft_expiration_cubit.dart';
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
    _cleanPacks = context.read<AircraftExpirationCubit>().state.cleanOldPacks;
    return SizedBox(
      width: 40,
      child: Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        inactiveThumbColor: AppColors.preferencesButtonColor,
        activeColor: AppColors.highlightBlue,
        trackColor: MaterialStateProperty.all<Color>(
          AppColors.lightGray,
        ),
        value: _cleanPacks,
        onChanged: (c) {
          setState(() {
            _cleanPacks = c;
            final packs = context.read<AircraftCubit>().state.packHistory();
            context
                .read<AircraftExpirationCubit>()
                .setCleanOldPacks(packs, clean: c);
          });
        },
      ),
    );
  }
}
