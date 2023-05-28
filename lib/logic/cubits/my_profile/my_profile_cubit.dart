import 'dart:convert';
import 'dart:developer';

import 'package:civic_user/main.dart';
import 'package:civic_user/models/my_profile.dart';
import 'package:civic_user/models/user_details.dart';
import 'package:civic_user/models/user_model.dart';
import 'package:civic_user/resources/repositories/my_profile/my_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../models/s3_upload_result.dart';

part 'my_profile_state.dart';

class MyProfileCubit extends Cubit<MyProfileState> {
  final MyProfileRerpository myProfileRepository;
  MyProfileCubit(this.myProfileRepository) : super(MyProfileLoading());
  // loadMyProfile() async {
  //   emit(MyProfileLoaded(
  //     myProfile: myProfileRepository.myProfile,
  //   ));
  // }

  getMyProfile(String userId) async {
    emit(MyProfileLoading());
    final response = await myProfileRepository.getMyProfileJson(userId);
    UserDetails userDetails = UserDetails.fromJson(jsonDecode(response.toString()));
    AuthBasedRouting.afterLogin.userDetails = UserDetails(
      emailID: userDetails.emailID,
      address: userDetails.address,
      notificationToken: userDetails.notificationToken,
      userLatitude: userDetails.userLatitude,
      userLongitude: userDetails.userLongitude,
      userWardNumber: userDetails.userWardNumber,
      municipalityID: userDetails.municipalityID,
      modifiedBy: userDetails.modifiedBy,
      mobileNumber: userDetails.mobileNumber,
      userID: userDetails.userID,
      profilePicture: userDetails.profilePicture,
      countryCode: userDetails.countryCode,
      createdBy: userDetails.createdBy,
      about: userDetails.about,
      firstName: userDetails.firstName,
      active: userDetails.active,
    );
    emit(MyProfileLoaded(
      myProfile: MyProfile(
        emailID: userDetails.emailID,
        about: userDetails.about,
        mobileNumber: userDetails.mobileNumber,
        firstName: userDetails.firstName,
        profilePicture: userDetails.profilePicture,
        address: userDetails.address,
        userLongitude: userDetails.userLongitude,
        userLatitude: userDetails.userLatitude,
        userWardNumber: userDetails.userWardNumber
      ), userDetails: userDetails));
  }

    uploadProfilePicture({
    required String encodedProfilePictureFile,
    required String fileType,
    required String userId,
  }) async {
    emit(ProfilePictureUploadingState());
    try {
      final response = await myProfileRepository.addProfilePictureFile(
        encodedProfilePictureFile: encodedProfilePictureFile,
        fileType: fileType,
        userId: userId,
      );
      S3UploadResult s3uploadResult = S3UploadResult.fromJson(response.data);
      emit(ProfilePictureUploadingSuccessState(s3uploadResult: s3uploadResult));
    } on DioError catch (e) {
      emit(ProfilePictureUploadingFailedState());
    }
  }

  editMyProfile(MyProfile myProfile) async {
    emit(MyProfileEditingStartedState());
    final userDetails = UserDetails(
      emailID: myProfile.emailID,
      address: myProfile.address,
      notificationToken: AuthBasedRouting.afterLogin.userDetails!.notificationToken,
      userLatitude: myProfile.userLatitude,
      userWardNumber: AuthBasedRouting.afterLogin.userDetails!.userWardNumber,
      municipalityID: AuthBasedRouting.afterLogin.userDetails!.municipalityID,
      modifiedBy: AuthBasedRouting.afterLogin.userDetails!.createdBy,
      profilePicture: myProfile.profilePicture,
      mobileNumber: AuthBasedRouting.afterLogin.userDetails!.mobileNumber,
      userID: AuthBasedRouting.afterLogin.userDetails!.userID,
      countryCode: '+91',
      createdDate: AuthBasedRouting.afterLogin.userDetails!.createdDate,
      lastModifiedDate: DateTime.now().toString(),
      createdBy: AuthBasedRouting.afterLogin.userDetails!.createdBy,
      about: myProfile.about,
      firstName: myProfile.firstName,
      active: myProfile.active,
      userLongitude: myProfile.userLongitude,
    );
    // emit(MyProfileLoading());
    try {
      final response = await myProfileRepository.editProfile(userDetails);
      UserDetails newUserDetails = UserDetails.fromJson(
        jsonDecode(
          response.toString(),
        ),
      );
      log("Before storing in local: ${AuthBasedRouting.afterLogin.userDetails!.address}");
      AuthBasedRouting.afterLogin.userDetails = UserDetails(
        emailID: userDetails.emailID,
      address: userDetails.address,
      notificationToken: userDetails.notificationToken,
      userLatitude: userDetails.userLatitude,
      userWardNumber: userDetails.userWardNumber,
      municipalityID: userDetails.municipalityID,
      modifiedBy: userDetails.createdBy,
      profilePicture: userDetails.profilePicture,
      mobileNumber: userDetails.mobileNumber,
      userID: userDetails.userID,
      countryCode: '+91',
      createdDate: userDetails.createdDate,
      lastModifiedDate: DateTime.now().toString(),
      createdBy: userDetails.createdBy,
      about: userDetails.about,
      firstName: userDetails.firstName,
      active: userDetails.active,
      userLongitude: userDetails.userLongitude,
      );
      emit(MyProfileEditingDoneState());
      log("new user details1: ${userDetails.address}");
      log("new user details2: ${AuthBasedRouting.afterLogin.userDetails!.address}");
    } on DioError catch (e) {
      emit(MyProfileEditingFailedState());
      print("Error is: ${e.response!.data}");
    }
  }

  // editMyProfile(MyProfile myProfile) {
  //   myProfileRepository.myProfile.firstName = myProfile.firstName;
  //   myProfileRepository.myProfile.lastName = myProfile.lastName;
  //   myProfileRepository.myProfile.mobileNumber = myProfile.mobileNumber;
  //   myProfileRepository.myProfile.email = myProfile.email;
  //   myProfileRepository.myProfile.about = myProfile.about;
  //   emit(MyProfileLoaded(myProfile: myProfile));
  // }
}
