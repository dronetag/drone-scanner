import 'dart:async';

import 'package:dri_receiver/dri_receiver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/pigeon.dart';

import 'aircraft/aircraft_cubit.dart';

class DriReceiversState {
  final String? connectedReceiverId;
  final Map<String, MessageContainer> receivedData;
  final bool isReceiving;

  DriReceiversState(
      {required this.receivedData,
      required this.connectedReceiverId,
      required this.isReceiving});

  DriReceiversState.initialState()
      : connectedReceiverId = null,
        receivedData = {},
        isReceiving = false;

  bool get isReceiverConnected => connectedReceiverId != null;

  DriReceiversState copyWith({
    Map<String, MessageContainer>? receivedData,
    String? connectedReceivedId,
    bool? isReceiving,
  }) =>
      DriReceiversState(
          receivedData: receivedData ?? this.receivedData,
          connectedReceiverId: connectedReceivedId ?? this.connectedReceiverId,
          isReceiving: isReceiving ?? this.isReceiving);

  DriReceiversState clearConnectedReceiver() => DriReceiversState(
        receivedData: this.receivedData,
        connectedReceiverId: null,
        isReceiving: false,
      );
}

class DriReceiversCubit extends Cubit<DriReceiversState> {
  final AircraftCubit aircraftCubit;
  final DriMessagesManager messagesManager;
  final ConnectionManager connectionManager;

  StreamSubscription? messagesListener;
  StreamSubscription? managedReceiversListener;

  DriReceiversCubit({
    required this.aircraftCubit,
    required this.messagesManager,
    required this.connectionManager,
  }) : super(DriReceiversState.initialState()) {
    managedReceiversListener =
        messagesManager.stream.listen(_handleManagedReceiversChanged);
  }

  @override
  Future<void> close() {
    messagesListener?.cancel();
    managedReceiversListener?.cancel();
    return super.close();
  }

  void connect(String serialNumber) {
    connectionManager.connect(serialNumber);
  }

  void disconnect(String serialNumber) {
    connectionManager.disconnect(serialNumber);
  }

  void discover() {
    connectionManager.clearDiscoveredReceivers();
    connectionManager.discover();
  }

  void startReceivingMessages() {
    if (state.connectedReceiverId == null) return;

    messagesListener = messagesManager.allMessages.listen(_handleReceivedData);
    messagesManager.startReceivingMessages(state.connectedReceiverId!);
    // TODO: create state
    emit(state.copyWith(isReceiving: true));
  }

  void stopReceivingMessages() {
    if (state.connectedReceiverId == null) return;

    messagesListener?.cancel();
    messagesManager.stopReceivingMessages(state.connectedReceiverId!);
    emit(state.copyWith(isReceiving: false));
  }

  void _handleReceivedData(ReceivedDriData driData) {
    final messageSource = _sourceFromReceiverSource(driData.messageSource);

    if (messageSource == null) return;

    final container = state.receivedData[driData.sourceMacAddress] ??
        MessageContainer(
          macAddress: driData.sourceMacAddress,
          lastUpdate: DateTime.now(),
          source: messageSource,
          lastMessageRssi: driData.rssi,
        );

    final updatedContainer = container.update(
      message: driData.odidMessage,
      receivedTimestamp: driData.receivedTimestamp.millisecondsSinceEpoch,
      source: messageSource,
      rssi: driData.rssi,
    );

    if (updatedContainer == null) {
      return;
    }

    emit(state.copyWith(receivedData: {
      ...state.receivedData,
      driData.sourceMacAddress: updatedContainer,
    }));
    aircraftCubit.addPack(updatedContainer);
  }

  void _handleManagedReceiversChanged(DriMessagesState driMessagesState) {
    if (driMessagesState.managedReceivers.length > 1) {
      throw 'DroneScanner does not support conencting more than 1 receiver';
    }
    if (driMessagesState.managedReceivers.isEmpty) {
      if (state.connectedReceiverId != null) {
        return emit(state.clearConnectedReceiver());
      }
      return;
    }
    final managedReceiverId = driMessagesState.managedReceivers.first;
    if (state.connectedReceiverId != managedReceiverId) {
      emit(state.copyWith(connectedReceivedId: managedReceiverId));
    }
  }

  MessageSource? _sourceFromReceiverSource(ReceivedMessageSource source) =>
      switch (source) {
        ReceivedMessageSource.bluetoothLegacy => MessageSource.BluetoothLegacy,
        ReceivedMessageSource.bluetoothLongRange =>
          MessageSource.BluetoothLongRange,
        ReceivedMessageSource.wifiBeacon => MessageSource.WifiBeacon,
        ReceivedMessageSource.wifiNan => MessageSource.WifiNan,
      };
}
