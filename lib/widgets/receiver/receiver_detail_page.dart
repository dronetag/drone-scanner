import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';

class ReceiverDetailPage extends StatelessWidget {
  static const routeName = 'ReceiverDetail';

  final String receiverId;

  const ReceiverDetailPage({super.key, required this.receiverId});

  @override
  Widget build(BuildContext context) {
    return DriReceiverProvider(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top,
            left: Sizes.preferencesMargin,
            right: Sizes.preferencesMargin,
          ),
          child: ReceiverDetailContent(receiverId: receiverId),
        ),
      ),
    );
  }
}

class ReceiverDetailContent extends StatefulWidget {
  final String receiverId;

  const ReceiverDetailContent({super.key, required this.receiverId});

  @override
  State<ReceiverDetailContent> createState() => _ReceiverDetailContentState();
}

class _ReceiverDetailContentState extends State<ReceiverDetailContent> {
  @override
  void initState() {
    context.read<ConnectionManager>().connect(widget.receiverId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              DroneScannerIcon.arrowBack,
              size: Sizes.iconSize,
            ),
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Text(
              'RIDER',
              textScaler: TextScaler.linear(2),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          child: ReceiverDetail(
            receiverId: widget.receiverId,
          ),
        ),
      ],
    );
  }
}
