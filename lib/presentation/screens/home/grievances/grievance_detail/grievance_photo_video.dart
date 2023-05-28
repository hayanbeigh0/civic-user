import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../../logic/blocs/grievances/grievances_bloc.dart';
import '../../../../../widgets/primary_top_shape.dart';
import '../../../../../widgets/video_widget.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../../../utils/styles/app_styles.dart';

class GrievancePhotoVideo extends StatelessWidget {
  static const routeName = '/grievancePhotoVideo';
  const GrievancePhotoVideo({
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
                                Container(
                                  width: 200.w,
                                  child: Text(
                                    LocaleKeys.grievanceDetail_photosAndVideos
                                        .tr(),
                                    style: AppStyles.screenTitleStyle,
                                  ),
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
                horizontal: AppConstants.screenPadding,
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
                itemCount: state.grievanceDetail.assets!.image!.length +
                    state.grievanceDetail.assets!.video!.length,
                itemBuilder: (context, index) {
                  if (index < state.grievanceDetail.assets!.image!.length) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: Center(
                              child: Image.network(state.grievanceDetail.assets!
                                          .image![index], fit: BoxFit.cover),
                            ),
                          );
                        }));
                      },
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.colorPrimaryExtraLight,
                          borderRadius: BorderRadius.circular(
                            20.r,
                          ),
                        ),
                        child: Image.network(
                          state.grievanceDetail.assets!.image![index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.colorPrimaryExtraLight,
                        borderRadius: BorderRadius.circular(
                          20.r,
                        ),
                      ),
                      child: VideoWidget(
                        url: state.grievanceDetail.assets!.video!.length == 1
                            ? state.grievanceDetail.assets!.video![0]
                            : state.grievanceDetail.assets!.video![index %
                                state.grievanceDetail.assets!.video!.length],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          SizedBox(
            height: 30.h,
          ),
        ],
      ),
      // bottomNavigationBar: PrimaryBottomShape(
      //   height: 80.h,
      // ),
    );
  }
}
