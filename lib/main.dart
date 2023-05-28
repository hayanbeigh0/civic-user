import 'package:civic_user/logic/blocs/grievances/grievances_bloc.dart';
import 'package:civic_user/logic/cubits/authentication/authentication_cubit.dart';
import 'package:civic_user/logic/cubits/current_location/current_location_cubit.dart';
import 'package:civic_user/logic/cubits/home_grid_items/home_grid_items_cubit.dart';
import 'package:civic_user/logic/cubits/my_profile/my_profile_cubit.dart';
import 'package:civic_user/logic/cubits/reverse_geocoding/reverse_geocoding_cubit.dart';
import 'package:civic_user/models/user_details.dart';
import 'package:civic_user/presentation/screens/home/home.dart';
import 'package:civic_user/presentation/screens/login/login.dart';
import 'package:civic_user/presentation/utils/colors/app_colors.dart';
import 'package:civic_user/resources/notification.dart';
import 'package:civic_user/resources/repositories/auth/authentication_repository.dart';
import 'package:civic_user/resources/repositories/grievances/grievances_repository.dart';
import 'package:civic_user/resources/repositories/my_profile/my_profile.dart';
import 'package:civic_user/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logic/cubits/cubit/local_storage_cubit.dart';

Future init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(onBackgroundMessageFromNotification);
}

late Locale locale;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await init();
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language') ?? 'en';
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Future.delayed(const Duration(seconds: 2));
  locale = WidgetsBinding.instance.window.locales.first;
  runApp(
    EasyLocalization(
      path: 'assets/i18n',
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
      ],
      startLocale: Locale(languageCode),
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    locale = WidgetsBinding.instance.window.locales.first;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    setState(() {
      context.setLocale(Locale(locales!.first.languageCode));
    });
    super.didChangeLocales(locales);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<GrievancesBloc>(
              create: (context) => GrievancesBloc(GrievancesRepository()),
            ),
            BlocProvider<ReverseGeocodingCubit>(
              create: (context) => ReverseGeocodingCubit(),
            ),
            BlocProvider<CurrentLocationCubit>(
              create: (context) => CurrentLocationCubit(),
            ),
            BlocProvider<MyProfileCubit>(
              create: (context) => MyProfileCubit(
                MyProfileRerpository(),
              ),
            ),
            BlocProvider<AuthenticationCubit>(
              create: (context) => AuthenticationCubit(
                AuthenticationRepository(),
              ),
            ),
            BlocProvider<LocalStorageCubit>(
              create: (context) => LocalStorageCubit(),
            ),
            BlocProvider<HomeGridItemsCubit>(
              create: (context) => HomeGridItemsCubit(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'User App',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData(
              fontFamily: 'LexendDeca',
              useMaterial3: true,
              primaryColor: AppColors.colorPrimary,
            ),
            home: const AuthBasedRouting(),
            onGenerateRoute: (settings) => AppRouter.onGenrateRoute(settings),
          ),
        );
      },
    );
  }
}

class AuthBasedRouting extends StatelessWidget {
  const AuthBasedRouting({
    Key? key,
  }) : super(key: key);

  static late AfterLogin afterLogin;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<LocalStorageCubit>(context).getUserDataFromLocalStorage();
    return BlocBuilder<LocalStorageCubit, LocalStorageState>(
      builder: (context, state) {
        if (state is LocalStorageFetchingDoneState) {
          afterLogin = state.afterLogin;
          return HomeScreen();
        }
        if (state is LocalStorageUserNotPresentState) {
          return Login();
        }
        if (state is LocalStorageFetchingFailedState) {
          return Login();
        }
        return const Scaffold(
          backgroundColor: AppColors.colorWhite,
          body: Center(
            child: RepaintBoundary(
              child: CircularProgressIndicator(
                color: AppColors.colorPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
