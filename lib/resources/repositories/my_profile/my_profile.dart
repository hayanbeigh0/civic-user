import 'dart:convert';
import 'dart:developer';

import 'package:civic_user/constants/env_variable.dart';
import 'package:civic_user/models/my_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../models/user_details.dart';

class MyProfileRerpository {
  // late MyProfile myProfile;

  getMyProfileJson(String userId) async {
    const String url = '$API_URL/user/by-user-id';
    final response = await Dio().get(
      url,
      data: jsonEncode({"userId": userId}),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  }

  Future<Response> addProfilePictureFile({
    required String encodedProfilePictureFile,
    required String fileType,
    required String userId,
  }) async {
    final response = await Dio().post(
      '$API_URL/general/upload-assets',
      data: jsonEncode({
        "File": encodedProfilePictureFile,
        "FileType": fileType,
        "UserID": userId,
        "Section": 'profile'
      }),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    // log(response.data.toString());
    return response;
  }

  editProfile(UserDetails userDetails) async {
    log('in editProfile  function');
    const String url = '$API_URL/user/modify-user';
    log("User ID: ${userDetails.userID}");
    final response = await Dio().put(
        url,
        data: jsonEncode({
          "userId": userDetails.userID,
          "about": userDetails.about,
          "active": userDetails.active,
          "address": userDetails.address,
          "countryCode": "+91",
          "staffId": userDetails.createdBy,
          "emailId": userDetails.emailID,
          "firstName": userDetails.firstName,
          "lastModifiedDate": DateTime.now().toString(),
          "mobileNumber": userDetails.mobileNumber,
          "municipalityId": userDetails.municipalityID,
          "notificationToken": userDetails.notificationToken,
          "profilePicture": userDetails.profilePicture,
          "latitude": userDetails.userLatitude,
          "longitude": userDetails.userLongitude,
          "wardNumber": userDetails.userWardNumber
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          }
        ));
        print("Response is: ${response.data}");
        return response;
  }

  // Future<MyProfile> loadMyProfileJson() async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   myProfile = MyProfile.fromJson(json.decode(await getMyProfileJson()));
  //   return myProfile;
  // }
}
