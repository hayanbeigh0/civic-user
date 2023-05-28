import 'dart:async';
import 'dart:developer';

import 'package:civic_user/logic/cubits/reverse_geocoding/reverse_geocoding_cubit.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/widgets/primary_display_field.dart';
import 'package:civic_user/widgets/primary_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// class LocationMapField extends StatelessWidget {
//   LocationMapField({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//     required this.mapController,
//     this.zoomEnabled = false,
//     this.myLocationEnabled = true,
//     this.gesturesEnabled = true,
//     this.markerEnabled = false,
//     this.mapEnabled = true,
//   });

//   final double latitude;
//   final double longitude;
//   final Completer<GoogleMapController> mapController;
//   late LatLng pickedLoc;
//   final bool zoomEnabled;
//   final bool myLocationEnabled;
//   final bool gesturesEnabled;
//   final bool markerEnabled;
//   final bool mapEnabled;

//   @override
//   Widget build(BuildContext context) {
//     pickedLoc = LatLng(latitude, longitude);
//     return Column(
//       children: [
//         mapEnabled
//             ? Container(
//                 height: 180.h,
//                 clipBehavior: Clip.antiAlias,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.r),
//                   color: AppColors.colorPrimaryLight,
//                 ),
//                 width: double.infinity,
//                 child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10.r),
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: LatLng(
//                           latitude,
//                           longitude,
//                         ),
//                         zoom: 14.4746,
//                       ),
//                       zoomControlsEnabled: zoomEnabled,
//                       scrollGesturesEnabled: gesturesEnabled,
//                       gestureRecognizers: <
//                           Factory<OneSequenceGestureRecognizer>>{
//                         Factory<OneSequenceGestureRecognizer>(
//                           () => EagerGestureRecognizer(),
//                         ),
//                       },
//                       markers: markerEnabled
//                           ? {
//                               Marker(
//                                 markerId: const MarkerId('1'),
//                                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                                   BitmapDescriptor.hueBlue,
//                                 ),
//                                 position: LatLng(latitude, longitude),
//                               ),
//                             }
//                           : {},
//                       myLocationEnabled: myLocationEnabled,
//                       myLocationButtonEnabled: myLocationEnabled,
//                       onMapCreated: (controller) async {
//                         mapController.complete(controller);
//                         BlocProvider.of<ReverseGeocodingCubit>(context)
//                             .loadReverseGeocodedAddress(
//                           latitude,
//                           longitude,
//                         );
//                       },
//                       onCameraIdle: () async {
//                         BlocProvider.of<ReverseGeocodingCubit>(context)
//                             .loadReverseGeocodedAddress(
//                           pickedLoc.latitude,
//                           pickedLoc.longitude,
//                         );
//                       },
//                       onCameraMove: (position) async {
//                         pickedLoc = position.target;
//                       },
//                       mapType: MapType.terrain,
//                     )),
//               )
//             : const SizedBox(),
//         SizedBox(
//           height: 15.h,
//         ),
//         BlocBuilder<ReverseGeocodingCubit, ReverseGeocodingState>(
//           builder: (context, state) {
//             if (state is ReverseGeocodingLoaded) {
//             // print('Street: ${state.street}\n');
//             // print('Sub-Locality: ${state.subLocality}\n');
//             // print('Locality: ${state.locality}\n');
//             // print('Postal Code: ${state.postalCode}');
//             // print('Administrative Area: ${state.administrativeArea}');
//             // print('Country Name: ${state.countryName}\n');
//               return Column(
//                 children: [
//                   PrimaryDisplayField(
//                     title: '',
//                     value: '${state.street}, ${state.subLocality}',
//                   ),
//                   SizedBox(
//                     height: 12.h,
//                   ),
//                   PrimaryDisplayField(
//                     title: '',
//                     value: '${state.locality} ${state.postalCode}',
//                   ),
//                   SizedBox(
//                     height: 12.h,
//                   ),
//                   PrimaryDisplayField(
//                     title: '',
//                     value: '${state.administrativeArea}, ${state.countryName}',
//                   ),
//                 ],
//               );
//             }
//             return Column(
//               children: [
//                 const PrimaryDisplayField(title: '', value: ''),
//                 SizedBox(
//                   height: 12.h,
//                 ),
//                 const PrimaryDisplayField(
//                   title: '',
//                   value: '',
//                 ),
//                 SizedBox(
//                   height: 12.h,
//                 ),
//                 const PrimaryDisplayField(title: '', value: ''),

//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

class LocationMapField extends StatelessWidget {
  LocationMapField({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.mapController,
    this.zoomEnabled = false,
    this.myLocationEnabled = true,
    this.gesturesEnabled = true,
    this.markerEnabled = false,
    this.textFieldsEnabled = false,
    this.addressFieldValidator,
    this.countryFieldValidator,
    this.address,
    this.mapEnabled = true,
  });

  final double latitude;
  final double longitude;
  final Completer<GoogleMapController> mapController;
  static late LatLng pickedLoc;
  final bool zoomEnabled;
  final bool myLocationEnabled;
  final bool gesturesEnabled;
  final bool markerEnabled;
  final bool textFieldsEnabled;
  final bool mapEnabled;
  final String? Function(String?)? addressFieldValidator;
  final String? Function(String?)? countryFieldValidator;
  static final TextEditingController addressLine1Controller =
      TextEditingController();
  static final TextEditingController addressLine2Controller =
      TextEditingController();
  String? address;

  @override
  Widget build(BuildContext context) {
    pickedLoc = LatLng(latitude, longitude);
    return Column(
      children: [
        Visibility(
          visible: mapEnabled,
          replacement: const SizedBox(),
          child: Container(
            height: 180.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.colorPrimaryLight,
            ),
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    latitude,
                    longitude,
                  ),
                  zoom: 14.4746,
                ),
                zoomControlsEnabled: zoomEnabled,
                scrollGesturesEnabled: gesturesEnabled,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                markers: markerEnabled
                    ? {
                        Marker(
                          markerId: const MarkerId('1'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          ),
                          position: LatLng(latitude, longitude),
                        ),
                      }
                    : {},
                myLocationEnabled: myLocationEnabled,
                myLocationButtonEnabled: myLocationEnabled,
                onMapCreated: (controller) async {
                  mapController.complete(controller);
                  BlocProvider.of<ReverseGeocodingCubit>(context)
                      .loadReverseGeocodedAddress(
                    latitude,
                    longitude,
                  );
                },
                onCameraIdle: () async {
                  BlocProvider.of<ReverseGeocodingCubit>(context)
                      .loadReverseGeocodedAddress(
                    pickedLoc.latitude,
                    pickedLoc.longitude,
                  );
                },
                onCameraMove: (position) async {
                  pickedLoc = position.target;
                  address = null;
                },
                mapType: MapType.terrain,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        BlocConsumer<ReverseGeocodingCubit, ReverseGeocodingState>(
          buildWhen: (previous, current) => previous != current,
          listener: (context, state) {
            if (state is ReverseGeocodingLoaded) {
              if (address == null) {
                addressLine1Controller.text =
                    '${state.street}, ${state.locality}';
                addressLine2Controller.text = state.countryName;
              }
              if (address != null) {
                log('Address loaded without getting it from location');
                int lastCommaIndex = address!.lastIndexOf(", ");
                addressLine1Controller.text =
                    address!.substring(0, lastCommaIndex);
                addressLine2Controller.text =
                    address!.substring(lastCommaIndex + 2);
              }
            }
            log('${addressLine1Controller.text}, ${addressLine2Controller.text}');
          },
          builder: (context, state) {
            if (state is ReverseGeocodingLoaded) {
              // if (address == null) {
              //   addressLine1Controller.text =
              //       '${state.street}, ${state.locality}';
              //   addressLine2Controller.text = state.countryName;
              // }
              // if (address != null) {
              //   log('Address loaded without getting it from location');
              //   int lastCommaIndex = address!.lastIndexOf(", ");
              //   addressLine1Controller.text =
              //       address!.substring(0, lastCommaIndex);
              //   addressLine2Controller.text =
              //       address!.substring(lastCommaIndex + 2);
              // }
              // log('${addressLine1Controller.text}, ${addressLine2Controller.text}');

              return Column(
                children: [
                  PrimaryTextField(
                    fieldValidator: addressFieldValidator,
                    enabled: textFieldsEnabled,
                    hintText: 'Address',
                    textEditingController: addressLine1Controller,
                    title: '',
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  PrimaryTextField(
                    fieldValidator: countryFieldValidator,
                    enabled: textFieldsEnabled,
                    hintText: 'Country',
                    textEditingController: addressLine2Controller,
                    title: '',
                  ),
                ],
              );
            }
            return Column(
              children: [
                const PrimaryDisplayField(title: '', value: ''),
                SizedBox(
                  height: 12.h,
                ),
                const PrimaryDisplayField(
                  title: '',
                  value: '',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
