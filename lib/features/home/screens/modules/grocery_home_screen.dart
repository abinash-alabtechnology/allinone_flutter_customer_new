// import 'package:flutter/material.dart';
// import 'package:handy_allinone/features/flash_sale/widgets/flash_sale_view_widget.dart';
// import 'package:handy_allinone/features/home/widgets/highlight_widget.dart';
// import 'package:handy_allinone/features/home/widgets/views/banner_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/best_reviewed_item_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/best_store_nearby_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/category_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/promo_code_banner_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/item_that_you_love_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/just_for_you_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/most_popular_item_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/new_on_mart_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/middle_section_banner_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/recommended_store_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/special_offer_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/promotional_banner_view.dart';
// import 'package:handy_allinone/features/home/widgets/views/top_offers_near_me.dart';
// import 'package:handy_allinone/features/home/widgets/views/visit_again_view.dart';
// import 'package:handy_allinone/helper/auth_helper.dart';
//
//
// class GroceryHomeScreen extends StatelessWidget {
//   const GroceryHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     bool isLoggedIn = AuthHelper.isLoggedIn();
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//       Container(
//         width: MediaQuery.of(context).size.width,
//         color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
//         child:  const Column(
//           children: [
//             BannerView(isFeatured: false),
//             SizedBox(height: 12),
//           ],
//         ),
//       ),
//
//       const CategoryView(),
//       isLoggedIn ? const VisitAgainView() : const SizedBox(),
//       const RecommendedStoreView(),
//       const SpecialOfferView(isFood: false, isShop: false),
//       const HighlightWidget(),
//       const FlashSaleViewWidget(),
//       const BestStoreNearbyView(),
//       const MostPopularItemView(isFood: false, isShop: false),
//       const MiddleSectionBannerView(),
//       const BestReviewItemView(),
//       const JustForYouView(),
//       const TopOffersNearMe(),
//       const ItemThatYouLoveView(forShop: false),
//       isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
//       const NewOnMartView(isPharmacy: false, isShop: false),
//       const PromotionalBannerView(),
//     ]);
//   }
// }

import 'dart:math';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/common/widgets/card_design/item_card.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../common/widgets/custom_asset_image_widget.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../common/widgets/item_view.dart';
import '../../../../common/widgets/not_logged_in_screen.dart';
import '../../../../common/widgets/paginated_list_view.dart';
import '../../../../helper/address_helper.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/images.dart';
import '../../../../weatherapi.dart';
import '../../../cart/widgets/Bottomcart_cart.dart';
import '../../../favourite/controllers/favourite_controller.dart';
import '../../../location/controllers/location_controller.dart';
import '../../../menu/screens/menu_screen.dart';
import '../../../notification/controllers/notification_controller.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../../splash/controllers/splash_controller.dart';
import '../../../store/controllers/store_controller.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/all_store_filter_widget.dart';
import '../../widgets/banner_view.dart';
import '../../widgets/category_pop_up.dart';
import '../../widgets/highlight_widget.dart';
import '../../widgets/views/best_reviewed_item_view.dart';
import '../../widgets/views/best_store_nearby_view.dart';
import '../../widgets/views/just_for_you_view.dart';
import '../../widgets/views/middle_section_banner_view.dart';
import '../../widgets/views/most_popular_item_view.dart';
import '../../widgets/views/new_on_mart_view.dart';
import '../../widgets/views/special_offer_view.dart';
import '../../widgets/views/top_offers_near_me.dart';
import '../../widgets/views/visit_again_view.dart';
import '../../widgets/views/promo_code_banner_view.dart';
import '../../widgets/views/item_that_you_love_view.dart';
import '../../widgets/views/promotional_banner_view.dart';
import '../../widgets/views/subscription_item_view.dart';
import '../../widgets/views/fresh_item_view.dart';
import '../home_screen.dart';

class GroceryHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  final String? wheathertype;
  final List<HourlyTemperature> hourlyTemp;

  const GroceryHomeScreen({
    super.key,
    required this.scrollController,
    this.wheathertype,
    required this.hourlyTemp,
  });

  @override
  State<GroceryHomeScreen> createState() => _GroceryHomeScreenState();
}

class _GroceryHomeScreenState extends State<GroceryHomeScreen> {
  ScrollDirection? _lastDirection;
  bool _isHeaderPinned = false;
  final splashController = Get.find<SplashController>();
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      final position = widget.scrollController.position;
      final currentDirection = position.userScrollDirection;
      if (currentDirection != _lastDirection) {
        _lastDirection = currentDirection;

        if (currentDirection == ScrollDirection.reverse) {
          if (homeController.showFavButton) {
            homeController.changeFavVisibility();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!homeController.showFavButton) {
                homeController.changeFavVisibility();
              }
            });
          }
          splashController.hideBottomNav();
        } else if (currentDirection == ScrollDirection.forward) {
          if (!homeController.showFavButton) {
            homeController.changeFavVisibility();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (homeController.showFavButton) {
                homeController.changeFavVisibility();
              }
            });
          }
          splashController.showBottomNavBar();
        }
      }

      const double headerOffset = 300;

      bool pinnedNow = position.pixels >= headerOffset;
      if (pinnedNow != _isHeaderPinned) {
        _isHeaderPinned = pinnedNow;
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_setupScrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: widget.scrollController,
          physics: const ScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 2.2,
                          tileMode: TileMode.mirror,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Positioned(
                    right: -20,
                    bottom: 30,
                    child: CustomAssetImageWidget(
                      Images.leaf,
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  const Positioned(
                    right: -20,
                    top: -10,
                    child: CustomAssetImageWidget(
                      Images.leaf,
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: 30,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                      child: const CustomAssetImageWidget(
                        Images.leaf,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    top: -10,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                      child: const CustomAssetImageWidget(
                        Images.leaf,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        GetBuilder<SplashController>(
                          builder: (splashController) {
                            return Column(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          const Gap(5),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: const Color(0xFF1E7F35),
                                              border: Border.all(
                                                width: 1.5,
                                                color: const Color(0xFF00E676),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8,
                                                  ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "10-25",
                                                    style: robotoBold.copyWith(
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    "MINS",
                                                    style: robotoBold.copyWith(
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Gap(10),
                                          SizedBox(
                                            width:
                                                (splashController.module !=
                                                        null &&
                                                    splashController
                                                            .configModel!
                                                            .module ==
                                                        null)
                                                ? Dimensions.paddingSizeSmall
                                                : 0,
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () =>
                                                  Get.find<LocationController>()
                                                      .navigateToLocationScreen(
                                                        'home',
                                                      ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: Dimensions
                                                      .paddingSizeSmall,
                                                  horizontal:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? Dimensions
                                                            .paddingSizeSmall
                                                      : 0,
                                                ),
                                                child: GetBuilder<LocationController>(
                                                  builder: (_) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Transform.rotate(
                                                              angle: 175,
                                                              child: const Icon(
                                                                Icons
                                                                    .send_rounded,
                                                                size: 22,
                                                              ),
                                                            ),
                                                            const Gap(10),
                                                            Text(
                                                              AuthHelper.isLoggedIn()
                                                                  ? AddressHelper.getUserAddressFromSharedPref()
                                                                            ?.addressType
                                                                            ?.tr ??
                                                                        'your_location'
                                                                            .tr
                                                                  : 'your_location'
                                                                        .tr,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: robotoBold
                                                                  .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeLarge,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                AddressHelper.getUserAddressFromSharedPref()?.address ?? '',
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: robotoBold.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).cardColor,
                                                                ),
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.expand_more,
                                                              size: 22,
                                                              color: Theme.of(
                                                                context,
                                                              ).cardColor,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Notifications icon
                                          InkWell(
                                            onTap: () => Get.toNamed(
                                              RouteHelper.getNotificationRoute(),
                                            ),
                                            child: GetBuilder<NotificationController>(
                                              builder: (notificationController) {
                                                return Stack(
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.bell,
                                                      size: 25,
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                    ),
                                                    notificationController
                                                            .hasNotification
                                                        ? Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Container(
                                                              height: 10,
                                                              width: 10,
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                  width: 1,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).cardColor,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          // Wishlist icon
                                          // InkWell(
                                          //   onTap: () => Navigator.of(context).push(
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //       const FavouriteScreen(),
                                          //     ),
                                          //   ),
                                          //   child: Icon(
                                          //     CupertinoIcons.heart,
                                          //     size: 25,
                                          //     color: Theme.of(context).textTheme.bodyLarge!.color,
                                          //   ),
                                          // ),
                                          GetBuilder<ProfileController>(
                                            builder: (profileController) {
                                              final bool isLoggedIn =
                                                  AuthHelper.isLoggedIn();

                                              final imageUrl =
                                                  isLoggedIn &&
                                                      profileController
                                                              .userInfoModel !=
                                                          null
                                                  ? profileController
                                                            .userInfoModel!
                                                            .imageFullUrl ??
                                                        ''
                                                  : Images.guestDummyIcon;

                                              return GestureDetector(
                                                onTap: () {
                                                  Get.to(const MenuScreen());
                                                },
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    height: 38,
                                                    width: 38,
                                                    child: Center(
                                                      child: ClipOval(
                                                        child: CustomImage(
                                                          placeholder: Images
                                                              .guestDummyIcon,
                                                          image: imageUrl,
                                                          height: 38,
                                                          width: 38,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Container(
                                  height: 55,
                                  width: Dimensions.webMaxWidth,
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  child: InkWell(
                                    onTap: () => Get.toNamed(
                                      RouteHelper.getSearchRoute(),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        // border: Border.all(
                                        //   color: Theme.of(context)
                                        //       .primaryColor
                                        //       .withOpacity(0.2),
                                        //   width: 1,
                                        // ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 10.w,
                                                  height: 100.h,
                                                ),
                                                Text(
                                                  'Search for',
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                  height: 100.h,
                                                ),
                                                Expanded(
                                                  child: GetBuilder<CategoryController>(
                                                    builder: (categoryController) {
                                                      if (categoryController
                                                                  .categoryList !=
                                                              null &&
                                                          categoryController
                                                              .categoryList!
                                                              .isNotEmpty) {
                                                        return AnimatedTextKit(
                                                          repeatForever: true,
                                                          animatedTexts: categoryController
                                                              .categoryList!
                                                              .map(
                                                                (
                                                                  category,
                                                                ) => RotateAnimatedText(
                                                                  ("${(category.name?.capitalizeFirst)}"),
                                                                  textStyle: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeLarge,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                        );
                                                      } else {
                                                        return const Text(
                                                          'Loading categories...',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Icon(
                                            CupertinoIcons.search,
                                            size: 25,
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 6.0,
                                              ),
                                              child: VerticalDivider(
                                                color: Colors.grey,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                          Icon(
                                            CupertinoIcons.mic,
                                            size: 25,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        // const Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 12.0),
                        //   child: BannerViewGrocery(isFeatured: false),
                        // ),
                        // const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // if (widget.wheathertype=="RAINY")
                  // const Positioned.fill(
                  //   child: IgnorePointer(
                  //     child: RainAnimation(),
                  //   ),
                  // ),
                  // if (widget.wheathertype=="RAINY")
                  // const Positioned.fill(
                  //   child: IgnorePointer(
                  //     child: ThunderFlash(),
                  //   ),
                  // ),
                ],
              ),
            ),
            // SliverToBoxAdapter(
            //   child:HourlyWeatherView(hourlyData:widget.hourlyTemp,),
            // ),
            SliverToBoxAdapter(
              child: GetBuilder<CategoryController>(
                builder: (categoryController) {
                  final list = categoryController.categoryList;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text(
                              "Categories",
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: Colors.black38,
                              ),
                            ),
                            const Gap(15),
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (list != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: InkWell(
                                  onTap: () {
                                    if (ResponsiveHelper.isMobile(context)) {
                                      Get.toNamed(
                                        RouteHelper.getCategoryRoute(),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (c) => Dialog(
                                          child: SizedBox(
                                            width: 600,
                                            height: 550,
                                            child: CategoryPopUp(
                                              categoryController:
                                                  categoryController,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: ResponsiveHelper.isMobile(context)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            'see_all'.tr,
                                            style: robotoMedium.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 32,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                          child: Text(
                                            'view_all'.tr,
                                            style: TextStyle(
                                              fontSize:
                                                  Dimensions.paddingSizeDefault,
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      Skeletonizer(
                        enabled: list == null,
                        child: SizedBox(
                          height: 270.h,
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 12.w,
                                  crossAxisSpacing: 10.h,
                                  childAspectRatio: .85,
                                ),
                            itemCount: list?.length ?? 12,
                            itemBuilder: (_, index) {
                              final category = list != null
                                  ? list[index]
                                  : null;
                              final isLoading = category == null;
                              return InkWell(
                                onTap: isLoading
                                    ? null
                                    : () => Get.toNamed(
                                        RouteHelper.getCategoryItemRoute(
                                          category.id,
                                          category.name!,
                                        ),
                                      ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60.h,
                                      height: 60.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        child: isLoading
                                            ? const SizedBox()
                                            : CustomImage(
                                                image:
                                                    '${category.imageFullUrl}',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      category?.name ?? "Loading...",
                                      style: robotoBold.copyWith(
                                        fontSize: 10.sp,
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const Gap(10),
                    ],
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                child: Column(
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 8.0,
                    //     vertical: 12,
                    //   ),
                    //   child: Container(
                    //     width: double.infinity,
                    //     padding: EdgeInsets.all(12),
                    //     decoration: BoxDecoration(
                    //       color: Colors.amber.withValues(alpha: 0.1),
                    //       borderRadius: BorderRadius.circular(12.0),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black.withOpacity(0.03),
                    //           offset: const Offset(0, 2),
                    //           blurRadius: 6,
                    //         ),
                    //       ],
                    //     ),
                    //     child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         Container(
                    //           width: 44.w,
                    //           height: 44.h,
                    //           alignment: Alignment.center,
                    //           margin: const EdgeInsets.only(right: 12),
                    //           child: CustomAssetImageWidget(
                    //             "assets/image/brain.png",
                    //             width: 44.w,
                    //             height: 44.h,
                    //           ),
                    //         ),
                    //         Container(
                    //           width: 1,
                    //           height: 44,
                    //           color: Colors.black12,
                    //           margin: const EdgeInsets.only(right: 12),
                    //         ),
                    //         Expanded(
                    //           child: RichText(
                    //             text: TextSpan(
                    //               style: TextStyle(
                    //                 color: Colors.black,
                    //                 fontSize: 11.sp,
                    //                 height: 1.25,
                    //               ),
                    //               children: const [
                    //                 TextSpan(
                    //                   text:
                    //                       "We're currently in our AYT testing phase\n",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.w400,
                    //                   ),
                    //                 ),
                    //                 TextSpan(
                    //                   text: "to ",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.w400,
                    //                   ),
                    //                 ),
                    //                 TextSpan(
                    //                   text: "fine-tune your experience",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.w700,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: BannerViewGrocery(isFeatured: false),
                    ),
                    SizedBox(height: 10.h),
                    // isLoggedIn ? const VisitAgainView() : const SizedBox(),
                    // const RecommendedStoreView(),
                    const SpecialOfferViewGrocery(isFood: false, isShop: false),
                    // const HighlightWidget(),
                    // const FlashSaleViewWidget(),
                    // const BestStoreNearbyView(),
                    const MostPopularItemView(isFood: false, isShop: false),
                    const SubscriptionItemView(isFood: false, isShop: false),
                    const FreshItemView(isFood: false, isShop: false),
                    const CategoryListScreen(),
                    const MiddleSectionBannerView(),
                    const BestReviewItemView(),
                    // const JustForYouView(),
                    const TopOffersNearMe(),
                    // const ItemThatYouLoveView(forShop: false),
                    // AuthHelper.isLoggedIn() ? const PromoCodeBannerView() : const SizedBox(),
                    // const NewOnMartView(isPharmacy: false, isShop: false),
                    // const PromotionalBannerView(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: _AllStoreFilterHeaderDelegate(
            //     minHeight: 100,
            //     maxHeight: 100,
            //     child: Container(
            //       color: Colors.white,
            //       child: const AllStoreFilterWidget(),
            //     ),
            //   ),
            // ),
            // SliverToBoxAdapter(
            //   child: GetBuilder<StoreController>(
            //     builder: (storeController) {
            //       return Padding(
            //         padding: const EdgeInsets.only(bottom: 220),
            //         child: PaginatedListView(
            //           scrollController: widget.scrollController,
            //           totalSize: storeController.storeModel?.totalSize,
            //           offset: storeController.storeModel?.offset,
            //           onPaginate: (int? offset) async =>
            //               await storeController.getStoreList(offset!, false),
            //           itemView: ItemsView(
            //             isStore: true,
            //             items: null,
            //             isFoodOrGrocery: true,
            //             stores: storeController.storeModel?.stores,
            //             padding: EdgeInsets.symmetric(
            //               horizontal: ResponsiveHelper.isDesktop(context)
            //                   ? Dimensions.paddingSizeExtraSmall
            //                   : Dimensions.paddingSizeSmall,
            //               vertical: Dimensions.paddingSizeExtraSmall,
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
        BackToTopButton(
          scrollController: widget.scrollController,
          isNavVisible: splashController.showBottomNav,
        ),
      ],
    );
  }
}

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        return GetBuilder<CategoryController>(
          builder: (categoryController) {
            if (categoryController.isLoadingCategories) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categoryController.categoryList == null ||
                categoryController.categoryList!.isEmpty) {
              return const SizedBox.shrink();
            }

            // Combine fresh items and subscription items, ensuring uniqueness by ID
            final List<Item> sourceItems = [];
            final Set<int> uniqueIds = {};

            for (var item in (itemController.freshItemList ?? [])) {
              if (item.id != null && uniqueIds.add(item.id!)) {
                sourceItems.add(item);
              }
            }
            for (var item in (itemController.subscriptionItemList ?? [])) {
              if (item.id != null && uniqueIds.add(item.id!)) {
                sourceItems.add(item);
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Product List
                ...categoryController.categoryList!.map((category) {
                  // Filter items that belong to the current category and exist in the sourceItems list
                  final items = sourceItems.where((item) {
                    return item.categoryId == category.id ||
                        item.categoryIds?.any(
                              (catId) => catId.id == category.id,
                            ) ==
                            true;
                  }).toList();

                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final width = MediaQuery.of(context).size.width;
                  int columns = width >= 700
                      ? 4
                      : width >= 500
                      ? 3
                      : width < 350
                      ? 1
                      : 2;

                  int rows = (items.length / columns).ceil();
                  double gridHeight = rows * 250.0 + (rows - 1) * 10.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.name?.capitalizeFirst ?? "",
                                style: robotoBold.copyWith(
                                  fontSize: 18.sp,
                                  color: Colors.black87,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(
                                    () => CategoryItemsScreen(
                                      categoryId: category.id!.toString(),
                                      categoryName: category.name!,
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "See All",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 14.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: gridHeight,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  mainAxisExtent: 250,
                                ),
                            itemBuilder: (context, idx) {
                              return ItemCard(
                                key: ValueKey(items[idx].id),
                                item: items[idx],
                                isFood: false,
                                isShop: false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}

class CategoryItemsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryItemsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  bool showFavouritesOnly = false;
  late ScrollController _scrollController;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _showBottomCart = true;
  bool _showLoginScreen = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _fetchPage(reload: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMore();
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showBottomCart) setState(() => _showBottomCart = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showBottomCart) setState(() => _showBottomCart = true);
      }
    });
  }

  Future<void> _fetchPage({bool reload = false}) async {
    final categoryController = Get.find<CategoryController>();
    await categoryController.fetchItemsForCategory(
      widget.categoryId,
      _currentPage,
      'all',
      reload,
    );

    final items = categoryController.getItemsForCategory(widget.categoryId);
    if (items == null || items.length < _currentPage * 10) {
      setState(() {
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final categoryController = Get.find<CategoryController>();
    if (!categoryController.isLoadingForCategory(widget.categoryId)) {
      setState(() => _isLoadingMore = true);
      _currentPage++;
      await _fetchPage(reload: false);
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favouriteController = Get.find<FavouriteController>();
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName.capitalizeFirst ?? "",
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge * 1.3,
          ),
        ),
        actions: [
          GetBuilder<FavouriteController>(
            builder: (_) {
              return IconButton(
                icon: Icon(
                  showFavouritesOnly
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (!AuthHelper.isLoggedIn()) {
                    setState(() {
                      _showLoginScreen = true;
                    });
                  } else {
                    setState(() {
                      showFavouritesOnly = !showFavouritesOnly;
                      _showLoginScreen = false;
                    });
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {
              Get.toNamed(RouteHelper.getSearchRoute());
            },
          ),
        ],
      ),
      body: _showLoginScreen
          ? NotLoggedInScreen(
              callBack: (value) {
                initState();
                setState(() {
                  _showLoginScreen = false;
                });
              },
            )
          : GetBuilder<CategoryController>(
              builder: (controller) {
                final allItems =
                    controller.getItemsForCategory(widget.categoryId) ?? [];

                final items = showFavouritesOnly
                    ? allItems
                          .where(
                            (item) => favouriteController.wishItemIdList
                                .contains(item.id),
                          )
                          .toList()
                    : allItems;

                if (controller.isLoadingForCategory(widget.categoryId) &&
                    allItems.isEmpty) {
                  return _buildShimmerList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      showFavouritesOnly
                          ? "No favourite items found"
                          : "No items found",
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _currentPage = 1;
                    _hasMore = true;
                    await _fetchPage(reload: true);
                  },
                  child: Stack(
                    children: [
                      ListView(
                        controller: _scrollController,
                        children: [
                          GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 0.75,
                                ),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ItemCard(
                                key: ValueKey(item.id),
                                item: item,
                                isFood: false,
                                isShop: false,
                              );
                            },
                          ),
                          if (_isLoadingMore && _hasMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                      _showBottomCart
                          ? const BottomCartButton()
                          : const SizedBox.shrink(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            interval: const Duration(milliseconds: 500),
            color: Colors.grey.shade300,
            colorOpacity: 0.3,
            enabled: true,
            direction: const ShimmerDirection.fromLeftToRight(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 100, height: 20, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final safeAreaHeight = MediaQuery.of(context).padding.top;
    final bool isPinned = shrinkOffset > 0;

    final double totalHeight = (isPinned ? (maxHeight + 50) : maxHeight);

    return Container(
      height: totalHeight,
      color: Colors.white,
      child: SizedBox.expand(
        child: SafeArea(top: isPinned, child: child),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _AllStoreFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _AllStoreFilterHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _AllStoreFilterHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

Widget _buildCategorySkeleton() {
  return SizedBox(
    height: 420,
    width: double.infinity,
    child: GridView.builder(
      itemCount: 8,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 140,
      ),
      padding: EdgeInsets.zero,
      itemBuilder: (_, __) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 115,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ),
  );
}

///newly added by ak
class CloudAnimation extends StatefulWidget {
  const CloudAnimation({super.key});

  @override
  State<CloudAnimation> createState() => _CloudAnimationState();
}

class _CloudAnimationState extends State<CloudAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: LoopingCloudPainter(_controller.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LoopingCloudPainter extends CustomPainter {
  final double progress;
  LoopingCloudPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Only top part visible
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.35));

    final cloudPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFD9D9D9)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    // Multiple cloud layers
    _drawMovingCloud(
      canvas,
      size,
      cloudPaint,
      shadowPaint,
      speed: 0.25,
      y: 55,
      scale: 1.2,
    );

    _drawMovingCloud(
      canvas,
      size,
      cloudPaint,
      shadowPaint,
      speed: 0.4,
      y: 40,
      scale: 0.9,
    );

    _drawMovingCloud(
      canvas,
      size,
      cloudPaint,
      shadowPaint,
      speed: 0.15,
      y: 70,
      scale: 1.5,
    );

    canvas.restore();
  }

  void _drawMovingCloud(
    Canvas canvas,
    Size size,
    Paint cloudPaint,
    Paint shadowPaint, {
    required double speed,
    required double y,
    required double scale,
  }) {
    final cloudWidth = 180 * scale;
    final travel = size.width + cloudWidth * 2;

    final x = ((progress * travel * speed) % travel) - cloudWidth;

    _drawCloud(canvas, cloudPaint, shadowPaint, Offset(x, y), scale);

    // Duplicate cloud for seamless looping
    _drawCloud(canvas, cloudPaint, shadowPaint, Offset(x + travel, y), scale);
  }

  void _drawCloud(
    Canvas canvas,
    Paint cloudPaint,
    Paint shadowPaint,
    Offset center,
    double scale,
  ) {
    final offsets = [
      const Offset(0, 0),
      const Offset(30, -10),
      const Offset(-30, -8),
      const Offset(55, 4),
      const Offset(-55, 6),
    ];

    final radii = [26, 22, 20, 18, 18];

    for (int i = 0; i < offsets.length; i++) {
      final pos = center + offsets[i] * scale;
      canvas.drawCircle(pos.translate(6, 8), radii[i] * scale, shadowPaint);
    }

    for (int i = 0; i < offsets.length; i++) {
      final pos = center + offsets[i] * scale;
      canvas.drawCircle(pos, radii[i] * scale, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class RainAnimation extends StatefulWidget {
  const RainAnimation({super.key});

  @override
  State<RainAnimation> createState() => _RainAnimationState();
}

class _RainAnimationState extends State<RainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(painter: RainPainter(_controller.value));
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RainPainter extends CustomPainter {
  final double progress;
  final Random random = Random();

  RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height + progress * size.height) %
          size.height;

      canvas.drawLine(Offset(x, y), Offset(x, y + 12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ThunderFlash extends StatefulWidget {
  const ThunderFlash({super.key});

  @override
  State<ThunderFlash> createState() => _ThunderFlashState();
}

class _ThunderFlashState extends State<ThunderFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final flash = _controller.value > 0.95;
        return Container(
          color: flash ? Colors.white.withOpacity(0.35) : Colors.transparent,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

///
