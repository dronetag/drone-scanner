import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../bloc/geocoding_cubit.dart';
import '../../../bloc/map/map_cubit.dart';
import '../../../bloc/sliders_cubit.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../models/place_details.dart';
import '../../app/dialogs.dart';

class LocationSearch extends StatefulWidget {
  const LocationSearch({super.key});

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  static const Duration _submitDelayDuration = Duration(milliseconds: 1200);

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Timer? querySubmitDelay;
  OverlayEntry? resultsOverlay;
  StreamSubscription? geocodingCubitSubscription;

  @override
  void initState() {
    geocodingCubitSubscription =
        context.read<GeocodingCubit>().stream.listen(_refreshOverlay);
    focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    querySubmitDelay?.cancel();
    resultsOverlay?.remove();
    focusNode.dispose();
    geocodingCubitSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      textAlignVertical: TextAlignVertical.center,
      focusNode: focusNode,
      autocorrect: false,
      cursorColor: Colors.white,
      onTap: () {
        if (context.read<SlidersCubit>().isPanelOpened) {
          context.read<SlidersCubit>().animatePanelToSnapPoint();
        }
        _autocomplete(context, textEditingController.text);
      },
      onChanged: (text) => _autocomplete(context, text),
      onSubmitted: (_) {
        final state = context.read<GeocodingCubit>().state;
        final results = state.results;
        // continue loading if currently loading
        if ((querySubmitDelay != null && querySubmitDelay!.isActive) ||
            state.isLoading) {
          return;
        }
        // use first suggestion if available
        else if (results != null && results.isNotEmpty) {
          _selectResult(results.first);
        } else {
          querySubmitDelay?.cancel();
          _disposeOverlayEntry(context);
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
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.lightGray,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.transparent,
        prefixIcon: _buildPrefixIcon(context),
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  OverlayEntry _buildOverlayEntry(List<PlaceDetails> autocompleteResult) =>
      OverlayEntry(
        builder: (context) {
          return Positioned(
            top: MediaQuery.of(context).viewPadding.top +
                Sizes.mapContentMargin +
                Sizes.toolbarHeight,
            left: Sizes.mapContentMargin,
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.standard)),
              elevation: 2.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2,
                    maxWidth: MediaQuery.of(context).size.width -
                        2 * Sizes.mapContentMargin),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: autocompleteResult.length,
                  separatorBuilder: (context, index) => const Divider(
                    indent: 0,
                    endIndent: 0,
                    height: Sizes.half,
                  ),
                  itemBuilder: (context, index) {
                    final option = autocompleteResult.elementAt(index);
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.all(Sizes.standard),
                      onTap: () => _selectResult(option),
                      title: Text(
                        option.address ?? 'Uknown address',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );

  Widget _buildPrefixIcon(BuildContext context) {
    if (context.watch<GeocodingCubit>().state.isLoading ||
        (querySubmitDelay != null && querySubmitDelay!.isActive)) {
      return Container(
        padding: const EdgeInsets.all(Sizes.standard * 2),
        width: Sizes.iconSize,
        height: Sizes.iconSize,
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.0,
        ),
      );
    } else if ((focusNode.hasFocus && textEditingController.text.isNotEmpty) ||
        (resultsOverlay != null && resultsOverlay!.mounted)) {
      return IconButton(
        onPressed: () {
          querySubmitDelay?.cancel();
          _disposeOverlayEntry(context);
          setState(textEditingController.clear);
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      );
    }
    return const Icon(
      Icons.search,
      color: Colors.white,
    );
  }

  void _selectResult(PlaceDetails result) {
    if (result.address != null) {
      textEditingController.text = result.address!;
    }

    if (result.hasValidLocation) {
      _applyFoundLocation(
        context,
        LatLng(result.latitude!, result.longitude!),
      );
    }
    focusNode.unfocus();
    resultsOverlay?.remove();
  }

  Future<void> _autocomplete(BuildContext context, String input) async {
    // require at least 3 characters
    if (input.length < 3) {
      _disposeOverlayEntry(context);
      return;
    }

    if (querySubmitDelay != null) {
      querySubmitDelay?.cancel();
    }
    setState(() {
      querySubmitDelay = Timer(
        _submitDelayDuration,
        () => context.read<GeocodingCubit>().autocomplete(input: input),
      );
    });
  }

  void _applyFoundLocation(BuildContext context, LatLng location) async {
    final mapCubit = context.read<MapCubit>();
    final slidersCubit = context.read<SlidersCubit>();
    await mapCubit.centerToLoc(location);
    await mapCubit.setDroppedPinLocation(location);
    await mapCubit.setDroppedPin(pinDropped: true);
    if (slidersCubit.isPanelOpened) {
      await slidersCubit.animatePanelToSnapPoint();
    }
  }

  void _refreshOverlay(GeocodingState state) {
    _disposeOverlayEntry(context);

    final autocompleteResult = state.results;
    resultsOverlay = autocompleteResult == null || autocompleteResult.isEmpty
        ? null
        : _buildOverlayEntry(autocompleteResult);

    if (resultsOverlay != null) {
      Overlay.of(context).insert(resultsOverlay!);
    } else if (autocompleteResult != null && autocompleteResult.isEmpty) {
      showSnackBar(context, 'No locations found.');
    } else if (state.error != null) {
      showSnackBar(
          context,
          'Failed to search for location.'
          ' Please check your internet connection.');
    }
  }

  void _disposeOverlayEntry(BuildContext context) {
    if (Overlay.of(context).mounted &&
        resultsOverlay != null &&
        resultsOverlay!.mounted) {
      resultsOverlay!.remove();
      resultsOverlay!.dispose();
      resultsOverlay = null;
      context.read<GeocodingCubit>().clearResults();
    }
  }
}
