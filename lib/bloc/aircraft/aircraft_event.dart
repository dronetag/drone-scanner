part of 'aircraft_bloc.dart';

class AircraftEvent {}

class AircraftLabelsUpdate extends AircraftEvent {
  final Map<String, String> labels;

  AircraftLabelsUpdate(this.labels);
}

class AircraftUpdate extends AircraftEvent {
  final Map<String, List<MessagePack>> packHistory;

  AircraftUpdate(this.packHistory);
}

class AircraftBuffering extends AircraftEvent {
  final Map<String, List<MessagePack>> packHistory;

  AircraftBuffering(this.packHistory);
}

class AircraftApplyState extends AircraftEvent {
  final AircraftState state;

  AircraftApplyState(this.state);
}
