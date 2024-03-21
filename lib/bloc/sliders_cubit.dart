import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/sliders/sheet/sheet.dart';

enum FilterValue { all, aircraft, zones }

enum SortValue { uasid, time, distance }

enum ListFieldPreference { distance, location, speed }

enum MyDronePositioning { defaultPosition, alwaysFirst, alwaysLast }

class SlidersState {
  bool showDroneDetail = false;
  FilterValue filterValue = FilterValue.all;
  SortValue sortValue = SortValue.uasid;
  ListFieldPreference listFieldPreference = ListFieldPreference.distance;
  MyDronePositioning myDronePositioning = MyDronePositioning.alwaysFirst;

  SlidersState({
    required this.showDroneDetail,
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
    FilterValue? filterValue,
    SortValue? sortValue,
    ListFieldPreference? listFieldPreference,
    MyDronePositioning? myDronePositioning,
  }) =>
      SlidersState(
        showDroneDetail: showDroneDetail ?? this.showDroneDetail,
        filterValue: filterValue ?? this.filterValue,
        sortValue: sortValue ?? this.sortValue,
        listFieldPreference: listFieldPreference ?? this.listFieldPreference,
        myDronePositioning: myDronePositioning ?? this.myDronePositioning,
      );
}

class SlidersCubit extends Cubit<SlidersState> {
  static const bottomSnap = 0.1;
  static const middleSnap = 0.3;
  static const topSnap = 0.9;

  static const snappings = [bottomSnap, middleSnap, topSnap];

  final SheetController panelController = SheetController();

  SlidersCubit()
      : super(
          SlidersState(
            showDroneDetail: false,
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

  bool get isPanelClosed {
    return panelController.state != null &&
        panelController.state!.extent == bottomSnap;
  }

  bool get isPanelOpened {
    return panelController.state != null &&
        panelController.state!.extent == topSnap;
  }

  Future<void> animatePanelToSnapPoint() async {
    // snap slightly higher for effect
    return panelController.snapToExtent(middleSnap + 0.01);
  }

  Future<void> openSlider() async {
    return await panelController.expand();
  }

  void closeSlider() {
    panelController.collapse();
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
