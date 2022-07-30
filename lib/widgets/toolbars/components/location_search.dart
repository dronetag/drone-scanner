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
  String location = 'Search Location';
  String? locationCache;

  @override
  Widget build(BuildContext context) {
    if (!context.watch<MapCubit>().state.droppedPin) {
      location = 'Search Location';
    }
    return ShowcaseItem(
      showcaseKey: context.read<ShowcaseCubit>().searchKey,
      description: context.read<ShowcaseCubit>().searchDescription,
      title: 'Map Toolbar',
      child: InkWell(
        onTap: () async {
          final place = await PlacesAutocomplete.show(
            startText: locationCache ?? '',
            hint: 'Search',
            context: context,
            apiKey: googleApikey,
            mode: Mode.fullscreen,
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
            var newlatlang = LatLng(lat, lang);

            await context.read<MapCubit>().centerToLoc(newlatlang);
            await context.read<MapCubit>().setDroppedPinLocation(newlatlang);
            await context.read<MapCubit>().setDroppedPin(pinDropped: true);
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
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Center(
            child: ListTile(
              title: Text(
                location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              leading: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              dense: true,
            ),
          ),
        ),
      ),
    );
  }
}
