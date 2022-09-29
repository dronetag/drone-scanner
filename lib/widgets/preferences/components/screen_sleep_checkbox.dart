import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/screen_cubit.dart';
import '../../../constants/colors.dart';

class ScreenSleepCheckbox extends StatefulWidget {
  const ScreenSleepCheckbox({
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenSleepCheckbox> createState() => _ScreenSleepCheckboxState();
}

class _ScreenSleepCheckboxState extends State<ScreenSleepCheckbox> {
  bool _screenSleepDisabled = false;
  @override
  Widget build(BuildContext context) {
    _screenSleepDisabled =
        context.read<ScreenCubit>().state.screenSleepDisabled;
    return SizedBox(
      width: 40,
      child: Switch(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        inactiveThumbColor: AppColors.preferencesButtonColor,
        activeColor: AppColors.highlightBlue,
        trackColor: MaterialStateProperty.all<Color>(
          AppColors.lightGray,
        ),
        value: _screenSleepDisabled,
        onChanged: (c) {
          setState(() {
            _screenSleepDisabled = c;
            context
                .read<ScreenCubit>()
                .setScreenSleepDisabled(screenSleepDisabled: c);
          });
        },
      ),
    );
  }
}
