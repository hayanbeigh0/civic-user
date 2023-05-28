import 'dart:convert';
import 'dart:developer';
import 'package:civic_user/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../models/user_details.dart';

part 'local_storage_state.dart';

class LocalStorageCubit extends Cubit<LocalStorageState> {
  LocalStorageCubit() : super(LocalStorageInitial());
  AfterLogin? afterLogin; 

  storeUserData(AfterLogin userDetails) async {
    emit(LocalStorageFetchingState());
    try {
      final userJson = jsonEncode(userDetails);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user-userdetails', userJson);
      log('User json storing in local storage:$userJson');
      emit(LocalStorageStoringDoneState());
      AuthBasedRouting.afterLogin = userDetails;
      emit(LocalStorageFetchingDoneState(afterLogin: userDetails));
    } catch (e) {
      emit(LocalStorageStoringFailedState());
    }
  }

  Future<void> containsUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool containsUser = prefs.containsKey('user-userdetails');
    emit(LocalStorageUserDataPresentState(userDataPresent: containsUser));
  }

  Future<void> getUserDataFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user-userdetails');
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      final afterLogin = AfterLogin.fromJson(jsonMap);
      // log('Allocated wards: ${afterLogin.masterData![0].name.toString()}');
      emit(LocalStorageFetchingDoneState(afterLogin: afterLogin));
    } else {
      log("Failed fetching local data");
      emit(LocalStorageFetchingFailedState());
    }
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    afterLogin = null;
    await prefs.remove('staff-userdetails');
    await prefs.clear();
    final containsUser = prefs.containsKey('staff-userdetails');
    if (!containsUser) {
      emit(const LocalStorageUserDataPresentState(userDataPresent: false));
      emit(LocalStorageClearingUserSuccessState());
    } else {
      emit(LocalStorageClearingUserFailedState());
    }
  }
}
