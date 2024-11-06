import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dri_receiver_cubit.dart';
import '../../constants/sizes.dart';

class ReceiverPageListContent extends StatefulWidget {
  final void Function(DriReceiverProperties)? onReceiverTapped;

  const ReceiverPageListContent({super.key, this.onReceiverTapped});

  @override
  State<ReceiverPageListContent> createState() =>
      _ReceiverPageListContentState();
}

class _ReceiverPageListContentState extends State<ReceiverPageListContent> {
  @override
  void initState() {
    context.read<DriReceiversCubit>().discover();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top,
            left: Sizes.preferencesMargin,
            right: Sizes.preferencesMargin,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Sizes.standard * 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detected RIDERs',
                        textScaler: TextScaler.linear(2),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () =>
                            context.read<DriReceiversCubit>().discover(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<ConnectionManager, ConnectionManagerState>(
                    builder: (context, state) {
                  return DiscoveredReceiversList(
                    discoveredReceivers:
                        state.discoveredReceivers.values.toList(),
                    connectionStates: state.connectionStates,
                  );
                }),
              ),
            ],
          )),
    );
  }
}
