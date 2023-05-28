import 'package:civic_user/presentation/screens/home/add_grievance/add_grievance.dart';
import 'package:civic_user/presentation/screens/home/business_lead/business_lead.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_detail/grievance_detail.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_list.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_map.dart';
import 'package:civic_user/presentation/screens/home/profile/edit_profile.dart';
import 'package:civic_user/presentation/screens/home/profile/profile.dart';
import 'package:civic_user/presentation/screens/home/settings/settings.dart';
import 'package:civic_user/presentation/screens/home/your_requirements/your_requirements.dart';
import 'package:flutter/material.dart';

import 'package:civic_user/presentation/screens/home/home.dart';
import 'package:civic_user/presentation/screens/login/activation_screen.dart';
import 'package:civic_user/presentation/screens/login/login.dart';

import '../presentation/screens/home/grievances/grievance_detail/comments/grievance_comments.dart';
import '../presentation/screens/home/grievances/grievance_detail/grievance_audio.dart';
import '../presentation/screens/home/grievances/grievance_detail/grievance_photo_video.dart';

class AppRouter {
  static Route? onGenrateRoute(RouteSettings routeSettings) {
    final Map<String, dynamic> args = routeSettings.arguments == null
        ? {}
        : routeSettings.arguments as Map<String, dynamic>;
    switch (routeSettings.name) {
      case Login.routeName:
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case Activation.routeName:
        return MaterialPageRoute(
          builder: (context) => Activation(
            mobileNumber: args['mobileNumber'],
            userDetails: args['userDetails'],
          ),
        );
      case GrievanceList.routeName:
        return MaterialPageRoute(
          builder: (context) => GrievanceList(),
        );
      case HomeScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => HomeScreen(),
        );
      case ProfileScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => ProfileScreen(),
        );
      case BusinessLead.routeName:
        return MaterialPageRoute(
          builder: (context) => const BusinessLead(),
        );
      case AddGrievance.routeName:
        return MaterialPageRoute(
          builder: (context) => AddGrievance(),
        );
      case YourRequirements.routeName:
        return MaterialPageRoute(
          builder: (context) => const YourRequirements(),
        );
      // case GrievanceMap.routeName:
      //   return MaterialPageRoute(
      //     builder: (context) => GrievanceMap(),
      //   );
      case GrievanceDetail.routeName:
        return MaterialPageRoute(
          builder: (context) => GrievanceDetail(
            grievanceId: args['grievanceId'],
          ),
        );
      case GrievancePhotoVideo.routeName:
        return MaterialPageRoute(
          builder: (context) => GrievancePhotoVideo(
            grievanceListIndex: args['index'],
            state: args['state'],
          ),
        );
      case GrievanceAudio.routeName:
        return MaterialPageRoute(
          builder: (context) => GrievanceAudio(
            grievanceListIndex: args['index'],
            state: args['state'],
          ),
        );
      case EditProfileScreen.routeName:
        return MaterialPageRoute(
          builder: (context) => EditProfileScreen(
            myProfile: args['my_profile'],
          ),
        );
      case Settings.routeName:
        return MaterialPageRoute(
          builder: (context) => const Settings(),
        );
      case AllComments.routeName:
        return MaterialPageRoute(
          builder: (context) => AllComments(
            grievanceId: args['grievanceId'],
          ),
        );

      default:
        return null;
    }
  }
}
