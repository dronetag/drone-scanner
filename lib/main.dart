import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/aircraft/aircraft_cubit.dart';
import 'bloc/aircraft/selected_aircraft_cubit.dart';
import 'bloc/map/map_cubit.dart';
import 'bloc/opendroneid_cubit.dart';
import 'bloc/screen_cubit.dart';
import 'bloc/showcase_cubit.dart';
import 'bloc/sliders_cubit.dart';
import 'bloc/standards_cubit.dart';
import 'bloc/zones/selected_zone_cubit.dart';
import 'bloc/zones/zones_cubit.dart';
import 'services/location_service.dart';
import 'utils/google_api_key_reader.dart';
import 'utils/uasid_prefix_reader.dart';
import 'widgets/app/app.dart';

void main() async {
  // init high priority services
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Google services
  await GoogleApiKeyReader.initialize();
  await UASIDPrefixReader.initialize();
  final locationService = LocationService();
  final mapCubit = MapCubit(locationService);
  final selectedCubit = SelectedAircraftCubit();
  final aircraftCubit = AircraftCubit();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<StandardsCubit>(
          create: (context) => StandardsCubit(),
          lazy: false,
        ),
        BlocProvider<ScreenCubit>(
          create: (context) => ScreenCubit(),
          lazy: false,
        ),
        BlocProvider<SlidersCubit>(
          create: (context) => SlidersCubit(),
          lazy: false,
        ),
        BlocProvider<MapCubit>(
          create: (context) => mapCubit,
          lazy: false,
        ),
        BlocProvider<ShowcaseCubit>(
          create: (context) => ShowcaseCubit(),
          lazy: false,
        ),
        BlocProvider<ZonesCubit>(
          create: (context) => ZonesCubit(),
          lazy: false,
        ),
        BlocProvider<SelectedZoneCubit>(
          create: (context) => SelectedZoneCubit(),
          lazy: false,
        ),
        BlocProvider<AircraftCubit>(
          create: (context) => aircraftCubit,
          lazy: false,
        ),
        BlocProvider<SelectedAircraftCubit>(
          create: (context) => selectedCubit,
          lazy: false,
        ),
        BlocProvider<OpendroneIdCubit>(
          create: (context) => OpendroneIdCubit(
            mapCubit: mapCubit,
            selectedAircraftCubit: selectedCubit,
            aircraftCubit: aircraftCubit,
          ),
          lazy: false,
        ),
      ],
      child: App(),
    ),
  );
}
