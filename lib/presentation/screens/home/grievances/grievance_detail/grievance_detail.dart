import 'dart:async';
import 'dart:developer';

import 'package:civic_user/constants/app_constants.dart';
import 'package:civic_user/generated/locale_keys.g.dart';
import 'package:civic_user/logic/blocs/grievances/grievances_bloc.dart';
import 'package:civic_user/main.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_detail/grievance_audio.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_detail/grievance_photo_video.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/widgets/audio_comment_widget.dart';
import 'package:civic_user/widgets/location_map_field.dart';
import 'package:civic_user/widgets/photo_comment_widget.dart';
import 'package:civic_user/widgets/primary_display_field.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:civic_user/widgets/secondary_button.dart';
import 'package:civic_user/widgets/text_comment_widget.dart';
import 'package:civic_user/widgets/video_comment_widget.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../models/grievances/grievance_detail.dart';
import '../../../../../models/grievances/grievances_model.dart';
import '../../../../../models/user_details.dart';
import '../../../../../widgets/primary_text_field.dart';
import '../../../../../widgets/video_thumbnail.dart';
import '../../../../../widgets/video_widget.dart';
import '../../../../utils/styles/app_styles.dart';
import 'comments/grievance_comments.dart';

class GrievanceDetail extends StatelessWidget {
  static const routeName = '/grievanceDetail';
  GrievanceDetail({
    super.key,
    required this.grievanceId,
  });
  final String grievanceId;
  final Completer<GoogleMapController> _controller = Completer();
  late List<dynamic> statusList = [];
  // late Map<dynamic, dynamic> grievanceTypesMap;
  late List<dynamic> grievanceTypesList;
  List<Comments>? grievanceComments;
  List<String> expectedCompletionList = ['1 Day', '2 Days', '3 Days'];
  late List<dynamic> priorityList = [];
  late String statusDropdownValue;
  late String expectedCompletionDropdownValue;
  late String priorityDropdownValue;
  late String grievanceTypeDropdownValue;

  bool showDropdownError = false;
  TextEditingController reporterController = TextEditingController();
  TextEditingController commentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var masterDataList = AuthBasedRouting.afterLogin.masterData!;
    for (var i = 0; i < masterDataList.length; i++) {
      if (masterDataList[i].active == true &&
          masterDataList[i].pK == '#PRIORITY#') {
        priorityList.add(masterDataList[i].name);
      }
    }

    for (var i = 0; i < masterDataList.length; i++) {
      if (masterDataList[i].active == true &&
          masterDataList[i].pK == '#GRIEVANCESTATUS#') {
        statusList.add(masterDataList[i].name);
      }
    }

    BlocProvider.of<GrievancesBloc>(context).add(
      GetGrievanceByIdEvent(
        municipalityId:
            AuthBasedRouting.afterLogin.userDetails!.municipalityID!,
        grievanceId: grievanceId,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: WillPopScope(
        onWillPop: () async {
          BlocProvider.of<GrievancesBloc>(context).add(
            LoadGrievancesEvent(
              municipalityId:
                  AuthBasedRouting.afterLogin.userDetails!.municipalityID!,
              createdBy: AuthBasedRouting.afterLogin.userDetails!.userID!,
            ),
          );
          return true;
        },
        child: Column(
          children: [
            const GrievanceDetailAppBar(),
            BlocConsumer<GrievancesBloc, GrievancesState>(
              listener: (context, state) {
                if (state is GrievanceUpdatedState) {
                  Navigator.of(context).maybePop();
                  BlocProvider.of<GrievancesBloc>(context).add(
                    LoadGrievancesEvent(
                      municipalityId: AuthBasedRouting
                          .afterLogin.userDetails!.municipalityID!,
                      createdBy:
                          AuthBasedRouting.afterLogin.userDetails!.userID!,
                    ),
                  );
                }
                if (state is GrievancesLoadedState) {
                  BlocProvider.of<GrievancesBloc>(context).add(
                    GetGrievanceByIdEvent(
                      municipalityId: AuthBasedRouting
                          .afterLogin.userDetails!.municipalityID
                          .toString(),
                      grievanceId: grievanceId,
                    ),
                  );
                }
                if (state is LoadingGrievanceByIdFailedState) {
                  BlocProvider.of<GrievancesBloc>(context).add(
                    GetGrievanceByIdEvent(
                      municipalityId: AuthBasedRouting
                          .afterLogin.userDetails!.municipalityID
                          .toString(),
                      grievanceId: grievanceId,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is UpdatingGrievanceStatusState) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  );
                }
                if (state is LoadingGrievanceByIdState) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.colorPrimary,
                      ),
                    ),
                  );
                }
                if (state is GrievanceByIdLoadedState) {
                  grievanceComments = state.grievanceDetail.comments;
                  grievanceComments!.sort((a, b) =>
                      DateTime.parse(a.createdDate.toString())
                          .compareTo(DateTime.parse(b.createdDate.toString())));
                  grievanceComments = grievanceComments!.reversed
                      .take(6)
                      .toList()
                      .reversed
                      .toList();
                  return grievanceDetails(context, state);
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

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

  final Map<String, String> priorityTypesMap = {
    "1": LocaleKeys.grievanceDetail_priorityImmidiate.tr(),
    "2": LocaleKeys.grievanceDetail_priority1WorkingDay.tr(),
    "3": LocaleKeys.grievanceDetail_priority1Week.tr(),
    "4": LocaleKeys.grievanceDetail_priority1Month.tr(),
    "5": LocaleKeys.grievanceDetail_priorityDummy.tr(),
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
      String status = '';
      status = statusList[index - 1];
      return getStatusText(status);
    } catch (e) {
      return '';
    }
  }

  String getPriorityText(String priority) {
    return priorityTypesMap[priority]!;
  }

  String getPriority(String num, List<dynamic> prioritylist) {
    return getPriorityText(num.toString());
    // try {
    //   int index = int.parse(num);
    //   String priority = '';
    //   priority = prioritylist[index - 1];
    //   return priority;
    // } catch (e) {
    //   return '';
    // }
  }

  grievanceDetails(BuildContext context, GrievanceByIdLoadedState state) {
    reporterController.text = state.grievanceDetail.createdByName.toString();
    statusDropdownValue = state.grievanceDetail.status.toString();
    expectedCompletionDropdownValue =
        state.grievanceDetail.expectedCompletion.toString();
    priorityDropdownValue = state.grievanceDetail.priority.toString();
    grievanceTypeDropdownValue = state.grievanceDetail.grievanceType!;

    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryDisplayField(
                  title: LocaleKeys.grievanceDetail_type.tr(),
                  value: getGrievanceText(
                      state.grievanceDetail.grievanceType.toString())),
              SizedBox(
                height: 5.h,
              ),
              SizedBox(
                height: 7.h,
              ),
              Divider(
                height: 10.h,
                color: AppColors.colorGreyLight,
              ),
              SizedBox(
                height: 10.h,
              ),
              PrimaryDisplayField(
                title: LocaleKeys.grievanceDetail_status.tr(),
                value: getStatus(
                    state.grievanceDetail.status.toString(), statusList),
              ),
              SizedBox(
                height: 12.h,
              ),
              PrimaryDisplayField(
                  title: LocaleKeys.grievanceDetail_priority.tr(),
                  value: getPriority(
                      state.grievanceDetail.priority.toString(), priorityList)),
              state.grievanceDetail.grievanceType == 'HOUSE' &&
                      state.grievanceDetail.planDetails != null
                  ? Column(
                      children: [
                        SizedBox(
                          height: 12.h,
                        ),
                        PrimaryDisplayField(
                          title: 'New house address',
                          value:
                              state.grievanceDetail.newHouseAddress.toString(),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        PrimaryDisplayField(
                          title: 'Plan details',
                          value: state.grievanceDetail.planDetails.toString(),
                        ),
                      ],
                    )
                  : const SizedBox(),
              state.grievanceDetail.grievanceType == 'CERT' &&
                      state.grievanceDetail.deceasedName != null
                  ? Column(
                      children: [
                        SizedBox(
                          height: 12.h,
                        ),
                        PrimaryDisplayField(
                          title: 'Deceased name',
                          value: state.grievanceDetail.deceasedName.toString(),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        PrimaryDisplayField(
                          title: 'Relation',
                          value: state.grievanceDetail.relation.toString(),
                        ),
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: 12.h,
              ),
              state.grievanceDetail.assets!.video!.isEmpty &&
                      state.grievanceDetail.assets!.image!.isEmpty
                  ? const SizedBox()
                  : Column(
                      children: [
                        Text(
                          LocaleKeys.grievanceDetail_photosAndVideos.tr(),
                          style: AppStyles.inputAndDisplayTitleStyle,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          height: 70.h,
                          child: Stack(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: state
                                        .grievanceDetail.assets!.image!.length +
                                    state.grievanceDetail.assets!.video!.length,
                                itemBuilder: (context, index) {
                                  if (index <
                                      state.grievanceDetail.assets!.image!
                                          .length) {
                                    return Container(
                                      clipBehavior: Clip.antiAlias,
                                      height: 70.h,
                                      width: 70.h,
                                      margin: EdgeInsets.only(right: 12.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Image.network(
                                        state.grievanceDetail.assets!
                                            .image![index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      clipBehavior: Clip.antiAlias,
                                      height: 70.h,
                                      width: 70.h,
                                      margin: EdgeInsets.only(right: 12.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.colorPrimaryLight,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        onPressed: () {},
                                      ),
                                    );
                                  }
                                },
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                top: 0,
                                child: Container(
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color.fromARGB(15, 0, 0, 0),
                                        Color.fromARGB(255, 0, 0, 0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          GrievancePhotoVideo.routeName,
                                          arguments: {
                                            "index": 1,
                                            "state": state,
                                          },
                                        );
                                      },
                                      child: Text(
                                        LocaleKeys.grievanceDetail_viewAll.tr(),
                                        style: AppStyles.viewAllWhiteTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              state.grievanceDetail.assets!.audio!.isEmpty
                  ? const SizedBox()
                  : Column(
                      children: [
                        SizedBox(
                          height: 12.h,
                        ),
                        Text(
                          LocaleKeys.grievanceDetail_voiceAndAudio.tr(),
                          style: AppStyles.inputAndDisplayTitleStyle,
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          height: 100.h,
                          child: Stack(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    state.grievanceDetail.assets!.audio!.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        clipBehavior: Clip.antiAlias,
                                        height: 70.h,
                                        width: 70.h,
                                        margin: EdgeInsets.only(right: 12.w),
                                        padding: EdgeInsets.all(20.sp),
                                        decoration: BoxDecoration(
                                          color: AppColors.colorPrimaryLight,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/svg/audiofile.svg',
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
                              Positioned(
                                right: 0,
                                bottom: 0,
                                top: 0,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    width: 100.w,
                                    height: 70.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.r),
                                        bottomRight: Radius.circular(10.r),
                                      ),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color.fromARGB(0, 0, 0, 0),
                                          Color.fromARGB(255, 0, 0, 0),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            GrievanceAudio.routeName,
                                            arguments: {
                                              "index": 1,
                                              "state": state,
                                            },
                                          );
                                        },
                                        child: Text(
                                          LocaleKeys.grievanceDetail_viewAll
                                              .tr(),
                                          style:
                                              AppStyles.viewAllWhiteTextStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                      ],
                    ),
              Text(
                LocaleKeys.grievanceDetail_locaiton.tr(),
                style: AppStyles.inputAndDisplayTitleStyle,
              ),
              SizedBox(
                height: 5.h,
              ),
              Stack(
                children: [
                  LocationMapField(
                    markerEnabled: true,
                    gesturesEnabled: false,
                    myLocationEnabled: false,
                    zoomEnabled: false,
                    mapController: _controller,
                    latitude: double.parse(
                      state.grievanceDetail.locationLat.toString(),
                    ),
                    longitude: double.parse(
                      state.grievanceDetail.locationLong.toString(),
                    ),
                    address: state.grievanceDetail.address,
                  ),
                  Container(
                    height: 180.h,
                    width: double.infinity,
                    color: Colors.transparent,
                  )
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              Text(
                LocaleKeys.grievanceDetail_description.tr(),
                style: AppStyles.inputAndDisplayTitleStyle,
              ),
              SizedBox(
                height: 5.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  state.grievanceDetail.description.toString(),
                  style: AppStyles.descriptiveTextStyle,
                ),
              ),
              SizedBox(
                height: 12.h,
              ),
              Row(
                children: [
                  Text(
                    LocaleKeys.grievanceDetail_contactByPhoneEnabled.tr(),
                    style: AppStyles.inputAndDisplayTitleStyle,
                  ),
                  const Spacer(),
                  Text(
                    state.grievanceDetail.mobileContactStatus == true
                        ? LocaleKeys.grievanceDetail_yes.tr()
                        : LocaleKeys.grievanceDetail_no.tr(),
                    style: AppStyles.inputAndDisplayTitleStyle,
                  ),
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              Row(
                children: [
                  Text(
                    LocaleKeys.grievanceDetail_comments.tr(),
                    style: AppStyles.inputAndDisplayTitleStyle,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    '(${LocaleKeys.grievanceDetail_latest6Comments.tr()})',
                    style: AppStyles.inputAndDisplayTitleStyle,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AllComments.routeName,
                        arguments: {
                          'grievanceId': state.grievanceDetail.grievanceID,
                        },
                      );
                    },
                    child: Text(
                      LocaleKeys.grievanceDetail_addComment.tr(),
                      style: AppStyles.inputAndDisplayTitleStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12.h,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: grievanceComments!.isEmpty
                    ? Center(
                        child: Text(
                            LocaleKeys.grievanceDetail_noCommentsMessage.tr()),
                      )
                    : Column(
                        children:
                            // children:

                            grievanceComments!.mapIndexed((i, e) {
                        if (i >= 6) {
                          return const SizedBox();
                        }
                        return Column(
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            e.comment == '' ||
                                    e.comment == null ||
                                    e.comment!.isEmpty
                                ? const SizedBox()
                                : TextCommentWidget(
                                    // commentList: [],
                                    commentList:
                                        grievanceComments as List<Comments>,
                                    commentListIndex: i,
                                  ),
                            e.assets == null
                                ? const SizedBox()
                                : e.assets!.image == null ||
                                        e.assets!.image == [] ||
                                        e.assets!.image!.isEmpty
                                    ? const SizedBox()
                                    : PhotoCommentWidget(
                                        // commentList: [],
                                        commentList:
                                            grievanceComments as List<Comments>,
                                        commentListIndex: i,
                                      ),
                            e.assets == null
                                ? const SizedBox()
                                : e.assets!.video == null ||
                                        e.assets!.video == [] ||
                                        e.assets!.video!.isEmpty
                                    ? const SizedBox()
                                    : Stack(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    FullScreenVideoPlayer(
                                                  url: e.assets!.video![0],
                                                  file: null,
                                                ),
                                              ));
                                            },
                                            child: Align(
                                              alignment: e.commentedBy ==
                                                      AuthBasedRouting
                                                          .afterLogin
                                                          .userDetails!
                                                          .userID
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: Container(
                                                width: 200.w,
                                                height: 150.h,
                                                decoration: BoxDecoration(
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      blurRadius: 2,
                                                      offset: Offset(1, 1),
                                                      color: AppColors
                                                          .cardShadowColor,
                                                    ),
                                                    BoxShadow(
                                                      blurRadius: 2,
                                                      offset: Offset(-1, -1),
                                                      color:
                                                          AppColors.colorWhite,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r),
                                                  color: AppColors
                                                      .colorPrimaryLight,
                                                ),
                                                child: VideoThumbnail(
                                                  url: e.assets!.video![0],
                                                  commentList:
                                                      grievanceComments,
                                                  commentListIndex: i,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                            e.assets == null
                                ? const SizedBox()
                                : e.assets!.audio == null ||
                                        e.assets!.video == [] ||
                                        e.assets!.audio!.isEmpty
                                    ? const SizedBox()
                                    : AudioCommentWidget(
                                        // commentList: [],
                                        commentList:
                                            grievanceComments as List<Comments>,
                                        commentListIndex: i,
                                      ),
                            SizedBox(
                              height: 10.h,
                            ),
                            // i <
                            //         state.grievanceDetail
                            //                 .comments!.length -
                            //             1
                            //     ? const Divider(
                            //         color: AppColors.colorGreyLight,
                            //       )
                            //     : const SizedBox(),
                          ],
                        );
                      }).toList()),
              ),
              SizedBox(
                height: 30.h,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: BlocConsumer<GrievancesBloc, GrievancesState>(
                  listener: (context, grievanceClosing) {
                    if (grievanceClosing is GrievanceClosedState) {
                      Navigator.of(context).pop();
                    }
                  },
                  builder: (context, grievanceClosing) {
                    if (state.grievanceDetail.status == '2') {
                      return const SizedBox();
                    }
                    if (grievanceClosing is ClosingGrievanceState) {
                      return SecondaryButton(
                        buttonText:
                            LocaleKeys.grievanceDetail_closeGrievance.tr(),
                        isLoading: true,
                        onTap: () {},
                      );
                    }
                    if (grievanceClosing is ClosingGrievanceFailedState) {
                      return SecondaryButton(
                        buttonText:
                            LocaleKeys.grievanceDetail_closeGrievance.tr(),
                        isLoading: false,
                        onTap: () async {
                          late bool showClosingDialog;
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Text(
                                LocaleKeys
                                    .grievanceDetail_closingGrievanceWarningMessage
                                    .tr(),
                              ),
                              contentPadding: EdgeInsets.all(24.sp),
                              actions: [
                                SecondaryDialogButton(
                                  onTap: () {
                                    showClosingDialog = false;
                                    Navigator.of(context).pop();
                                    return;
                                  },
                                  buttonText:
                                      LocaleKeys.grievanceDetail_no.tr(),
                                  isLoading: false,
                                  trailingIconEnabled: false,
                                ),
                                PrimaryDialogButton(
                                  onTap: () {
                                    showClosingDialog = true;
                                    Navigator.of(context).pop();
                                  },
                                  buttonText:
                                      LocaleKeys.grievanceDetail_yes.tr(),
                                  isLoading: false,
                                  trailingIconEnabled: false,
                                ),
                              ],
                            ),
                          );
                          if (!showClosingDialog) {
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.grievanceDetail_closingMessage
                                        .tr(),
                                    style: AppStyles.inputAndDisplayTitleStyle,
                                  ),
                                  SizedBox(
                                    height: 12.h,
                                  ),
                                  PrimaryTextField(
                                    title: LocaleKeys.addComment_comment.tr(),
                                    hintText: LocaleKeys
                                        .grievanceDetail_closeHintText
                                        .tr(),
                                    textEditingController:
                                        commentTextController,
                                  ),
                                  SizedBox(
                                    height: 24.h,
                                  ),
                                  BlocConsumer<GrievancesBloc, GrievancesState>(
                                    listener: (context, state) {
                                      if (state
                                          is AddingGrievanceCommentSuccessState) {
                                        log('comment added');
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is GrievanceByIdLoadedState) {
                                        return Align(
                                          alignment: Alignment.bottomRight,
                                          child: PrimaryDialogButton(
                                            buttonText: LocaleKeys
                                                .addGrievance_submit
                                                .tr(),
                                            isLoading: false,
                                            onTap: () {
                                              BlocProvider.of<GrievancesBloc>(
                                                      context)
                                                  .add(
                                                AddGrievanceCommentEvent(
                                                  grievanceId: grievanceId,
                                                  userId: AuthBasedRouting
                                                      .afterLogin
                                                      .userDetails!
                                                      .userID
                                                      .toString(),
                                                  name: AuthBasedRouting
                                                      .afterLogin
                                                      .userDetails!
                                                      .firstName
                                                      .toString(),
                                                  assets: const {},
                                                  comment: commentTextController
                                                          .text.isEmpty
                                                      ? 'The grievance is closed.'
                                                      : commentTextController
                                                          .text,
                                                ),
                                              );
                                              final grievance =
                                                  state.grievanceDetail;
                                              BlocProvider.of<GrievancesBloc>(
                                                      context)
                                                  .add(
                                                UpdateGrievanceEvent(
                                                  grievanceId: state
                                                      .grievanceDetail
                                                      .grievanceID
                                                      .toString(),
                                                  municipalityId:
                                                      AuthBasedRouting
                                                          .afterLogin
                                                          .userDetails!
                                                          .municipalityID!,
                                                  newGrievance: Grievances(
                                                    createdBy: AuthBasedRouting
                                                        .afterLogin
                                                        .userDetails!
                                                        .userID!,
                                                    createdDate:
                                                        grievance.createdDate,
                                                    deceasedName:
                                                        grievance.deceasedName,
                                                    newHouseAddress: grievance
                                                        .newHouseAddress,
                                                    planDetails:
                                                        grievance.planDetails,
                                                    relation:
                                                        grievance.relation,
                                                    municipalityId: grievance
                                                        .municipalityID,
                                                    grievanceId:
                                                        grievance.grievanceID,
                                                    address: grievance.address,
                                                    contactNumber:
                                                        grievance.contactNumber,
                                                    createdByName:
                                                        grievance.createdByName,
                                                    description:
                                                        grievance.description,
                                                    assets: state
                                                        .grievanceDetail.assets!
                                                        .toJson(),
                                                    expectedCompletion:
                                                        expectedCompletionDropdownValue,
                                                    grievanceType:
                                                        grievanceTypeDropdownValue,
                                                    latitude:
                                                        grievance.locationLat,
                                                    longitude:
                                                        grievance.locationLong,
                                                    priority:
                                                        priorityDropdownValue,
                                                    status: '2',
                                                    wardNumber:
                                                        grievance.wardNumber,
                                                    lastModifiedDate:
                                                        DateTime.now()
                                                            .toString(),
                                                    location:
                                                        grievance.location,
                                                    contactByPhoneEnabled:
                                                        grievance
                                                            .mobileContactStatus,
                                                  ),
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        );
                                      }
                                      if (state is AddGrievanceCommentEvent) {
                                        return Align(
                                          alignment: Alignment.bottomRight,
                                          child: PrimaryDialogButton(
                                            buttonText: LocaleKeys
                                                .addGrievance_submit
                                                .tr(),
                                            isLoading: true,
                                            onTap: () {},
                                          ),
                                        );
                                      }
                                      return Align(
                                        alignment: Alignment.bottomRight,
                                        child: PrimaryDialogButton(
                                          buttonText: LocaleKeys
                                              .addGrievance_submit
                                              .tr(),
                                          isLoading: false,
                                          onTap: () {},
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                          // BlocProvider.of<GrievancesBloc>(context).add(
                          //   CloseGrievanceEvent(
                          //     grievanceId:
                          //         state.grievanceDetail.grievanceID.toString(),
                          //   ),
                          // );
                        },
                      );
                    }
                    return SecondaryButton(
                      buttonText:
                          LocaleKeys.grievanceDetail_closeGrievance.tr(),
                      isLoading: false,
                      onTap: () async {
                        late bool showClosingDialog;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(
                              LocaleKeys
                                  .grievanceDetail_closingGrievanceWarningMessage
                                  .tr(),
                            ),
                            contentPadding: EdgeInsets.all(24.sp),
                            actions: [
                              SecondaryDialogButton(
                                onTap: () {
                                  showClosingDialog = false;
                                  Navigator.of(context).pop();
                                  return;
                                },
                                buttonText: LocaleKeys.grievanceDetail_no.tr(),
                                isLoading: false,
                                trailingIconEnabled: false,
                              ),
                              PrimaryDialogButton(
                                onTap: () {
                                  showClosingDialog = true;
                                  Navigator.of(context).pop();
                                },
                                buttonText: LocaleKeys.grievanceDetail_yes.tr(),
                                isLoading: false,
                                trailingIconEnabled: false,
                              ),
                            ],
                          ),
                        );
                        if (!showClosingDialog) {
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Closing comment',
                                //   style: AppStyles.inputAndDisplayTitleStyle,
                                // ),
                                SizedBox(
                                  height: 12.h,
                                ),
                                PrimaryTextField(
                                  title: LocaleKeys
                                      .grievanceDetail_closingMessage
                                      .tr(),
                                  hintText: LocaleKeys
                                      .grievanceDetail_closeHintText
                                      .tr(),
                                  textEditingController: commentTextController,
                                ),
                                SizedBox(
                                  height: 24.h,
                                ),
                                BlocConsumer<GrievancesBloc, GrievancesState>(
                                  listener: (context, state) {
                                    if (state
                                        is AddingGrievanceCommentSuccessState) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is GrievanceByIdLoadedState) {
                                      return Align(
                                        alignment: Alignment.bottomRight,
                                        child: PrimaryDialogButton(
                                          buttonText: LocaleKeys
                                              .addGrievance_submit
                                              .tr(),
                                          isLoading: false,
                                          onTap: () {
                                            BlocProvider.of<GrievancesBloc>(
                                                    context)
                                                .add(
                                              AddGrievanceCommentEvent(
                                                grievanceId: grievanceId,
                                                userId: AuthBasedRouting
                                                    .afterLogin
                                                    .userDetails!
                                                    .userID
                                                    .toString(),
                                                name: AuthBasedRouting
                                                    .afterLogin
                                                    .userDetails!
                                                    .firstName
                                                    .toString(),
                                                assets: const {},
                                                comment: commentTextController
                                                        .text.isEmpty
                                                    ? 'The grievance is closed.'
                                                    : commentTextController
                                                        .text,
                                              ),
                                            );
                                            final grievance =
                                                state.grievanceDetail;
                                            BlocProvider.of<GrievancesBloc>(
                                                    context)
                                                .add(
                                              UpdateGrievanceEvent(
                                                grievanceId: state
                                                    .grievanceDetail.grievanceID
                                                    .toString(),
                                                municipalityId: AuthBasedRouting
                                                    .afterLogin
                                                    .userDetails!
                                                    .municipalityID!,
                                                newGrievance: Grievances(
                                                  createdBy: AuthBasedRouting
                                                      .afterLogin
                                                      .userDetails!
                                                      .userID!,
                                                  createdDate:
                                                      grievance.createdDate,
                                                  deceasedName:
                                                      grievance.deceasedName,
                                                  newHouseAddress:
                                                      grievance.newHouseAddress,
                                                  planDetails:
                                                      grievance.planDetails,
                                                  relation: grievance.relation,
                                                  grievanceId:
                                                      grievance.grievanceID,
                                                  assets: state
                                                      .grievanceDetail.assets!
                                                      .toJson(),
                                                  description:
                                                      grievance.description,
                                                  expectedCompletion:
                                                      expectedCompletionDropdownValue,
                                                  grievanceType:
                                                      grievanceTypeDropdownValue,
                                                  latitude:
                                                      grievance.locationLat,
                                                  longitude:
                                                      grievance.locationLong,
                                                  address: grievance.address,
                                                  priority:
                                                      priorityDropdownValue,
                                                  status: '2',
                                                  wardNumber:
                                                      grievance.wardNumber,
                                                  contactNumber:
                                                      grievance.contactNumber,
                                                  createdByName:
                                                      grievance.createdByName,
                                                  lastModifiedDate:
                                                      DateTime.now().toString(),
                                                  location: grievance.location,
                                                  contactByPhoneEnabled:
                                                      grievance
                                                          .mobileContactStatus,
                                                  municipalityId:
                                                      grievance.municipalityID,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    if (state is AddGrievanceCommentEvent) {
                                      return Align(
                                        alignment: Alignment.bottomRight,
                                        child: PrimaryDialogButton(
                                          buttonText: LocaleKeys
                                              .addGrievance_submit
                                              .tr(),
                                          isLoading: true,
                                          onTap: () {},
                                        ),
                                      );
                                    }
                                    return Align(
                                      alignment: Alignment.bottomRight,
                                      child: PrimaryDialogButton(
                                        buttonText:
                                            LocaleKeys.addGrievance_submit.tr(),
                                        isLoading: false,
                                        onTap: () {},
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            // content: const Text(
                            //     'Are you sure you want to cancel the grievance?'),
                            // contentPadding: EdgeInsets.all(24.sp),
                            // actions: [
                            //   SecondaryDialogButton(
                            //     onTap: () => Navigator.of(context).pop(),
                            //     buttonText: 'No',
                            //     isLoading: false,
                            //     trailingIconEnabled: false,
                            //   ),
                            //   PrimaryDialogButton(
                            //     onTap: () {},
                            //     buttonText: 'Yes',
                            //     isLoading: false,
                            //     trailingIconEnabled: false,
                            //   ),
                            // ],
                          ),
                        );
                        // BlocProvider.of<GrievancesBloc>(context).add(
                        //   CloseGrievanceEvent(
                        //     grievanceId:
                        //         state.grievanceDetail.grievanceID.toString(),
                        //   ),
                        // );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GrievanceDetailAppBar extends StatelessWidget {
  const GrievanceDetailAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrimaryTopShape(
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
                    onTap: () async {
                      BlocProvider.of<GrievancesBloc>(context).add(
                        LoadGrievancesEvent(
                            municipalityId: AuthBasedRouting
                                .afterLogin.userDetails!.municipalityID!,
                            createdBy: AuthBasedRouting
                                .afterLogin.userDetails!.userID!),
                      );
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
    );
  }
}

class PrimaryDialogButton extends StatelessWidget {
  const PrimaryDialogButton({
    Key? key,
    required this.onTap,
    required this.buttonText,
    required this.isLoading,
    this.enabled = true,
    this.trailingIconEnabled = true,
  }) : super(key: key);

  final VoidCallback onTap;
  final String buttonText;
  final bool isLoading;
  final bool enabled;
  final bool trailingIconEnabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading && !enabled ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: 12.sp,
          horizontal: 28.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.r,
          ),
        ),
        backgroundColor: AppColors.colorPrimary,
        foregroundColor: AppColors.colorWhite,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            buttonText,
            style: AppStyles.primaryButtonTextStyle.copyWith(
              fontSize: 14.sp,
            ),
          ),
          trailingIconEnabled
              ? Column(
                  children: [
                    SizedBox(
                      width: 10.w,
                    ),
                    isLoading
                        ? Center(
                            child: SizedBox(
                              height: 20.sp,
                              width: 20.sp,
                              child: const RepaintBoundary(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.colorWhite,
                                ),
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/icons/arrowright.svg',
                            width: 20.w,
                          ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class SecondaryDialogButton extends StatelessWidget {
  const SecondaryDialogButton({
    Key? key,
    required this.onTap,
    required this.buttonText,
    required this.isLoading,
    this.enabled = true,
    this.trailingIconEnabled = true,
  }) : super(key: key);

  final VoidCallback onTap;
  final String buttonText;
  final bool isLoading;
  final bool enabled;
  final bool trailingIconEnabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading && !enabled ? null : onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.colorWhite,
        foregroundColor: AppColors.colorPrimary,
        side: const BorderSide(
          color: AppColors.colorPrimary,
          width: 1.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 12.sp,
          horizontal: 28.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.r,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            buttonText,
            style: AppStyles.secondaryButtonTextStyle.copyWith(
              fontSize: 14.sp,
            ),
          ),
          trailingIconEnabled
              ? Column(
                  children: [
                    SizedBox(
                      width: 10.w,
                    ),
                    isLoading
                        ? Center(
                            child: SizedBox(
                              height: 20.sp,
                              width: 20.sp,
                              child: const RepaintBoundary(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.colorWhite,
                                ),
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/icons/arrowright.svg',
                            width: 20.w,
                          ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
