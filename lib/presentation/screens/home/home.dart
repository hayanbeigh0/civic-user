// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:civic_user/constants/app_constants.dart';
import 'package:civic_user/generated/locale_keys.g.dart';
import 'package:civic_user/logic/blocs/grievances/grievances_bloc.dart';
import 'package:civic_user/logic/cubits/current_location/current_location_cubit.dart';
import 'package:civic_user/logic/cubits/home_grid_items/home_grid_items_cubit.dart';
import 'package:civic_user/logic/cubits/my_profile/my_profile_cubit.dart';
import 'package:civic_user/main.dart';
import 'package:civic_user/models/grid_tile_model.dart';
import 'package:civic_user/presentation/screens/home/profile/profile.dart';
import 'package:civic_user/resources/notification.dart';
import 'package:civic_user/widgets/primary_bottom_shape.dart';
import 'package:civic_user/widgets/primary_top_shape.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:civic_user/presentation/utils/colors/app_colors.dart';

import '../../../logic/cubits/cubit/local_storage_cubit.dart';
import '../../utils/styles/app_styles.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> municpalityList = {};

  final Map<String, String> municipalitiesTypesMap = {
    "MUNCI-1": LocaleKeys.municipality_MUNCI_1.tr(),
  };

  final List<HomeGridTile> gridItems = [
    HomeGridTile(
      routeName: ProfileScreen.routeName,
      gridIcon: AspectRatio(
        aspectRatio: 3,
        child: SvgPicture.asset('assets/svg/profile.svg'),
      ),
      gridTileTitle: LocaleKeys.homeScreen_profile.tr(),
    ),
  ];

  FCM fcm = FCM();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fcm.setNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    var masterDataList = AuthBasedRouting.afterLogin.masterData!;
    var userWardList = AuthBasedRouting.afterLogin.wardDetails!;

    Map<String, String> activeMunicipalities = {};
    Map<String, String> activeWards = {};

    for (var i = 0; i < masterDataList.length; i++) {
      if (masterDataList[i].active == true &&
          masterDataList[i].pK == '#MUNICIPALITY#') {
        activeMunicipalities[masterDataList[i].sK!] = masterDataList[i].name!;
      }
    }

    String getMunicipalityName(String sk) {
      String munci = '';
      munci = activeMunicipalities[sk].toString();
      return munci;
    }

    String getWardName(String wardNumber, String municipalityID) {
      String wardName = '';
      for (var i = 0; i < userWardList.length; i++) {
        if (userWardList[i].active == true &&
            userWardList[i].municipalityID == municipalityID) {
          activeWards[userWardList[i].wardNumber!] = userWardList[i].wardName!;
        }
      }
      wardName = activeWards[wardNumber].toString();
      return wardName;
    }

    List<String> gridTitles = [LocaleKeys.homeScreen_grievances.tr(), LocaleKeys.homeScreen_addGrievance.tr(), LocaleKeys.homeScreen_contactUs.tr(), LocaleKeys.homeScreen_profile.tr()]; 

    BlocProvider.of<CurrentLocationCubit>(context).getCurrentLocation();
    BlocProvider.of<HomeGridItemsCubit>(context).loadAllGridItems();
    BlocProvider.of<MyProfileCubit>(context).getMyProfile(
        AuthBasedRouting.afterLogin.userDetails!.userID.toString());
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
                        Text(
                          LocaleKeys.appName.tr(),
                          style: TextStyle(
                            color: AppColors.colorWhite,
                            fontFamily: 'LexendDeca',
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<Locale>(
                          color: AppColors.colorPrimaryExtraLight,
                          icon: const Icon(
                            Icons.language,
                            color: AppColors.colorWhite,
                          ),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: Locale('en'),
                              child: Text(LocaleKeys.english.tr()),
                            ),
                            PopupMenuItem(
                              value: Locale('ta'),
                              child: Text(LocaleKeys.tamil.tr()),
                            ),
                          ],
                          onSelected: (newLocale) async {
                            await SharedPreferences.getInstance().then((prefs) {
                              prefs.setString(
                                  'language', newLocale.languageCode);
                            });
                            context.setLocale(newLocale);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        HomeScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  BlocBuilder<LocalStorageCubit, LocalStorageState>(
                    builder: (context, state) {
                      if (state is LocalStorageFetchingDoneState) {
                        return Text(
                          municipalitiesTypesMap.containsKey(state
                                  .afterLogin.masterData!
                                  .firstWhere((element) =>
                                      element.sK ==
                                      state.afterLogin.userDetails!
                                          .municipalityID!)
                                  .sK)
                              ? municipalitiesTypesMap[state
                                  .afterLogin.masterData!
                                  .firstWhere((element) =>
                                      element.sK ==
                                      state.afterLogin.userDetails!
                                          .municipalityID!)
                                  .sK]!
                              : state.afterLogin.masterData!
                                  .firstWhere((element) =>
                                      element.sK ==
                                      state.afterLogin.userDetails!
                                          .municipalityID!)
                                  .name!,
                          style: AppStyles.dashboardAppNameStyle
                              .copyWith(fontSize: 18.sp),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  // Row(children: [
                  //   Text(
                  //     '${getMunicipalityName(AuthBasedRouting.afterLogin.userDetails!.municipalityID!)}',
                  //     style: TextStyle(
                  //       color: AppColors.colorWhite,
                  //       fontFamily: 'LexendDeca',
                  //       fontSize: 22.sp,
                  //       fontWeight: FontWeight.w400,
                  //       height: 1.1,
                  //     ),
                  //   ),
                  // ]),
                  SizedBox(
                    height: 10.h,
                  ),
                  // Row(children: [
                  //   const Icon(
                  //     Icons.location_pin,
                  //     color: Colors.white,
                  //   ),
                  //   BlocBuilder<MyProfileCubit, MyProfileState>(
                  //       builder: (context, profileState) {
                  //     if (profileState is MyProfileLoading) {
                  //       return Center(
                  //         child: SizedBox(
                  //           height: 15.h,
                  //           width: 15.w,
                  //           child: const CircularProgressIndicator(
                  //             strokeWidth: 2.0,
                  //             color: AppColors.colorWhite,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //     if (profileState is MyProfileLoaded) {
                  //       return SizedBox(
                  //         width: 200.h,
                  //         child: Text(
                  //           profileState.myProfile.address.toString(),
                  //           style: TextStyle(
                  //             color: AppColors.colorWhite,
                  //             fontFamily: 'LexendDeca',
                  //             fontSize: 12.sp,
                  //             fontWeight: FontWeight.w400,
                  //             height: 1.1,
                  //           ),
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //         ),
                  //       );
                  //     }
                  //     if (profileState is MyProfileLoading) {
                  //       return const Center(
                  //         child: CircularProgressIndicator(
                  //             color: AppColors.colorPrimary),
                  //       );
                  //     }
                  //     return const SizedBox();
                  //   }),
                  // ]),
                  // SizedBox(
                  //   height: 5.h,
                  // ),
                  // Row(children: [
                  //   const Icon(
                  //     Icons.call,
                  //     color: Colors.white,
                  //   ),
                  //   Text(
                  //     '${AuthBasedRouting.afterLogin.userDetails!.mobileNumber.toString()}',
                  //     style: TextStyle(
                  //       color: AppColors.colorWhite,
                  //       fontFamily: 'LexendDeca',
                  //       fontSize: 12.sp,
                  //       fontWeight: FontWeight.w400,
                  //       height: 1.1,
                  //     ),
                  //   ),
                  // ]),
                  BlocBuilder<MyProfileCubit, MyProfileState>(
                      builder: (context, profileState) {
                    if (profileState is MyProfileLoading) {
                      return SizedBox(
                        height: 15.h,
                        width: 15.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: AppColors.colorWhite,
                        ),
                      );
                    }
                    if (profileState is MyProfileLoaded) {
                      return Text(
                        '${LocaleKeys.homeScreen_welcome.tr()} ${profileState.myProfile.firstName.toString()}!',
                        style: TextStyle(
                          color: AppColors.colorWhite,
                          fontFamily: 'LexendDeca',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                  SizedBox(
                    height: 75.h,
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: 30.h,
          // ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              width: double.infinity,
              child: BlocBuilder<HomeGridItemsCubit, HomeGridItemsState>(
                builder: (context, state) {
                  if (state is HomeGridItemsLoaded) {
                    return GridView.builder(
                      padding: EdgeInsets.only(
                        left: AppConstants.screenPadding,
                        right: AppConstants.screenPadding,
                        bottom: AppConstants.screenPadding,
                        top: AppConstants.screenPadding,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 30.w,
                        mainAxisSpacing: 30.w,
                      ),
                      itemCount: state.gridItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(
                            20.r,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              state.gridItems[index].routeName,
                            );
                          },
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30.h,
                                ),
                                state.gridItems[index].gridIcon,
                                Expanded(
                                  child: Container(
                                    width: 120.w,
                                    alignment: Alignment.center,
                                    child: Text(
                                      // state.gridItems[index].gridTileTitle,
                                      gridTitles[index],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textColorDark,
                                        fontFamily: 'LexendDeca',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
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
}
