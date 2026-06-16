import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/common/models/module_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/rating_bar.dart';
import 'package:handy_allinone/common/widgets/title_widget.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../common/widgets/custom_snackbar.dart';
import '../../../../helper/auth_helper.dart';
import '../../../favourite/controllers/favourite_controller.dart';
import '../../../location/controllers/location_controller.dart';
import '../module_view.dart';

import '../../../../helper/responsive_helper.dart';
import '../web/widgets/arrow_icon_button.dart';

class BestStoreNearbyView extends StatefulWidget {
  const BestStoreNearbyView({super.key});

  @override
  State<BestStoreNearbyView> createState() => _BestStoreNearbyViewState();
}

class _BestStoreNearbyViewState extends State<BestStoreNearbyView> {
  final ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy =
        Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;
    bool isFood =
        Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.food;
    final bool ltr = Get.find<LocalizationController>().isLtr;

    return GetBuilder<StoreController>(
      builder: (storeController) {
        List<Store>? storeList = isPharmacy
            ? storeController.featuredStoreList
            : storeController.popularStoreList;

        if (storeList != null && storeList.length > 3 && isFirstTime) {
          showForwardButton = true;
          isFirstTime = false;
        }

        Widget content = Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeDefault,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nearby Favorites",
                          style: robotoBold.copyWith(fontSize: 18.sp),
                        ),
                        Gap(5.h),
                        Text(
                          "Discover the best local shops",
                          style: robotoRegular.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          RouteHelper.getAllStoreRoute(
                            isPharmacy ? 'featured' : 'popular',
                            isNearbyStore: true,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.grey.shade200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "View All",
                                style: robotoMedium.copyWith(
                                  fontSize: 12.sp,
                                ),
                              ),
                              Gap(5),
                              Icon(
                                Icons.arrow_forward_outlined,
                                size: 18.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              child: Stack(
                children: [
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context) ? 260 : 240.h,
                    child: ListView.builder(
                      controller: scrollController,
                      primary: false,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                      ),
                      itemCount: storeList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final store = storeList![index];
                        double distance = Get.find<LocationController>()
                            .getRestaurantDistance(
                              LatLng(
                                double.parse(store.latitude!),
                                double.parse(store.longitude!),
                              ),
                            );
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeSmall,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 5 : 0,
                              right: Dimensions.paddingSizeDefault,
                              bottom: 5,
                            ),
                            child: Container(
                              width: 290,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CustomInkWell(
                                onTap: storeController.isOpenNow(store)
                                    ? () {
                                        if (Get.find<SplashController>()
                                                .moduleList !=
                                            null) {
                                          for (ModuleModel module
                                              in Get.find<
                                                    SplashController
                                                  >()
                                                  .moduleList!) {
                                            if (module.id ==
                                                storeList[index].moduleId) {
                                              Get.find<SplashController>()
                                                  .setModule(module);
                                              break;
                                            }
                                          }
                                        }
                                        Get.toNamed(
                                          RouteHelper.getStoreRoute(
                                            id: storeList[index].id,
                                            page: 'store',
                                          ),
                                          arguments: StoreScreen(
                                            store: storeList[index],
                                            fromModule: true,
                                          ),
                                        );
                                      }
                                    : () {
                                        showCustomSnackBar(
                                          "store_is_closed".tr, isError: true,
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
                                      child: ColorFiltered(
                                        colorFilter: storeController.isOpenNow(store)
                                            ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                        child: CustomImage(
                                          image:
                                              store.coverPhotoFullUrl ?? "",
                                          height: 240,
                                          width: 290,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.transparent,
                                                Colors.black,
                                              ],
                                              stops: [0.0, 0.3, 1.0],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    if (!storeController.isOpenNow(store))
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),

                                    /// Favorite Button
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: GetBuilder<FavouriteController>(
                                        builder: (fc) {
                                          final isWished = fc
                                              .wishStoreIdList
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
                                                    : Icons.favorite_border,
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
                                        padding: const EdgeInsets.all(8.0),
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),

                                            /// Rating + Delivery
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .yellow
                                                            .shade700,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal:
                                                                  10.0,
                                                              vertical: 4,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              FontAwesome
                                                                  .star_solid,
                                                              color: Theme.of(
                                                                context,
                                                              ).cardColor,
                                                              size: 12,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),

                                                            if (store
                                                                    .avgRating !=
                                                                null)
                                                              Text(
                                                                store.avgRating
                                                                        ?.toStringAsFixed(
                                                                          1,
                                                                        ) ??
                                                                    "0.0",
                                                                style: GoogleFonts.inter(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              )
                                                            else
                                                              const SizedBox.shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),

                                                    store.ratingCount !=
                                                            null
                                                        ? Text(
                                                            "(${store.ratingCount?.toStringAsFixed(0) ?? 0})",
                                                            style: GoogleFonts.inter(
                                                              color: Colors
                                                                  .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                            ),
                                                          )
                                                        : const SizedBox.shrink(),
                                                  ],
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withValues(
                                                          alpha: 0.2,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10.0,
                                                          vertical: 4,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color: Theme.of(
                                                            context,
                                                          ).cardColor,
                                                          size: 12,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                                          style: GoogleFonts.inter(
                                                            color: Colors
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 5.h),
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
                          ),
                        );
                      },
                    ),
                  ),

                  if(ResponsiveHelper.isDesktop(context) && showBackButton)
                    Positioned(
                      top: 90, left: 5,
                      child: ArrowIconButton(
                        isRight: false,
                        onTap: () => scrollController.animateTo(scrollController.offset - (Dimensions.webMaxWidth / 3),
                            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                      ),
                    ),

                  if(ResponsiveHelper.isDesktop(context) && showForwardButton)
                    Positioned(
                      top: 90, right: 5,
                      child: ArrowIconButton(
                        onTap: () => scrollController.animateTo(scrollController.offset + (Dimensions.webMaxWidth / 3),
                            duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

        return Skeletonizer(
          enabled: storeList == null,
          child: storeList != null && storeList.isNotEmpty
              ? ResponsiveHelper.isDesktop(context)
                  ? Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: content,
                      ),
                    )
                  : content
              : SizedBox(),
        );
      },
    );
  }
}

class BestStoreNearbyShimmer extends StatelessWidget {
  final bool isPharmacy;
  final bool isFood;

  const BestStoreNearbyShimmer({
    super.key,
    required this.isPharmacy,
    required this.isFood,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        (isPharmacy || isFood)
            ? Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                ),
                child: TitleWidget(
                  title: isPharmacy
                      ? 'featured_store'.tr
                      : 'best_store_nearby'.tr,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  left: Dimensions.paddingSizeLarge,
                  right: Dimensions.paddingSizeDefault,
                ),
                child: FittedBox(
                  child: Row(
                    children: [
                      Container(
                        height: 2,
                        width: context.width * 0.75,
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                      ),
                      Container(
                        transform: Matrix4.translationValues(-5, 0, 0),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                        child: Text(
                          'see_all'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

        isPharmacy
            ? SizedBox(
                height: 130,
                width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeSmall,
                      ),
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: true,
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: Dimensions.paddingSizeSmall,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 10,
                                            width: 100,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          !isPharmacy
                                              ? const RatingBar(
                                                  rating: 0,
                                                  ratingCount: 0,
                                                  size: 12,
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                      Icons.storefront,
                                                      size: 15,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Expanded(
                                                      child: Container(
                                                        height: 10,
                                                        width: 100,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          !isPharmacy
                                              ? Row(
                                                  children: [
                                                    Icon(
                                                      Icons.storefront,
                                                      size: 15,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Expanded(
                                                      child: Container(
                                                        height: 10,
                                                        width: 100,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  height: 10,
                                                  width: 100,
                                                  color: Theme.of(
                                                    context,
                                                  ).cardColor,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusExtraLarge,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            Images.distanceLine,
                                            height: 15,
                                            width: 15,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          Container(
                                            height: 10,
                                            width: 50,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          Container(
                                            height: 10,
                                            width: 50,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusExtraLarge,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            Images.clockIcon,
                                            height: 15,
                                            width: 15,
                                          ),
                                          const SizedBox(
                                            width: Dimensions
                                                .paddingSizeExtraSmall,
                                          ),

                                          Container(
                                            height: 10,
                                            width: 50,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : isFood
            ? SizedBox(
                height: 215,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Stack(
                        children: [
                          Shimmer(
                            duration: const Duration(seconds: 2),
                            enabled: true,
                            child: Container(
                              width: 260,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                        topRight: Radius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.1),
                                          ),

                                          Positioned(
                                            top: 15,
                                            right: 15,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withValues(alpha: 0.8),
                                              ),
                                              child: Icon(
                                                Icons.favorite_border,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 95,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 5,
                                                    width: 100,
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),

                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: Colors.blue,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        height: 10,
                                                        width: 100,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 10,
                                                  width: 70,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 3,
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusLarge,
                                                        ),
                                                  ),
                                                ),

                                                Container(
                                                  height: 20,
                                                  width: 65,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            top: 60,
                            left: 15,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 65,
                                  width: 65,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : SizedBox(
                height: 160,
                width: Get.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Shimmer(
                            duration: const Duration(seconds: 2),
                            enabled: true,
                            child: Container(
                              height: 155,
                              width: 250,
                              margin: const EdgeInsets.only(top: 30),
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          flex: 3,
                                          child: SizedBox(),
                                        ),

                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 10,
                                                        width: 50,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Row(
                                                    children: [
                                                      Icon(
                                                        FontAwesome.star_solid,
                                                        size: 15,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),

                                                      Container(
                                                        height: 10,
                                                        width: 50,
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),

                                              Icon(
                                                Icons.favorite_border,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 10,
                                      width: 100,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -5,
                            left: 15,
                            child: Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: double.infinity,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                      ),

                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              Container(
                                                height: 10,
                                                width: 50,
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
