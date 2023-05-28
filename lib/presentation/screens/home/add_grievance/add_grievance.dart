import 'dart:convert';

import 'package:civic_user/logic/blocs/grievances/grievances_bloc.dart';
import 'package:civic_user/logic/cubits/authentication/authentication_cubit.dart';
import 'package:civic_user/main.dart';
import 'package:civic_user/models/grievances/grievance_detail.dart';
import 'package:civic_user/models/grievances/grievances_model.dart';
import 'package:civic_user/presentation/utils/functions/get_temporary_directory.dart';
import 'package:civic_user/presentation/utils/functions/snackbars.dart';
import 'package:civic_user/resources/repositories/grievances/grievances_repository.dart';
import 'package:civic_user/widgets/audio_comment_widget.dart';
import 'package:civic_user/widgets/video_widget.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:civic_user/generated/locale_keys.g.dart';
import 'package:civic_user/logic/cubits/current_location/current_location_cubit.dart';
import 'package:civic_user/logic/cubits/my_profile/my_profile_cubit.dart';
import 'package:civic_user/logic/cubits/reverse_geocoding/reverse_geocoding_cubit.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/presentation/utils/functions/image_and_video_compress.dart';
import 'package:civic_user/presentation/utils/styles/app_styles.dart';
import 'package:civic_user/widgets/display_title_text.dart';
import 'package:civic_user/widgets/location_map_field.dart';
import 'package:civic_user/widgets/primary_button.dart';
import 'package:civic_user/widgets/primary_text_field.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:civic_user/widgets/progress_dialog_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../constants/env_variable.dart';
import '../../../../logic/cubits/cubit/local_storage_cubit.dart';
import '../grievances/grievance_detail/grievance_detail.dart';

class AddGrievance extends StatefulWidget {
  static const routeName = '/addGrievance';
  const AddGrievance({super.key});

  @override
  State<AddGrievance> createState() => _AddGrievanceState();
}

class _AddGrievanceState extends State<AddGrievance> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController newHouseAddressController =
      TextEditingController();
  final TextEditingController newHousePlanDetailsController =
      TextEditingController();
  final TextEditingController deceasedNameController = TextEditingController();
  final TextEditingController relationWithDeceasedController =
      TextEditingController();
  String? dropdownValue;
  List<String> grievanceTypes = [
    'Electricity',
    'Garbage Collection',
    'Certificate request',
    'House plan approval',
    'Street Lighting',
    'Road maintenance / Construction',
    'Water supply / drainage',
    'Others',
  ];
  final Map<String, String> grievanceTypesMap = {
    "garb": LocaleKeys.grievanceDetail_garb.tr(),
    "road": LocaleKeys.grievanceDetail_road.tr(),
    "light": LocaleKeys.grievanceDetail_light.tr(),
    "cert": LocaleKeys.grievanceDetail_cert.tr(),
    "house": LocaleKeys.grievanceDetail_house.tr(),
    "water": LocaleKeys.grievanceDetail_water.tr(),
    "elect": LocaleKeys.grievanceDetail_elect.tr(),
    "other": LocaleKeys.grievanceDetail_otherGrievanceType.tr(),
  };
  List<String?> imageLinks = [];
  List<String?> videoLinks = [];
  List<String?> audioLinks = [];
  bool showDropdownError = false;
  bool pickLocation = false;
  bool useCurrentLocation = true;
  bool contactMeByPhone = true;
  List<XFile> images = [];
  List<XFile> videos = [];
  List<XFile> audios = [];
  final recorder = FlutterSoundRecorder();
  List<Uint8List?> thumbnailBytes = [];
  int? videoSize;
  List<MediaInfo?> compressVideoInfo = [];
  final Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription audioDurationSubscription;

  @override
  void initState() {
    BlocProvider.of<LocalStorageCubit>(context).getUserDataFromLocalStorage();
    BlocProvider.of<CurrentLocationCubit>(context).getCurrentLocation();
    BlocProvider.of<MyProfileCubit>(context).getMyProfile(
        AuthBasedRouting.afterLogin.userDetails!.userID.toString());
    initAudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  String getAcronym(String grievanceType) {
    switch (grievanceType) {
      case 'Electricity':
        return 'ELECT';
      case 'Garbage Collection':
        return 'GARB';
      case 'Certificate request':
        return 'CERT';
      case 'House plan approval':
        return 'HOUSE';
      case 'Street Lighting':
        return 'LIGHT';
      case 'Road maintenance / Construction':
        return 'ROAD';
      case 'Water supply / drainage':
        return 'WATER';
      case 'Others':
        return 'OTHER';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GrievancesBloc, GrievancesState>(
      listener: (context, assetState) {
        if (assetState is AddingGrievanceImageAssetSuccessState) {
          log('Adding image to s3 done');
          SnackBars.sucessMessageSnackbar(
              context, LocaleKeys.addGrievance_addedImage.tr());
          var imageLink = assetState.s3uploadResult.uploadResult!.key1;
          imageLinks.add('$CLOUDFRONT_URL/$imageLink');
        }
        if (assetState is AddingGrievanceVideoAssetSuccessState) {
          log('Adding video to s3 done');
          SnackBars.sucessMessageSnackbar(
              context, LocaleKeys.addGrievance_addedVideo.tr());
          var videoLink = assetState.s3uploadResult.uploadResult!.key1;
          videoLinks.add('$CLOUDFRONT_URL/$videoLink');
        }
        if (assetState is AddingGrievanceImageAssetState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                LocaleKeys.addGrievance_addingImage.tr(),
                style: const TextStyle(
                  color: AppColors.colorWhite,
                ),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (assetState is AddingGrievanceVideoAssetState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                LocaleKeys.addGrievance_addingVideo.tr(),
                style: const TextStyle(
                  color: AppColors.colorWhite,
                ),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (assetState is AddingGrievanceImageAssetFailedState) {
          SnackBars.errorMessageSnackbar(
              context, LocaleKeys.addGrievance_addingImageFailed.tr());
        }
        if (assetState is AddingGrievanceVideoAssetFailedState) {
          SnackBars.errorMessageSnackbar(
              context, LocaleKeys.addGrievance_addingVideoFailed.tr());
        }
        if (assetState is AddingGrievanceAudioAssetSuccessState) {
          log('Adding audio to s3 done');
          SnackBars.sucessMessageSnackbar(
              context, LocaleKeys.addGrievance_addedAudio.tr());
          var audioLink = assetState.s3uploadResult.uploadResult!.key1;
          audioLinks.add('$CLOUDFRONT_URL/$audioLink');
          Navigator.of(context).pop();
        }
        if (assetState is AddingGrievanceAudioAssetState) {
          log("Trying to add audio");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                LocaleKeys.addGrievance_addingAudio.tr(),
                style: const TextStyle(
                  color: AppColors.colorWhite,
                ),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        if (assetState is AddingGrievanceAudioAssetFailedState) {
          log("Failed to add audio");
          audios.removeLast();
          SnackBars.errorMessageSnackbar(
              context, LocaleKeys.addGrievance_addingAudioFailed.tr());
        }
        if (assetState is GrievanceAddedState) {
          // SnackBars.sucessMessageSnackbar(
          //     context, LocaleKeys.addGrievance_addedGrievance.tr());
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Column(
            children: [
              PrimaryTopShape(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.0.w,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/arrowleft.svg',
                                    color: AppColors.colorWhite,
                                    height: 18.sp,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    LocaleKeys.addGrievance_addGrievance.tr(),
                                    style: AppStyles.screenTitleStyle,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60.h,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<LocalStorageCubit, LocalStorageState>(
                    builder: (context, authSuccessState) {
                  if (authSuccessState is LocalStorageFetchingDoneState) {
                    return BlocBuilder<CurrentLocationCubit,
                        CurrentLocationState>(
                      builder: (context, state) {
                        if (state is CurrentLocationLoaded) {
                          log('Current location: ${state.latitude} ${state.longitude}');
                          return SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 18.0.sp),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${LocaleKeys.addGrievance_grievanceType.tr()}*',
                                      style:
                                          AppStyles.inputAndDisplayTitleStyle,
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.colorPrimaryLight,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.sp),
                                      child: DropdownButtonFormField(
                                        isExpanded: true,
                                        iconSize: 24.sp,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                        hint: Text(
                                          LocaleKeys.addGrievance_grievanceType
                                              .tr(),
                                          style:
                                              AppStyles.dropdownHintTextStyle,
                                        ),
                                        decoration: InputDecoration(
                                          labelStyle:
                                              AppStyles.dropdownTextStyle,
                                          border: InputBorder.none,
                                        ),
                                        items: grievanceTypesMap.entries
                                            .map((entry) =>
                                                DropdownMenuItem<String>(
                                                  value: entry.key,
                                                  child: Text(
                                                    entry.value,
                                                    maxLines: 1,
                                                    style: AppStyles
                                                        .dropdownTextStyle,
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            dropdownValue = value.toString();
                                            showDropdownError = false;
                                          });
                                          print(dropdownValue);
                                        },
                                        validator: (value) =>
                                            validateGreivanceType(
                                          value.toString(),
                                        ),
                                      ),
                                    ),
                                    showDropdownError
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 16.w),
                                                child: Text(
                                                  LocaleKeys
                                                      .addGrievance_wardDropdownError
                                                      .tr(),
                                                  style:
                                                      AppStyles.errorTextStyle,
                                                ),
                                              )
                                            ],
                                          )
                                        : const SizedBox(),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    PrimaryTextField(
                                      title:
                                          '${LocaleKeys.addGrievance_description.tr()}*',
                                      hintText: LocaleKeys
                                          .addGrievance_descriptionText
                                          .tr(),
                                      textEditingController:
                                          descriptionController,
                                      maxLines: 8,
                                      fieldValidator: (value) =>
                                          descriptionValidator(
                                              value.toString()),
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    BlocConsumer<MyProfileCubit,
                                        MyProfileState>(
                                      listener: (context, state) {
                                        if (state is MyProfileLoaded) {
                                          log('running');

                                          contactNumberController.text =
                                              authSuccessState.afterLogin
                                                  .userDetails!.mobileNumber
                                                  .toString();
                                        }
                                      },
                                      builder: (context, state) {
                                        return PrimaryTextField(
                                          title:
                                              '${LocaleKeys.addGrievance_contact.tr()}*',
                                          hintText: '888 999 7777',
                                          textEditingController:
                                              contactNumberController,
                                          maxLines: 1,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                          fieldValidator: (value) =>
                                              validateMobileNumber(
                                                  value.toString()),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    dropdownValue == "house"
                                        ? Column(
                                            children: [
                                              PrimaryTextField(
                                                fieldValidator: (p0) =>
                                                    newHouseAddressValidator(
                                                        p0.toString()),
                                                maxLines: 4,
                                                title: 'New house address*',
                                                hintText:
                                                    'Enter the new house address here...',
                                                textEditingController:
                                                    newHouseAddressController,
                                              ),
                                              SizedBox(
                                                height: 12.h,
                                              ),
                                              PrimaryTextField(
                                                fieldValidator: (p0) =>
                                                    newHousePlanDetailsValidator(
                                                        p0.toString()),
                                                maxLines: 4,
                                                title: 'Plan details*',
                                                hintText:
                                                    'Enter your plan details here...',
                                                textEditingController:
                                                    newHousePlanDetailsController,
                                              ),
                                              SizedBox(
                                                height: 12.h,
                                              ),
                                            ],
                                          )
                                        : dropdownValue == "cert"
                                            ? Column(
                                                children: [
                                                  PrimaryTextField(
                                                    fieldValidator: (p0) =>
                                                        deceasedNameValidator(
                                                            p0.toString()),
                                                    title:
                                                        'Name of the deceased*',
                                                    hintText:
                                                        'Enter full name of the deceased here...',
                                                    textEditingController:
                                                        deceasedNameController,
                                                  ),
                                                  SizedBox(
                                                    height: 12.h,
                                                  ),
                                                  PrimaryTextField(
                                                    fieldValidator: (p0) =>
                                                        relationValidator(
                                                            p0.toString()),
                                                    title:
                                                        'Relation with the deceased*',
                                                    hintText:
                                                        'Enter your relation with the deceased here...',
                                                    textEditingController:
                                                        relationWithDeceasedController,
                                                  ),
                                                  SizedBox(
                                                    height: 12.h,
                                                  ),
                                                ],
                                              )
                                            : whenHousePlanAndCertNotSelected(
                                                context),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    SizedBox(
                                      height: 12.h,
                                    ),
                                    DisplayTitleText(
                                      title:
                                          LocaleKeys.addGrievance_location.tr(),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.colorPrimaryLight,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      padding: EdgeInsets.all(8.sp),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                BlocProvider.of<
                                                            ReverseGeocodingCubit>(
                                                        context)
                                                    .loadReverseGeocodedAddress(
                                                  state.latitude,
                                                  state.longitude,
                                                );
                                                setState(() {
                                                  useCurrentLocation = true;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 15.sp,
                                                  vertical: 5.sp,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.r),
                                                  color: useCurrentLocation
                                                      ? AppColors
                                                          .colorPrimary200
                                                      : Colors.transparent,
                                                ),
                                                child: Text(
                                                  LocaleKeys
                                                      .addGrievance_currentLocation
                                                      .tr(),
                                                  style: TextStyle(
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  useCurrentLocation = false;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 15.sp,
                                                  vertical: 5.sp,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.r),
                                                  color: useCurrentLocation
                                                      ? Colors.transparent
                                                      : AppColors
                                                          .colorPrimary200,
                                                ),
                                                child: Text(
                                                  LocaleKeys
                                                      .addGrievance_pickLocation
                                                      .tr(),
                                                  style: TextStyle(
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Stack(
                                      children: useCurrentLocation
                                          ? [
                                              LocationMapField(
                                                mapEnabled: !useCurrentLocation,
                                                textFieldsEnabled: true,
                                                gesturesEnabled: false,
                                                myLocationEnabled: false,
                                                zoomEnabled: false,
                                                mapController: _mapController,
                                                latitude: state.latitude,
                                                longitude: state.longitude,
                                                addressFieldValidator: (p0) =>
                                                    validateAddress(
                                                        p0.toString()),
                                                countryFieldValidator: (p0) =>
                                                    validateCountry(
                                                        p0.toString()),
                                              ),
                                              // Container(
                                              //   height: 180.h,
                                              //   alignment: Alignment.center,
                                              //   child: Center(
                                              //     child: Transform.translate(
                                              //       offset: Offset(0, -10.h),
                                              //       child: SvgPicture.asset(
                                              //         'assets/svg/marker.svg',
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              // Container(
                                              //   width: double.infinity,
                                              //   height: 180.h,
                                              //   color: Colors.transparent,
                                              // ),
                                            ]
                                          : [
                                              LocationMapField(
                                                textFieldsEnabled: true,
                                                gesturesEnabled: true,
                                                myLocationEnabled: true,
                                                zoomEnabled: true,
                                                mapController: _mapController,
                                                latitude: state.latitude,
                                                longitude: state.longitude,
                                                addressFieldValidator: (p0) =>
                                                    validateAddress(
                                                        p0.toString()),
                                                countryFieldValidator: (p0) =>
                                                    validateCountry(
                                                        p0.toString()),
                                              ),
                                              Container(
                                                height: 180.h,
                                                alignment: Alignment.center,
                                                child: Center(
                                                  child: Transform.translate(
                                                    offset: Offset(0, -10.h),
                                                    child: SvgPicture.asset(
                                                      'assets/svg/marker.svg',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        DisplayTitleText(
                                          title: LocaleKeys
                                              .addGrievance_contactByPhone
                                              .tr(),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          height: 20.h,
                                          child: CupertinoSwitch(
                                            trackColor:
                                                AppColors.colorPrimaryLight,
                                            activeColor:
                                                AppColors.colorPrimary200,
                                            thumbColor: contactMeByPhone
                                                ? AppColors.colorPrimary
                                                : AppColors
                                                    .colorPrimaryExtraLight,
                                            value: contactMeByPhone,
                                            onChanged: (value) {
                                              setState(() {
                                                contactMeByPhone =
                                                    !contactMeByPhone;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    BlocBuilder<ReverseGeocodingCubit,
                                        ReverseGeocodingState>(
                                      builder: (context, state) {
                                        if (state is ReverseGeocodingLoaded) {
                                          return BlocBuilder<MyProfileCubit,
                                              MyProfileState>(
                                            builder: (context, myProfileState) {
                                              if (myProfileState
                                                  is MyProfileLoaded) {
                                                return BlocConsumer<
                                                    GrievancesBloc,
                                                    GrievancesState>(
                                                  listener: (context,
                                                      grievancesState) {},
                                                  builder: (context,
                                                      grievancesState) {
                                                    if (grievancesState
                                                        is AddingGrievanceAudioAssetState) {
                                                      return Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: PrimaryButton(
                                                          onTap: () {
                                                            if (dropdownValue ==
                                                                null) {
                                                              setState(() {
                                                                showDropdownError =
                                                                    true;
                                                              });
                                                            }
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                            } else {}
                                                          },
                                                          buttonText: LocaleKeys
                                                              .addGrievance_submit
                                                              .tr(),
                                                          isLoading: false,
                                                          enabled: false,
                                                        ),
                                                      );
                                                    }
                                                    if (grievancesState
                                                        is AddingGrievanceImageAssetState) {
                                                      return Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: PrimaryButton(
                                                          onTap: () {
                                                            if (dropdownValue ==
                                                                null) {
                                                              setState(() {
                                                                showDropdownError =
                                                                    true;
                                                              });
                                                            }
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                            } else {}
                                                          },
                                                          buttonText: LocaleKeys
                                                              .addGrievance_submit
                                                              .tr(),
                                                          isLoading: false,
                                                          enabled: false,
                                                        ),
                                                      );
                                                    }
                                                    if (grievancesState
                                                        is AddingGrievanceVideoAssetState) {
                                                      return Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: PrimaryButton(
                                                          onTap: () {
                                                            if (dropdownValue ==
                                                                null) {
                                                              setState(() {
                                                                showDropdownError =
                                                                    true;
                                                              });
                                                            }
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                            } else {}
                                                          },
                                                          buttonText: LocaleKeys
                                                              .addGrievance_submit
                                                              .tr(),
                                                          isLoading: false,
                                                          enabled: false,
                                                        ),
                                                      );
                                                    }
                                                    if (grievancesState
                                                        is AddingGrievanceState) {
                                                      return Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: PrimaryButton(
                                                          onTap: () {
                                                            if (dropdownValue ==
                                                                null) {
                                                              setState(() {
                                                                showDropdownError =
                                                                    true;
                                                              });
                                                            }
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                            } else {}
                                                          },
                                                          buttonText: LocaleKeys
                                                              .addGrievance_submit
                                                              .tr(),
                                                          isLoading: true,
                                                        ),
                                                      );
                                                    }
                                                    return Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: PrimaryButton(
                                                        onTap: () async {
                                                          // log("${LocationMapField.addressLine1Controller.text}, ${LocationMapField.addressLine2Controller.text}");
                                                          // log("${state.latitude}, ${state.longitude}");
                                                          // log("${state.subLocality}");
                                                          // return;
                                                          if (dropdownValue ==
                                                              null) {
                                                            setState(() {
                                                              showDropdownError =
                                                                  true;
                                                            });
                                                            return;
                                                          }

                                                          if (_formKey
                                                                  .currentState!
                                                                  .validate() &&
                                                              !showDropdownError) {
                                                            late bool
                                                                showClosingDialog;
                                                            await showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                content: Text(
                                                                  LocaleKeys
                                                                      .grievanceDetail_addingGrievanceWarningMessage
                                                                      .tr(),
                                                                ),
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(24
                                                                            .sp),
                                                                actions: [
                                                                  SecondaryDialogButton(
                                                                    onTap: () {
                                                                      showClosingDialog =
                                                                          false;
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      return;
                                                                    },
                                                                    buttonText:
                                                                        LocaleKeys
                                                                            .grievanceDetail_no
                                                                            .tr(),
                                                                    isLoading:
                                                                        false,
                                                                    trailingIconEnabled:
                                                                        false,
                                                                  ),
                                                                  PrimaryDialogButton(
                                                                    onTap: () {
                                                                      showClosingDialog =
                                                                          true;
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    buttonText:
                                                                        LocaleKeys
                                                                            .grievanceDetail_yes
                                                                            .tr(),
                                                                    isLoading:
                                                                        false,
                                                                    trailingIconEnabled:
                                                                        false,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                            if (!showClosingDialog) {
                                                              return;
                                                            }
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            BlocProvider.of<
                                                                        GrievancesBloc>(
                                                                    context)
                                                                .add(
                                                                    AddGrievanceEvent(
                                                                        grievance:
                                                                            Grievances(
                                                              municipalityId:
                                                                  authSuccessState
                                                                      .afterLogin
                                                                      .userDetails!
                                                                      .municipalityID,
                                                              address:
                                                                  "${LocationMapField.addressLine1Controller.text}, ${LocationMapField.addressLine2Controller.text}",
                                                              contactNumber:
                                                                  contactNumberController
                                                                      .text,
                                                              createdBy:
                                                                  AuthBasedRouting
                                                                      .afterLogin
                                                                      .userDetails!
                                                                      .userID
                                                                      .toString(),
                                                              createdByName:
                                                                  authSuccessState
                                                                      .afterLogin
                                                                      .userDetails!
                                                                      .firstName,
                                                              createdDate:
                                                                  DateTime.now()
                                                                      .toString(),
                                                              description:
                                                                  descriptionController
                                                                      .text,
                                                              expectedCompletion:
                                                                  '1 Day',
                                                              grievanceType:
                                                                  dropdownValue
                                                                      .toString()
                                                                      .toUpperCase(),
                                                              // grievanceType:
                                                              //     getAcronym(
                                                              //         dropdownValue
                                                              //             .toString()),
                                                              lastModifiedDate:
                                                                  DateTime.now()
                                                                      .toString(),
                                                              location: state
                                                                      .subLocality
                                                                      .isNotEmpty
                                                                  ? state
                                                                      .subLocality
                                                                  : LocationMapField
                                                                      .addressLine1Controller
                                                                      .text,
                                                              latitude: state
                                                                  .latitude,
                                                              longitude: state
                                                                  .longitude,
                                                              contactByPhoneEnabled:
                                                                  contactMeByPhone,
                                                              priority: '1',
                                                              status: '1',
                                                              wardNumber: authSuccessState
                                                                  .afterLogin
                                                                  .userDetails!
                                                                  .userWardNumber,
                                                              newHouseAddress:
                                                                  newHouseAddressController
                                                                          .text
                                                                          .isEmpty
                                                                      ? null
                                                                      : newHouseAddressController
                                                                          .text,
                                                              planDetails:
                                                                  newHousePlanDetailsController
                                                                          .text
                                                                          .isEmpty
                                                                      ? null
                                                                      : newHousePlanDetailsController
                                                                          .text,
                                                              deceasedName:
                                                                  deceasedNameController
                                                                          .text
                                                                          .isEmpty
                                                                      ? null
                                                                      : deceasedNameController
                                                                          .text,
                                                              relation: relationWithDeceasedController
                                                                      .text
                                                                      .isEmpty
                                                                  ? null
                                                                  : relationWithDeceasedController
                                                                      .text,
                                                              assets: {
                                                                'Audio':
                                                                    audioLinks,
                                                                'Image':
                                                                    imageLinks,
                                                                'Video':
                                                                    videoLinks,
                                                              },
                                                            )));
                                                          } else {}
                                                        },
                                                        buttonText: LocaleKeys
                                                            .addGrievance_submit
                                                            .tr(),
                                                        isLoading: false,
                                                      ),
                                                    );
                                                  },
                                                );
                                              }

                                              return Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: PrimaryButton(
                                                  onTap: () {
                                                    if (dropdownValue == null) {
                                                      setState(() {
                                                        showDropdownError =
                                                            true;
                                                      });
                                                    }
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                    } else {}
                                                  },
                                                  buttonText: LocaleKeys
                                                      .addGrievance_submit
                                                      .tr(),
                                                  isLoading: false,
                                                ),
                                              );
                                            },
                                          );
                                        }
                                        return Align(
                                          alignment: Alignment.bottomRight,
                                          child: PrimaryButton(
                                            onTap: () {
                                              if (dropdownValue == null) {
                                                setState(() {
                                                  showDropdownError = true;
                                                });
                                              }
                                              if (_formKey.currentState!
                                                  .validate()) {
                                              } else {}
                                            },
                                            buttonText: LocaleKeys
                                                .addGrievance_submit
                                                .tr(),
                                            isLoading: false,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: 30.h,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.colorPrimary,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column whenHousePlanAndCertNotSelected(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayTitleText(
          title: LocaleKeys.addGrievance_addPhotoVideo.tr(),
        ),
        SizedBox(
          height: 5.h,
        ),
        SizedBox(
          height: 80.h,
          child: Row(
            children: [
              Container(
                height: 80.h,
                width: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppColors.colorPrimaryLight,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 50.sp,
                  ),
                  onPressed: () {
                    _showPicker(context);
                  },
                ),
              ),
              images.isEmpty && videos.isEmpty
                  ? Expanded(
                      child: Container(
                        height: 80.h,
                        width: 80.h,
                        margin: EdgeInsets.only(right: 12.w, left: 12.w),
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.colorPrimaryLight,
                        ),
                        child: Center(
                          child:
                              Text(LocaleKeys.addGrievance_noMediaUploads.tr()),
                        ),
                      ),
                    )
                  : BlocBuilder<GrievancesBloc, GrievancesState>(
                      builder: (context, assetState) {
                        if (assetState is AddingGrievanceImageAssetState) {
                          return Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: const CircularProgressIndicator(
                              color: AppColors.colorPrimary,
                            ),
                          );
                        }
                        if (assetState is AddingGrievanceVideoAssetState) {
                          return Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: const CircularProgressIndicator(
                              color: AppColors.colorPrimary,
                            ),
                          );
                        }
                        return Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length + videos.length,
                            itemBuilder: (context, index) {
                              log(videos.length.toString());
                              log(images.length.toString());
                              return Container(
                                height: 80.h,
                                width: 80.h,
                                clipBehavior: Clip.antiAlias,
                                margin: EdgeInsets.only(right: 12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: AppColors.colorPrimaryLight,
                                ),
                                child: index < images.length
                                    ? Stack(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Image.file(
                                              File(images[index].path),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                              onTap: () {
                                                images.removeAt(index);
                                                imageLinks.removeAt(index);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(LocaleKeys
                                                        .addGrievance_deletingImage
                                                        .tr()),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0.sp),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.textColorRed,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : buildThumbnail(
                                        index - images.length,
                                      ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
        SizedBox(
          height: 12.h,
        ),
        DisplayTitleText(
          title: LocaleKeys.addGrievance_addAudio.tr(),
        ),
        SizedBox(
          height: 5.h,
        ),
        SizedBox(
          height: 80.h,
          child: Row(
            children: [
              Container(
                height: 80.h,
                width: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppColors.colorPrimaryLight,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 50.sp,
                  ),
                  onPressed: () {
                    _showAudioPicker(context);
                  },
                ),
              ),
              audios.isEmpty
                  ? Expanded(
                      child: Container(
                        height: 80.h,
                        width: 80.h,
                        margin: EdgeInsets.only(right: 12.w, left: 12.w),
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: AppColors.colorPrimaryLight,
                        ),
                        child: Center(
                          child:
                              Text(LocaleKeys.addGrievance_noAudioUploads.tr()),
                        ),
                      ),
                    )
                  : BlocConsumer<GrievancesBloc, GrievancesState>(
                      listener: (context, assetState) {},
                      builder: (context, assetState) {
                        if (assetState is AddingGrievanceAudioAssetState) {
                          return Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: const CircularProgressIndicator(
                              color: AppColors.colorPrimary,
                            ),
                          );
                        }
                        return Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: audios.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.all(
                                              12.sp,
                                            ),
                                            content: AudioComment(
                                              audioUrl: audios[index].path,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 80.h,
                                      width: 80.h,
                                      margin: EdgeInsets.only(right: 12.w),
                                      padding: EdgeInsets.all(20.sp),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        color: AppColors.colorPrimaryLight,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/svg/audiofile.svg',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.h,
                                    right: 5.w,
                                    child: InkWell(
                                      onTap: () {
                                        audios.removeAt(index);
                                        audioLinks.removeAt(index);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(LocaleKeys
                                                .addGrievance_deletingAudio
                                                .tr()),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0.sp),
                                        child: const Icon(
                                          Icons.delete,
                                          color: AppColors.textColorRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      })
            ],
          ),
        ),
      ],
    );
  }

  String? validateAddress(String value) {
    if (value.isEmpty) {
      return LocaleKeys.addGrievance_addressRequired.tr();
    }
    return null;
  }

  String? validateCountry(String value) {
    if (value.isEmpty) {
      return "Country is required";
    }
    return null;
  }

  String? validateMobileNumber(String value) {
    if (value.isEmpty) {
      return LocaleKeys.loginAndActivationScreen_mobileNumberRequiredError.tr();
    }
    if (value.length != 10) {
      return LocaleKeys.loginAndActivationScreen_mobileNumberLengthError.tr();
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return LocaleKeys.loginAndActivationScreen_mobileNumberInputTypeError
          .tr();
    }
    return null;
  }

  validateGreivanceType(String value) {
    if (value.isEmpty) {
      return LocaleKeys.addGrievance_selectaValue.tr();
    }
    return null;
  }

  validateName(String value) {
    if (value.isEmpty) {
      return "Name of the person is required";
    }
    return null;
  }

  validateRelation(String value) {
    if (value.isEmpty) {
      return "Relation is required";
    }
    return null;
  }

  descriptionValidator(String value) {
    if (value.isEmpty) {
      return LocaleKeys.addGrievance_descriptionRequired.tr();
    }
    return null;
  }

  newHouseAddressValidator(String value) {
    if (value.isEmpty) {
      return 'New house address is required';
    }
    return null;
  }

  newHousePlanDetailsValidator(String value) {
    if (value.isEmpty) {
      return 'Plan details are required';
    }
    return null;
  }

  deceasedNameValidator(String value) {
    if (value.isEmpty) {
      return 'Deceased name is required';
    }
    return null;
  }

  relationValidator(String value) {
    if (value.isEmpty) {
      return 'Relation with the deceased is required';
    }
    return null;
  }

  Future<void> pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    final file = File(pickedFile.path);
    final fileSize = await file.length();
    print(fileSize);
    if (fileSize > 30 * 1024 * 1024) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(LocaleKeys.comments_videoSizeLimit.tr()),
            actions: [
              Align(
                alignment: Alignment.bottomRight,
                child: PrimaryDialogButton(
                  buttonText: LocaleKeys.comments_ok.tr(),
                  onTap: () => Navigator.of(context).pop(),
                  isLoading: false,
                ),
              ),
            ],
          );
        },
      );
      return;
    }
    setState(() {
      videos.add(pickedFile);
    });
    log('Picking video');
    log('Picked file size: ${pickedFile.length()}');
    generateThumbnail(file);
    getVideoSize(file);
    File compressedFile = await compressVideo(file);
    final Uint8List videoBytes = await compressedFile.readAsBytes();
    final String base64Video = base64Encode(videoBytes);
    BlocProvider.of<GrievancesBloc>(context).add(AddGrievanceVideoAssetEvent(
      userId: AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
      fileType: 'video',
      encodedAssetFile: base64Video,
    ));
    log('Compressed file size: ${compressedFile.length()}');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> getVideoSize(File file) async {
    final size = await file.length();
    setState(() {
      videoSize = size;
    });
    log('Video Size: $videoSize');
  }

  Future<File> compressVideo(File file) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          child: ProgressDialogWidget(),
        );
      },
    );
    final info = await VideoCompressApi.compressVideo(file);
    setState(() {
      compressVideoInfo.add(info);
    });
    return File(info!.file!.path.toString());
    // log(compressVideoInfo!.filesize.toString());
  }

  Future<void> recordVideo() async {
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.camera,
    );
    if (pickedFile == null) return;
    final file = File(pickedFile.path);
    final fileSize = await file.length();
    print(fileSize);
    if (fileSize > 30 * 1024 * 1024) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(LocaleKeys.comments_videoSizeLimit.tr()),
            actions: [
              Align(
                alignment: Alignment.bottomRight,
                child: PrimaryDialogButton(
                  buttonText: LocaleKeys.comments_ok.tr(),
                  onTap: () => Navigator.of(context).pop(),
                  isLoading: false,
                ),
              ),
            ],
          );
        },
      );
      return;
    }
    setState(() {
      videos.add(pickedFile);
    });
    generateThumbnail(file);
    getVideoSize(file);
    File compressedFile = await compressVideo(file);
    final Uint8List videoBytes = await compressedFile.readAsBytes();
    final String base64Video = base64Encode(videoBytes);
    BlocProvider.of<GrievancesBloc>(context).add(AddGrievanceVideoAssetEvent(
      userId: AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
      fileType: 'video',
      encodedAssetFile: base64Video,
    ));
    log('Picked file size: ${pickedFile.length()}');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget buildThumbnail(int index) {
    return thumbnailBytes == null
        ? const CircularProgressIndicator()
        : SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.memory(
                    thumbnailBytes[index]!,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: IconButton(
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => FullScreenVideoPlayer(
                      //       file: File(compressVideoInfo[index]!.file!.path),
                      //     ),
                      //   ),
                      // );
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: AppColors.colorWhite,
                      size: 28.sp,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      videos.removeAt(index);
                      videoLinks.removeAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(LocaleKeys.addGrievance_deletingVideo.tr()),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5.0.sp),
                      child: const Icon(
                        Icons.delete,
                        color: AppColors.textColorRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Future<void> generateThumbnail(File file) async {
    final thumbnailByte = await VideoCompress.getByteThumbnail(file.path);
    setState(() {
      thumbnailBytes.add(thumbnailByte);
    });
  }

  Future<void> pickPhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      images.add(pickedFile!);
    });
    log('Picking image');
    final Uint8List imageBytes = await pickedFile!.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    BlocProvider.of<GrievancesBloc>(context).add(
      AddGrievanceImageAssetEvent(
        userId: AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
        fileType: 'image',
        encodedAssetFile: base64Image,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> capturePhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    setState(() {
      images.add(pickedFile!);
    });
    final Uint8List imageBytes = await pickedFile!.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    BlocProvider.of<GrievancesBloc>(context).add(
      AddGrievanceImageAssetEvent(
        userId: AuthBasedRouting.afterLogin.userDetails!.toString(),
        fileType: 'image',
        encodedAssetFile: base64Image,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                width: 100.w,
                child: const Divider(
                  thickness: 2,
                  color: AppColors.textColorDark,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.sp),
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: Text(LocaleKeys.addComment_photoLibrary.tr()),
                      onTap: () async {
                        await pickPhoto();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: Text(LocaleKeys.addComment_camera.tr()),
                      onTap: () async {
                        await capturePhoto();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.videocam),
                      title: Text(LocaleKeys.addComment_videoLibrary.tr()),
                      onTap: () async {
                        await pickVideo();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.videocam),
                      title: Text(LocaleKeys.addComment_recordVideo.tr()),
                      onTap: () async {
                        await recordVideo();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAudioPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                width: 100.w,
                child: const Divider(
                  thickness: 2,
                  color: AppColors.textColorDark,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.sp),
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.audio_file),
                      title: Text(LocaleKeys.addComment_chooseAudio.tr()),
                      onTap: () async {
                        await chooseAudio();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.record_voice_over),
                      title: Text(LocaleKeys.addComment_recordAudio.tr()),
                      onTap: () async {
                        await recordAudio();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> chooseAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        final file = result.files.single;
        audios.add(
          XFile(
            file.path.toString(),
          ),
        );
        final Uint8List audioBytes =
            await File(file.path.toString()).readAsBytes();
        final String base64Audio = base64Encode(audioBytes);
        BlocProvider.of<GrievancesBloc>(context).add(
          AddGrievanceAudioAssetEvent(
            userId: AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
            fileType: 'audio',
            encodedAssetFile: base64Audio,
          ),
        );

        // Do something with the selected audio file, e.g. play it
        log('Selected audio file: ${file.path}');
      } catch (e) {
        print(e.toString());
      }

      // hideLoading(context);
    } else {
      // User canceled the picker
      log('No audio file selected');
    }
  }

  Future<void> recordAudio() async {
    File? audioFile;
    bool recordingAudio = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, dialogState) {
              // if (recorder == null) {
              //   initAudioRecorder();
              // }
              return audioFile != null && recorder.isStopped
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleKeys.addComment_recordingDoneMessage.tr(),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: AppColors.colorPrimaryLight,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: AudioComment(
                            audioUrl: audioFile!.path,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        BlocConsumer<GrievancesBloc, GrievancesState>(
                          listener: (context, state) {
                            if (state
                                is AddingGrievanceAudioAssetSuccessState) {
                              Navigator.of(context).pop;
                            }
                          },
                          builder: (context, state) {
                            if (state is AddingGrievanceAudioAssetState) {
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: PrimaryDialogButton(
                                  onTap: () {},
                                  buttonText:
                                      LocaleKeys.addComment_uploadRecoding.tr(),
                                  isLoading: true,
                                ),
                              );
                            }
                            return Align(
                              alignment: Alignment.bottomRight,
                              child: PrimaryDialogButton(
                                onTap: () async {
                                  final Uint8List audioBytes =
                                      await File(audioFile!.path.toString())
                                          .readAsBytes();
                                  final String base64Audio =
                                      base64Encode(audioBytes);
                                  BlocProvider.of<GrievancesBloc>(context).add(
                                    AddGrievanceAudioAssetEvent(
                                      encodedAssetFile: base64Audio,
                                      fileType: 'audio',
                                      userId: AuthBasedRouting
                                          .afterLogin.userDetails!.userID
                                          .toString(),
                                    ),
                                  );
                                },
                                buttonText:
                                    LocaleKeys.addComment_uploadRecoding.tr(),
                                isLoading: false,
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        StreamBuilder<RecordingDisposition>(
                          stream: recorder.onProgress,
                          builder: (context, snapshot) {
                            final duration = snapshot.hasData
                                ? snapshot.data!.duration
                                : Duration.zero;
                            String twoDigits(int n) =>
                                n.toString().padLeft(2, '0');
                            final twoDigitMinutes =
                                twoDigits(duration.inMinutes.remainder(60));
                            final twoDigitSeconds =
                                twoDigits(duration.inSeconds.remainder(60));

                            return Text(
                              '$twoDigitMinutes : $twoDigitSeconds',
                              style: TextStyle(
                                fontSize: 28.sp,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            if (recorder.isRecording) {
                              audioFile = await stopAudioRecording();
                              await recorder.closeRecorder();
                              audios.add(XFile(audioFile!.path));
                              int sizeInBytes = audioFile!.lengthSync();
                              double sizeInMb = sizeInBytes / (1024 * 1024);
                              log('Recorded audio file size: $sizeInMb MB');
                              dialogState(() {
                                audioDurationSubscription.cancel();
                                recordingAudio = false;
                              });
                              return;
                            }
                            if (!recorder.isRecording) {
                              dialogState(() {
                                recordingAudio = true;
                              });
                              await initAudioRecorder();
                              // recorder.dispositionStream();
                              await recorder.startRecorder(
                                codec: Codec.aacMP4,
                                toFile:
                                    await getTemporaryFilePath(audios.length),
                              );
                              audioDurationSubscription =
                                  recorder.onProgress!.listen(
                                (event) async {
                                  if (event.duration >=
                                      const Duration(seconds: 60)) {
                                    audioFile = await stopAudioRecording();
                                    await recorder.closeRecorder();
                                    audios.add(XFile(audioFile!.path));
                                    int sizeInBytes = audioFile!.lengthSync();
                                    double sizeInMb =
                                        sizeInBytes / (1024 * 1024);
                                    log('Recorded audio file size: $sizeInMb MB');
                                    if (mounted) {
                                      dialogState(() {
                                        audioDurationSubscription.cancel();
                                        recordingAudio = false;
                                      });
                                    }
                                    return;
                                  }
                                },
                              );
                            }
                          },
                          icon: recordingAudio
                              ? Icon(
                                  Icons.stop_circle_outlined,
                                  color: AppColors.textColorRed,
                                  size: 50.sp,
                                )
                              : Icon(
                                  Icons.circle,
                                  color: AppColors.textColorRed,
                                  size: 50.sp,
                                ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          recordingAudio
                              ? LocaleKeys.addComment_stop.tr()
                              : LocaleKeys.addComment_record.tr(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Text(
                          LocaleKeys.addComment_audioMaxDuration.tr(),
                          style: AppStyles.listOrderedByTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                      ],
                    );
            },
          ),
        );
      },
    );
    // recorder.dispositionStream();
  }

  Future<File> stopAudioRecording() async {
    recorder.dispositionStream();
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    log('Recorded audio: $audioFile');
    return audioFile;
  }

  Future<void> initAudioRecorder() async {
    final storageStatus = await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted ||
        storageStatus != PermissionStatus.granted) {
      throw 'Microphone Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(
      const Duration(
        milliseconds: 500,
      ),
    );
  }
}
