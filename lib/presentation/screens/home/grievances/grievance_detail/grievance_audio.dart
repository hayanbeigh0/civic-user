import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../../logic/blocs/grievances/grievances_bloc.dart';
import '../../../../../widgets/audio_comment_widget.dart';
import '../../../../../widgets/primary_bottom_shape.dart';
import '../../../../../widgets/primary_top_shape.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../../../utils/styles/app_styles.dart';

class GrievanceAudio extends StatelessWidget {
  static const routeName = '/grievanceAudio';
  const GrievanceAudio({
    super.key,
    required this.state,
    required this.grievanceListIndex,
  });
  final GrievanceByIdLoadedState state;
  final int grievanceListIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryTopShape(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 18.0.w,
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
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5.sp),
                            color: Colors.transparent,
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
                                  LocaleKeys.grievanceDetail_audio.tr(),
                                  style: AppStyles.screenTitleStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18.0.w,
                vertical: 10.h,
              ),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 30.w,
                  mainAxisSpacing: 20.h,
                ),
                itemCount: state.grievanceDetail.assets!.audio!.length,
                //  +
                //     state.grievanceList[grievanceListIndex].videos!.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AudioComment(
                                      audioUrl: state.grievanceDetail.assets!.audio![index],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          height: 110.h,
                          width: 110.h,
                          margin: EdgeInsets.only(right: 12.w),
                          padding: EdgeInsets.all(20.sp),
                          decoration: BoxDecoration(
                            color: AppColors.colorPrimaryLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: SvgPicture.asset(
                            'assets/svg/audiofile.svg',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        '${LocaleKeys.grievanceDetail_audio.tr()} - ${index + 1}',
                        style: AppStyles.audioTitleTextStyle,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 30.h,
          ),
        ],
      ),
      bottomNavigationBar: PrimaryBottomShape(
        height: 80.h,
      ),
    );
  }
}
