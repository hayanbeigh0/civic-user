// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'reverse_geocoding_cubit.dart';

abstract class ReverseGeocodingState extends Equatable {
  const ReverseGeocodingState();
}

class ReverseGeocodingLoading extends ReverseGeocodingState {
  @override
  List<Object?> get props => [];
}

class ReverseGeocodingLoaded extends ReverseGeocodingState {
  final String name;
  final String countryName;
  final String locality;
  final String administrativeArea;
  final String subAdministrativeArea;
  final String subLocality;
  final String street;
  final String postalCode;
  final String latitude;
  final String longitude;
  const ReverseGeocodingLoaded({
    required this.name,
    required this.countryName,
    required this.locality,
    required this.street,
    required this.administrativeArea,
    required this.subAdministrativeArea,
    required this.subLocality,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [name, countryName, street, locality, administrativeArea, subAdministrativeArea, subLocality, postalCode];
}

class ReverseGeocodingLoadingError extends ReverseGeocodingState {
  @override
  List<Object?> get props => [];
}
