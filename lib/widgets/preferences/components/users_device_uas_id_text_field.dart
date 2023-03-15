import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_cubit.dart';
import 'preferences_field_with_description.dart';

class UsersDeviceUASIDTextField extends StatelessWidget {
  UsersDeviceUASIDTextField({Key? key}) : super(key: key);
  final TextEditingController _controller = TextEditingController();

  void _submit(BuildContext context) {
    // TODO: validate
    context.read<AircraftCubit>().setUsersAircraftUASID(_controller.text);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final userDevice = context.read<AircraftCubit>().state.usersAircraftUASID;
    if (userDevice != null) {
      _controller.text = userDevice;
    }
    return PreferencesFieldWithDescription(
      label: 'Own device UAS ID',
      description: 'Register your aircrafts UAS ID to be able to receive'
          'proximity alerts',
      child: Expanded(
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
    );
  }
}
