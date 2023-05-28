import 'dart:async';

import 'package:civic_user/generated/locale_keys.g.dart';
import 'package:civic_user/logic/cubits/my_profile/my_profile_cubit.dart';
import 'package:civic_user/logic/cubits/reverse_geocoding/reverse_geocoding_cubit.dart';
import 'package:civic_user/main.dart';
import 'package:civic_user/models/my_profile.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/widgets/location_map_field.dart';
import 'package:civic_user/widgets/primary_button.dart';
import 'package:civic_user/widgets/primary_text_field.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../widgets/primary_display_field.dart';
import '../../../utils/functions/snackbars.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/editProfileScreen';
  const EditProfileScreen({
    super.key,
    required this.myProfile,
  });
  final MyProfile myProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  final Completer<GoogleMapController> _controller = Completer();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    firstNameController.text = widget.myProfile.firstName.toString();
    // lastNameController.text = widget.myProfile.lastName.toString();
    contactNumberController.text = widget.myProfile.mobileNumber.toString();
    emailController.text = widget.myProfile.emailID.toString();
    aboutController.text = widget.myProfile.about.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PrimaryTopShape(
            height: 150.h,
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
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: SvgPicture.asset(
                            'assets/icons/arrowleft.svg',
                            color: AppColors.colorWhite,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          LocaleKeys.profile_screenTitle.tr(),
                          style: TextStyle(
                            color: AppColors.colorWhite,
                            fontFamily: 'LexendDeca',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0.sp),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        fieldValidator: (p0) {
                          return validateFirstName(p0.toString());
                        },
                        title: LocaleKeys.editProfile_name.tr(),
                        hintText: LocaleKeys.editProfile_name.tr(),
                        textEditingController: firstNameController,
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      // PrimaryTextField(
                      //   fieldValidator: (p0) {
                      //     return validateLastName(p0.toString());
                      //   },
                      //   title: LocaleKeys.editProfile_lastName.tr(),
                      //   hintText: LocaleKeys.editProfile_lastName.tr(),
                      //   textEditingController: lastNameController,
                      // ),
                      // SizedBox(
                      //   height: 12.h,
                      // ),
                      PrimaryTextField(
                        fieldValidator: (p0) => validateEmailAddress(
                          p0.toString(),
                        ),
                        title: LocaleKeys.editProfile_email.tr(),
                        hintText: 'you@example.com',
                        textEditingController: emailController,
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      PrimaryDisplayField(
                        fillColor: AppColors.colorDisabledTextField,
                        value: AuthBasedRouting.afterLogin.userDetails!.mobileNumber.toString(),
                        title: LocaleKeys.editProfile_contactNumber.tr(),
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      PrimaryTextField(
                        maxLines: 8,
                        fieldValidator: (p0) => validateAbout(
                          p0.toString(),
                        ),
                        title: LocaleKeys.editProfile_about.tr(),
                        hintText: LocaleKeys.editProfile_aboutHint.tr(),
                        textEditingController: aboutController,
                      ),
                      SizedBox(
                        height: 12.h,
                      ),
                      Text(
                        LocaleKeys.editProfile_location.tr(),
                        style: TextStyle(
                          color: AppColors.textColorDark,
                          fontFamily: 'LexendDeca',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Stack(
                        children: [
                          LocationMapField(
                            textFieldsEnabled: true,
                            addressFieldValidator: (p0) => validateAddress(p0.toString()),
                            countryFieldValidator: (p0) => validateCountry(p0.toString()),
                            zoomEnabled: true,
                            mapController: _controller,
                            latitude: double.parse(
                              widget.myProfile.userLatitude.toString(),
                            ),
                            longitude: double.parse(
                              widget.myProfile.userLongitude.toString(),
                            ),
                            address: widget.myProfile.address,
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
                        height: 12.h,
                      ),
                      SizedBox(
                        height: 50.h,
                      ),
                      BlocBuilder<ReverseGeocodingCubit, ReverseGeocodingState>(
                        builder: (context, geoCodingState) {
                          if (geoCodingState is ReverseGeocodingLoaded) {
                            return BlocConsumer<MyProfileCubit, MyProfileState>(
                               listener: (context, profileState) {
                                if (profileState is MyProfileEditingDoneState) {
                                  // SnackBars.sucessMessageSnackbar(context, '✅ Profile updated successfully.');
                                  Navigator.of(context).pop();
                                }
                                if (profileState is MyProfileEditingFailedState) {
                                  SnackBars.errorMessageSnackbar(context, LocaleKeys.editProfile_somethingWentWrong.tr());
                                }
                               },
                              builder: (context, profileState) {
                                if (profileState is MyProfileEditingStartedState) {
                                  return Align(
                                    alignment: Alignment.bottomRight,
                                    child: PrimaryButton(
                                      isLoading: true,
                                      onTap: () {},
                                      buttonText: LocaleKeys.editProfile_submit.tr(),
                                    ),
                                  );
                                }
                                return Align(
                                  alignment: Alignment.bottomRight,
                                  child: PrimaryButton(
                                    isLoading: false,
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        BlocProvider.of<MyProfileCubit>(context).editMyProfile(
                                          MyProfile(
                                            firstName: firstNameController.text,
                                            emailID: emailController.text,
                                            userID: AuthBasedRouting.afterLogin.userDetails!.userID,
                                            about: aboutController.text,
                                            address: "${LocationMapField.addressLine1Controller.text}, ${LocationMapField.addressLine2Controller.text}",
                                            userLatitude: LocationMapField.pickedLoc.latitude.toString(),
                                            userLongitude: LocationMapField.pickedLoc.longitude.toString(),
                                            profilePicture: AuthBasedRouting.afterLogin.userDetails!.profilePicture,
                                            active: AuthBasedRouting.afterLogin.userDetails!.active,
                                          ),
                                        );
                                      } else {}
                                    },
                                buttonText: LocaleKeys.editProfile_submit.tr(),
                                  ),
                                );
                              },
                              );
                          }
                          return const SizedBox();
                        },
                      ),
                      SizedBox(
                        height: 50.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // String? validateWardNumber(String value) {
  //   if (value.isEmpty) {
  //     return LocaleKeys.editProfile_wardError.tr();
  //   }
  //   return null;
  // }

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


  String? validateFirstName(String value) {
    if (value.isEmpty) {
      return LocaleKeys.editProfile_firstNameError.tr();
    }
    return null;
  }

  String? validateAbout(String value) {
    if (value.isEmpty) {
      return LocaleKeys.editProfile_aboutError.tr();
    }
    return null;
  }

  String? validateLastName(String value) {
    if (value.isEmpty) {
      return LocaleKeys.editProfile_lastNameError.tr();
    }
    return null;
  }

  String? validateEmailAddress(String value) {
    if (value.isEmpty) {
      return LocaleKeys.editProfile_emailError.tr();
    }
    return null;
  }

  String? validateMobileNumber(String value) {
    if (value.isEmpty) {
      return LocaleKeys.editProfile_mobileNumberRequiredErrorMessage.tr();
    }
    if (value.length != 10) {
      return LocaleKeys.editProfile_mobileNumberLengthErrorMessage.tr();
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return LocaleKeys.editProfile_mobileNumberInputTypeError.tr();
    }
    return null;
  }
}
