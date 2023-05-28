import 'dart:async';
import 'dart:developer';
import 'package:civic_user/resources/repositories/auth/authentication_repository.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../models/user_details.dart';
import '../cubit/local_storage_cubit.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(this.authRepository) : super(AuthenticationInitial());
  final AuthenticationRepository authRepository;

  String? sessionId;
  String? username;
  String? phoneNumber;

  late StreamSubscription subscription;
  authSuccessState() {
    subscription = LocalStorageCubit().stream.listen(
      (state) {
        if (state is LocalStorageFetchingDoneState) {
          // emit(AuthenticationSuccessState(afterLogin: state.userDetails));
        }
      },
    );
  }

  signIn(String phoneNumber, bool resendOtp) async {
    this.phoneNumber = phoneNumber;
    emit(AuthenticationLoading());
    try {
      final response = await authRepository.signIn(phoneNumber);
      final responseBody = response.data;
      if (response.statusCode == 200) {
        if (responseBody['CUSTOM_CHALLENGE'] != null &&
            responseBody['Session'] != null) {
          sessionId = responseBody['Session'];
        } else {
          sessionId = responseBody['session'];
          username = responseBody['username'];
        }

        if (!resendOtp) {
          emit(
            NavigateToActivationState(
              phoneNumber: phoneNumber,
              sessionId: sessionId.toString(),
              username: username.toString(),
            ),
          );
        } else {
          emit(OtpSentSuccessfully());
          emit(
            OtpSentState(
              phoneNumber: phoneNumber,
              sessionId: sessionId.toString(),
              username: username.toString(),
            ),
          );
        }
      } else {
        emit(AuthenticationLoginErrorState(error: responseBody));
      }
    } on DioError catch (e) {
      // if (e.response!.statusCode == 400) {}
      if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.receiveTimeout ||
          e.type == DioErrorType.sendTimeout) {
        emit(
            AuthenticationLoginErrorState(
            error: LocaleKeys.loginAndActivationScreen_timeoutErrorMessage.tr(),
          ),
        );
      }
      if (e.type == DioErrorType.unknown) {
        return emit(
          AuthenticationLoginErrorState(
            error: LocaleKeys.loginAndActivationScreen_unknownErrorMessage.tr(),
          ),
        );
      }
      if (e.response!.data == "User Phone number is not yet registered") {
        return emit(
          AuthenticationLoginErrorState(
            error: LocaleKeys.loginAndActivationScreen_phoneNotRegistered.tr(),
          ),
        );
      }
      log(error: e.toString(), '3');
      emit(
        AuthenticationLoginErrorState(
          error: e.response!.statusMessage.toString(),
        ),
      );
    }
  }

  verifyOtp(Map<String, dynamic> userDetails, String otp, String notificationToken) async {
    emit(AuthenticationLoading());
    try {
      final Response response =
          await authRepository.verifyOtp(userDetails, otp, notificationToken);
      final responseBody = response.data;
      if (response.statusCode == 200) {
        if (responseBody['AuthenticationResult'] == null) {
          emit(AuthenticationOtpErrorState(
            error:  LocaleKeys.loginAndActivationScreen_invalidOtp.tr()));
          sessionId = responseBody['Session'];
          username = username;
          emit(
            OtpSentState(
              phoneNumber: phoneNumber.toString(),
              sessionId: sessionId.toString(),
              username: username.toString(),
            ),
          );
        } else if (responseBody['AuthenticationResult']['AccessToken'] !=
            null) {
          AfterLogin afterLogin = AfterLogin.fromJson(responseBody);
          emit(AuthenticationSuccessState(afterLogin: afterLogin));
        } else {
          log(error: response.data, '1');
          emit(AuthenticationOtpErrorState(error: response.data));
        }
      } else {
        log(error: response.data, '2');
        emit(
          AuthenticationOtpErrorState(
            error: response.data,
          ),
        );
      }
    } on DioError catch (e) {
      // if (e.response!.statusCode == 400) {}
      if (e.type == DioErrorType.connectionTimeout ||
          e.type == DioErrorType.receiveTimeout ||
          e.type == DioErrorType.sendTimeout) {
        emit(
          AuthenticationOtpErrorState(
            error: LocaleKeys.loginAndActivationScreen_timeoutErrorMessage.tr(),
          ),
        );
      }
      if (e.type == DioErrorType.unknown) {
        emit(
          AuthenticationOtpErrorState(
            error:LocaleKeys.loginAndActivationScreen_unknownErrorMessage.tr(),
          ),
        );
        emit(
          OtpSentState(
            sessionId: sessionId.toString(),
            username: username.toString(),
            phoneNumber: phoneNumber.toString(),
          ),
        );
      }
      log(error: e.toString(), '3');
      try {
        if (e.response!.data['message'] == 'Unrecognizable lambda output') {
          emit(
            AuthenticationOtpErrorState(
              error:
                  LocaleKeys.loginAndActivationScreen_unknownErrorMessage.tr(),
            ),
          );
          emit(
            OtpSentState(
              sessionId: sessionId.toString(),
              username: username.toString(),
              phoneNumber: phoneNumber.toString(),
            ),
          );
          return;
        }
      } catch (e) {
        emit(
          AuthenticationOtpErrorState(
            error: LocaleKeys.loginAndActivationScreen_unknownErrorMessage.tr(),
          ),
        );
        emit(
          OtpSentState(
            sessionId: sessionId.toString(),
            username: username.toString(),
            phoneNumber: phoneNumber.toString(),
          ),
        );
        return;
      }
      if (e.response!.data['message'] == "Invalid session for the user.") {
        emit(
          AuthenticationOtpErrorState(
            error:
                LocaleKeys.loginAndActivationScreen_exeeded3attemptsError.tr(),
          ),
        );
        emit(
          OtpSentState(
            sessionId: sessionId.toString(),
            username: username.toString(),
            phoneNumber: phoneNumber.toString(),
          ),
        );
        return;
      }
      if (e.type == DioErrorType.unknown) {
        emit(
           AuthenticationOtpErrorState(
            error: LocaleKeys.loginAndActivationScreen_unknownErrorMessage.tr(),
          ),
        );
        emit(
          OtpSentState(
            sessionId: sessionId.toString(),
            username: username.toString(),
            phoneNumber: phoneNumber.toString(),
          ),
        );
        return;
      }
      log(error: e.toString(), '3');
      emit(
        AuthenticationOtpErrorState(
          error: LocaleKeys.loginAndActivationScreen_unknownErrorMessage.tr(),
        ),
      );
      emit(
        OtpSentState(
          sessionId: sessionId.toString(),
          username: username.toString(),
          phoneNumber: phoneNumber.toString(),
        ),
      );
    }
  }
}

