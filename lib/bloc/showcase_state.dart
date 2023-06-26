part of 'showcase_cubit.dart';

class ShowcaseState {
  bool showcaseActive;
  bool showcaseAlreadyPlayed;
  // keep aircraft state and apply it after showcase ends
  // so user wont lose data when starting showcase with data already gathered
  AircraftState? aircraftState;

  ShowcaseState(
      {required this.showcaseActive,
      required this.showcaseAlreadyPlayed,
      this.aircraftState});

  ShowcaseState copyWith({
    bool? showcaseActive,
    bool? showcaseAlreadyPlayed,
    AircraftState? aircraftState,
  }) =>
      ShowcaseState(
        showcaseActive: showcaseActive ?? this.showcaseActive,
        showcaseAlreadyPlayed:
            showcaseAlreadyPlayed ?? this.showcaseAlreadyPlayed,
        aircraftState: aircraftState ?? this.aircraftState,
      );
}

class ShowcaseStateNotInitialized extends ShowcaseState {
  ShowcaseStateNotInitialized({
    required super.showcaseActive,
    required super.showcaseAlreadyPlayed,
    super.aircraftState,
  });

  @override
  ShowcaseStateNotInitialized copyWith({
    bool? showcaseActive,
    bool? showcaseAlreadyPlayed,
    AircraftState? aircraftState,
  }) =>
      ShowcaseStateNotInitialized(
        showcaseActive: showcaseActive ?? this.showcaseActive,
        showcaseAlreadyPlayed:
            showcaseAlreadyPlayed ?? this.showcaseAlreadyPlayed,
        aircraftState: aircraftState ?? this.aircraftState,
      );
}

class ShowcaseStateInitialized extends ShowcaseState {
  ShowcaseStateInitialized({
    required super.showcaseActive,
    required super.showcaseAlreadyPlayed,
    super.aircraftState,
  });
  @override
  ShowcaseStateInitialized copyWith({
    bool? showcaseActive,
    bool? showcaseAlreadyPlayed,
    AircraftState? aircraftState,
  }) =>
      ShowcaseStateInitialized(
        showcaseActive: showcaseActive ?? this.showcaseActive,
        showcaseAlreadyPlayed:
            showcaseAlreadyPlayed ?? this.showcaseAlreadyPlayed,
        aircraftState: aircraftState ?? this.aircraftState,
      );
}
