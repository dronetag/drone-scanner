import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../app/dialogs.dart';

class AircraftLabelText extends StatefulWidget {
  final String aircraftMac;

  AircraftLabelText({Key? key, required this.aircraftMac}) : super(key: key);

  @override
  State<AircraftLabelText> createState() => _AircraftLabelTextState();
}

class _AircraftLabelTextState extends State<AircraftLabelText> {
  final TextEditingController _controller = TextEditingController();
  bool isInit = false;

  void deleteLabelCallback() {
    context
        .read<AircraftBloc>()
        .deleteAircraftLabel(
          widget.aircraftMac,
        )
        .then((value) => setState(() {
              isInit = false;
              _controller.clear();
            }));
  }

  void submitCallback() {
    context.read<AircraftBloc>().addAircraftLabel(
          widget.aircraftMac,
          _controller.text,
        );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      final text =
          context.read<AircraftBloc>().getAircraftLabel(widget.aircraftMac);
      if (text != null) {
        _controller.text = text;
      }
      isInit = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.detailFieldHeaderColor,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter label for an aircraft',
                ),
                controller: _controller,
                onSubmitted: (_) => submitCallback,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
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
                onPressed: submitCallback,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
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
                    'Are you sure you want to delete the aircraft label?',
                    deleteLabelCallback,
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
