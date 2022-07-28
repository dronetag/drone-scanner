import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../../constants/colors.dart';

class AircraftLabelText extends StatefulWidget {
  final String aircraftMac;

  AircraftLabelText({Key? key, required this.aircraftMac}) : super(key: key);

  @override
  State<AircraftLabelText> createState() => _AircraftLabelTextState();
}

class _AircraftLabelTextState extends State<AircraftLabelText> {
  final TextEditingController _controller = TextEditingController();
  bool isInit = false;

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      final text =
          context.read<AircraftCubit>().getAircraftLabel(widget.aircraftMac);
      if (text != null) _controller.text = text;
      isInit = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.droneScannerDetailFieldHeaderColor,
          ),
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter label for an aircraft',
          ),
          controller: _controller,
          onSubmitted: (label) {
            context.read<AircraftCubit>().addAircraftLabel(
                  widget.aircraftMac,
                  label,
                );
          },
        ),
      ],
    );
  }
}
