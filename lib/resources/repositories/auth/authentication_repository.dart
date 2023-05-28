import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../constants/env_variable.dart';

class AuthenticationRepository {
  signIn(String phoneNumber) async {
    var url = "$API_URL/cognito/sign-in";
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({"phone_number": phoneNumber, "user_type": "USER"});

    var response = await Dio().post(
      url,
      options: Options(
        headers: headers,
      ),
      data: body,
    );
    return response;
  }

  // verifyOtp(Map<String, dynamic> userDetails, String otp) async {
  //   var url = "$API_URL/cognito/verify";
  //   var headers = {'Content-Type': 'application/json'};
  //   var body = jsonEncode({
  //     "username": userDetails['username'],
  //     "session": userDetails['session'],
  //     "phone_number": userDetails['phone_number'],
  //     "user_type": userDetails['user_type'],
  //     "answer": otp
  //   });
  //   // log(body);

  //   var response = await Dio().post(
  //     url,
  //     options: Options(
  //       headers: headers,
  //     ),
  //     data: body,
  //   );
  //   return response;
  // }

  verifyOtp(Map<String, dynamic> userDetails, String otp, String notificationToken) async {
    var url = "$API_URL/cognito/verify";
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({
      "username": userDetails['username'],
      "session": userDetails['session'],
      "phone_number": userDetails['phone_number'],
      "user_type": userDetails['user_type'],
      "notificationToken": notificationToken,
      "answer": otp
    });
    // log(body);

    var response = await Dio().post(
      url,
      options: Options(
        headers: headers,
      ),
      data: body,
    );
    return response;
  }

  
}

