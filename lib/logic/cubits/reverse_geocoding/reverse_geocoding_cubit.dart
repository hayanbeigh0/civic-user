import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';

part 'reverse_geocoding_state.dart';

class ReverseGeocodingCubit extends Cubit<ReverseGeocodingState> {
  ReverseGeocodingCubit() : super(ReverseGeocodingLoading());
  List<Placemark> placemarks = [];
  Future<void> loadReverseGeocodedAddress(
    double latitude,
    double longitude,
  ) async {
    emit(ReverseGeocodingLoading());
    placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    emit(
      ReverseGeocodingLoaded(
        countryName: placemarks[0].country.toString(),
        name: placemarks[0].name.toString(),
        street: placemarks[0].street.toString(),
        administrativeArea: placemarks[0].administrativeArea.toString(),
        subAdministrativeArea: placemarks[0].subAdministrativeArea.toString(),
        subLocality: placemarks[0].subLocality.toString(),
        locality: placemarks[0].locality.toString(),
        postalCode: placemarks[0].postalCode.toString(),
        latitude: latitude.toString(),
        longitude: longitude.toString(),
      ),
    );
  }
}
