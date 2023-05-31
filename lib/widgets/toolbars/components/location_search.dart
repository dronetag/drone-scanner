import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class LocationSearch extends StatelessWidget {
  const LocationSearch({Key? key}) : super(key: key);

  Future<List<SearchInfo>> suggest(String input) async {
    return await addressSuggestion(input);
  }

  void applyFoundLocation(BuildContext context, LatLng location) async {
    await context.read<MapCubit>().centerToLoc(location);
    await context.read<MapCubit>().setDroppedPinLocation(location);
    await context.read<MapCubit>().setDroppedPin(pinDropped: true);
    if (context.read<SlidersCubit>().isPanelOpened()) {
      await context.read<SlidersCubit>().animatePanelToSnapPoint();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    final hintStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.lightGray,
      fontWeight: FontWeight.w600,
    );
    final suggestionStyle = const TextStyle(
      fontSize: 14,
    );
    return Container(
      child: Autocomplete<SearchInfo>(
        optionsBuilder: (textEditingValue) async {
          return await suggest(textEditingValue.text);
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: Container(
                width: MediaQuery.of(context).size.width -
                    2 * Sizes.toolbarMargin -
                    2 * Sizes.mapContentMargin,
                height: MediaQuery.of(context).size.height / 2,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        title: Text(
                          option.address.toString(),
                          style: suggestionStyle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        displayStringForOption: (option) => option.address.toString(),
        onSelected: (option) {
          // unfocus text field
          FocusManager.instance.primaryFocus?.unfocus();
          if (option.point != null) {
            applyFoundLocation(
              context,
              LatLng(option.point!.latitude, option.point!.longitude),
            );
          }
        },
        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) =>
                TextField(
          controller: textEditingController,
          textAlignVertical: TextAlignVertical.center,
          focusNode: focusNode,
          autocorrect: false,
          cursorColor: Colors.white,
          onTap: () {
            if (context.read<SlidersCubit>().isPanelOpened()) {
              context.read<SlidersCubit>().animatePanelToSnapPoint();
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: 'Search Locations',
            hintStyle: hintStyle,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.transparent,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          style: style,
        ),
      ),
    );
  }
}
