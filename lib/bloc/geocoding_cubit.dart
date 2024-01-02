import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import '../models/place_details.dart';
import '../services/geocoding_rest_client.dart';

class GeocodingState {
  final List<PlaceDetails>? results;
  final Object? error;
  final bool isLoading;

  GeocodingState.initial()
      : error = null,
        results = null,
        isLoading = false;

  GeocodingState.failed(
    Object err,
  )   : error = err,
        results = null,
        isLoading = false;

  GeocodingState.loading()
      : error = null,
        results = null,
        isLoading = true;

  GeocodingState.loaded(
    List<PlaceDetails> loadedItems,
  )   : error = null,
        results = loadedItems,
        isLoading = false;
}

class GeocodingCubit extends Cubit<GeocodingState> {
  final GeocodingRestClient geocodingRestClient;

  GeocodingCubit({required this.geocodingRestClient})
      : super(GeocodingState.initial());

  Future<void> autocomplete({required String input}) async {
    try {
      emit(GeocodingState.loading());
      final res = await geocodingRestClient.autocomplete(query: input);
      emit(GeocodingState.loaded(res));
    } on ClientException catch (error) {
      emit(GeocodingState.failed(error));
    }
  }

  void clearResults() => emit(GeocodingState.initial());
}
