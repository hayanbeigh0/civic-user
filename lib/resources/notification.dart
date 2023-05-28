import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:civic_user/models/grievances/grievance_notification.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_detail/grievance_detail.dart';
import 'package:civic_user/presentation/screens/home/settings/settings.dart';
import 'package:civic_user/widgets/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../generated/locale_keys.g.dart';
import '../presentation/utils/colors/app_colors.dart';

final _firebaseMessaging = FirebaseMessaging.instance;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> onBackgroundMessageFromNotification(RemoteMessage message) async {
  // await commonFloatingMsg(message);
  print("In Background: ${message.data['body']}");
}

final Map<String, String> statusTypesMap = {
  "in-progress": LocaleKeys.grievanceDetail_inProgress.tr(),
  "hold": LocaleKeys.grievanceDetail_hold.tr(),
  "closed": LocaleKeys.grievanceDetail_closed.tr(),
};

String getStatusText(String status) {
  return statusTypesMap[status.toLowerCase()]!;
}

String getGrievanceText(String grievanceType) {
  final Map<String, String> grievanceTypesMap = {
  // "garb": LocaleKeys.grievanceDetail_garb.tr(),
  // "road": LocaleKeys.grievanceDetail_road.tr(),
  // "light": LocaleKeys.grievanceDetail_light.tr(),
  // "cert": LocaleKeys.grievanceDetail_cert.tr(),
  // "house": LocaleKeys.grievanceDetail_house.tr(),
  // "water": LocaleKeys.grievanceDetail_water.tr(),
  // "elect": LocaleKeys.grievanceDetail_elect.tr(),
  // "other": LocaleKeys.grievanceDetail_otherGrievanceType.tr(),
  "garb": "Garbage Collection",
  "road": "Road Maintenance/Construction",
  "light": "Street Lighting",
  "cert": "Certificate Request",
  "house": "House plan approval",
  "water": "Water Supply/ drainage",
  "elect": "Electricity",
  "other": "Other",
};
  log(grievanceTypesMap[grievanceType.toLowerCase()].toString());
  return grievanceTypesMap[grievanceType.toLowerCase()]!;
}

String getStatus(String num) {
  try {
    if (num == '1') {
      return "In-Progress";
    } else if (num == '2') {
      return "Closed";
    } else {
      return "Hold";
    }
  } catch (e) {
    print("error");
    return " ";
  }
}

commonFloatingMsg(message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  String jsonStr = message.notification!.body.toString();
  // String jsonStr = message.data.toString();
  log(jsonStr);
      // print("DATA::: ${message.data.toString()}");


  Map<String, dynamic> map = jsonDecode(jsonStr);
  String grievanceType = map['GrievanceType'];
  String status = map['Status'];
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        "${getGrievanceText(grievanceType)} grievance is updated to ${getStatus(status)}!",
        // notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.blue,
            playSound: true,
            importance: Importance.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),);
  }
}

class FCM {
  Future<String> getTokenValue() async {
    String token = await _firebaseMessaging.getToken() ?? '';
    return token;
  }

  setNotifications(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // listen when notification came. while app is in foreground
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

      final Map<String, String> statusTypesMap = {
        "in-progress": LocaleKeys.grievanceDetail_inProgress.tr(),
        "hold": LocaleKeys.grievanceDetail_hold.tr(),
        "closed": LocaleKeys.grievanceDetail_closed.tr(),
      };

      String getStatusText(String status) {
        return statusTypesMap[status.toLowerCase()]!;
      }

      String getGrievanceText(String grievanceType) {
        return grievanceTypesMap[grievanceType.toLowerCase()]!;
      }

      String getStatus(String num) {
        try {
          if (num == '1') {
            return "In-Progress";
          } else if (num == '2') {
            return "Closed";
          } else {
            return "Hold";
          }
        } catch (e) {
          print("error");
          return " ";
        }
      }

      // String jsonStr = message.notification!.body.toString();
      String jsonStr = message.data["body"];
      log(jsonStr);

      Map<String, dynamic> map = jsonDecode(jsonStr);
      String grievanceID = map['GrievanceID'];
      String grievanceType = map['GrievanceType'];
      String status = map['Status'];
      String lastModifiedDate = map['LastModifiedDate'];
      String description = map['Description'];

      DateTime date = DateTime.parse(lastModifiedDate);
      print("BODY IS: ${message.notification!.body.toString()}");

      // log(message.notification!.body.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "${message.notification!.title.toString()}!",
              style: TextStyle(fontSize: 18.sp),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "The status of your ${getGrievanceText(grievanceType)} grievance is updated to ${getStatus(status)}!"),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  children: [
                    const Text('Description: '),
                    SizedBox(
                        width: 150.w,
                        child: Text(
                          description,
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ))
                  ],
                ),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  children: [
                    const Text('Last Updated: '),
                    Text(
                      DateFormat('\'${(date.day)}\' MMMM yyyy').format(date),
                      style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // PrimaryButton(onTap: () => Navigator.pop(context), buttonText: "Ok", isLoading: false),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style:
                      TextStyle(color: AppColors.colorPrimary, fontSize: 16.sp),
                ),
              ),
            ],
          );
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      // listen when notification came. while app is in background by click of that notification.
      print("onMessageOpenedApp: $message");
      //  final String? payload = message.data['payload'];
      //  if (payload != null) {
      //    final Uri uri = Uri.parse(payload);
      //    if (uri.path == 'grievanceDetail') {
      //      final String? grievanceId = uri.queryParameters['id'];
      //      if (grievanceId != null) {
      //   Navigator.of(context).push(MaterialPageRoute(
      //     builder: (context) => GrievanceDetail(grievanceId: grievanceId),
      //   ));
      // }
      //    }
      //  }



      String jsonStr = message.data['body'];
      // String jsonStr = message.data.toString();

      Map<String, dynamic> map = jsonDecode(jsonStr);
      String grievanceID = map['GrievanceID'];
      // showNotification()
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GrievanceDetail(grievanceId: grievanceID)));
    });

    // With this token you can test it easily on your phone
    final token = _firebaseMessaging.getToken().then((value) async {
      print('Token: $value');
      // Generated fcm token for the device.
    });
  }
}
