import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/Auto_scroll.dart'
    show AutoScrollImageRow, ContinuousImageScroller;
import 'package:handy_allinone/features/home/widgets/views/category_view.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:handy_allinone/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:handy_allinone/features/home/widgets/views/most_popular_item_view.dart';
import 'package:handy_allinone/features/home/widgets/views/new_on_mart_view.dart';
import 'package:handy_allinone/features/home/widgets/views/special_offer_view.dart';
import 'package:handy_allinone/features/home/widgets/banner_view.dart';
import '../../../../common/widgets/custom_asset_image_widget.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../common/widgets/item_view.dart';
import '../../../../common/widgets/paginated_list_view.dart';
import '../../../../helper/address_helper.dart';
import '../../../../helper/auth_helper.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/images.dart';
import '../../../../util/styles.dart';
import '../../../../weatherapi.dart';
import '../../../category/controllers/category_controller.dart';
import '../../../location/controllers/location_controller.dart';
import '../../../menu/screens/menu_screen.dart';
import '../../../notification/controllers/notification_controller.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../../splash/controllers/splash_controller.dart';
import '../../../store/controllers/store_controller.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/all_store_filter_widget.dart';
import '../home_screen.dart';
import 'grocery_home_screen.dart';

class FoodHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  final String? wheathertype;
  final List<HourlyTemperature> hourlyTemp;

  const FoodHomeScreen({super.key, required this.scrollController, this.wheathertype, required this.hourlyTemp});

  @override
  _FoodHomeScreenState createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
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
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: 30,
                    child: CustomAssetImageWidget(
                      Images.leaf,
                      width: 100,
                      height: 100,
                      color: Colors.orange.shade900,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -10,
                    child: CustomAssetImageWidget(
                      Images.leaf,
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                      color:
                      Colors.orange.shade900,
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: 30,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                      child: CustomAssetImageWidget(
                        Images.leaf,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                       color: Colors.orange.shade900,

                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    top: -10,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                      child:  CustomAssetImageWidget(
                        Images.leaf,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                        color: Colors.orange.shade900,

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
                                              color: const Color(0xFF4BB045),
                                              border: Border.all(
                                                width: 1.5,
                                                color: const Color(0xFF4BB055),
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
                                                                AddressHelper.getUserAddressFromSharedPref()!
                                                                    .address!,
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
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const SizedBox(
                                                  width: 10.0,
                                                  height: 100.0,
                                                ),
                                                Text(
                                                  'Search for',
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                  height: 100.0,
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: BannerViewGrocery(isFeatured: false),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // if (widget.wheathertype=="RAINY")
                  //   const Positioned.fill(
                  //     child: IgnorePointer(
                  //       child: RainAnimation(),
                  //     ),
                  //   ),
                  // if (widget.wheathertype=="RAINY")
                  //   const Positioned.fill(
                  //     child: IgnorePointer(
                  //       child: ThunderFlash(),
                  //     ),
                  //   ),
                ],
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.paddingSizeDefault),
            ),
            // const BannerView(isFeatured: false),
            // SliverToBoxAdapter(
            //   child:HourlyWeatherView(hourlyData:widget.hourlyTemp,),
            // ),
            SliverToBoxAdapter(
              child: Container(
                child: Column(
                  children: [
                    const CategoryView(),
                    const BestStoreNearbyView(),
                    // const RecommendedStoreView(),
                    const SpecialOfferView(isFood: true, isShop: false),
                    // const HighlightWidget(),
                    const SizedBox(height: 15),
                    const ContinuousImageScroller(
                      assetImages: [
                        'assets/image/scroll1.jpg',
                        'assets/image/scroll2.jpg',
                        'assets/image/scroll3.jpg',
                        'assets/image/scroll4.jpg',
                        'assets/image/scroll5.jpg',
                      ],
                      itemWidth: 120,
                      itemHeight: 150,
                    ),
                    SizedBox(height: Dimensions.fontSizeSmall),
                    const BestReviewItemViewFood(),
                    // const ItemThatYouLoveView(forShop: false),
                    const MostPopularItemView(isFood: true, isShop: false),
                    // const JustForYouView(),
                    const NewOnMartView(
                      isNewStore: true,
                      isPharmacy: false,
                      isShop: false,
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _AllStoreFilterHeaderDelegate(
                minHeight: 100,
                maxHeight: 100,
                child: Container(
                  color: Colors.white,
                  child: const AllStoreFilterWidget(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: GetBuilder<StoreController>(
                builder: (storeController) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 220),
                    child: PaginatedListView(
                      scrollController: widget.scrollController,
                      totalSize: storeController.storeModel?.totalSize,
                      offset: storeController.storeModel?.offset,
                      onPaginate: (int? offset) async =>
                      await storeController.getStoreList(
                        offset!,
                        false,
                      ),
                      itemView: ItemsView(
                        isStore: true,
                        items: null,
                        isFoodOrGrocery: true,
                        stores: storeController.storeModel?.stores,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                          ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeExtraSmall
                              : Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _AllStoreFilterHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
