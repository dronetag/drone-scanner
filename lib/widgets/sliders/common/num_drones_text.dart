import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../constants/colors.dart';

class NumDronesText extends StatelessWidget {
  const NumDronesText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numPacks = context.watch<AircraftCubit>().state.packHistory().length;
    final numPacksText = numPacks == 1 ? ' drone around' : ' drones around';
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          width: 20,
          height: 20,
          child: Text(
            numPacks.toString(),
            textScaleFactor: 0.9,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        Text(
          numPacksText,
          textScaleFactor: 0.9,
        ),
      ],
    );
  }
}
