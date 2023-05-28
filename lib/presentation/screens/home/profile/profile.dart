import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:civic_user/constants/app_constants.dart';
import 'package:civic_user/generated/locale_keys.g.dart';
import 'package:civic_user/logic/cubits/cubit/local_storage_cubit.dart';
import 'package:civic_user/logic/cubits/my_profile/my_profile_cubit.dart';
import 'package:civic_user/main.dart';
import 'package:civic_user/models/my_profile.dart';
import 'package:civic_user/models/user_details.dart';
import 'package:civic_user/presentation/screens/home/profile/edit_profile.dart';
import 'package:civic_user/presentation/screens/login/login.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/widgets/location_map_field.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:civic_user/widgets/secondary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants/env_variable.dart';
import '../../../utils/functions/snackbars.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  List<WardDetails> wards = [];
  String? wardValue;

  @override
  initState() {
    wards = AuthBasedRouting.afterLogin.wardDetails!
        .where((element) =>
            element.municipalityID ==
            AuthBasedRouting.afterLogin.userDetails!.municipalityID!)
        .toList();
    wards.sort(
        (a, b) => int.parse(a.wardNumber!).compareTo(int.parse(b.wardNumber!)));
    wardValue = wards
        .firstWhere((element) =>
            element.wardNumber ==
            AuthBasedRouting.afterLogin.userDetails!.userWardNumber)
        .wardName;
    super.initState();
    print(wardValue);
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<MyProfileCubit>(context).getMyProfile(
        AuthBasedRouting.afterLogin.userDetails!.userID.toString());

    return Scaffold(
      body: BlocConsumer<MyProfileCubit, MyProfileState>(
        listener: (context, state) {
          if (state is ProfilePictureUploadingSuccessState) {
            log('Uploaded profile picture successfully');
            UserDetails userDetails = AuthBasedRouting.afterLogin.userDetails!;
            BlocProvider.of<MyProfileCubit>(context).editMyProfile(
              MyProfile(
                  userID: AuthBasedRouting.afterLogin.userDetails!.userID,
                  about: userDetails.about,
                  address: userDetails.address,
                  userLatitude: userDetails.userLatitude,
                  userLongitude: userDetails.userLongitude,
                  active: AuthBasedRouting.afterLogin.userDetails!.active,
                  profilePicture:
                      '$CLOUDFRONT_URL/${state.s3uploadResult.uploadResult!.key1!}',
                  firstName: userDetails.firstName,
                  mobileNumber: userDetails.mobileNumber,
                  emailID: userDetails.emailID),
            );
          }
          if (state is MyProfileEditingDoneState) {
            BlocProvider.of<MyProfileCubit>(context).getMyProfile(
                AuthBasedRouting.afterLogin.userDetails!.userID.toString());
          }
          if (state is MyProfileEditingDoneState) {
            SnackBars.sucessMessageSnackbar(context,
                LocaleKeys.editProfile_profileUpdatedSuccessfully.tr());
          }
          if (state is MyProfileEditingFailedState) {
            SnackBars.errorMessageSnackbar(
                context, LocaleKeys.editProfile_somethingWentWrong.tr());
          }
        },
        builder: (context, state) {
          if (state is MyProfileEditingStartedState) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            );
          }
          if (state is ProfilePictureUploadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            );
          }
          if (state is MyProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.colorPrimary),
            );
          }
          if (state is MyProfileLoaded) {
            return Column(
              children: [
                PrimaryTopShape(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.screenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              const Spacer(),
                              InkWell(
                                onTap: () async {
                                  await Navigator.of(context).pushNamed(
                                    EditProfileScreen.routeName,
                                    arguments: {
                                      'my_profile': state.myProfile,
                                    },
                                  ).then(
                                    (value) =>
                                        BlocProvider.of<MyProfileCubit>(context)
                                            .getMyProfile(
                                      AuthBasedRouting
                                          .afterLogin.userDetails!.userID
                                          .toString(),
                                    ),
                                  );
                                },
                                child: Text(
                                  LocaleKeys.profile_edit.tr(),
                                  style: TextStyle(
                                    color: AppColors.colorWhite,
                                    fontFamily: 'LexendDeca',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        Row(
                          children: [
                            Stack(children: [
                              InkWell(
                                onLongPress: () {
                                  _showPicker(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(10.sp),
                                  child: CircleAvatar(
                                    radius: 35.w,
                                    backgroundColor:
                                        AppColors.colorPrimaryExtraLight,
                                    child: ClipOval(
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: state.userDetails
                                                          .profilePicture !=
                                                      null ||
                                                  state.userDetails
                                                          .profilePicture ==
                                                      ''
                                              ? Image.network(
                                                  state.userDetails
                                                      .profilePicture!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 60.sp,
                                                    ),
                                                  ),
                                                )
                                              : Center(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.photo_camera,
                                                      size: 30.sp,
                                                    ),
                                                    onPressed: () {
                                                      _showPicker(context);
                                                    },
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: InkWell(
                                  onTap: () => _showPicker(context),
                                  child: CircleAvatar(
                                    radius: 14.sp,
                                    backgroundColor: AppColors.colorWhite,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20.sp,
                                        color: AppColors.colorPrimary,
                                      ),
                                      onPressed: () {
                                        _showPicker(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              width: 15.w,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.myProfile.firstName.toString(),
                                  style: TextStyle(
                                    color: AppColors.colorWhite,
                                    fontFamily: 'LexendDeca',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                SizedBox(
                                  width: 150.h,
                                  child: Text(
                                    state.myProfile.address.toString(),
                                    style: TextStyle(
                                      color: AppColors.colorWhite,
                                      fontFamily: 'LexendDeca',
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.call,
                              color: AppColors.colorWhite,
                              size: 16.sp,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              state.myProfile.mobileNumber.toString(),
                              style: TextStyle(
                                color: AppColors.colorWhite,
                                fontFamily: 'LexendDeca',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: AppColors.colorWhite,
                              size: 16.sp,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              state.myProfile.emailID.toString(),
                              style: TextStyle(
                                color: AppColors.colorWhite,
                                fontFamily: 'LexendDeca',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 50.h,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.profile_about.tr(),
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
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.colorPrimaryLight,
                            ),
                            padding: EdgeInsets.all(10.sp),
                            child: Text(
                              state.myProfile.about.toString(),
                              style: TextStyle(
                                overflow: TextOverflow.fade,
                                color: AppColors.textColorDark,
                                fontFamily: 'LexendDeca',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300,
                                height: 1.1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            LocaleKeys.profile_location.tr(),
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
                                gesturesEnabled: false,
                                markerEnabled: true,
                                myLocationEnabled: false,
                                zoomEnabled: false,
                                latitude: double.parse(
                                    state.myProfile.userLatitude.toString()),
                                longitude: double.parse(
                                    state.myProfile.userLongitude.toString()),
                                mapController: _controller,
                                address: state.myProfile.address,
                              ),
                              Container(
                                height: 180.h,
                                width: double.infinity,
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            LocaleKeys.profile_wardNumber.tr(),
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
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.sp),
                              color: AppColors.colorPrimaryLight,
                            ),
                            padding: EdgeInsets.all(10.sp),
                            child: Text(
                              // state.myProfile.userWardNumber.toString(),
                              wardValue.toString(),
                              style: TextStyle(
                                overflow: TextOverflow.fade,
                                color: AppColors.textColorDark,
                                fontFamily: 'LexendDeca',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300,
                                height: 1.1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                          BlocListener<LocalStorageCubit, LocalStorageState>(
                            listener: (context, state) {
                              if (state
                                  is LocalStorageClearingUserFailedState) {
                                SnackBars.sucessMessageSnackbar(
                                    context, 'Local Storage clearing failed!');
                              }
                              if (state
                                  is LocalStorageClearingUserSuccessState) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Login.routeName,
                                  (route) => false,
                                );
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.screenPadding,
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: SecondaryButton(
                                  buttonText: LocaleKeys.profile_logout.tr(),
                                  isLoading: false,
                                  onTap: () {
                                    BlocProvider.of<LocalStorageCubit>(context)
                                        .clearStorage();
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
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
                      title: const Text('Photo Library'),
                      onTap: () async {
                        await pickPhoto(bc);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Camera'),
                      onTap: () async {
                        await capturePhoto(bc);
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

  Future<void> pickPhoto(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    log('Picking image');
    final Uint8List imageBytes = await pickedFile!.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    BlocProvider.of<MyProfileCubit>(context).uploadProfilePicture(
      encodedProfilePictureFile: base64Image,
      fileType: 'image',
      userId: AuthBasedRouting.afterLogin.userDetails!.userID!,
    );
    Navigator.of(context).pop();
  }

  Future<void> capturePhoto(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    final Uint8List imageBytes = await pickedFile!.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    BlocProvider.of<MyProfileCubit>(context).uploadProfilePicture(
      encodedProfilePictureFile: base64Image,
      fileType: 'image',
      userId: AuthBasedRouting.afterLogin.userDetails!.userID!,
    );

    Navigator.of(context).pop();
  }
}
