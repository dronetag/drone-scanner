import 'package:flutter_bloc/flutter_bloc.dart';

import 'zone_item.dart';

class SelectedZoneState {
  ZoneItem? selectedZone;
  SelectedZoneState({required this.selectedZone});
}

class SelectedZoneCubit extends Cubit<SelectedZoneState> {
  SelectedZoneCubit()
      : super(
          SelectedZoneState(selectedZone: null),
        );
  void selectZone(ZoneItem item) {
    emit(SelectedZoneState(selectedZone: item));
  }

  void unselectZone() {
    emit(SelectedZoneState(selectedZone: null));
  }

  bool get isZoneSelected {
    return state.selectedZone != null;
  }
}
