import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FilterValue { all, aircraft, zones }

enum SortValue { uasid, time, distance }

enum ListFieldPreference { distance, location, speed }

class SlidersState {
  bool showDroneDetail = false;
  bool sliderMaximized = false;
  FilterValue filterValue = FilterValue.all;
  SortValue sortValue = SortValue.uasid;
  ListFieldPreference listFieldPreference = ListFieldPreference.distance;

  SlidersState({
    required this.showDroneDetail,
    required this.sliderMaximized,
    required this.filterValue,
    required this.sortValue,
    required this.listFieldPreference,
  });

  String sortValueString() {
    if (sortValue == SortValue.distance) {
      return 'Distance';
    } else if (sortValue == SortValue.time) {
      return 'Time';
    } else {
      return 'UAS ID';
    }
  }

  String filterValueString() {
    if (filterValue == FilterValue.aircraft) {
      return 'Aircraft';
    } else if (filterValue == FilterValue.zones) {
      return 'Zones';
    } else {
      return 'All';
    }
  }

  String listFieldPreferenceString() {
    if (listFieldPreference == ListFieldPreference.distance) {
      return 'Distance';
    }
    if (listFieldPreference == ListFieldPreference.speed) {
      return 'Speed';
    }
    if (listFieldPreference == ListFieldPreference.location) {
      return 'Location';
    }

    return 'Unknown';
  }

  SlidersState copyWith({
    bool? showDroneDetail,
    bool? sliderMaximized,
    FilterValue? filterValue,
    SortValue? sortValue,
    ListFieldPreference? listFieldPreference,
  }) =>
      SlidersState(
        showDroneDetail: showDroneDetail ?? this.showDroneDetail,
        sliderMaximized: sliderMaximized ?? this.sliderMaximized,
        filterValue: filterValue ?? this.filterValue,
        sortValue: sortValue ?? this.sortValue,
        listFieldPreference: listFieldPreference ?? this.listFieldPreference,
      );
}

class SlidersCubit extends Cubit<SlidersState> {
  final PanelController panelController = PanelController();

  SlidersCubit()
      : super(
          SlidersState(
            showDroneDetail: false,
            sliderMaximized: false,
            filterValue: FilterValue.aircraft,
            sortValue: SortValue.uasid,
            listFieldPreference: ListFieldPreference.distance,
          ),
        );

  void setFilterValue(FilterValue val) {
    emit(
      state.copyWith(filterValue: val),
    );
  }

  void setSortValue(SortValue val) {
    emit(
      state.copyWith(sortValue: val),
    );
  }

  bool isSliderAnimating() {
    return panelController.isAttached && panelController.isPanelAnimating;
  }

  bool isAtSnapPoint() {
    return panelController.panelPosition - 0.3 < 0.0001;
  }

  void openSlider() {
    panelController.open();
  }

  void closeSlider() {
    if (panelController.isAttached && panelController.isPanelOpen) {
      panelController.close();
    }
  }

  Future<void> setSliderMaximized({required bool maximized}) async {
    emit(state.copyWith(sliderMaximized: maximized));
  }

  Future<void> setShowDroneDetail({required bool show}) async {
    emit(state.copyWith(showDroneDetail: show));
  }

  Future<void> fetchAndSetPreference() async {
    final preferences = await SharedPreferences.getInstance();
    final preference = preferences.getString('listFieldPreference');

    if (preference == null) {
      return;
    }
    await setListFieldPreference(preference);
  }

  Future<void> setListFieldPreference(String preference) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('listFieldPreference', preference);

    ListFieldPreference pref;
    if (preference == 'Distance') {
      pref = ListFieldPreference.distance;
    } else if (preference == 'Location') {
      pref = ListFieldPreference.location;
    } else if (preference == 'Speed') {
      pref = ListFieldPreference.speed;
    } else {
      return;
    }
    emit(state.copyWith(listFieldPreference: pref));
  }
}
