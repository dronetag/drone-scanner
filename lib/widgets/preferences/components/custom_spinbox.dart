import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '../../../bloc/aircraft/aircraft_bloc.dart';
import '../../../bloc/aircraft/aircraft_expiration_cubit.dart';
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
            final current =
                context.read<AircraftExpirationCubit>().state.cleanTimeSec;
            if (current - step >= minVal) {
              final packs = context.read<AircraftBloc>().state.packHistory();
              context
                  .read<AircraftExpirationCubit>()
                  .setcleanTimeSec(current - step, packs);
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
              keyboardType: TextInputType.phone,
              min: minVal,
              max: maxVal,
              value: context
                  .watch<AircraftExpirationCubit>()
                  .state
                  .cleanTimeSec
                  .toDouble(),
              step: step,
              showButtons: false,
              onChanged: (v) {
                if (v < minVal) v = minVal;
                if (v > maxVal) v = maxVal;
                final packs = context.read<AircraftBloc>().state.packHistory();
                context.read<AircraftExpirationCubit>().setcleanTimeSec(
                      v,
                      packs,
                    );
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
            final current =
                context.read<AircraftExpirationCubit>().state.cleanTimeSec;
            if (current + step <= maxVal) {
              final packs = context.read<AircraftBloc>().state.packHistory();
              context.read<AircraftExpirationCubit>().setcleanTimeSec(
                    current + step,
                    packs,
                  );
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
