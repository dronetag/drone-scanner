import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../constants/colors.dart';

class CustomSpinBox extends StatelessWidget {
  const CustomSpinBox({Key? key}) : super(key: key);
  static const maxVal = 600.0;
  static const minVal = 10.0;
  static const step = 5.0;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            print('pres');
            final current = context.read<AircraftCubit>().state.cleanTimeSec;
            if (current - step >= minVal) {
              context.read<AircraftCubit>().setcleanTimeSec(current - step);
            }
          },
          icon: Icon(
            Icons.remove,
            color: AppColors.preferencesButtonColor,
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        Align(
          child: SizedBox(
            width: width / 6,
            child: SpinBox(
              min: minVal,
              max: maxVal,
              value:
                  context.watch<AircraftCubit>().state.cleanTimeSec.toDouble(),
              step: step,
              showButtons: false,
              onChanged: (v) {
                if (v < minVal) v = minVal;
                if (v > maxVal) v = maxVal;
                context.read<AircraftCubit>().setcleanTimeSec(v);
              },
              decoration: const InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                constraints: BoxConstraints(),
              ),
            ),
          ),
        ),
        IconButton(
          constraints: BoxConstraints(),
          onPressed: () {
            final current = context.read<AircraftCubit>().state.cleanTimeSec;
            if (current + step <= maxVal) {
              context.read<AircraftCubit>().setcleanTimeSec(current + step);
            }
          },
          icon: Icon(
            Icons.add,
            color: AppColors.preferencesButtonColor,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
