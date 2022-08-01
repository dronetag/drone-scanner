import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../widgets/preferences/preferences_page.dart';
import 'aircraft/aircraft_cubit.dart';
import 'aircraft/selected_aircraft_cubit.dart';
import 'opendroneid_cubit.dart';
import 'sliders_cubit.dart';

class ShowcaseState {
  bool showcaseActive;
  bool showcaseAlreadyPlayed;

  ShowcaseState({
    required this.showcaseActive,
    required this.showcaseAlreadyPlayed,
  });

  ShowcaseState copyWith({
    bool? showcaseActive,
    bool? showcaseAlreadyPlayed,
  }) =>
      ShowcaseState(
        showcaseActive: showcaseActive ?? this.showcaseActive,
        showcaseAlreadyPlayed:
            showcaseAlreadyPlayed ?? this.showcaseAlreadyPlayed,
      );
}

class ShowcaseCubit extends Cubit<ShowcaseState> {
  final GlobalKey rootKey = GlobalKey();
  final GlobalKey showInfoKey = GlobalKey();
  final GlobalKey scanningStateKey = GlobalKey();
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey mapKey = GlobalKey();
  final GlobalKey mapToolbarKey = GlobalKey();
  final GlobalKey droneDetailPanelKey = GlobalKey();
  final GlobalKey droneDetailMoreKey = GlobalKey();
  final GlobalKey droneListKey = GlobalKey();
  final GlobalKey droneListSortKey = GlobalKey();
  final GlobalKey droneListFilterKey = GlobalKey();
  final GlobalKey droneListItemKey = GlobalKey();
  final GlobalKey aboutPageKey = GlobalKey();
  final GlobalKey standardsKey = GlobalKey();
  final GlobalKey permissionsKey = GlobalKey();
  final GlobalKey cleaningPacksKey = GlobalKey();
  final GlobalKey lastKey = GlobalKey();

  final String rootDescription =
      'A quick tutorial will guide you through the features of this application step by step.';
  final String showInfoDescription =
      'Show additional information and settings.';
  final String scanningStateDescription =
      'Icons show which technology is currently used for scanning.\nTap to start and stop scans.';
  final String searchDescription = 'Use the bar to search for locations.';
  final String mapDescription =
      'Pan, zoom and rotate map with touch gestures, tap on aircraft or zone to highlight.';
  final String mapToolbarDescription =
      'Use the map toolbar to center on your position, change zoom or switch to satellite map';
  final String droneDetailPanelDescription =
      'After tap on item on list or selecting aircraft from map, see detailed Aircraft information.\nAll the data acquired will be shown here.';
  final String droneDetailMoreDescription =
      'More options are accessible in the menu. Export, share, delete data or lock map center to aircraft.';
  final String droneListDescription =
      'Detected aircraft and zones are displayed in a list. Slide panel upwards to maximize.';
  final String droneListFilterDescription =
      'Use filter to show aircraft, zones or both.';
  final String droneListSortDescription =
      'Sort aircraft according to last update time or distance from you.';
  final String droneListItemDescription =
      'Card shows basic aircaft information. Tap for details.';
  final String lastDescription =
      'Your can replay this showcase from the About page. Enjoy!';

  ShowcaseCubit()
      : super(
          ShowcaseState(showcaseActive: false, showcaseAlreadyPlayed: false),
        );

  List<GlobalKey> get keys {
    return [
      rootKey,
      mapKey,
      searchKey,
      scanningStateKey,
      showInfoKey,
      mapToolbarKey,
      droneListKey,
      droneListItemKey,
      // to-do: uncomment when zones are back
      //droneListFilterKey,
      droneListSortKey,
      droneDetailPanelKey,
      droneDetailMoreKey,
      lastKey,
    ];
  }

  Future<bool> displayShowcase() async {
    final preferences = await SharedPreferences.getInstance();
    final showcasePlayed = preferences.getBool('showcasePlayed');
    if (showcasePlayed == null || !showcasePlayed) {
      await preferences.setBool('showcasePlayed', true);
      emit(state.copyWith(showcaseAlreadyPlayed: true));
      return true;
    }
    return false;
  }

  Future<void> restartShowcase() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('showcasePlayed', false);
    emit(state.copyWith(showcaseActive: true));
  }

  Future<void> setShowcaseActive({
    required BuildContext context,
    required bool active,
  }) async {
    // if dismissing showcase, restart scans and recover state
    if (!active) {
      await context
          .read<AircraftCubit>()
          .removeShowcaseDummyPack()
          .then((value) {
        context.read<AircraftCubit>().applyCachedState();
        context.read<OpendroneIdCubit>().start();
      });
    }
    emit(state.copyWith(showcaseActive: active));
  }

  void startShowcase(BuildContext context) {
    // if showcasing, add dumy data
    context.read<OpendroneIdCubit>().stop().then((value) {
      context
          .read<AircraftCubit>()
          .clear()
          .then((value) => _startShowcaseRoutine(context));
      emit(state.copyWith(showcaseActive: true));
    });
  }

  void _startShowcaseRoutine(BuildContext context) {
    context.read<AircraftCubit>().cacheCurrentState();
    context.read<SlidersCubit>().setShowDroneDetail(show: false);
    context.read<AircraftCubit>().addShowcaseDummyPack();
    context.read<SlidersCubit>().panelController.animatePanelToSnapPoint();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context)?.startShowCase(keys),
    );
  }

  void onShowcaseFinish(BuildContext context) {
    context.read<AircraftCubit>().removeShowcaseDummyPack();
    context.read<AircraftCubit>().applyCachedState();
    context.read<OpendroneIdCubit>().start();
    emit(state.copyWith(showcaseActive: false));
  }

  void onKeyComplete(
    BuildContext context,
    int? index,
    GlobalKey<State<StatefulWidget>> key,
  ) {
    if (key == lastKey) {
      context.read<SelectedAircraftCubit>().unselectAircraft();
      context.read<SlidersCubit>().setShowDroneDetail(show: false);
    }
    if (key == droneDetailMoreKey) {
      context.read<SlidersCubit>().panelController.animatePanelToSnapPoint();
    }
  }

  void onKeyStart(
    BuildContext context,
    int? index,
    GlobalKey<State<StatefulWidget>> key,
  ) {
    if (key == droneDetailPanelKey) {
      context
          .read<SelectedAircraftCubit>()
          .selectAircraft(context.read<AircraftCubit>().showcaseDummyMac);
      context.read<SlidersCubit>().setShowDroneDetail(show: true);
    }
    if (key == aboutPageKey) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PreferencesPage()),
      );
    }
    if (key == droneListItemKey) {
      context.read<SlidersCubit>().setShowDroneDetail(show: false);
      context.read<SlidersCubit>().openSlider();
    }
    if (key == droneDetailPanelKey) {
      context.read<SlidersCubit>().setShowDroneDetail(show: true);
      context.read<SlidersCubit>().openSlider();
    }
  }
}
