import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedAircraftState {
  String? selectedAircraftMac;
  SelectedAircraftState({required this.selectedAircraftMac});
}

class SelectedAircraftCubit extends Cubit<SelectedAircraftState> {
  SelectedAircraftCubit()
      : super(
          SelectedAircraftState(selectedAircraftMac: null),
        );
  void selectAircraft(String mac) {
    emit(SelectedAircraftState(selectedAircraftMac: mac));
  }

  void unselectAircraft() {
    emit(SelectedAircraftState(selectedAircraftMac: null));
  }

  bool get isAircraftSelected {
    return state.selectedAircraftMac != null;
  }
}
