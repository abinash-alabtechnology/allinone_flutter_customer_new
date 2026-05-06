import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/features/auth/widgets/auth_dialog_widget.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/home/controllers/home_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';

// import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/confirmation_dialog.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/features/menu/widgets/portion_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../util/app_constants.dart';
import '../../profile/controllers/profile_controller.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.01),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25)),
                color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtremeLarge,
                right: Dimensions.paddingSizeExtremeLarge,
                top: 50,
                bottom: Dimensions.paddingSizeExtremeLarge,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        style: robotoBold.copyWith(
                            fontSize: 22, color: Theme.of(context).cardColor),
                      ),
                      GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 22,
                            color: Theme.of(context).cardColor,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: ClipOval(
                          child: CustomImage(
                        placeholder: Images.guestIconLight,
                        image:
                            '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      )),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isLoggedIn &&
                                    profileController.userInfoModel == null
                                ? Shimmer(
                                    child: Container(
                                      height: 15,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  )
                                : Text(
                                    isLoggedIn
                                        ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}'
                                        : 'guest_user'.tr,
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeExtraLarge,
                                        color: Theme.of(context).cardColor),
                                  ),
                            SizedBox(
                                height: isLoggedIn &&
                                        profileController.userInfoModel == null
                                    ? Dimensions.paddingSizeSmall
                                    : Dimensions.paddingSizeExtraSmall),
                            isLoggedIn &&
                                    profileController.userInfoModel == null
                                ? Shimmer(
                                    child: Container(
                                      height: 15,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  )
                                : isLoggedIn
                                    ? Text(
                                        profileController.userInfoModel != null
                                            ? DateConverter
                                                .containTAndZToUTCFormat(
                                                    profileController
                                                        .userInfoModel!
                                                        .createdAt!)
                                            : '',
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).cardColor),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          if (!ResponsiveHelper.isDesktop(
                                              context)) {
                                            await Get.toNamed(
                                                RouteHelper.getSignInRoute(
                                                    Get.currentRoute));
                                            if (AuthHelper.isLoggedIn()) {
                                              profileController.getUserInfo();
                                            }
                                          } else {
                                            Get.dialog(const Center(
                                                child: AuthDialogWidget(
                                                    exitFromApp: true,
                                                    backFromThis: true)));
                                          }
                                        },
                                        child: Text(
                                          'login_to_view_all_feature'.tr,
                                          style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color:
                                                  Theme.of(context).cardColor),
                                        ),
                                      ),
                          ]),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Ink(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.01),
              child: Column(children: [
                const Gap(10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: Dimensions.paddingSizeDefault),
                            child: Text(
                              'general'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                          const Gap(10),
                          PortionWidget(
                            icon: Images.profileIcon,
                            title: 'profile'.tr,
                            route: RouteHelper.getProfileRoute(),
                            iconcolor: Colors.blue,
                          ),
                          PortionWidget(
                            icon: Images.addressIcon,
                            title: 'my_address'.tr,
                            route: RouteHelper.getAddressRoute(),
                            iconcolor: Colors.orange,
                          ),
                            PortionWidget(
                              icon: Images.languageIcon,
                              title: 'language'.tr,
                              hideDivider: false,
                              onTap: () => _manageLanguageFunctionality(),
                              route: '',
                              iconcolor: Colors.green,
                            ),
                            PortionWidget(
                              icon: Images.chatIcon,
                              title: 'Request Delivery List',
                              route: RouteHelper.getDeliveryQuotationListRoute(),
                              iconcolor: Colors.red,
                              hideDivider: true,
                            ),
                          ]),
                  )
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  //   child: Text(
                  //     'promotional_activity'.tr,
                  //     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                  //   ),
                  // ),

                  Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(

                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(colors: [Colors.green.shade500,Colors.green.shade900],begin: Alignment.centerLeft,end:Alignment.bottomRight)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Limited-Time\nOffers Inside 🔥",
                                      style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).cardColor),
                                    ),
                                    const SizedBox(height: 10,),
                                    Text(
                                        "Grab flat discounts, cash-back,\nsurprice coupon drops-only on ${AppConstants.appName}!",
                                        style: robotoRegular.copyWith(
                                            fontSize:
                                            Dimensions.fontSizeOverSmall,
                                            color: Theme.of(context).cardColor)),
                                  ],
                                ),
                                Spacer(),
                                const CustomAssetImageWidget(
                                  Images.discountblue,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.fitHeight,
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                              vertical: Dimensions.paddingSizeDefault),

                          child: Column(children: [
                            PortionWidget(
                              icon: Images.couponIcon,
                              title: 'coupon'.tr,
                              route: RouteHelper.getCouponRoute(),
                              hideDivider: Get.find<SplashController>()
                                              .configModel!
                                              .loyaltyPointStatus ==
                                          1 ||
                                      Get.find<SplashController>()
                                              .configModel!
                                              .customerWalletStatus ==
                                          1
                                  ? false
                                  : true,
                              iconcolor: Colors.purple,
                            ),
                            (Get.find<SplashController>()
                                        .configModel!
                                        .loyaltyPointStatus ==
                                    1)
                                ? PortionWidget(
                                    icon: Images.pointIcon,
                                    title: 'loyalty_points'.tr,
                                    route: RouteHelper.getLoyaltyRoute(),
                                    iconcolor: Colors.yellow,
                                    hideDivider: Get.find<SplashController>()
                                                .configModel!
                                                .customerWalletStatus ==
                                            1
                                        ? false
                                        : true,
                                    suffix: !isLoggedIn
                                        ? null
                                        : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                                  )
                                : const SizedBox(),
                            (Get.find<SplashController>()
                                        .configModel!
                                        .customerWalletStatus ==
                                    1)
                                ? PortionWidget(
                                    icon: Images.walletIcon,
                                    title: 'my_wallet'.tr,
                                    hideDivider: true,
                                    route: RouteHelper.getWalletRoute(),
                                    iconcolor: Colors.green,
                                    suffix: !isLoggedIn
                                        ? null
                                        : PriceConverter.convertPrice(
                                            profileController.userInfoModel != null
                                                ? profileController
                                                    .userInfoModel!.walletBalance
                                                : 0),
                                  )
                                : const SizedBox(),
                          ]),
                        ),
                      ],
                    ),
                  )
                ]),
                (Get.find<SplashController>().configModel!.refEarningStatus ==
                            1) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleDmRegistration! &&
                            !ResponsiveHelper.isDesktop(context)) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleStoreRegistration! &&
                            !ResponsiveHelper.isDesktop(context))
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 1)
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                  vertical: Dimensions.paddingSizeDefault),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: 8),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeDefault),
                                      child: Text(
                                        'earnings'.tr,
                                        style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault),
                                      ),
                                    ),
                                    const Gap(10),
                                    (Get.find<SplashController>()
                                                .configModel!
                                                .refEarningStatus ==
                                            1)
                                        ? PortionWidget(
                                            icon: Images.referIcon,
                                            title: 'refer_and_earn'.tr,
                                            route: RouteHelper
                                                .getReferAndEarnRoute(),
                                            iconcolor: Colors.orange,
                                            hideDivider: (Get.find<
                                                                SplashController>()
                                                            .configModel!
                                                            .toggleDmRegistration! &&
                                                        !ResponsiveHelper
                                                            .isDesktop(
                                                                context)) ||
                                                    (Get.find<SplashController>()
                                                            .configModel!
                                                            .toggleStoreRegistration! &&
                                                        !ResponsiveHelper
                                                            .isDesktop(context))
                                                ? false
                                                : true,
                                          )
                                        : const SizedBox(),
                                    (Get.find<SplashController>()
                                                .configModel!
                                                .toggleDmRegistration! &&
                                            !ResponsiveHelper.isDesktop(
                                                context))
                                        ? PortionWidget(
                                            icon: Images.dmIcon,
                                            title: 'join_as_a_delivery_man'.tr,
                                            route: RouteHelper
                                                .getDeliverymanRegistrationRoute(),
                                            iconcolor: Colors.blue,
                                            hideDivider: (Get.find<
                                                            SplashController>()
                                                        .configModel!
                                                        .toggleStoreRegistration! &&
                                                    !ResponsiveHelper.isDesktop(
                                                        context))
                                                ? false
                                                : true,
                                          )
                                        : const SizedBox(),
                                    (Get.find<SplashController>()
                                                .configModel!
                                                .toggleStoreRegistration! &&
                                            !ResponsiveHelper.isDesktop(
                                                context))
                                        ? PortionWidget(
                                            icon: Images.storeIcon,
                                            title: 'open_vendor'.tr,
                                            hideDivider: true,
                                            route: RouteHelper
                                                .getRestaurantRegistrationRoute(),
                                            iconcolor: Colors.deepOrange,
                                          )
                                        : const SizedBox(),
                                  ]),
                            )
                          ])
                    : const SizedBox(),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                        vertical: Dimensions.paddingSizeDefault),
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault, vertical: 8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: Dimensions.paddingSizeDefault),
                            child: Text(
                              'help_and_support'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                          ),
                          const Gap(10),
                          PortionWidget(
                            icon: Images.chatIcon,
                            title: 'live_chat'.tr,
                            route: RouteHelper.getConversationRoute(),
                            iconcolor: Colors.blue,
                          ),
                          PortionWidget(
                            icon: Images.helpIcon,
                            title: 'help_and_support'.tr,
                            route: RouteHelper.getSupportRoute(),
                            iconcolor: Colors.green,
                          ),
                          PortionWidget(
                            icon: Images.aboutIcon,
                            title: 'about_us'.tr,
                            route: RouteHelper.getHtmlRoute('about-us'),
                            iconcolor: Colors.purple,
                          ),
                          PortionWidget(
                            icon: Images.termsIcon,
                            title: 'terms_conditions'.tr,
                            route:
                                RouteHelper.getHtmlRoute('terms-and-condition'),
                            iconcolor: Colors.brown,
                          ),
                          PortionWidget(
                            icon: Images.privacyIcon,
                            title: 'privacy_policy'.tr,
                            route: RouteHelper.getHtmlRoute('privacy-policy'),
                            iconcolor: Colors.red,
                          ),
                          (Get.find<SplashController>()
                                      .configModel!
                                      .refundPolicyStatus ==
                                  1)
                              ? PortionWidget(
                                  icon: Images.refundIcon,
                                  title: 'refund_policy'.tr,
                                  route:
                                      RouteHelper.getHtmlRoute('refund-policy'),
                                  hideDivider: (Get.find<SplashController>()
                                                  .configModel!
                                                  .cancellationPolicyStatus ==
                                              1) ||
                                          (Get.find<SplashController>()
                                                  .configModel!
                                                  .shippingPolicyStatus ==
                                              1)
                                      ? false
                                      : true,
                                  iconcolor: Colors.blue.shade900,
                                )
                              : const SizedBox(),
                          (Get.find<SplashController>()
                                      .configModel!
                                      .cancellationPolicyStatus ==
                                  1)
                              ? PortionWidget(
                                  icon: Images.cancelationIcon,
                                  title: 'cancellation_policy'.tr,
                                  route: RouteHelper.getHtmlRoute(
                                      'cancellation-policy'),
                                  iconcolor: Colors.yellow,
                                  hideDivider: (Get.find<SplashController>()
                                              .configModel!
                                              .shippingPolicyStatus ==
                                          1)
                                      ? false
                                      : true,
                                )
                              : const SizedBox(),
                          (Get.find<SplashController>()
                                      .configModel!
                                      .shippingPolicyStatus ==
                                  1)
                              ? PortionWidget(
                                  icon: Images.shippingIcon,
                                  title: 'shipping_policy'.tr,
                                  hideDivider: true,
                                  route: RouteHelper.getHtmlRoute(
                                      'shipping-policy'),
                                  iconcolor: Colors.green.shade700,
                                )
                              : const SizedBox(),
                        ]),
                  )
                ]),

                const SizedBox(height: 20),
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      Text(
                        "Follow us",
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Keep up with the latest from us",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AnimatedIconButton(
                            color: Colors.blue,
                            asset: Images.facebook,
                            url: 'https://www.facebook.com',
                            delay: const Duration(
                                milliseconds: 0),
                          ),
                          _AnimatedIconButton(
                            color: Colors.pink,
                            asset: Images.instagram,
                            url: 'https://www.instagram.com',
                            delay: const Duration(
                                milliseconds: 300),
                          ),
                          _AnimatedIconButton(
                            color: Colors.black,
                            asset: Images.youtube,
                            url: 'https://youtube.com',
                            delay: const Duration(
                                milliseconds: 600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "App Version: DEV -3.5.0",
                  style: TextStyle(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 10),
                TypingText(
                  lines: [
                    "©${DateTime.now().year} Crafted with ❤️",
                    "By Alabtechnology Pvt.Ltd",
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  speed: Duration(milliseconds: 100),
                ),
                InkWell(
                    onTap: () async {
                      if (AuthHelper.isLoggedIn()) {
                        Get.dialog(
                            ConfirmationDialog(
                                icon: Images.support,
                                description: 'are_you_sure_to_logout'.tr,
                                isLogOut: true,
                                onYesPressed: () async {
                                  Get.find<AuthController>().resetOtpView();
                                  Get.find<ProfileController>().clearUserInfo();
                                  Get.find<AuthController>().socialLogout();
                                  Get.find<CartController>()
                                      .clearCartList(canRemoveOnline: false);
                                  Get.find<FavouriteController>()
                                      .removeFavourite();
                                  await Get.find<AuthController>()
                                      .clearSharedData();
                                  Get.find<HomeController>()
                                      .forcefullyNullCashBackOffers();
                                  Get.find<TaxiCartController>()
                                      .getCarCartList();
                                  Get.offAllNamed(
                                      RouteHelper.getInitialRoute());
                                }),
                            useSafeArea: false);
                      } else {
                        Get.find<FavouriteController>().removeFavourite();
                        await Get.toNamed(
                            RouteHelper.getSignInRoute(Get.currentRoute));
                        if (AuthHelper.isLoggedIn()) {
                          await Get.find<FavouriteController>()
                              .getFavouriteList();
                          profileController.getUserInfo();
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2B2B2B), // start (red tone)
                              Color(0xFF4B4B4B), // end (deep red tone)
                            ],
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                ),
                                child: const Icon(
                                  Icons.logout,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                AuthHelper.isLoggedIn()
                                    ? 'logout'.tr
                                    : 'sign_in'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                SizedBox(
                    height: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.paddingSizeExtremeLarge
                        : 100),
              ]),
            ),
          )),
        ]);
      }),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});
//
//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }
//
// class _MenuScreenState extends State<MenuScreen> {
//   late final bool _isLoggedIn;
//
//   @override
//   void initState() {
//     _isLoggedIn = AuthHelper.isLoggedIn();
//     if (_isLoggedIn) {
//       Get.find<ProfileController>().getUserInfo();
//     }
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).cardColor,
//       body: GetBuilder<ProfileController>(
//         builder: (profileController) {
//           final bool isLoggedIn = AuthHelper.isLoggedIn();
//
//           // Update the local variable if login status changes
//           if (isLoggedIn != _isLoggedIn) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               setState(() {
//                 _isLoggedIn = isLoggedIn;
//               });
//             });
//           }
//
//           final bool showWalletCard = Get.find<SplashController>()
//               .configModel!
//               .customerWalletStatus ==
//               1 ||
//               Get.find<SplashController>().configModel!.loyaltyPointStatus == 1;
//
//           return RefreshIndicator(
//             onRefresh: () {
//               // Only refresh user info if logged in
//               if (_isLoggedIn) {
//                 return Get.find<ProfileController>().getUserInfo();
//               } else {
//                 return Future.value(); // Return empty future for guest
//               }
//             },
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   //? name and use image , edit
//                   Container(
//                     color: Colors.white,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Theme.of(context).primaryColor.withValues(alpha: 0.8),
//                             Theme.of(context)
//                                 .primaryColor
//                                 .withValues(alpha: 0.6), // lighter shade
//                             Theme.of(context)
//                                 .cardColor
//                                 .withValues(alpha: 0.2), // soft white blend
//                           ],
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                           left: Dimensions.paddingSizeSmall,
//                           right: Dimensions.paddingSizeSmall,
//                           top: 80,
//                           bottom: Dimensions.paddingSizeSmall,
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 //? profile area
//                                 GestureDetector(
//                                   onTap:(){
//                                     Get.back();
//                                   },
//                                   child: Container(
//                                     height: 50,width: 50,
//                                     decoration: const BoxDecoration(
//                                       shape: BoxShape.circle,
//                                           color:Colors.black12
//                                     ),
//                                     child:const Padding(
//                                       padding: EdgeInsets.only(left: 8.0),
//                                       child: Center(child: Icon(Icons.arrow_back_ios,color: Colors.white,)),
//                                     )
//                                   ),
//                                 ),
//                                const Gap(20),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       width: 1.2,
//                                       color: Colors.redAccent.shade100,
//                                     ),
//                                   ),
//                                   child: Container(
//                                     margin: const EdgeInsets.all(4),
//                                     decoration: const BoxDecoration(
//                                       color: Color.fromARGB(221, 255, 236, 179),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     height: 60,
//                                     width: 60,
//                                     padding: const EdgeInsets.all(2),
//                                     child: Center(
//                                       child: ClipOval(
//                                         child: CustomImage(
//                                           placeholder: Images.guestDummyIcon,
//                                           image: isLoggedIn &&
//                                               profileController
//                                                   .userInfoModel !=
//                                                   null
//                                               ? profileController.userInfoModel!
//                                               .imageFullUrl ??
//                                               ''
//                                               : '',
//                                           height: 60,
//                                           width: 60,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 //? -- till this profile image
//                                 const SizedBox(
//                                     width: Dimensions.paddingSizeDefault),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       //? use name and edit option
//                                       Row(
//                                         children: [
//                                           Text(
//                                             isLoggedIn &&
//                                                 profileController
//                                                     .userInfoModel !=
//                                                     null
//                                                 ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName ?? ''}'
//                                                 : 'guest_user'.tr,
//                                             style: robotoBold.copyWith(
//                                               fontSize: 22,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           if (isLoggedIn) // Only show edit button when logged in
//                                             const SizedBox(
//                                                 width:
//                                                 Dimensions.paddingSizeSmall),
//                                           if (isLoggedIn)
//                                             InkWell(
//                                               onTap: () {
//                                                 Get.toNamed(RouteHelper
//                                                     .getProfileRoute());
//                                               },
//                                               borderRadius:
//                                               BorderRadius.circular(20),
//                                               child: Container(
//                                                 padding: const EdgeInsets.all(3),
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                   BorderRadius.circular(20),
//                                                   border: Border.all(
//                                                     width: 2,
//                                                     color: Theme.of(context)
//                                                         .primaryColor,
//                                                   ),
//                                                 ),
//                                                 child: Icon(
//                                                   Icons.edit_outlined,
//                                                   size: 16.0,
//                                                   color: Theme.of(context)
//                                                       .primaryColor,
//                                                 ),
//                                               ),
//                                             )
//                                         ],
//                                       ),
//                                       //? till now
//                                       //? checking if the use is logged in showing mobile number if not showing something.
//                                       isLoggedIn
//                                           ? Text(
//                                         profileController.userInfoModel !=
//                                             null
//                                             ? profileController
//                                             .userInfoModel!.phone ??
//                                             ""
//                                             : '',
//                                         style: robotoMedium.copyWith(
//                                           fontSize:
//                                           Dimensions.fontSizeSmall,
//                                           color: Colors.black54,
//                                         ),
//                                       )
//                                           : InkWell(
//                                         onTap: () async {
//                                           if (!ResponsiveHelper.isDesktop(
//                                               context)) {
//                                             await Get.toNamed(
//                                                 RouteHelper.getSignInRoute(
//                                                     Get.currentRoute));
//                                             if (AuthHelper.isLoggedIn()) {
//                                               profileController
//                                                   .getUserInfo();
//                                             }
//                                           } else {
//                                             Get.dialog(const SignInScreen(
//                                                 exitFromApp: true,
//                                                 backFromThis: true));
//                                           }
//                                         },
//                                         child: Text(
//                                           'login_to_view_all_feature'.tr,
//                                           style: robotoMedium.copyWith(
//                                               fontSize:
//                                               Dimensions.fontSizeSmall,
//                                               color: Theme.of(context)
//                                                   .cardColor),
//                                         ),
//                                       ),
//                                       //? --finishing loged in
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             //? referal area - only show when logged in
//                             if (isLoggedIn)
//                               Container(
//                                 padding: const EdgeInsets.only(
//                                   left: Dimensions.paddingSizeSmall,
//                                   right: Dimensions.paddingSizeSmall,
//                                   top: 25,
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'refer_and_earn'.tr,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                             color:
//                                             Color.fromARGB(255, 20, 55, 38),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           'Refer a Friend & Earn ₹100',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey[700],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Text(
//                                               'Referral Code : ',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey[700],
//                                               ),
//                                             ),
//                                             Text(
//                                               profileController
//                                                   .userInfoModel?.refCode ??
//                                                   "",
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 14,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                                 width:
//                                                 Dimensions.paddingSizeSmall),
//                                             InkWell(
//                                               onTap: () {
//                                                 if ((profileController
//                                                     .userInfoModel
//                                                     ?.refCode ??
//                                                     "")
//                                                     .isNotEmpty) {
//                                                   Clipboard.setData(ClipboardData(
//                                                       text: profileController
//                                                           .userInfoModel
//                                                           ?.refCode ??
//                                                           ''));
//                                                   showCustomSnackBar(
//                                                       'referral_code_copied'.tr,
//                                                       isError: false);
//                                                 }
//                                               },
//                                               child: const Icon(Icons.copy,
//                                                   size: 16),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         Share.share(
//                                           Get.find<SplashController>()
//                                               .configModel
//                                               ?.appUrlAndroid !=
//                                               null
//                                               ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel?.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
//                                               : "I've been enjoying ${AppConstants.appName} restaurant recently, and I wanted to share a little something with you! If you sign up using my referral code, you can get started with ${AppConstants.appName} too! 🎉Here's my \n${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel?.refCode} \n\n ${AppConstants.applink}",
//                                         );
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                         Theme.of(context).primaryColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: Dimensions.paddingSizeLarge,
//                                           vertical: Dimensions.paddingSizeSmall,
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         'Share',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             //? referal code
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   //? -- till name and user.
//                   //? order tab
//                   // PortionWidget2(
//                   //     icon: Images.packageIcon,
//                   //     title: "Your Orders",
//                   //     onTap: () => Get.to(() => const OrderScreen()),
//                   //     route: ""),
//                   //? -- order
//
//                   //? Bookings tab
//                   // PortionWidget2(
//                   //     icon: Images.TaxiIcon,
//                   //     title: "Your Bookings",
//                   //     onTap: () => Get.to(()=> HistoryScreen()),
//                   //     route: ""),
//                   //? -- Bookings
//
//                   //? favrouit
//                   // PortionWidget2(
//                   //     icon: Images.favrouitIcon,
//                   //     title: 'Favrouite',
//                   //     onTap: () => Get.to(() => const FavouriteScreen()),
//                   //     route: ""),
//                   //? -- favrouit
//
//                   //? wallet - only show wallet balance if logged in
//                   (Get.find<SplashController>()
//                       .configModel!
//                       .customerWalletStatus ==
//                       1)
//                       ? PortionWidget2(
//                     icon: Images.walletIcon,
//                     title: 'my_wallet'.tr,
//                     hideDivider: true,
//                     route: isLoggedIn ? RouteHelper.getWalletRoute() : "",
//                     onTap: isLoggedIn
//                         ? null
//                         : () {
//                       // Show login prompt for guest users
//                       if (!ResponsiveHelper.isDesktop(context)) {
//                         Get.toNamed(RouteHelper.getSignInRoute(
//                             Get.currentRoute));
//                       } else {
//                         Get.dialog(const SignInScreen(
//                             exitFromApp: true, backFromThis: true));
//                       }
//                     },
//                     suffix: !isLoggedIn
//                         ? null
//                         : PriceConverter.convertPrice(
//                         profileController.userInfoModel != null
//                             ? profileController
//                             .userInfoModel!.walletBalance
//                             : 0),
//                   )
//                       : const SizedBox(),
//                   //?--wallet
//                   //? address
//                   PortionWidget2(
//                       icon: Images.addressIcon2,
//                       title: "Address Book",
//                       route: RouteHelper.getAddressRoute()),
//                   //?-- address
//
//                   //? coupon
//                   PortionWidget2(
//                     icon: Images.percentageIcon,
//                     title: 'Coupons & offers',
//                     route: isLoggedIn ? RouteHelper.getCouponRoute() : "",
//                     onTap: !isLoggedIn
//                         ? () {
//                       // Show login prompt for guest users
//                       if (!ResponsiveHelper.isDesktop(context)) {
//                         Get.toNamed(
//                             RouteHelper.getSignInRoute(Get.currentRoute));
//                       } else {
//                         Get.dialog(const SignInScreen(
//                             exitFromApp: true, backFromThis: true));
//                       }
//                     }
//                         : null,
//                     hideDivider: Get.find<SplashController>()
//                         .configModel!
//                         .loyaltyPointStatus ==
//                         1 ||
//                         Get.find<SplashController>()
//                             .configModel!
//                             .customerWalletStatus ==
//                             1
//                         ? false
//                         : true,
//                   ),
//                   //?---- coupon
//                   //? Live chat
//                   PortionWidget2(
//                       icon: Images.livechat,
//                       title: "Live Chat",
//                       route: RouteHelper.getConversationRoute()),
//                   //?-- Live chat
//                   //? language
//                   PortionWidget2(
//                       icon: Images.languageIcon2,
//                       title: 'language'.tr,
//                       hideDivider: true,
//                       onTap: () =>
//                           Get.to(() => const LanguageBottomSheetWidget()),
//                       route: ''),
//                   //?--- language
//                   // ? 24/7 support
//                   PortionWidget2(
//                       icon: Images.alltimesupport,
//                       title: "24/7 Support",
//                       route: RouteHelper.getSupportRoute()),
//                   //?-- Live chat
//                   //? favrouit
//                   // PortionWidget2(
//                   //     icon: Images.refundIcon2,
//                   //     title: 'Refund',
//                   //     onTap: () => Get.to(() => const RefundScreen()),
//                   //     route: ""),
//                   //? -- order
//
//                   //? notification
//                   // PortionWidget2(
//                   //     icon: Images.notificationIcon,
//                   //     title: 'Notification',
//                   //     onTap: () =>
//                   //         Get.to(() => const NotificationOptionscreen()),
//                   //     route: ""),
//                   //? -- notification
//
//                   //? Review
//                   // PortionWidget2(
//                   //     icon: Images.review,
//                   //     title: 'Reviews',
//                   //     onTap: () => Get.to(() => const ReviewNewScreen()),
//                   //     route: ""),
//                   //? -- Review
//
//                   //? about and help
//                   PortionWidget2(
//                       icon: Images.messageIcon,
//                       title: 'Know your rights',
//                       onTap: () => Get.to(() => const AboutScreen()),
//                       route: ""),
//
//                   //?--- about and help :: this only show about want to add about
//
//                   //? logout/sign in
//                   PortionWidget2(
//                     color: isLoggedIn ? Colors.red : Colors.green,
//                     icon: isLoggedIn ? Images.logoutIcon2 : Images.logOut,
//                     title: isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
//                     onTap: () async {
//                       if (isLoggedIn) {
//                         Get.dialog(
//                             ConfirmationDialog(
//                                 icon: Images.support,
//                                 description: 'are_you_sure_to_logout'.tr,
//                                 isLogOut: true,
//                                 onYesPressed: () async {
//                                   logoutUser();
//                                   Get.find<ProfileController>().clearUserInfo();
//                                   Get.find<AuthController>().socialLogout();
//                                   Get.find<CartController>()
//                                       .clearCartList(canRemoveOnline: false);
//                                   Get.find<FavouriteController>()
//                                       .removeFavourite();
//                                   await Get.find<AuthController>()
//                                       .clearSharedData();
//                                   Get.find<HomeController>()
//                                       .forcefullyNullCashBackOffers();
//                                   await Get.offAllNamed(
//                                       RouteHelper.getSignInRoute(
//                                           Get.currentRoute));
//                                 }),
//                             useSafeArea: false);
//                       } else {
//                         Get.find<FavouriteController>().removeFavourite();
//                         await Get.toNamed(
//                             RouteHelper.getSignInRoute(Get.currentRoute));
//                         if (AuthHelper.isLoggedIn()) {
//                           await Get.find<FavouriteController>()
//                               .getFavouriteList();
//                           profileController!.getUserInfo();
//                         }
//                       }
//                     },
//                     route: "",
//                   ),
//                   //?----- Deleteaccount        //? logout/sign in
//                   // isLoggedIn ?
//                   //  PortionWidget2(
//                   //    color: Colors.orange,
//                   //    icon:  Images.deleteacc,
//                   //    title:  'Delete Account'.tr ,
//                   //    onTap: () => Get.to(() => const AboutLogoutScreen()),
//                   //    route: "",
//                   //  )
//                   //      :SizedBox.shrink(),
//                   //  //?----- Delete Account
//
//                   //? Follow Us Section
//                   //? Follow Us Section
//                   const SizedBox(height: 20),
//                   Container(
//                     color: Colors.white,
//                     width: double.infinity,
//                     margin: const EdgeInsets.symmetric(
//                         horizontal: Dimensions.paddingSizeDefault),
//                     // padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
//                     // decoration: BoxDecoration(
//                     //   color: Colors.white,
//                     //   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                     //   boxShadow: [
//                     //     BoxShadow(
//                     //       color: Colors.grey.withOpacity(0.1),
//                     //       blurRadius: 10,
//                     //       spreadRadius: 2,
//                     //       offset: const Offset(0, 3),
//                     //     ),
//                     //   ],
//                     // ),
//                     child: Column(
//                       children: [
//                         Text(
//                           "Follow us",
//                           style: robotoBold.copyWith(
//                             fontSize: Dimensions.fontSizeExtraLarge,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Keep up with the latest from us",
//                           style: robotoRegular.copyWith(
//                             fontSize: Dimensions.fontSizeSmall,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//
//                         // Social Media Icons
//                         const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             _AnimatedIconButton(
//                               color: Colors.blue,
//                               asset: Images.facebook,
//                               url: 'https://www.facebook.com',
//                               delay: const Duration(
//                                   milliseconds: 0), // starts immediately
//                             ),
//                             _AnimatedIconButton(
//                               color: Colors.pink,
//                               asset: Images.instagram,
//                               url: 'https://www.instagram.com',
//                               delay: const Duration(
//                                   milliseconds: 300), // starts immediately
//                             ),
//                             _AnimatedIconButton(
//                               color: Colors.black,
//                               asset: Images.youtube,
//                               url: 'https://youtube.com',
//                               delay: const Duration(
//                                   milliseconds: 600), // starts immediately
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   //? app version
//                   const SizedBox(height: 20),
//                   Text(
//                     "App Version: DEV-1.0.2",
//                     style: TextStyle(
//                       fontSize: Dimensions.fontSizeDefault,
//                       color: Theme.of(context).hintColor,
//                     ),
//                   ),
//                   //?----------appp version
//                   //App Version: PRO-1.0.2
//                   // ©2025 Crafted with ❤️ by Alabtechnology Pvt. Ltd
//                   //? powerby
//                   const SizedBox(height: 10),
//                   const TypingText(
//                     lines: [
//                       "©2025 Crafted with ❤️",
//                       "By Alabtechnology Pvt.Ltd",
//                       "In Association",
//                       "With SV Soft Solutions Pvt Ltd."
//                     ],
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     speed: Duration(milliseconds: 100),
//                   ),
//
//                   // TypingText(
//                   //   lines: [
//                   //     "©2025 Crafted with ❤️",
//                   //     "by Alabtechnology Pvt.Ltd",
//                   //   ],
//                   //   style: TextStyle(
//                   //     fontSize: 16,
//                   //     color: Colors.black,
//                   //     fontWeight: FontWeight.w500,
//                   //   ),
//                   //   speed: const Duration(milliseconds: 100),
//                   // ),
//                   //?---------powerby
//
//                   SizedBox(
//                       height: ResponsiveHelper.isDesktop(context)
//                           ? Dimensions.paddingSizeExtremeLarge
//                           : 90),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//

class TypingText extends StatefulWidget {
  final List<String> lines;
  final TextStyle? style;
  final Duration speed; // speed per character

  const TypingText({
    super.key,
    required this.lines,
    this.style,
    this.speed = const Duration(milliseconds: 100),
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  int _currentLine = 0;
  int _currentChar = 0;
  String _displayedText = "";
  Timer? _timer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentLine >= widget.lines.length) {
        _timer?.cancel();
        setState(() => _isFinished = true);
        return;
      }

      final line = widget.lines[_currentLine];

      setState(() {
        _currentChar++;
        _displayedText = _displayedText + line[_currentChar - 1];
      });

      if (_currentChar >= line.length) {
        _currentLine++;
        _currentChar = 0;
        if (_currentLine < widget.lines.length) {
          _displayedText += "\n";
        }
      }
    });
  }

  Future<void> _launchURL() async {
    const url = 'https://alabtechnology.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When animation finishes, show clickable hyperlink on the last line
    if (_isFinished) {
      List<String> parts = _displayedText.split('\n');
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            parts[0],
            textAlign: TextAlign.center,
            style: widget.style ??
                const TextStyle(fontSize: 16, color: Colors.black),
          ),
          GestureDetector(
            onTap: _launchURL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  parts.length > 1 ? parts[1] : "",
                  textAlign: TextAlign.center,
                  style: widget.style?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  parts.length > 2 ? parts[2] : "",
                  textAlign: TextAlign.center,
                  style: widget.style?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  parts.length > 3 ? parts[3] : "",
                  textAlign: TextAlign.center,
                  style: widget.style?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // While typing animation is ongoing
    return Text(
      _displayedText,
      textAlign: TextAlign.center,
      style: widget.style ?? const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}

//
// class TypingText extends StatefulWidget {
//   final List<String> lines;
//   final TextStyle? style;
//   final Duration speed; // speed per character
//
//   const TypingText({
//     Key? key,
//     required this.lines,
//     this.style,
//     this.speed = const Duration(milliseconds: 100),
//   }) : super(key: key);
//
//   @override
//   State<TypingText> createState() => _TypingTextState();
// }
//
// class _TypingTextState extends State<TypingText> {
//   int _currentLine = 0;
//   int _currentChar = 0;
//   String _displayedText = "";
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTyping();
//   }
//
//   void _startTyping() {
//     _timer = Timer.periodic(widget.speed, (timer) {
//       if (_currentLine >= widget.lines.length) {
//         _timer?.cancel();
//         return;
//       }
//
//       final line = widget.lines[_currentLine];
//
//       setState(() {
//         _currentChar++;
//         _displayedText = _displayedText + line[_currentChar - 1];
//       });
//
//       if (_currentChar >= line.length) {
//         _currentLine++;
//         _currentChar = 0;
//         if (_currentLine < widget.lines.length) {
//           _displayedText += "\n";
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       _displayedText,
//       textAlign: TextAlign.center,
//       style: widget.style ?? const TextStyle(fontSize: 16, color: Colors.black),
//     );
//   }
// }

class _AnimatedIconButton extends StatefulWidget {
  final Color color;
  final String asset;
  final String url;
  final Duration delay;

  const _AnimatedIconButton({
    required this.color,
    required this.asset,
    required this.url,
    required this.delay,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl(widget.url),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.1),
                border:
                    Border.all(color: widget.color.withOpacity(0.3), width: 1),
              ),
              child: Image.asset(
                widget.asset,
                width: 28,
                height: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}

// class _MenuScreenState extends State<MenuScreen> {
//   @override
//   void initState() {
//     Get.find<ProfileController>().getUserInfo();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//         onRefresh: () {
//
//           return Get.find<ProfileController>().getUserInfo();
//         },
//         child: Scaffold(
//           backgroundColor: Theme.of(context).cardColor,
//           body: GetBuilder<ProfileController>(builder: (profileController) {
//             final bool isLoggedIn = AuthHelper.isLoggedIn();
//             final bool showWalletCard = Get.find<SplashController>()
//                 .configModel!
//                 .customerWalletStatus ==
//                 1 ||
//                 Get.find<SplashController>().configModel!.loyaltyPointStatus ==
//                     1;
//
//             return Column(children: [
//               //? below this code are sticky app bar look
//               // Container(
//               //   decoration: BoxDecoration(
//               //     gradient: LinearGradient(
//               //       begin: Alignment.topCenter,
//               //       end: Alignment.bottomCenter,
//               //       colors: [
//               //         Colors.green.shade200,
//               //         Colors.green.shade100,
//               //         Colors.white,
//               //       ],
//               //     ),
//               //   ),
//               //   child: Padding(
//               //     padding: const EdgeInsets.only(
//               //       left: Dimensions.paddingSizeExtremeLarge,
//               //       right: Dimensions.paddingSizeExtremeLarge,
//               //       top: 80,
//               //       bottom: Dimensions.paddingSizeExtremeLarge,
//               //     ),
//               //     child: Row(
//               //       children: [
//               //         //? profile area
//               //         Container(
//               //           decoration: BoxDecoration(
//               //             color: Theme.of(context).primaryColor,
//               //             shape: BoxShape.circle,
//               //           ),
//               //           padding: const EdgeInsets.all(1),
//               //           child: ClipOval(
//               //             child: CustomImage(
//               //               placeholder: Images.guestIconLight,
//               //               image:
//               //                   '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
//               //               height: 85,
//               //               width: 85,
//               //               fit: BoxFit.cover,
//               //             ),
//               //           ),
//               //         ),
//               //         //? -- till this profile image
//               //         const SizedBox(width: Dimensions.paddingSizeDefault),
//               //         Expanded(
//               //           child: Column(
//               //             crossAxisAlignment: CrossAxisAlignment.start,
//               //             children: [
//               //               //? use name and edit option
//               //               Row(
//               //                 children: [
//               //                   Text(
//               //                     isLoggedIn
//               //                         ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName ?? ''}'
//               //                         : 'guest_user'.tr,
//               //                     style: robotoBold.copyWith(
//               //                       fontSize: 22,
//               //                       //color: Theme.of(context).cardColor,
//               //                       color: Colors.black,
//               //                     ),
//               //                   ),
//               //                   const SizedBox(
//               //                     width: Dimensions.paddingSizeSmall,
//               //                   ),
//               //                   Container(
//               //                     padding: const EdgeInsets.all(3),
//               //                     decoration: BoxDecoration(
//               //                       color: Colors.white,
//               //                       borderRadius: BorderRadius.circular(20),
//               //                       border: Border.all(
//               //                         width: 2,
//               //                         color: Colors.green,
//               //                       ),
//               //                     ),
//               //                     child: const Icon(
//               //                       Icons.edit_outlined,
//               //                       size: 16.0,
//               //                       color: Colors.green,
//               //                     ),
//               //                   )
//               //                 ],
//               //               ),
//               //               //? till now
//               //               const SizedBox(
//               //                 height: Dimensions.paddingSizeExtraSmall,
//               //               ),
//               //               //? checking if the use is loged in showing mobile number if not showing something.
//               //               isLoggedIn
//               //                   ? Text(
//               //                       profileController.userInfoModel != null
//               //                           ? profileController
//               //                                   .userInfoModel!.phone ??
//               //                               ""
//               //                           : '',
//               //                       style: robotoMedium.copyWith(
//               //                         fontSize: Dimensions.fontSizeSmall,
//               //                         //color: Theme.of(context).cardColor,
//               //                         color: Colors.black54,
//               //                       ),
//               //                     )
//               //                   : InkWell(
//               //                       onTap: () async {
//               //                         if (!ResponsiveHelper.isDesktop(
//               //                             context)) {
//               //                           await Get.toNamed(
//               //                               RouteHelper.getSignInRoute(
//               //                                   Get.currentRoute));
//               //                           if (AuthHelper.isLoggedIn()) {
//               //                             profileController.getUserInfo();
//               //                           }
//               //                         } else {
//               //                           Get.dialog(const SignInScreen(
//               //                               exitFromApp: true,
//               //                               backFromThis: true));
//               //                         }
//               //                       },
//               //                       child: Text(
//               //                         'login_to_view_all_feature'.tr,
//               //                         style: robotoMedium.copyWith(
//               //                             fontSize: Dimensions.fontSizeSmall,
//               //                             color: Theme.of(context).cardColor),
//               //                       ),
//               //                     ),
//               //               //? --finishing loged in
//               //             ],
//               //           ),
//               //         ),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               //? -- till here app bar
//
//               Expanded(
//                   child: SingleChildScrollView(
//                     child: Ink(
//                       //color: Theme.of(context).primaryColor.withOpacity(0.1),
//                       color: Colors.white,
//                       child: Column(
//                         children: [
//                           //? name and use image , edit
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.green.shade300,
//                                   Colors.green.shade200,
//                                   Colors.white10,
//                                 ],
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                 left: Dimensions.paddingSizeSmall,
//                                 right: Dimensions.paddingSizeSmall,
//                                 top: 80,
//                                 bottom: Dimensions.paddingSizeSmall,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       //? profile area
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             width: 1.2,
//                                             color: Colors.redAccent.shade100,
//                                           ),
//                                         ),
//                                         child: Container(
//                                           margin: const EdgeInsets.all(4),
//                                           decoration: const BoxDecoration(
//                                             color:
//                                             Color.fromARGB(221, 255, 236, 179),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           height: 75,
//                                           width: 75,
//                                           padding: const EdgeInsets.all(2),
//                                           child: Center(
//                                             child: ClipOval(
//                                               child: CustomImage(
//                                                 placeholder: Images.guestDummyIcon,
//                                                 image:
//                                                 '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
//                                                 height: 75,
//                                                 width: 75,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       //? -- till this profile image
//                                       const SizedBox(
//                                           width: Dimensions.paddingSizeDefault),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             //? use name and edit option
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   isLoggedIn
//                                                       ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName ?? ''}'
//                                                       : 'guest_user'.tr,
//                                                   style: robotoBold.copyWith(
//                                                     fontSize: 22,
//                                                     //color: Theme.of(context).cardColor,
//                                                     color: Colors.black,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(
//                                                   width:
//                                                   Dimensions.paddingSizeSmall,
//                                                 ),
//                                                 Container(
//                                                   padding: const EdgeInsets.all(3),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                     BorderRadius.circular(20),
//                                                     border: Border.all(
//                                                       width: 2,
//                                                       color: Colors.green,
//                                                     ),
//                                                   ),
//                                                   child: const Icon(
//                                                     Icons.edit_outlined,
//                                                     size: 16.0,
//                                                     color: Colors.green,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                             //? till now
//                                             // const SizedBox(
//                                             //   height:
//                                             //       Dimensions.paddingSizeExtraSmall -
//                                             //           5,
//                                             // ),
//                                             //? checking if the use is loged in showing mobile number if not showing something.
//                                             isLoggedIn
//                                                 ? Text(
//                                               profileController
//                                                   .userInfoModel !=
//                                                   null
//                                                   ? profileController
//                                                   .userInfoModel!
//                                                   .phone ??
//                                                   ""
//                                                   : '',
//                                               style: robotoMedium.copyWith(
//                                                 fontSize:
//                                                 Dimensions.fontSizeSmall,
//                                                 //color: Theme.of(context).cardColor,
//                                                 color: Colors.black54,
//                                               ),
//                                             )
//                                                 : InkWell(
//                                               onTap: () async {
//                                                 if (!ResponsiveHelper
//                                                     .isDesktop(context)) {
//                                                   await Get.toNamed(
//                                                       RouteHelper
//                                                           .getSignInRoute(Get
//                                                           .currentRoute));
//                                                   if (AuthHelper
//                                                       .isLoggedIn()) {
//                                                     profileController
//                                                         .getUserInfo();
//                                                   }
//                                                 } else {
//                                                   Get.dialog(
//                                                       const SignInScreen(
//                                                           exitFromApp: true,
//                                                           backFromThis:
//                                                           true));
//                                                 }
//                                               },
//                                               child: Text(
//                                                 'login_to_view_all_feature'
//                                                     .tr,
//                                                 style: robotoMedium.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeSmall,
//                                                     color: Theme.of(context)
//                                                         .cardColor),
//                                               ),
//                                             ),
//                                             //? --finishing loged in
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   //? referal area
//                                   Container(
//                                     padding: const EdgeInsets.only(
//                                       left: Dimensions.paddingSizeSmall,
//                                       right: Dimensions.paddingSizeSmall,
//                                       top: 25,
//                                     ),
//                                     child: Row(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'refer_and_earn'.tr,
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 16,
//                                                 color:
//                                                 Color.fromARGB(255, 20, 55, 38),
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               'Refer a Friend & Earn ₹100',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey[700],
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   'Referral Code : ',
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     color: Colors.grey[700],
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   profileController
//                                                       .userInfoModel?.refCode ??
//                                                       "",
//                                                   style: const TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 14,
//                                                     color: Colors.black,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(
//                                                   width:
//                                                   Dimensions.paddingSizeSmall,
//                                                 ),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     if (profileController
//                                                         .userInfoModel!
//                                                         .refCode!
//                                                         .isNotEmpty) {
//                                                       Clipboard.setData(ClipboardData(
//                                                           text:
//                                                           '${profileController.userInfoModel != null ? profileController.userInfoModel!.refCode : ''}'));
//                                                       showCustomSnackBar(
//                                                           'referral_code_copied'.tr,
//                                                           isError: false);
//                                                     }
//                                                   },
//                                                   child: const Icon(
//                                                     Icons.copy,
//                                                     size: 16,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () {
//                                             Share.share(
//                                               Get.find<SplashController>()
//                                                   .configModel
//                                                   ?.appUrlAndroid !=
//                                                   null
//                                                   ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
//                                                   : "I’ve been enjoying TOGOX restaurant recently, and I wanted to share a little something with you! If you sign up using my referral code, you can get started with TOGOX too! 🎉Here’s my \n${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n\n ${AppConstants.applink}",
//                                             );
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Color(0xFF014734),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                               BorderRadius.circular(8),
//                                             ),
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal:
//                                               Dimensions.paddingSizeLarge,
//                                               vertical: Dimensions.paddingSizeSmall,
//                                             ),
//                                           ),
//                                           child: const Text(
//                                             'Share',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   //? referal code
//                                 ],
//                               ),
//                             ),
//                           ),
//                           //? -- till name and user.
//
//                           //? order tab
//                           PortionWidget2(
//                               icon: Images.packageIcon,
//                               title: "Your Orders",
//                               onTap: () => Get.to(() => const OrderScreen()),
//                               route: ""),
//                           //? -- order
//                           //? Bookings tab
//                           // PortionWidget2(
//                           //     icon: Images.TaxiIcon,
//                           //     title: "Your Bookings",
//                           //     onTap: () => Get.to(()=> HistoryScreen()),
//                           //     route: ""),
//                           //? -- Bookings
//                           //? favrouit
//                           PortionWidget2(
//                               icon: Images.favrouitIcon,
//                               title: 'Favrouite',
//                               onTap: () => Get.to(() => const FavouriteScreen()),
//                               route: ""),
//                           //? -- favrouit
//
//                           //? address
//                           PortionWidget2(
//                               icon: Images.addressIcon2,
//                               title: "Address Book",
//                               route: RouteHelper.getAddressRoute()),
//                           //?-- address
//
//                           //? favrouit
//                           // PortionWidget2(
//                           //     icon: Images.refundIcon2,
//                           //     title: 'Refund',
//                           //     onTap: () => Get.to(() => const RefundScreen()),
//                           //     route: ""),
//                           //? -- order
//
//                           //? wallet
//                           (Get.find<SplashController>()
//                               .configModel!
//                               .customerWalletStatus ==
//                               1)
//                               ? PortionWidget2(
//                             icon: Images.walletIcon,
//                             title: 'my_wallet'.tr,
//                             hideDivider: true,
//                             route: RouteHelper.getWalletRoute(),
//                             suffix: !isLoggedIn
//                                 ? null
//                                 : PriceConverter.convertPrice(
//                                 profileController.userInfoModel != null
//                                     ? profileController
//                                     .userInfoModel!.walletBalance
//                                     : 0),
//                           )
//                               : const SizedBox(),
//                           //?--wallet
//
//                           //? notification
//                           // PortionWidget2(
//                           //     icon: Images.notificationIcon,
//                           //     title: 'Notification',
//                           //     onTap: () =>
//                           //         Get.to(() => const NotificationOptionscreen()),
//                           //     route: ""),
//                           //? -- notification
//
//                           //? language
//                           PortionWidget2(
//                               icon: Images.languageIcon2,
//                               title: 'language'.tr,
//                               hideDivider: true,
//                               ///onTap: () => _manageLanguageFunctionality(),
//                               //onTap: () => Get.to(() => const LanguageNewScreen()),
//                               onTap: () => Get.to(() => const LanguageBottomSheetWidget()),
//                               route: ''),
//                           //?--- language
//
//                           //? Review
//                           // PortionWidget2(
//                           //     icon: Images.review,
//                           //     title: 'Reviews',
//                           //     onTap: () => Get.to(() => const ReviewNewScreen()),
//                           //     route: ""),
//                           //? -- Review
//
//                           //? about and help
//                           PortionWidget2(
//                               icon: Images.messageIcon,
//                               title: 'About and help',
//                               onTap: ()=> Get.to(()=> const AboutScreen()),
//                               route: ""),
//
//                           //?--- about and help :: this only show about want to add about
//
//                           //? coupon
//                           PortionWidget2(
//                             icon: Images.percentageIcon,
//                             title: 'Coupons',
//                             route:
//                             RouteHelper.getCouponRoute(),
//                             hideDivider: Get.find<SplashController>()
//                                 .configModel!
//                                 .loyaltyPointStatus ==
//                                 1 ||
//                                 Get.find<SplashController>()
//                                     .configModel!
//                                     .customerWalletStatus ==
//                                     1
//                                 ? false
//                                 : true,
//                           ),
//                           //?---- coupon
//
//                           //? logout
//                           PortionWidget2(
//                             color: Colors.red,
//                             icon: Images.logoutIcon2,
//                             title: AuthHelper.isLoggedIn()
//                                 ? 'logout'.tr
//                                 : 'sign_in'.tr,
//                             onTap: () async {
//                               if (AuthHelper.isLoggedIn()) {
//                                 Get.dialog(
//                                     ConfirmationDialog(
//                                         icon: Images.support,
//                                         description: 'are_you_sure_to_logout'.tr,
//                                         isLogOut: true,
//                                         onYesPressed: () async {
//                                           logoutUser();
//                                           Get.find<ProfileController>()
//                                               .clearUserInfo();
//                                           Get.find<AuthController>().socialLogout();
//                                           Get.find<CartController>().clearCartList(
//                                               canRemoveOnline: false);
//                                           Get.find<FavouriteController>()
//                                               .removeFavourite();
//                                           await Get.find<AuthController>()
//                                               .clearSharedData();
//                                           Get.find<HomeController>()
//                                               .forcefullyNullCashBackOffers();
//                                           await Get.offAllNamed(
//                                               RouteHelper.getSignInRoute(
//                                                   Get.currentRoute));
//                                           //   Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false)); by ak
//                                         }),
//                                     useSafeArea: false);
//                               } else {
//                                 Get.find<FavouriteController>().removeFavourite();
//                                 await Get.toNamed(
//                                     RouteHelper.getSignInRoute(Get.currentRoute));
//                                 if (AuthHelper.isLoggedIn()) {
//                                   await Get.find<FavouriteController>()
//                                       .getFavouriteList();
//                                   profileController.getUserInfo();
//                                 }
//                               }
//                             },
//                             route: "",
//                           ),
//                           //?----- logout
//
//                           //? app version
//                           const SizedBox(height: 20),
//                           Text(
//                             "Release Version 2.0.12",
//                             style: TextStyle(
//                               fontSize: Dimensions.fontSizeLarge,
//                               color: Theme.of(context).hintColor,
//                             ),
//                           ),
//                           //?----------appp version
//
//                           //? powerby
//                           const SizedBox(height: 20),
//                           RichText(
//                             textAlign: TextAlign.center,
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: "Designed & Developed By \n",
//                                   style: TextStyle(
//                                     fontSize: Dimensions.fontSizeLarge,
//                                     color: Theme.of(context).hintColor,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: "Alabtechnology Pvt.Ltd With ❤️",
//                                   style: TextStyle(
//                                     fontSize: Dimensions.fontSizeLarge,
//                                     color: Colors.black54,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           //?---------powerby
// /*
//                     Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                               padding: const EdgeInsets.only(
//                                   left: Dimensions.paddingSizeDefault,
//                                   right: Dimensions.paddingSizeDefault),
//                               child: Text(
//                                 'Orders & Bookings '.tr,
//                                 style: robotoMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.5),
//                                 ),
//                               )),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(
//                                   Dimensions.radiusDefault),
//                               boxShadow: const [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 5,
//                                     spreadRadius: 1)
//                               ],
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeLarge,
//                                 vertical: Dimensions.paddingSizeDefault),
//                             margin: const EdgeInsets.all(
//                                 Dimensions.paddingSizeDefault),
//                             child: Column(children: [
//                               PortionWidget(
//                                   icon: Images.orders,
//                                   title: 'orders'.tr,
//                                   onTap: () => Get.to(() => OrderScreen()),
//                                   route: ""),
//                               PortionWidget(
//                                   icon: Images.clockIcon,
//                                   title: 'Bookings'.tr,
//                                   hideDivider: true,
//                                   onTap: () => Get.to(() => HistoryScreen()),
//                                   route: ''),
//                             ]),
//                           )
//                         ]),
//                     Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                               padding: const EdgeInsets.only(
//                                   left: Dimensions.paddingSizeDefault,
//                                   right: Dimensions.paddingSizeDefault),
//                               child: Text(
//                                 'general'.tr,
//                                 style: robotoMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.5),
//                                 ),
//                               )),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(
//                                   Dimensions.radiusDefault),
//                               boxShadow: const [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 5,
//                                     spreadRadius: 1)
//                               ],
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeLarge,
//                                 vertical: Dimensions.paddingSizeDefault),
//                             margin: const EdgeInsets.all(
//                                 Dimensions.paddingSizeDefault),
//                             child: Column(children: [
//                               PortionWidget(
//                                   icon: Images.profileIcon,
//                                   title: 'profile'.tr,
//                                   route: RouteHelper.getProfileRoute()),
//                               PortionWidget(
//                                   icon: Images.addressIcon,
//                                   title: 'my_address'.tr,
//                                   route: RouteHelper.getAddressRoute()),
//                               PortionWidget(
//                                   icon: Images.languageIcon,
//                                   title: 'language'.tr,
//                                   hideDivider: true,
//                                   onTap: () => _manageLanguageFunctionality(),
//                                   route: ''),
//                             ]),
//                           )
//                         ]),
//                     Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeDefault),
//                             child: Text(
//                               "App Settings",
//                               style: robotoMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.5)),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(
//                                   Dimensions.radiusDefault),
//                               boxShadow: const [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     spreadRadius: 1,
//                                     blurRadius: 5)
//                               ],
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeLarge,
//                                 vertical: Dimensions.paddingSizeDefault),
//                             margin: const EdgeInsets.all(
//                                 Dimensions.paddingSizeDefault),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "App Version :",
//                                           style: robotoRegular,
//                                         ),
//                                         Text(
//                                           AppConstants.appVersion.toString(),
//                                           style: robotoRegular,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 10,
//                                   ),
//                                   Container(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(top: 8.0),
//                                       child: FittedBox(
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                                 'Developed By : Alab Technology Pvt.Ltd Care with ',
//                                                 style: robotoRegular),
//                                             const SizedBox(
//                                               width: 5,
//                                             ),
//                                             const Icon(
//                                               Icons.favorite,
//                                               size: 20,
//                                               color: Colors.pink,
//                                               shadows: [
//                                                 Shadow(
//                                                     color: Colors.white,
//                                                     offset: Offset(0, 2),
//                                                     blurRadius: 0),
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ]),
//                           )
//                         ]),
//                     Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: Dimensions.paddingSizeDefault,
//                                 right: Dimensions.paddingSizeDefault),
//                             child: Text(
//                               'promotional_activity'.tr,
//                               style: robotoMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.5)),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(
//                                   Dimensions.radiusDefault),
//                               boxShadow: const [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 5,
//                                     spreadRadius: 1)
//                               ],
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeLarge,
//                                 vertical: Dimensions.paddingSizeDefault),
//                             margin: const EdgeInsets.all(
//                                 Dimensions.paddingSizeDefault),
//                             child: Column(children: [
//                               PortionWidget(
//                                 icon: Images.couponIcon,
//                                 title: 'coupon'.tr,
//                                 route: RouteHelper.getCouponRoute(),
//                                 hideDivider: Get.find<SplashController>()
//                                                 .configModel!
//                                                 .loyaltyPointStatus ==
//                                             1 ||
//                                         Get.find<SplashController>()
//                                                 .configModel!
//                                                 .customerWalletStatus ==
//                                             1
//                                     ? false
//                                     : true,
//                               ),
//                               (Get.find<SplashController>()
//                                           .configModel!
//                                           .loyaltyPointStatus ==
//                                       1)
//                                   ? PortionWidget(
//                                       icon: Images.pointIcon,
//                                       title: 'loyalty_points'.tr,
//                                       route: RouteHelper.getLoyaltyRoute(),
//                                       hideDivider: Get.find<SplashController>()
//                                                   .configModel!
//                                                   .customerWalletStatus ==
//                                               1
//                                           ? false
//                                           : true,
//                                       suffix: !isLoggedIn
//                                           ? null
//                                           : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
//                                     )
//                                   : const SizedBox(),
//                               (Get.find<SplashController>()
//                                           .configModel!
//                                           .customerWalletStatus ==
//                                       1)
//                                   ? PortionWidget(
//                                       icon: Images.walletIcon,
//                                       title: 'my_wallet'.tr,
//                                       hideDivider: true,
//                                       route: RouteHelper.getWalletRoute(),
//                                       suffix: !isLoggedIn
//                                           ? null
//                                           : PriceConverter.convertPrice(
//                                               profileController.userInfoModel !=
//                                                       null
//                                                   ? profileController
//                                                       .userInfoModel!
//                                                       .walletBalance
//                                                   : 0),
//                                     )
//                                   : const SizedBox(),
//                             ]),
//                           )
//                         ]),
//                     (Get.find<SplashController>()
//                                     .configModel!
//                                     .refEarningStatus ==
//                                 1) ||
//                             (Get.find<SplashController>()
//                                     .configModel!
//                                     .toggleDmRegistration! &&
//                                 !ResponsiveHelper.isDesktop(context)) ||
//                             (Get.find<SplashController>()
//                                     .configModel!
//                                     .toggleStoreRegistration! &&
//                                 !ResponsiveHelper.isDesktop(context))
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: Dimensions.paddingSizeDefault,
//                                       right: Dimensions.paddingSizeDefault),
//                                   child: Text(
//                                     'earnings'.tr,
//                                     style: robotoMedium.copyWith(
//                                         fontSize: Dimensions.fontSizeDefault,
//                                         color: Theme.of(context)
//                                             .primaryColor
//                                             .withOpacity(0.5)),
//                                   ),
//                                 ),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).cardColor,
//                                     borderRadius: BorderRadius.circular(
//                                         Dimensions.radiusDefault),
//                                     boxShadow: const [
//                                       BoxShadow(
//                                           color: Colors.black12,
//                                           blurRadius: 5,
//                                           spreadRadius: 1)
//                                     ],
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: Dimensions.paddingSizeLarge,
//                                       vertical: Dimensions.paddingSizeDefault),
//                                   margin: const EdgeInsets.all(
//                                       Dimensions.paddingSizeDefault),
//                                   child: Column(children: [
//                                     (Get.find<SplashController>()
//                                                 .configModel!
//                                                 .refEarningStatus ==
//                                             1)
//                                         ? PortionWidget(
//                                             icon: Images.referIcon,
//                                             title: 'refer_and_earn'.tr,
//                                             route: RouteHelper
//                                                 .getReferAndEarnRoute(),
//                                             hideDivider: (Get.find<
//                                                                 SplashController>()
//                                                             .configModel!
//                                                             .toggleDmRegistration! &&
//                                                         !ResponsiveHelper
//                                                             .isDesktop(
//                                                                 context)) ||
//                                                     (Get.find<SplashController>()
//                                                             .configModel!
//                                                             .toggleStoreRegistration! &&
//                                                         !ResponsiveHelper
//                                                             .isDesktop(context))
//                                                 ? false
//                                                 : true,
//                                           )
//                                         : const SizedBox(),
//                                     (Get.find<SplashController>()
//                                                 .configModel!
//                                                 .toggleDmRegistration! &&
//                                             !ResponsiveHelper.isDesktop(
//                                                 context))
//                                         ? PortionWidget(
//                                             icon: Images.dmIcon,
//                                             title: 'join_as_a_delivery_man'.tr,
//                                             route: RouteHelper
//                                                 .getDeliverymanRegistrationRoute(),
//                                             hideDivider: (Get.find<
//                                                             SplashController>()
//                                                         .configModel!
//                                                         .toggleStoreRegistration! &&
//                                                     !ResponsiveHelper.isDesktop(
//                                                         context))
//                                                 ? false
//                                                 : true,
//                                           )
//                                         : const SizedBox(),
//                                     (Get.find<SplashController>()
//                                                 .configModel!
//                                                 .toggleStoreRegistration! &&
//                                             !ResponsiveHelper.isDesktop(
//                                                 context))
//                                         ? PortionWidget(
//                                             icon: Images.storeIcon,
//                                             title: 'open_store'.tr,
//                                             hideDivider: true,
//                                             route: RouteHelper
//                                                 .getRestaurantRegistrationRoute(),
//                                           )
//                                         : const SizedBox(),
//                                   ]),
//                                 )
//                               ])
//                         : const SizedBox(),
//                     Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: Dimensions.paddingSizeDefault,
//                                 right: Dimensions.paddingSizeDefault),
//                             child: Text(
//                               'help_and_support'.tr,
//                               style: robotoMedium.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                   color: Theme.of(context)
//                                       .primaryColor
//                                       .withOpacity(0.5)),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(
//                                   Dimensions.radiusDefault),
//                               boxShadow: const [
//                                 BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 5,
//                                     spreadRadius: 1)
//                               ],
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: Dimensions.paddingSizeLarge,
//                                 vertical: Dimensions.paddingSizeDefault),
//                             margin: const EdgeInsets.all(
//                                 Dimensions.paddingSizeDefault),
//                             child: Column(children: [
//                               PortionWidget(
//                                   icon: Images.chatIcon,
//                                   title: 'live_chat'.tr,
//                                   route: RouteHelper.getConversationRoute()),
//                               PortionWidget(
//                                   icon: Images.helpIcon,
//                                   title: 'help_and_support'.tr,
//                                   route: RouteHelper.getSupportRoute()),
//                               PortionWidget(
//                                   icon: Images.aboutIcon,
//                                   title: 'about_us'.tr,
//                                   route: RouteHelper.getHtmlRoute('about-us')),
//                               PortionWidget(
//                                   icon: Images.termsIcon,
//                                   title: 'terms_conditions'.tr,
//                                   route: RouteHelper.getHtmlRoute(
//                                       'terms-and-condition')),
//                               PortionWidget(
//                                   icon: Images.privacyIcon,
//                                   title: 'privacy_policy'.tr,
//                                   route: RouteHelper.getHtmlRoute(
//                                       'privacy-policy')),
//                               (Get.find<SplashController>()
//                                           .configModel!
//                                           .refundPolicyStatus ==
//                                       1)
//                                   ? PortionWidget(
//                                       icon: Images.refundIcon,
//                                       title: 'refund_policy'.tr,
//                                       route: RouteHelper.getHtmlRoute(
//                                           'refund-policy'),
//                                       hideDivider: (Get.find<SplashController>()
//                                                       .configModel!
//                                                       .cancellationPolicyStatus ==
//                                                   1) ||
//                                               (Get.find<SplashController>()
//                                                       .configModel!
//                                                       .shippingPolicyStatus ==
//                                                   1)
//                                           ? false
//                                           : true,
//                                     )
//                                   : const SizedBox(),
//                               (Get.find<SplashController>()
//                                           .configModel!
//                                           .cancellationPolicyStatus ==
//                                       1)
//                                   ? PortionWidget(
//                                       icon: Images.cancelationIcon,
//                                       title: 'cancellation_policy'.tr,
//                                       route: RouteHelper.getHtmlRoute(
//                                           'cancellation-policy'),
//                                       hideDivider: (Get.find<SplashController>()
//                                                   .configModel!
//                                                   .shippingPolicyStatus ==
//                                               1)
//                                           ? false
//                                           : true,
//                                     )
//                                   : const SizedBox(),
//                               (Get.find<SplashController>()
//                                           .configModel!
//                                           .shippingPolicyStatus ==
//                                       1)
//                                   ? PortionWidget(
//                                       icon: Images.shippingIcon,
//                                       title: 'shipping_policy'.tr,
//                                       hideDivider: true,
//                                       route: RouteHelper.getHtmlRoute(
//                                           'shipping-policy'),
//                                     )
//                                   : const SizedBox(),
//                             ]),
//                           )
//                         ]),
//
//                       InkWell(
//                         onTap: () async {
//                           if (AuthHelper.isLoggedIn()) {
//                             Get.dialog(
//                                 ConfirmationDialog(
//                                     icon: Images.support,
//                                     description: 'are_you_sure_to_logout'.tr,
//                                     isLogOut: true,
//                                     onYesPressed: () async {
//                                       logoutUser();
//                                       Get.find<ProfileController>()
//                                           .clearUserInfo();
//                                       Get.find<AuthController>().socialLogout();
//                                       Get.find<CartController>().clearCartList(
//                                           canRemoveOnline: false);
//                                       Get.find<FavouriteController>()
//                                           .removeFavourite();
//                                       await Get.find<AuthController>()
//                                           .clearSharedData();
//                                       Get.find<HomeController>()
//                                           .forcefullyNullCashBackOffers();
//                                       await Get.offAllNamed(
//                                           RouteHelper.getSignInRoute(
//                                               Get.currentRoute));
//                                       //   Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false)); by ak
//                                     }),
//                                 useSafeArea: false);
//                           } else {
//                             Get.find<FavouriteController>().removeFavourite();
//                             await Get.toNamed(
//                                 RouteHelper.getSignInRoute(Get.currentRoute));
//                             if (AuthHelper.isLoggedIn()) {
//                               await Get.find<FavouriteController>()
//                                   .getFavouriteList();
//                               profileController.getUserInfo();
//                             }
//                           }
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: Dimensions.paddingSizeSmall),
//                           child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(2),
//                                   decoration: const BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.red),
//                                   child: Icon(Icons.power_settings_new_sharp,
//                                       size: 18,
//                                       color: Theme.of(context).cardColor),
//                                 ),
//                                 const SizedBox(
//                                     width: Dimensions.paddingSizeExtraSmall),
//                                 Text(
//                                     AuthHelper.isLoggedIn()
//                                         ? 'logout'.tr
//                                         : 'sign_in'.tr,
//                                     style: robotoMedium.copyWith(
//                                         fontSize: Dimensions.fontSizeLarge))
//                               ]),
//                         ),
//                       ),
//
//                        */
//
//                           SizedBox(
//                               height: ResponsiveHelper.isDesktop(context)
//                                   ? Dimensions.paddingSizeExtremeLarge
//                                   : 100),
//                         ],
//                       ),
//                     ),
//                   )),
//             ]);
//           }),
//         ));
//   }

void _manageLanguageFunctionality() {
  Get.find<LocalizationController>().saveCacheLanguage(null);
  Get.find<LocalizationController>().searchSelectedLanguage();

  showModalBottomSheet(
    isScrollControlled: true,
    useRootNavigator: true,
    context: Get.context!,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: const LanguageBottomSheetWidget(),
      );
    },
  ).then((value) => Get.find<LocalizationController>().setLanguage(
      Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
}

class ProfileCard extends StatelessWidget {
  final String image;
  final String title;
  final String data;

  const ProfileCard(
      {super.key, required this.data, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveHelper.isDesktop(context) ? 130 : 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor, width: 0.1),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1)
        ],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(image, height: 30, width: 30),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          data,
          textDirection: TextDirection.ltr,
          style: robotoMedium.copyWith(
              fontSize: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.fontSizeDefault
                  : Dimensions.fontSizeExtraLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(title,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).disabledColor,
            )),
      ]),
    );
  }
}

Future<String> logoutUser() async {
  int? id = Get.find<ProfileController>().userInfoModel!.id;
  const String url = '${AppConstants.baseUrl}/api/v1/auth/logout';
  final Map<String, dynamic> body = {
    'user_id': id,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json', // Headers
      },
      body: jsonEncode(body), // Encode the body as JSON
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Logout successful: $responseData');
      return 'Logout successful';
    } else {
      print('Failed to logout: ${response.statusCode}');
      return 'Logout failed: ${response.statusCode}';
    }
  } catch (error) {
    print('Error: $error');
    return 'An error occurred: $error';
  }
}
//
// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});
//
//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }
//
// class _MenuScreenState extends State<MenuScreen> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).cardColor,
//       body: GetBuilder<ProfileController>(builder: (profileController) {
//         final bool isLoggedIn = AuthHelper.isLoggedIn();
//
//         return Column(children: [
//
//           Container(
//             decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 left: Dimensions.paddingSizeExtremeLarge, right: Dimensions.paddingSizeExtremeLarge,
//                 top: 50, bottom: Dimensions.paddingSizeExtremeLarge,
//               ),
//               child: Row(children: [
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: const EdgeInsets.all(1),
//                   child: ClipOval(child: CustomImage(
//                     placeholder: Images.guestIconLight,
//                     image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
//                     height: 70, width: 70, fit: BoxFit.cover,
//                   )),
//                 ),
//                 const SizedBox(width: Dimensions.paddingSizeDefault),
//
//                 Expanded(
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                     isLoggedIn && profileController.userInfoModel == null ? Shimmer(
//                       child: Container(
//                         height: 15, width: 150,
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).cardColor,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                     ) : Text(
//                       isLoggedIn ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}' : 'guest_user'.tr,
//                       style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
//                     ),
//                     SizedBox(height: isLoggedIn && profileController.userInfoModel == null ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),
//
//                     isLoggedIn && profileController.userInfoModel == null ? Shimmer(
//                       child: Container(
//                         height: 15, width: 100,
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).cardColor,
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                     ) : isLoggedIn ? Text(
//                       profileController.userInfoModel != null ? DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!) : '',
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
//                     ) : InkWell(
//                       onTap: () async {
//                         if(!ResponsiveHelper.isDesktop(context)) {
//                           await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
//                           if(AuthHelper.isLoggedIn()) {
//                             profileController.getUserInfo();
//                           }
//                         }else{
//                           Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: true, backFromThis: true)));
//                         }
//                       },
//                       child: Text(
//                         'login_to_view_all_feature'.tr,
//                         style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
//                       ),
//                     ) ,
//
//                   ]),
//                 ),
//
//               ]),
//             ),
//           ),
//
//           Expanded(child: SingleChildScrollView(
//             child: Ink(
//               color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
//               padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
//               child: Column(children: [
//
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
//                     child: Text(
//                       'general'.tr,
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
//                     ),
//                   ),
//
//                   Container(
//                     decoration: BoxDecoration(
//                         color: Theme.of(context).cardColor,
//                         borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
//                     margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                     child: Column(children: [
//                       PortionWidget(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
//                       PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
//                       PortionWidget(icon: Images.languageIcon, title: 'language'.tr, hideDivider: true, onTap: ()=> _manageLanguageFunctionality(), route: ''),
//                     ]),
//                   )
//
//                 ]),
//
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
//                     child: Text(
//                       'promotional_activity'.tr,
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
//                     ),
//                   ),
//
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
//                     margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                     child: Column(children: [
//                       PortionWidget(
//                         icon: Images.couponIcon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(),
//                         hideDivider: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 || Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
//                       ),
//
//                       (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) ? PortionWidget(
//                           icon: Images.pointIcon, title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute(),
//                         hideDivider: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
//                         suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}' ,
//                       ) : const SizedBox(),
//
//                       (Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? PortionWidget(
//                           icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: RouteHelper.getWalletRoute(),
//                         suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? profileController.userInfoModel!.walletBalance : 0),
//                       ) : const SizedBox(),
//                     ]),
//                   )
//                 ]),
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
//                     child: Text(
//                       "App Settings",
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withOpacity(0.5)),
//                     ),
//                   ),
//
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                       boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
//                     margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                     child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             child:
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("App Version :",style: robotoRegular,),
//                                 Text("1.0.0",style: robotoRegular,),
//                               ],
//                             ),),
//                           const SizedBox(height: 10,),
//                           Container(
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: FittedBox(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('Developed By : Alab Technology Pvt.Ltd Care with ', style:robotoRegular),
//                                     const SizedBox(width: 5,),
//                                     const Icon(Icons.favorite,size: 20,color: Colors.pink,shadows: [
//                                       Shadow(color: Colors.white,offset:Offset(0,2),blurRadius: 0),
//                                     ],)
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                         ]),
//                   )
//                 ]),
//
//                 (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) || (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
//                     (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ?
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
//                     child: Text(
//                       'earnings'.tr,
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
//                     margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                     child: Column(children: [
//
//                       (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? PortionWidget(
//                           icon: Images.referIcon, title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute(),
//                         hideDivider: (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
//                             (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
//                       ) : const SizedBox(),
//
//                       (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
//                           icon: Images.dmIcon, title: 'join_as_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute(),
//                         hideDivider: (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
//                       ) : const SizedBox(),
//
//                       (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
//                           icon: Images.storeIcon, title: 'open_vendor'.tr, hideDivider: true, route: RouteHelper.getRestaurantRegistrationRoute(),
//                       ) : const SizedBox(),
//                     ]),
//                   )
//                 ]) : const SizedBox(),
//
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
//                     child: Text(
//                       'help_and_support'.tr,
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
//                     ),
//                   ),
//
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
//                     margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//                     child: Column(children: [
//                       PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
//                       PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
//                       PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
//                       PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
//                       PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
//
//                       (Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ) ? PortionWidget(
//                           icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy'),
//                         hideDivider: (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ||
//                             (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
//                       ) : const SizedBox(),
//
//                       (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ? PortionWidget(
//                           icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy'),
//                         hideDivider: (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
//                       ) : const SizedBox(),
//
//                       (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? PortionWidget(
//                           icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.getHtmlRoute('shipping-policy'),
//                       ) : const SizedBox(),
//                     ]),
//                   )
//                 ]),
//
//                 InkWell(
//                   onTap: () async {
//                     if(AuthHelper.isLoggedIn()) {
//                       Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
//                         Get.find<AuthController>().resetOtpView();
//                         Get.find<ProfileController>().clearUserInfo();
//                         Get.find<AuthController>().socialLogout();
//                         Get.find<CartController>().clearCartList(canRemoveOnline: false);
//                         Get.find<FavouriteController>().removeFavourite();
//                         await Get.find<AuthController>().clearSharedData();
//                         Get.find<HomeController>().forcefullyNullCashBackOffers();
//                         Get.find<TaxiCartController>().getCarCartList();
//                         Get.offAllNamed(RouteHelper.getInitialRoute());
//                       }), useSafeArea: false);
//                     }else {
//                       Get.find<FavouriteController>().removeFavourite();
//                       await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
//                       if(AuthHelper.isLoggedIn()) {
//                         await Get.find<FavouriteController>().getFavouriteList();
//                         profileController.getUserInfo();
//                       }
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//                     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                       Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
//                         child: Icon(Icons.power_settings_new_sharp, size: 18, color: Theme.of(context).cardColor),
//                       ),
//                       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                       Text(AuthHelper.isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))
//                     ]),
//                   ),
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 100),
//
//               ]),
//             ),
//           )),
//         ]);
//       }),
//     );
//   }
//
//   _manageLanguageFunctionality() {
//     Get.find<LocalizationController>().saveCacheLanguage(null);
//     Get.find<LocalizationController>().searchSelectedLanguage();
//
//     showModalBottomSheet(
//       isScrollControlled: true, useRootNavigator: true, context: Get.context!,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
//       ),
//       builder: (context) {
//         return ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
//           child: const LanguageBottomSheetWidget(),
//         );
//       },
//     ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
//   }
//
// }
