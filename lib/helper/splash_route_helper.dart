import 'package:get/get.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/notification/domain/models/notification_body_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';

import 'dilogscreen_help.dart';

// class SplashRouteHelper{

  void route({NotificationBodyModel? body}) {
    double? minimumVersion = _getMinimumVersion();
    bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
    bool needsUpdate = AppConstants.appVersion < minimumVersion!;

    if(needsUpdate || isMaintenanceMode) {
      Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
    }else if(!GetPlatform.isWeb){
      if(body != null) {
        _forNotificationRouteProcess(body);
      }else {
        _handleUserRouting();
      }
    }
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
    final notificationType = notificationBody?.notificationType;

    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody!.orderId, fromNotification: true)),
      NotificationType.block: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
      NotificationType.unblock: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
      NotificationType.message: () =>  Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody!.conversationId, fromNotification: true)),
      NotificationType.otp: () => null,
      NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
      NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
      NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

bool _hasShownOfferDialog = false; // Add this as a class-level variable inside your controller

Future<void> _forLoggedInUserRouteProcess() async {
  Get.find<AuthController>().updateToken();

  if (AddressHelper.getUserAddressFromSharedPref() != null) {
    if (Get.find<SplashController>().module != null) {
      await Get.find<FavouriteController>().getFavouriteList();
    }

    Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));

    if (!_hasShownOfferDialog) {
      _hasShownOfferDialog = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        final ctx = Get.context;
        if (ctx != null && Get.find<SplashController>().configModel!.welcomeimage!=null) {
          DilogscreenHelp.offerdilog(
            ctx,
            Get.find<SplashController>().configModel!.welcomeimage,
          );
        }
      });
    }
  } else {
    Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  }
}


  void _newlyRegisteredRouteProcess() {
    if(AppConstants.languages.length > 1) {
      Get.offNamed(RouteHelper.getLanguageRoute('splash'));
    }else {
      Get.offNamed(RouteHelper.getOnBoardingRoute());
    }
  }

  void _forGuestUserRouteProcess() {
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
    }
  }

  Future<void> _handleUserRouting() async {
    if (AuthHelper.isLoggedIn()) {
      _forLoggedInUserRouteProcess();
    } else if (Get.find<SplashController>().showIntro() == true) {
      _newlyRegisteredRouteProcess();
    } else if (AuthHelper.isGuestLoggedIn()) {
      _forGuestUserRouteProcess();
    } else {
      await Get.find<AuthController>().guestLogin();
      _forGuestUserRouteProcess();
    }
  }
// }