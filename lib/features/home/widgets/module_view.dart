import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/home/widgets/banner_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../common/models/module_model.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../helper/address_helper.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';
import '../../favourite/controllers/favourite_controller.dart';
import '../../language/controllers/language_controller.dart';
import '../../location/controllers/location_controller.dart';
import '../../menu/screens/menu_screen.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/home/widgets/request_based_delivery_widget.dart';
import '../../store/screens/store_screen.dart';

class ModuleView extends StatelessWidget {
  final ScrollController scrollController;
  final SplashController splashController;

  const ModuleView({
    super.key,
    required this.splashController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: Dimensions.webMaxWidth,
          height: Get.find<LocalizationController>().isLtr ? 120 : 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor, // left green
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 10,
                top: -30,
                child: CustomAssetImageWidget(
                  Images.leaf,
                  width: 100,
                  height: 100,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Positioned(
                left: 10,
                top: -30,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                  child: const CustomAssetImageWidget(
                    Images.leaf,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const Gap(5),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF4BB045),
                            border: Border.all(
                              width: 1.5,
                              color: Color(0xFF4BB055),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "10-25",
                                  style: robotoBold.copyWith(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "MINS",
                                  style: robotoBold.copyWith(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(10),

                        (splashController.module != null &&
                                splashController.configModel!.module == null)
                            ? InkWell(
                                onTap: () {
                                  splashController.removeModule();
                                  Get.find<StoreController>().resetStoreData();
                                },
                                child: Image.asset(
                                  Images.homeIcon,
                                  height: 25,
                                  width: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(
                          width:
                              (splashController.module != null &&
                                  splashController.configModel!.module == null)
                              ? Dimensions.paddingSizeSmall
                              : 0,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => Get.find<LocationController>()
                                .navigateToLocationScreen('home'),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall,
                                horizontal: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.paddingSizeSmall
                                    : 0,
                              ),
                              child: GetBuilder<LocationController>(
                                builder: (_) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Transform.rotate(
                                            angle: 175,
                                            child: const Icon(
                                              Icons.send_rounded,
                                              size: 22,
                                            ),
                                          ),
                                          const Gap(10),
                                          Text(
                                            AuthHelper.isLoggedIn()
                                                ? AddressHelper.getUserAddressFromSharedPref()
                                                          ?.addressType
                                                          ?.tr ??
                                                      'your_location'.tr
                                                : 'your_location'.tr,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeLarge,
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
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.expand_more,
                                            size: 22,
                                            color: Theme.of(context).cardColor,
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
                          onTap: () =>
                              Get.toNamed(RouteHelper.getNotificationRoute()),
                          child: GetBuilder<NotificationController>(
                            builder: (notificationController) {
                              return Stack(
                                children: [
                                  Icon(
                                    CupertinoIcons.bell,
                                    size: 25,
                                    color: Theme.of(context).cardColor,
                                  ),
                                  notificationController.hasNotification
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
                                              shape: BoxShape.circle,
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
                            final bool isLoggedIn = AuthHelper.isLoggedIn();

                            final imageUrl =
                                isLoggedIn &&
                                    profileController.userInfoModel != null
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
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  height: 38,
                                  width: 38,
                                  child: Center(
                                    child: ClipOval(
                                      child: CustomImage(
                                        placeholder: Images.guestDummyIcon,
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
            ],
          ),
        ),
        GetBuilder<BannerController>(
          builder: (bannerController) {
            return Stack(
              children: [
                const BannerViewModule(isFeatured: true),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                             Theme.of(context).primaryColor.withValues(alpha: 0.7),
                          Theme.of(context).primaryColor.withValues(alpha: 0.001),
                          Theme.of(context).primaryColor.withValues(alpha: 0.001),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: Get.height * 0.01),
        Skeletonizer(
          enabled: splashController.moduleList == null,
          child:
              (splashController.moduleList != null &&
                  splashController.moduleList!.isNotEmpty)
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 220,
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  itemCount: splashController.moduleList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final module = splashController.moduleList![index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("Selected Module: ${module.moduleName}");
                            splashController.showBottomNavBar();
                            scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeIn,
                            );
                            splashController.switchModule(index, true);
                          },
                          child: CustomImage(
                            image: module.iconFullUrl ?? "",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : notInYourAreaWidget(),
        ),
        GetBuilder<StoreController>(
          builder: (storeController) {
            final storeList = storeController.featuredStoreList;
            return Skeletonizer(
              enabled: storeList == null,
              child: (storeList != null && storeList.isNotEmpty)
                  ? SizedBox(
                      height: 320,
                      width: Get.width - 24,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'featured_stores'.tr,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Discover new stores",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFFB1AFAE),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(
                                    RouteHelper.getAllStoreRoute('featured'),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'See all',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              controller: ScrollController(),
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall,
                              ),
                              itemCount: storeList.length > 10
                                  ? 10
                                  : storeList.length,
                              itemBuilder: (context, index) {
                                final store = storeList[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 5 : 0,
                                    right: Dimensions.paddingSizeDefault,
                                    bottom: 5,
                                  ),
                                  child: Container(
                                    width: 290,
                                    margin: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: CustomInkWell(
                                      onTap: !storeController.isOpenNow(store)
                                          ? () {
                                              showCustomSnackBar(
                                                "store_is_closed".tr,
                                                isError: true,
                                              );
                                            }
                                          : () {
                                              if (Get.find<SplashController>()
                                                      .moduleList !=
                                                  null) {
                                                for (ModuleModel module
                                                    in Get.find<
                                                          SplashController
                                                        >()
                                                        .moduleList!) {
                                                  if (module.id ==
                                                      store.moduleId) {
                                                    Get.find<SplashController>()
                                                        .setModule(module);
                                                    break;
                                                  }
                                                }
                                              }

                                              Get.toNamed(
                                                RouteHelper.getStoreRoute(
                                                  id: store.id,
                                                  page: 'module',
                                                ),
                                                arguments: StoreScreen(
                                                  store: store,
                                                  fromModule: true,
                                                ),
                                              );
                                            },
                                      radius: Dimensions.radiusSmall,
                                      child: Stack(
                                        children: [
                                          /// Image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: CustomImage(
                                              image:
                                                  store.coverPhotoFullUrl ?? "",
                                              height: 278,
                                              width: 290,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                          /// Bottom gradient overlay
                                          Positioned.fill(
                                            child: IgnorePointer(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.transparent,
                                                          Colors.black,
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          /// Favorite Button
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: GetBuilder<FavouriteController>(
                                              builder: (fc) {
                                                final isWished = fc.wishStoreIdList
                                                    .contains(store.id);

                                                return InkWell(
                                                  onTap: () {
                                                    if (AuthHelper.isLoggedIn()) {
                                                      isWished
                                                          ? fc.removeFromFavouriteList(
                                                              store.id,
                                                              true,
                                                            )
                                                          : fc.addToFavouriteList(
                                                              null,
                                                              store.id,
                                                              true,
                                                            );
                                                    } else {
                                                      showCustomSnackBar(
                                                        'you_are_not_logged_in'
                                                            .tr,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            25,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      isWished
                                                          ? Icons.favorite
                                                          : Icons
                                                                .favorite_border,
                                                      size: 20,
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          /// Bottom store info
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    store.name ?? "",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),

                                                  /// Rating + Delivery
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        FontAwesome.star_solid,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                        size: 12,
                                                      ),
                                                      const SizedBox(width: 5),

                                                      store.avgRating != null
                                                          ? Text(
                                                              store.avgRating
                                                                      ?.toStringAsFixed(
                                                                        1,
                                                                      ) ??
                                                                  "0.0",
                                                              style: GoogleFonts.inter(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          : const SizedBox.shrink(),
                                                      const SizedBox(width: 5),

                                                      store.ratingCount != null
                                                          ? Text(
                                                              "(${store.ratingCount?.toStringAsFixed(0) ?? 0})",
                                                              style:
                                                                  GoogleFonts.inter(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            )
                                                          : const SizedBox.shrink(),

                                                      const SizedBox(width: 10),

                                                      Icon(
                                                        Icons.circle,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                        size: 5,
                                                      ),
                                                      const SizedBox(width: 10),

                                                      /// Delivery Time tag
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(
                                                            context,
                                                          ).cardColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6.0,
                                                                vertical: 4,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.bolt,
                                                                color: AppConstants
                                                                    .backgroundColor,
                                                                size: 12,
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                store.deliveryTime ??
                                                                    "",
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 5),

                                                  Text(
                                                    store.address ?? "",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          /// Closed Banner
                                          storeController.isOpenNow(store)
                                              ? const SizedBox()
                                              : const Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: PendulumImage(
                                                    asset: Images.closed,
                                                    angle: 20,
                                                    size: 80,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
        const RequestBasedDeliveryWidget(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(
            "Live\nit up!",
            style: robotoBold.copyWith(
              fontSize: 80,
              color: Colors.blueGrey.shade300,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 10),
          child: RichText(
            text: TextSpan(
              style: robotoRegular.copyWith(
                fontSize: ResponsiveHelper.isDesktop(context)
                    ? Dimensions.fontSizeLarge * 1.1
                    : Dimensions.fontSizeLarge * 1.1,
                color: Colors.grey.shade600,
              ),
              children: [
                const TextSpan(text: 'Crafted with\t'),
                WidgetSpan(
                  child: Icon(
                    Icons.favorite, // You can change this to a heart symbol
                    color: Colors.pink.shade500, // Change the color as desired
                  ),
                ),
                const TextSpan(text: '\tin Tamilnadu,India'),
              ],
            ),
          ),
        ),
        // const PromoBanner(),
        const SizedBox(height: 120),
      ],
    );
  }
}

class PendulumImage extends StatefulWidget {
  final String asset;
  final double angle; // in degrees
  final Duration duration;
  final double size;

  const PendulumImage({
    super.key,
    required this.asset,
    this.angle = 18, // recommended swing angle
    this.duration = const Duration(seconds: 2),
    this.size = 150,
  });

  @override
  State<PendulumImage> createState() => _PendulumImageState();
}

class _PendulumImageState extends State<PendulumImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.angle,
      end: widget.angle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: Image.asset(widget.asset, width: widget.size, height: widget.size),
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 3.14159 / 180,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Local Business,",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Hyperlocal ",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextSpan(
                  text: "Speed!",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffE91E63), // Pink accent
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Made in",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Tamilnadu",
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffE91E63), // bright pink
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CustomAssetImageWidget(
                  Images.startup,
                  height: 100,
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget notInYourAreaWidget() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFFF8F8F8), Color(0xFFFFFFFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("😢", style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text(
          "Not in Your Area Yet",
          style: TextStyle(
            fontSize: 22,
            color: Color(0xFFE21E63),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "We're expanding fast.\n${AppConstants.appName} will reach you soon!",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 35),
        const CustomAssetImageWidget(
          Images.logo,
          height: 100,
        ),
      ],
    ),
  );
}
