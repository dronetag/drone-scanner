import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/flutter_opendroneid.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../bloc/proximity_alerts_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../utils/utils.dart';
import '../../../app/dialogs.dart';

class SetAsMineButton extends StatelessWidget {
  const SetAsMineButton({
    super.key,
    required this.uasId,
    required this.proximityAlertsActive,
  });

  final UASID? uasId;
  final bool proximityAlertsActive;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final alertsCubit = context.read<ProximityAlertsCubit>();
        if (uasId?.asString() != null &&
            alertsCubit.state.usersAircraftUASID == uasId!.asString()) {
          alertsCubit.clearUsersAircraftUASID();
          showSnackBar(context, 'Owned aircaft was unset');
        } else {
          if (uasId?.asString() == null) {
            showSnackBar(
                context, 'Cannot set aircraft as owned: Unknown UAS ID');
            return;
          }
          if (uasId?.type == IDType.serialNumber) {
            final validationError = validateUASID(uasId!.asString()!);
            if (validationError != null) {
              showSnackBar(context, 'Error parsing UAS ID: $validationError');
              FocusManager.instance.primaryFocus?.unfocus();
              return;
            }
          }
          alertsCubit.setUsersAircraftUASID(uasId!.asString()!);
          showSnackBar(context, 'Aircaft set as owned');
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          proximityAlertsActive ? AppColors.green : Colors.white,
        ),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(
              width: 2.0,
              color: proximityAlertsActive ? Colors.white : AppColors.green),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: proximityAlertsActive ? 0 : Sizes.iconPadding,
            ),
            child: Icon(
              Icons.person,
              size: Sizes.iconSize,
              color: proximityAlertsActive ? Colors.white : AppColors.green,
            ),
          ),
          if (proximityAlertsActive)
            const Padding(
              padding: EdgeInsets.only(right: Sizes.iconPadding),
              child: Icon(
                Icons.done,
                color: Colors.white,
                size: Sizes.iconSize * 0.75,
              ),
            ),
          Text(
            proximityAlertsActive ? 'MINE' : 'SET AS MINE',
            style: TextStyle(
                fontSize: 12,
                color: proximityAlertsActive ? Colors.white : AppColors.green),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
