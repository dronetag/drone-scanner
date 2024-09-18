import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dri_receiver_cubit.dart';
import '../../constants/sizes.dart';

class ReceiverPageDetailContent extends StatelessWidget {
  static const routeName = 'ReceiverDetail';

  final String serialNumber;

  const ReceiverPageDetailContent({super.key, required this.serialNumber});

  @override
  Widget build(BuildContext context) {
    final receiverProperties =
        context.select<ConnectionManager, DriReceiverProperties?>(
      (cubit) => cubit.state.discoveredReceivers[serialNumber],
    );
    final connectionState =
        context.select<ConnectionManager, ReceiverConnectionState?>(
      (cubit) => cubit.state.connectionStates[serialNumber],
    );

    if (receiverProperties == null || connectionState == null) {
      throw 'Receiver must have properties and connection state';
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          left: Sizes.preferencesMargin,
          right: Sizes.preferencesMargin,
        ),
        child: Column(
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
                      'RIDER',
                      textScaler: TextScaler.linear(2),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // TODO: move to package
                    if (!context.select<DriReceiversCubit, bool>(
                        (cubit) => cubit.state.isReceiving)) ...[
                      ElevatedButton(
                          onPressed: () => context
                              .read<DriReceiversCubit>()
                              .startReceivingMessages(),
                          child: const Text('Start ')),
                    ] else ...[
                      ElevatedButton(
                          onPressed: () => context
                              .read<DriReceiversCubit>()
                              .stopReceivingMessages(),
                          child: const Text('Stop ')),
                    ],

                    ElevatedButton(
                        onPressed: () => context
                            .read<DriReceiversCubit>()
                            .disconnect(serialNumber),
                        child: const Text('Disconnect'))
                  ],
                ),
              ),
            ),
            Expanded(
              child: ReceiverDetail(
                  receiverProperties: receiverProperties,
                  connectionState: connectionState),
            ),
          ],
        ),
      ),
    );
  }
}
