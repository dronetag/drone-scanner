import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/showcase_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../utils/google_api_key_reader.dart';
import '../../showcase/showcase_item.dart';

class LocationSearch extends StatefulWidget {
  const LocationSearch({Key? key}) : super(key: key);

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  String? googleApikey = GoogleApiKeyReader.getApiKey();
  String location = 'Search Locations';
  String? locationCache;

  Future<void> onTapHandle() async {
    final place = await PlacesAutocomplete.show(
      startText: locationCache ?? '',
      context: context,
      apiKey: googleApikey,
      types: [],
      strictbounds: false,
    );

    if (place != null) {
      //form google_maps_webservice package
      final plist = GoogleMapsPlaces(
        apiKey: googleApikey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
        //from google_api_headers package
      );
      final placeid = place.placeId ?? '0';
      final detail = await plist.getDetailsByPlaceId(placeid);
      final geometry = detail.result.geometry!;
      final lat = geometry.location.lat;
      final lang = geometry.location.lng;
      final newlatlang = LatLng(lat, lang);
      if (!mounted) return;
      await context.read<MapCubit>().centerToLoc(newlatlang);
      if (!mounted) return;
      await context.read<MapCubit>().setDroppedPinLocation(newlatlang);
      if (!mounted) return;
      await context.read<MapCubit>().setDroppedPin(pinDropped: true);
      if (!mounted) return;
      if (context.read<SlidersCubit>().panelController.isPanelOpen) {
        await context
            .read<SlidersCubit>()
            .panelController
            .animatePanelToSnapPoint();
      }
      setState(() {
        location = place.description.toString();
        locationCache = place.description.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<MapCubit>().state.droppedPin) {
      location = 'Search Locations';
    }
    return InkWell(
      onTap: onTapHandle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Center(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 0,
            title: Text(
              location,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            dense: true,
          ),
        ),
      ),
    );
  }
}
