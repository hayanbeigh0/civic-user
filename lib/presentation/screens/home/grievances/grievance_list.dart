import 'dart:developer';

import 'package:civic_user/constants/app_constants.dart';
import 'package:civic_user/generated/locale_keys.g.dart';
import 'package:civic_user/logic/blocs/grievances/grievances_bloc.dart';
import 'package:civic_user/main.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_detail/grievance_detail.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_map.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/presentation/utils/functions/date_formatter.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class GrievanceList extends StatelessWidget {
  static const routeName = '/grievanceList';
  GrievanceList({super.key});

  final TextEditingController _searchController = TextEditingController();

  GlobalKey roadmaintainance = GlobalKey();

  GlobalKey streetlighting = GlobalKey();

  GlobalKey watersupplyanddrainage = GlobalKey();

  GlobalKey garbagecollection = GlobalKey();

  GlobalKey certificaterequest = GlobalKey();

  static bool showOnlyOpen = true;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<GrievancesBloc>(context).add(
      LoadGrievancesEvent(
        municipalityId:
            AuthBasedRouting.afterLogin.userDetails!.municipalityID.toString(),
        createdBy: AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
      ),
    );
    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: Column(
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
                                LocaleKeys.grievancesScreen_screenTitle.tr(),
                                style: TextStyle(
                                  color: AppColors.colorWhite,
                                  fontFamily: 'LexendDeca',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                ),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.colorPrimaryExtraLight,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 10.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.sp),
                        borderSide: BorderSide.none,
                      ),
                      hintText:
                          LocaleKeys.grievancesScreen_grievanceSearchHint.tr(),
                      hintStyle: TextStyle(
                        color: AppColors.textColorLight,
                        fontFamily: 'LexendDeca',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.sp,
                          horizontal: 20.sp,
                        ),
                        child: SvgPicture.asset(
                          'assets/svg/searchfieldsuffix.svg',
                          fit: BoxFit.contain,
                          width: 20.sp,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        return BlocProvider.of<GrievancesBloc>(context).add(
                          LoadGrievancesEvent(
                              municipalityId: AuthBasedRouting
                                  .afterLogin.userDetails!.municipalityID
                                  .toString(),
                              createdBy: AuthBasedRouting
                                  .afterLogin.userDetails!.userID
                                  .toString()),
                        );
                      }
                      if (value.isNotEmpty) {
                        return BlocProvider.of<GrievancesBloc>(context).add(
                          SearchGrievanceByTypeEvent(grievanceType: value),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 75.h,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.screenPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            LocaleKeys.grievancesScreen_openGrievancesOnly.tr(),
                            style: TextStyle(
                              color: AppColors.colorPrimary,
                              fontFamily: 'LexendDeca',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ShowOnlyOpenSwitch(),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            LocaleKeys.grievancesScreen_resultsOrderedBy.tr(),
                            style: TextStyle(
                              color: AppColors.colorGreyLight,
                              fontFamily: 'LexendDeca',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      Divider(
                        height: 10.h,
                        color: AppColors.colorGreyLight,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<GrievancesBloc, GrievancesState>(
                    builder: (context, state) {
                      if (state is GrievancesLoadingState) {
                        return Shimmer.fromColors(
                          baseColor: AppColors.colorPrimary200,
                          highlightColor: AppColors.colorPrimaryExtraLight,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            itemCount: 8,
                            itemBuilder: (context, index) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.screenPadding,
                                vertical: 15.h,
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: AppConstants.screenPadding,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.colorPrimaryLight,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(5, 5),
                                    blurRadius: 10,
                                    color: AppColors.cardShadowColor,
                                  ),
                                  BoxShadow(
                                    offset: Offset(-5, -5),
                                    blurRadius: 10,
                                    color: AppColors.colorWhite,
                                  ),
                                ],
                              ),
                              width: double.infinity,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SvgPicture.asset('assets/svg/complaint.svg'),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: AppColors.cardTextColor,
                                            fontFamily: 'LexendDeca',
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: AppColors.cardTextColor,
                                            fontFamily: 'LexendDeca',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: AppColors.cardTextColor,
                                            fontFamily: 'LexendDeca',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: AppColors.cardTextColor,
                                            fontFamily: 'LexendDeca',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(100.r),
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.all(18.w),
                                        decoration: const BoxDecoration(
                                          color: AppColors.colorPrimaryLight,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(5, 5),
                                              blurRadius: 10,
                                              color: AppColors.cardShadowColor,
                                            ),
                                            BoxShadow(
                                              offset: Offset(-5, -5),
                                              blurRadius: 10,
                                              color: AppColors.colorWhite,
                                            ),
                                          ],
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/arrowright.svg',
                                          color: AppColors.colorPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      if (state is GrievancesLoadedState) {
                        print("State.grievanceList: ${state.grievanceList}");
                        if (state.grievanceList.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              return BlocProvider.of<GrievancesBloc>(context)
                                  .add(LoadGrievancesEvent(
                                      municipalityId: AuthBasedRouting
                                          .afterLogin
                                          .userDetails!
                                          .municipalityID
                                          .toString(),
                                      createdBy: AuthBasedRouting
                                          .afterLogin.userDetails!.userID
                                          .toString()));
                            },
                            child: Stack(
                              children: [
                                ListView(),
                                Center(
                                  child: Text(
                                    LocaleKeys
                                        .grievancesScreen_noGrievanceErrorMessage
                                        .tr(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return GrievanceListWidget(
                            state: state,
                          );
                        }
                      }
                      if (state is NoGrievanceFoundState) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            return BlocProvider.of<GrievancesBloc>(context).add(
                                LoadGrievancesEvent(
                                    municipalityId: AuthBasedRouting
                                        .afterLogin.userDetails!.municipalityID
                                        .toString(),
                                    createdBy: AuthBasedRouting
                                        .afterLogin.userDetails!.userID
                                        .toString()));
                          },
                          child: Stack(
                            children: [
                              ListView(),
                              Center(
                                child: Text(LocaleKeys
                                    .grievancesScreen_noGrievanceErrorMessage
                                    .tr()),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShowOnlyOpenSwitch extends StatefulWidget {
  const ShowOnlyOpenSwitch({
    Key? key,
  }) : super(key: key);

  // static bool showOnlyOpen = false;
  @override
  State<ShowOnlyOpenSwitch> createState() => ShowOnlyOpenSwitchState();
}

class ShowOnlyOpenSwitchState extends State<ShowOnlyOpenSwitch> {
  static bool showOnlyOpen = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeColor: AppColors.colorPrimary,
      value: showOnlyOpen,
      onChanged: (value) {
        setState(() {
          showOnlyOpen = value;
        });
        if (value) {
          return BlocProvider.of<GrievancesBloc>(context)
              .add(ShowOnlyOpenGrievancesEvent());
        } else {
          return BlocProvider.of<GrievancesBloc>(context).add(
            LoadGrievancesEvent(
              municipalityId: AuthBasedRouting
                  .afterLogin.userDetails!.municipalityID
                  .toString(),
              createdBy:
                  AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
            ),
          );
        }
      },
    );
  }
}

class GrievanceListWidget extends StatelessWidget {
  GrievanceListWidget({
    Key? key,
    this.state = const GrievancesLoadedState(
      grievanceList: [],
      selectedFilterNumber: 1,
    ),
  }) : super(key: key);
  final GrievancesLoadedState state;
  late List<dynamic> statusList = [];
  final Map<String, String> svgList = {
    "road": 'assets/svg/roadmaintainance.svg',
    "light": 'assets/svg/streetlighting.svg',
    "water": 'assets/svg/watersupplyanddrainage.svg',
    "garb": 'assets/svg/garbagecollection.svg',
    "cert": 'assets/svg/certificaterequest.svg',
    "house": 'assets/svg/houseplanapproval.svg',
    "other": 'assets/svg/complaint.svg',
    "elect": 'assets/svg/elec.svg',
  };

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

  String getGrievanceText(String grievanceType) {
    return grievanceTypesMap[grievanceType.toLowerCase()]!;
  }

  String getStatusText(String status) {
    return statusTypesMap[status.toLowerCase()]!;
  }

  String getStatus(String num, List<dynamic> statusList) {
    try {
      int index = int.parse(num);
      String priority = '';
      priority = statusList[index - 1];
      return getStatusText(priority);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var masterDataList = AuthBasedRouting.afterLogin.masterData!;
    for (var i = 0; i < masterDataList.length; i++) {
      if (masterDataList[i].active == true &&
          masterDataList[i].pK == '#GRIEVANCESTATUS#') {
        statusList.add(masterDataList[i].name);
      }
    }
    return RefreshIndicator(
      color: AppColors.colorPrimary,
      onRefresh: () async {
        log("OpenSwitch: ${ShowOnlyOpenSwitchState.showOnlyOpen}");
        if (ShowOnlyOpenSwitchState.showOnlyOpen) {
          BlocProvider.of<GrievancesBloc>(context)
              .add(ShowOnlyOpenGrievancesEvent());
        } else {
          BlocProvider.of<GrievancesBloc>(context).add(
            LoadGrievancesEvent(
              municipalityId: AuthBasedRouting
                  .afterLogin.userDetails!.municipalityID
                  .toString(),
              createdBy:
                  AuthBasedRouting.afterLogin.userDetails!.userID.toString(),
            ),
          );
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        itemCount: state.grievanceList.isEmpty ? 8 : state.grievanceList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(GrievanceDetail.routeName, arguments: {
                "state": state,
                "index": index,
                "grievanceId": state.grievanceList[index].grievanceId,
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 15.h,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.colorPrimaryLight,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(5, 5),
                    blurRadius: 10,
                    color: AppColors.cardShadowColor,
                  ),
                  BoxShadow(
                    offset: Offset(-5, -5),
                    blurRadius: 10,
                    color: AppColors.colorWhite,
                  ),
                ],
              ),
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(
                    width: 10.w,
                  ),
                  SvgPicture.asset(
                    svgList[state.grievanceList[index].grievanceType!
                            .replaceAll(' ', '')
                            .toString()
                            .toLowerCase()]
                        .toString(),
                    width: 60.w,
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGrievanceText(state
                              .grievanceList[index].grievanceType
                              .toString()),
                          // getGrievanceText(state.grievanceList[index].grievanceType.toString(),),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.cardTextColor,
                            fontFamily: 'LexendDeca',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, 3),
                              child: Icon(
                                Icons.location_pin,
                                color: AppColors.colorPrimaryDark,
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              child: Text(
                                state.grievanceList[index].location.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  color: AppColors.cardTextColor,
                                  fontFamily: 'LexendDeca',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppColors.colorPrimaryDark,
                              size: 16.sp,
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Text(
                              '${getStatus(state.grievanceList[index].status.toString(), statusList)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.cardTextColor,
                                fontFamily: 'LexendDeca',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color: AppColors.colorPrimaryDark,
                              size: 16.sp,
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Text(
                              '${DateFormatter.formatDate(
                                state.grievanceList[index].lastModifiedDate
                                    .toString(),
                              )}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.cardTextColor,
                                fontFamily: 'LexendDeca',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Container(
                      padding: EdgeInsets.all(14.sp),
                      decoration: const BoxDecoration(
                        color: AppColors.colorPrimaryLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(5, 5),
                            blurRadius: 10,
                            color: AppColors.cardShadowColor,
                          ),
                          BoxShadow(
                            offset: Offset(-5, -5),
                            blurRadius: 10,
                            color: AppColors.colorWhite,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrowright.svg',
                        color: AppColors.colorPrimary,
                        width: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
