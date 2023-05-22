import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum FilterValue { all, aircraft, zones }

enum SortValue { uasid, time, distance }

enum ListFieldPreference { distance, location, speed }

enum MyDronePositioning { defaultPosition, alwaysFirst, alwaysLast }

class SlidersState {
  bool showDroneDetail = false;
  bool sliderMaximized = false;
  FilterValue filterValue = FilterValue.all;
  SortValue sortValue = SortValue.uasid;
  ListFieldPreference listFieldPreference = ListFieldPreference.distance;
  MyDronePositioning myDronePositioning = MyDronePositioning.alwaysFirst;

  SlidersState({
    required this.showDroneDetail,
    required this.sliderMaximized,
    required this.filterValue,
    required this.sortValue,
    required this.listFieldPreference,
    required this.myDronePositioning,
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

  String myDronePositioningString() {
    if (myDronePositioning == MyDronePositioning.defaultPosition) {
      return 'Default';
    }
    if (myDronePositioning == MyDronePositioning.alwaysFirst) {
      return 'Always First';
    }
    if (myDronePositioning == MyDronePositioning.alwaysLast) {
      return 'Always Last';
    }

    return 'Unknown';
  }

  SlidersState copyWith({
    bool? showDroneDetail,
    bool? sliderMaximized,
    FilterValue? filterValue,
    SortValue? sortValue,
    ListFieldPreference? listFieldPreference,
    MyDronePositioning? myDronePositioning,
  }) =>
      SlidersState(
        showDroneDetail: showDroneDetail ?? this.showDroneDetail,
        sliderMaximized: sliderMaximized ?? this.sliderMaximized,
        filterValue: filterValue ?? this.filterValue,
        sortValue: sortValue ?? this.sortValue,
        listFieldPreference: listFieldPreference ?? this.listFieldPreference,
        myDronePositioning: myDronePositioning ?? this.myDronePositioning,
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
            myDronePositioning: MyDronePositioning.alwaysFirst,
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

  void openIfClosed() {
    if (panelController.isPanelClosed) {
      panelController.animatePanelToSnapPoint();
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
    final myDronePositioning = preferences.getString('myDronePositioning');

    if (preference != null) {
      await setListFieldPreference(preference);
    }

    if (myDronePositioning != null) {
      await setMyDronePositioning(myDronePositioning);
    }
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

  Future<void> setMyDronePositioning(String myDronePositioning) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('myDronePositioning', myDronePositioning);

    MyDronePositioning pref;
    if (myDronePositioning == 'Default') {
      pref = MyDronePositioning.defaultPosition;
    } else if (myDronePositioning == 'Always First') {
      pref = MyDronePositioning.alwaysFirst;
    } else if (myDronePositioning == 'Always Last') {
      pref = MyDronePositioning.alwaysLast;
    } else {
      return;
    }
    emit(state.copyWith(myDronePositioning: pref));
  }
}
