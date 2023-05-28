import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_constants.dart';
import '../generated/locale_keys.g.dart';
import '../presentation/utils/colors/app_colors.dart';
import '../presentation/utils/styles/app_styles.dart';

class VideoPlay extends StatefulWidget {
  final String videoUrl;
  const VideoPlay({super.key, required this.videoUrl});

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  late VideoPlayerController controller;
  
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.videoUrl);
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
                horizontal: AppConstants.screenPadding,
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
                          onTap: () {
                            Navigator.of(context).pop();
                          },
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
                                LocaleKeys.grievanceDetail_screenTitle.tr(),
                                style: AppStyles.screenTitleStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 150.h,
          ),
        ],
      ),
    );
  }
}
