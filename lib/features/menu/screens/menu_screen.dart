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
import 'package:handy_allinone/features/menu/screens/faq_screen.dart';

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
  final bool fromNav;
  const MenuScreen({super.key, this.fromNav = false});

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
                      widget.fromNav ? const SizedBox() : GestureDetector(
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
                            icon: Images.support,
                            title: 'faq'.tr,
                            route: '',
                            onTap: () => Get.to(() => const FaqScreen()),
                            iconcolor: Colors.pinkAccent,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: (Get.find<SplashController>().configModel!.socialMedia ?? []).where((social) {
                          bool isSupported = ['facebook', 'instagram', 'youtube'].contains(social.name?.toLowerCase());
                          return social.status == 1 && isSupported;
                        }).map((social) {
                          String? asset;
                          Color color = Colors.blue;

                          switch (social.name?.toLowerCase()) {
                            case 'facebook':
                              asset = Images.facebook;
                              color = const Color(0xFF1877F2);
                              break;
                            case 'instagram':
                              asset = Images.instagram;
                              color = const Color(0xFFE4405F);
                              break;
                            case 'youtube':
                              asset = Images.youtube;
                              color = const Color(0xFFFF0000);
                              break;
                          }

                          if (asset == null) return const SizedBox();

                          return _AnimatedIconButton(
                            color: color,
                            asset: asset,
                            url: social.link ?? '',
                            delay: Duration(milliseconds: (Get.find<SplashController>().configModel!.socialMedia!.indexOf(social) * 200)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "App Version: ${AppConstants.devAppVersion}",
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  speed: const Duration(milliseconds: 100),
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

class TypingText extends StatefulWidget {
  final List<String> lines;
  final TextStyle? style;
  final Duration speed;

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

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentLine >= widget.lines.length) {
        _timer?.cancel();
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      textAlign: TextAlign.center,
      style: widget.style ?? const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}

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


