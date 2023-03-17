import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/proximity_alerts_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../utils/utils.dart';
import '../../app/dialogs.dart';

class UsersDeviceUASIDTextField extends StatefulWidget {
  UsersDeviceUASIDTextField({Key? key}) : super(key: key);

  @override
  State<UsersDeviceUASIDTextField> createState() =>
      _UsersDeviceUASIDTextFieldState();
}

class _UsersDeviceUASIDTextFieldState extends State<UsersDeviceUASIDTextField> {
  final TextEditingController _controller = TextEditingController();
  bool isInit = false;

  void _submit(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      // check if text is not just whitespaces
      if (_controller.text.trim() != '') {
        final validationError = validateUASID(_controller.text);
        if (validationError != null) {
          showSnackBar(context, 'Error parsing UAS ID: $validationError');
          FocusManager.instance.primaryFocus?.unfocus();
          return;
        }
        context
            .read<ProximityAlertsCubit>()
            .setUsersAircraftUASID(_controller.text);
        showSnackBar(context, 'UAS ID set sucessfully');
      } else {
        _controller.text = '';
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _delete(BuildContext context) {
    context.read<ProximityAlertsCubit>().clearUsersAircraftUASID().then((_) {
      final snackBarText = 'Users aircraft UAS ID was cleared.';
      showSnackBar(
        context,
        snackBarText,
      );
      _controller.clear();
      isInit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (!isInit) {
      final userDevice =
          context.read<ProximityAlertsCubit>().state.usersAircraftUASID;
      if (userDevice != null) {
        _controller.text = userDevice;
      } else {
        _controller.clear();
      }
      isInit = true;
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owned device UAS ID',
          ),
          Text(
            'Register your aircrafts UAS ID to be able to receive'
            ' proximity alerts. The UAS ID must be compliant with the ANSI/CTA-2063 standard.',
            textScaleFactor: 0.8,
            style: const TextStyle(
              color: AppColors.lightGray,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'UAS ID',
                  ),
                  controller: _controller,
                  onSubmitted: (_) => _submit(context),
                  onEditingComplete: () => _submit(context),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: Sizes.standard / 2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.highlightBlue,
                ),
                height: Sizes.iconSize,
                width: Sizes.iconSize,
                child: IconButton(
                  padding: const EdgeInsets.all(1.0),
                  iconSize: 20,
                  icon: const Icon(
                    Icons.done_sharp,
                    color: Colors.white,
                  ),
                  onPressed: () => _submit(context),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: Sizes.standard / 2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.highlightBlue,
                ),
                height: Sizes.iconSize,
                width: Sizes.iconSize,
                child: IconButton(
                  padding: const EdgeInsets.all(1.0),
                  iconSize: 20,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showAlertDialog(
                      context,
                      'Are you sure you want to delete the aircraft UAS ID?',
                      () => _delete(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
