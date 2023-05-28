import 'package:civic_user/presentation/screens/home/settings/settings.dart';
import 'package:civic_user/presentation/screens/home/your_requirements/your_requirements.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:civic_user/models/grid_tile_model.dart';
import 'package:civic_user/presentation/screens/home/add_grievance/add_grievance.dart';
import 'package:civic_user/presentation/screens/home/business_lead/business_lead.dart';
import 'package:civic_user/presentation/screens/home/grievances/grievance_list.dart';
import 'package:civic_user/presentation/screens/home/profile/profile.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/locale_keys.g.dart';

part 'home_grid_items_state.dart';

class HomeGridItemsCubit extends Cubit<HomeGridItemsState> {
  final List<HomeGridTile> gridItems = [
    HomeGridTile(
      routeName: GrievanceList.routeName,
      gridIcon: AspectRatio(
        aspectRatio: 3.5,
        child: SvgPicture.asset('assets/svg/enrolluser.svg'),
      ),
      gridTileTitle: LocaleKeys.homeScreen_grievances.tr(),
    ),
    HomeGridTile(
      routeName: AddGrievance.routeName,
      gridIcon: AspectRatio(
        aspectRatio: 3,
        child: SvgPicture.asset(
          'assets/svg/complaint.svg',
          color: AppColors.colorPrimaryIcon,
        ),
      ),
      gridTileTitle: LocaleKeys.homeScreen_addGrievance.tr(),
    ),
    // HomeGridTile(
    //   routeName: BusinessLead.routeName,
    //   gridIcon: AspectRatio(
    //     aspectRatio: 3.5,
    //     child: SvgPicture.asset('assets/svg/businesslead.svg'),
    //   ),
    //   gridTileTitle: 'Business Lead',
    // ),
    // HomeGridTile(
    //   routeName: YourRequirements.routeName,
    //   gridIcon: AspectRatio(
    //     aspectRatio: 4,
    //     child: SvgPicture.asset('assets/svg/yourrequirements.svg'),
    //   ),
    //   gridTileTitle: 'Your Requirements',
    // ),
    HomeGridTile(
      routeName: Settings.routeName,
      gridIcon: AspectRatio(
        aspectRatio: 3,
        child: SvgPicture.asset('assets/svg/contact.svg', color: Color(0xff687EA6),),
      ),
      gridTileTitle: LocaleKeys.homeScreen_contactUs.tr(),
    ),
    HomeGridTile(
      routeName: ProfileScreen.routeName,
      gridIcon: AspectRatio(
        aspectRatio: 3,
        child: SvgPicture.asset('assets/svg/profile.svg'),
      ),
      gridTileTitle: LocaleKeys.homeScreen_profile.tr(),
    ),
  ];
  HomeGridItemsCubit() : super(HomeGridItemsLoading());
  loadSearchedGridItems(String title, bool searching) {
    emit(HomeGridItemsLoading());
    if (searching) {
      final List<HomeGridTile> sortedList = gridItems
          .where((element) =>
              element.gridTileTitle.toLowerCase().toString().contains(title))
          .toList();

      emit(HomeGridItemsLoaded(gridItems: sortedList));
    } else {
      emit(HomeGridItemsLoaded(gridItems: gridItems));
    }
  }

  loadAllGridItems() {
    emit(HomeGridItemsLoading());

    emit(HomeGridItemsLoaded(gridItems: gridItems));
  }
}
