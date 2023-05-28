import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/presentation/utils/styles/app_styles.dart';
import 'package:civic_user/widgets/primary_bottom_shape.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../generated/locale_keys.g.dart';

class Settings extends StatelessWidget {
  static const routeName = '/settings';
  const Settings({super.key});

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
                          LocaleKeys.homeScreen_contactUs.tr(),
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
                padding: EdgeInsets.symmetric(
                  horizontal: 18.0.sp,
                  vertical: 20.h,
                ),
                child: Column(
                  children: [
                    SettingsScreenCard(
                      icon: SvgPicture.asset(
                        'assets/svg/email.svg',
                        color: AppColors.colorPrimary,
                        width: 30.w,
                      ),
                      onTap: () {
                        launchEmailApp('nammaoorapp@gmail.com');
                      },
                      title: 'nammaoorapp@gmail.com',
                    ),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                    // SettingsScreenCard(
                    //   icon: SvgPicture.asset(
                    //     'assets/svg/call.svg',
                    //     width: 25.w,
                    //   ),
                    //   onTap: () {
                    //     makePhoneCall('7051744660');
                    //   },
                    //   title: '7051744660',
                    // ),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                    // SettingsScreenCard(
                    //   icon: SvgPicture.asset(
                    //     'assets/svg/website.svg',
                    //     width: 35.w,
                    //   ),
                    //   onTap: () {
                    //     launchWebUrl('https://www.google.com');
                    //   },
                    //   title: 'www.google.com',
                    // ),
                    // SizedBox(
                    //   height: 20.h,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PrimaryBottomShape(
        height: 80.h,
      ),
    );
  }

  void launchWebUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void makePhoneCall(String phoneNumber) async {
    final Uri params = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    String url = params.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void launchEmailApp(String path) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: path,
    );
    String url = params.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class SettingsScreenCard extends StatelessWidget {
  const SettingsScreenCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        20.r,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorPrimaryExtraLight,
          borderRadius: BorderRadius.circular(
            20.r,
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Color.fromARGB(87, 40, 97, 204),
            ),
            BoxShadow(
              offset: Offset(-1, -1),
              blurRadius: 2,
              color: AppColors.colorWhite,
              blurStyle: BlurStyle.normal,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 60.h,
              width: 60.w,
              child: Align(
                alignment: Alignment.center,
                child: icon,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: AppStyles.settingsScreenCardText,
              ),
            ),
            // const Spacer(),
            Container(
              padding: EdgeInsets.all(14.sp),
              decoration: const BoxDecoration(
                color: AppColors.colorPrimaryLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: AppColors.cardShadowColor,
                  ),
                  BoxShadow(
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                    color: AppColors.colorWhite,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/icons/arrowright.svg',
                color: AppColors.colorPrimary,
                width: 25.sp,
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
          ],
        ),
      ),
    );
  }
}
