import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/notification/domain/models/notification_body_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../../util/app_constants.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/domain/models/update_user_model.dart';
import 'package:http/http.dart' as http;


class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        isConnected ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar() : const SizedBox();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          Get.find<SplashController>().getConfigData(notificationBody: widget.body);
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getCartDataOnline();

      final sharedPreferences = Get.find<SharedPreferences>();
      final String? token =
      sharedPreferences.getString(AppConstants.token);
      if(token != null && token.isNotEmpty){
        updateOnlineStatus(1, token).then((success) {;
        if (success) {
          // debugPrint("Online status updated successfully.");
        } else {
          // debugPrint("Failed to update online status.");
        }
        });

      }

    }
    // _route();
    Get.find<SplashController>().getConfigData(notificationBody: widget.body);

  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
  }

  // void _route() {
  //   Get.find<SplashController>().getConfigData().then((isSuccess) {
  //     if(isSuccess) {
  //       Timer(const Duration(seconds: 1), () async {
  //         double? minimumVersion = _getMinimumVersion();
  //         bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
  //         bool needsUpdate = AppConstants.appVersion < minimumVersion!;
  //
  //         if(needsUpdate || isMaintenanceMode) {
  //           Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
  //         }else {
  //           if(widget.body != null) {
  //             _forNotificationRouteProcess(widget.body);
  //           }else {
  //             _handleUserRouting();
  //           }
  //         }
  //       });
  //     }
  //   });
  // }
  //
  // double? _getMinimumVersion() {
  //   if (GetPlatform.isAndroid) {
  //     return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
  //   } else if (GetPlatform.isIOS) {
  //     return Get.find<SplashController>().configModel!.appMinimumVersionIos;
  //   }
  //   return 0;
  // }
  //
  // void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
  //   final notificationType = notificationBody?.notificationType;
  //
  //   final Map<NotificationType, Function> notificationActions = {
  //     NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(widget.body!.orderId, fromNotification: true)),
  //     NotificationType.block: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
  //     NotificationType.unblock: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
  //     NotificationType.message: () =>  Get.toNamed(RouteHelper.getChatRoute(notificationBody: widget.body, conversationID: widget.body!.conversationId, fromNotification: true)),
  //     NotificationType.otp: () => null,
  //     NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
  //     NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
  //   };
  //
  //   notificationActions[notificationType]?.call();
  // }
  //
  // Future<void> _forLoggedInUserRouteProcess() async {
  //   Get.find<AuthController>().updateToken();
  //   if (AddressHelper.getUserAddressFromSharedPref() != null) {
  //     if(Get.find<SplashController>().module != null) {
  //       await Get.find<FavouriteController>().getFavouriteList();
  //     }
  //     Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  //   } else {
  //     Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  //   }
  // }
  //
  // void _newlyRegisteredRouteProcess() {
  //   if(AppConstants.languages.length > 1) {
  //     Get.offNamed(RouteHelper.getLanguageRoute('splash'));
  //   }else {
  //     Get.offNamed(RouteHelper.getOnBoardingRoute());
  //   }
  // }
  //
  // void _forGuestUserRouteProcess() {
  //   if (AddressHelper.getUserAddressFromSharedPref() != null) {
  //     Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  //   } else {
  //     Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  //   }
  // }
  //
  // Future<void> _handleUserRouting() async {
  //   if (AuthHelper.isLoggedIn()) {
  //     _forLoggedInUserRouteProcess();
  //   } else if (Get.find<SplashController>().showIntro() == true) {
  //     _newlyRegisteredRouteProcess();
  //   } else if (AuthHelper.isGuestLoggedIn()) {
  //     _forGuestUserRouteProcess();
  //   } else {
  //     await Get.find<AuthController>().guestLogin();
  //     _forGuestUserRouteProcess();
  //   }
  // }
  static const Color backgroundColor = Color(0xFFFF8110); // Vibrant Pink/Magenta
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White
  static const Color accentColor = Color(0xFFFFD700);
  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if(AddressHelper.getUserAddressFromSharedPref() != null && AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      // backgroundColor: backgroundColor,
      body: GetBuilder<SplashController>(
        builder: (splashController) {
          return Center(
            child: splashController.hasConnection
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: scale,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const double maxImageContainerWidth = 400;

                            final double effectiveWidth =
                            constraints.maxWidth > maxImageContainerWidth
                                ? maxImageContainerWidth
                                : constraints.maxWidth;

                            double imageWidth;
                            if (effectiveWidth <= 360) {
                              imageWidth = effectiveWidth * 0.70;
                            } else if (effectiveWidth <= 480) {
                              imageWidth = effectiveWidth * 0.75;
                            } else if (effectiveWidth <= 720) {
                              imageWidth = effectiveWidth * 0.80;
                            } else {
                              imageWidth = effectiveWidth * 0.85;
                            }

                            return ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: maxImageContainerWidth),
                              child: CustomAssetImageWidget(
                                Images.logotransparent,
                                width: imageWidth,
                                // color:Colors.white
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Believe in yourself!',
                          style: robotoBold.copyWith(
                            fontSize: 18,
                            color: const Color(0xE6FFFFFF),
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Center(
                      //   child: LayoutBuilder(
                      //     builder: (context, constraints) {
                      //       final maxWidth = constraints.maxWidth;
                      //
                      //       double imageWidth;
                      //       if (maxWidth <= 360) {
                      //         imageWidth = maxWidth * 0.70;
                      //       } else if (maxWidth <= 480) {
                      //         imageWidth = maxWidth * 0.75;
                      //       } else if (maxWidth <= 720) {
                      //         imageWidth = maxWidth * 0.80;
                      //       } else {
                      //         imageWidth = maxWidth * 0.85;
                      //       }
                      //
                      //       return CustomAssetImageWidget(
                      //         Images.logotransparent,
                      //         width: imageWidth,
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            )
                : NoInternetScreen(
              child: SplashScreen(body: widget.body),
            ),
          );
        },
      ),
    );
  }
}


Future<bool> updateOnlineStatus(int status, String token) async {
  final url = Uri.parse('${AppConstants.baseUrl}/api/v1/customer/update-onlineoroffline');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'status': status.toString(),
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error updating online status: $e');
    return false;
  }
}