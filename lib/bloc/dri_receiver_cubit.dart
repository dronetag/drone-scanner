import 'dart:async';

import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart';

import 'aircraft/aircraft_cubit.dart';

class DriReceiversState {
  final Map<String, MessageContainer> receivedData;

  DriReceiversState({required this.receivedData});

  DriReceiversState copyWith({Map<String, MessageContainer>? receivedData}) =>
      DriReceiversState(receivedData: receivedData ?? this.receivedData);
}

class DriReceiversCubit extends Cubit<DriReceiversState> {
  final AircraftCubit aircraftCubit;
  final DriMessagesManager messagesManager;

  StreamSubscription? listener;

  DriReceiversCubit({
    required this.aircraftCubit,
    required this.messagesManager,
  }) : super(DriReceiversState(receivedData: {})) {
    listener = messagesManager.allMessages.listen(_scanCallback);
  }

  void _scanCallback(ReceivedDriData driData) {
    final container = state.receivedData[driData.sourceMacAddress] ??
        MessageContainer(
          macAddress: driData.sourceMacAddress,
          lastUpdate: driData.receiverProperties.lastSeen,
          // TODO: use real source
          source: MessageSource.BluetoothLegacy,
          lastMessageRssi: driData.rssi,
        );

    final updatedContainer = container.update(
        message: driData.odidMessage,
        receivedTimestamp: driData.receivedTimestamp.millisecondsSinceEpoch,
        // TODO: use real source
        source: MessageSource.BluetoothLegacy,
        rssi: driData.rssi);

    if (updatedContainer == null) {
      return;
    }

    emit(state.copyWith(receivedData: {
      ...state.receivedData,
      driData.sourceMacAddress: updatedContainer,
    }));
    aircraftCubit.addPack(updatedContainer);
  }
}
