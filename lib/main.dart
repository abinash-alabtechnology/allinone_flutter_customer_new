import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/features/notification/domain/models/notification_body_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/notification_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/theme/dark_theme.dart';
import 'package:handy_allinone/theme/light_theme.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/applifecycle.dart';
import 'package:handy_allinone/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:handy_allinone/features/home/widgets/cookies_view.dart';
import 'helper/get_di.dart' as di;
import 'package:flutter_web_plugins/url_strategy.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  usePathUrlStrategy();

  /// added by ak
  // LinkHandlerService().init(); // Activate deep link routing

  /*///Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };


  ///Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };*/

  if (GetPlatform.isWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCLRIsZgBnF3M4H9jvjXi1tftYsd74hBwc",
        authDomain: "alabtechdemos.firebaseapp.com",
        databaseURL: "https://alabtechdemos-default-rtdb.firebaseio.com",
        projectId: "alabtechdemos",
        storageBucket: "alabtechdemos.firebasestorage.app",
        messagingSenderId: "591429626414",
        appId: "1:591429626414:web:1a1fb782f5b85074290dbf",
        measurementId: "G-K3RQ31D4HD",
      ),
    );
  } else if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA9k3Box6xLUqwAXuiMDQqgbK2Rlw7kG9Y",
        appId: "1:591429626414:android:a9276f43200a53bb290dbf",
        messagingSenderId: "591429626414",
        projectId: "alabtechdemos",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }
  runApp(
    AppLifecycleHandler(
      child: MyApp(languages: languages, body: body),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _route();
  }

  void _route() async {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if (AddressHelper.getUserAddressFromSharedPref() != null &&
          AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }

      if (!AuthHelper.isLoggedIn() &&
          !AuthHelper.isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/ ) {
        await Get.find<AuthController>().guestLogin();
      }

      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }

      Get.find<SplashController>().getConfigData(
        loadLandingData:
            (GetPlatform.isWeb &&
            AddressHelper.getUserAddressFromSharedPref() == null),
        fromMainFunction: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                Color primaryColor = const Color(0xFFFF8110);
                Color secondaryColor = const Color(0xFF22C55E);
                if (splashController.module != null) {
                  if (splashController.module!.moduleType.toString() ==
                      AppConstants.pharmacy) {
                    primaryColor = const Color(0xFF16A34A);
                  } else if (splashController.module!.moduleType.toString() ==
                      AppConstants.grocery) {
                    primaryColor = const Color(0xFF1E7F35);
                    secondaryColor = const Color(0xFF00E676);
                  } else if (splashController.module!.moduleType.toString() ==
                      AppConstants.taxi) {
                    primaryColor = const Color(0xFF16A34A);
                  } else if (splashController.module!.moduleType.toString() ==
                      AppConstants.food) {
                    primaryColor = const Color(0xFF16A34A);
                  } else if (splashController.module!.moduleType.toString() ==
                      AppConstants.parcel) {
                    primaryColor = const Color(0xFF16A34A);
                  } else if (splashController.module!.moduleType.toString() ==
                      AppConstants.ecommerce) {
                    primaryColor = const Color(0xFF16A34A);
                  } else if (splashController.module!.moduleType.toString() ==
                      AppConstants.taxi) {
                    primaryColor = const Color(0xFF16A34A);
                  }
                }

                return (GetPlatform.isWeb &&
                        splashController.configModel == null)
                    ? const SizedBox()
                    : ScreenUtilInit(
                        designSize: const Size(
                          375,
                          812,
                        ), // match your Figma design device
                        minTextAdapt: true,
                        splitScreenMode: true,
                        child: GetMaterialApp(
                          title: AppConstants.appName,
                          debugShowCheckedModeBanner: false,
                          navigatorKey: Get.key,
                          scrollBehavior: const MaterialScrollBehavior()
                              .copyWith(
                                dragDevices: {
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.touch,
                                },
                              ),
                          theme: themeController.darkTheme
                              ? dark(
                                  color: primaryColor,
                                  secondaryColor: secondaryColor,
                                )
                              : light(
                                  color: primaryColor,
                                  secondaryColor: secondaryColor,
                                ),
                          locale: localizeController.locale,
                          translations: Messages(languages: widget.languages),
                          fallbackLocale: Locale(
                            AppConstants.languages[0].languageCode!,
                            AppConstants.languages[0].countryCode,
                          ),
                          initialRoute: GetPlatform.isWeb
                              ? RouteHelper.getInitialRoute()
                              : RouteHelper.getSplashRoute(widget.body),
                          getPages: RouteHelper.routes,
                          defaultTransition: Transition.zoom,
                          transitionDuration: const Duration(milliseconds: 500),
                          builder: (BuildContext context, widget) {
                            return Theme(
                              data: themeController.darkTheme
                                  ? dark(
                                      color: primaryColor,
                                      secondaryColor: secondaryColor,
                                    )
                                  : light(
                                      color: primaryColor,
                                      secondaryColor: secondaryColor,
                                    ),
                              child: MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaler: const TextScaler.linear(1),
                                ),
                                child: AnnotatedRegion<SystemUiOverlayStyle>(
                                  value: SystemUiOverlayStyle(
                                    statusBarColor: Colors.transparent,
                                    statusBarIconBrightness:
                                        themeController.darkTheme
                                        ? Brightness.light
                                        : Brightness.dark,
                                    statusBarBrightness:
                                        themeController.darkTheme
                                        ? Brightness.dark
                                        : Brightness.light,
                                    systemNavigationBarColor:
                                        Colors.transparent,
                                    systemNavigationBarIconBrightness:
                                        themeController.darkTheme
                                        ? Brightness.light
                                        : Brightness.dark,
                                  ),
                                  child: Material(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    child: SafeArea(
                                      top: false,
                                      bottom: GetPlatform.isAndroid,
                                      child: Stack(
                                        children: [
                                          widget!,

                                          GetBuilder<SplashController>(
                                            builder: (splashController) {
                                              if (!splashController
                                                      .savedCookiesData &&
                                                  !splashController
                                                      .getAcceptCookiesStatus(
                                                        splashController
                                                                    .configModel !=
                                                                null
                                                            ? splashController
                                                                  .configModel!
                                                                  .cookiesText!
                                                            : '',
                                                      )) {
                                                return ResponsiveHelper.isWeb()
                                                    ? const Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: CookiesView(),
                                                      )
                                                    : const SizedBox();
                                              } else {
                                                return const SizedBox();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
