import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';
import 'receiver_detail_page.dart';

class ReceiverListPage extends StatelessWidget {
  static const routeName = 'ReceiverList';

  const ReceiverListPage({super.key});

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
          child: const ReceiverListContent(),
        ),
      ),
    );
  }
}

class ReceiverListContent extends StatefulWidget {
  const ReceiverListContent({super.key});

  @override
  State<ReceiverListContent> createState() => _ReceiverListContentState();
}

class _ReceiverListContentState extends State<ReceiverListContent> {
  @override
  void initState() {
    context.read<ConnectionManager>().discover();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              'Detected RIDERs',
              textScaler: TextScaler.linear(2),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          child: DiscoveredReceiversList(
            onTileTapped: _navigateToReceiverDetail,
          ),
        ),
      ],
    );
  }

  void _navigateToReceiverDetail(DriReceiverProperties receiverProperties) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiverDetailPage(
            receiverId: receiverProperties.id,
          ),
          settings: const RouteSettings(
            name: ReceiverDetailPage.routeName,
          ),
        ),
      );
}
