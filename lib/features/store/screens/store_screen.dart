import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/category/domain/models/category_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/item_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/paginated_list_view.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:handy_allinone/features/checkout/screens/checkout_screen.dart';
import 'package:handy_allinone/features/store/widgets/store_description_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/store/widgets/store_details_screen_shimmer_widget.dart';
import 'package:handy_allinone/features/store/widgets/bottom_cart_widget.dart';
import 'package:handy_allinone/features/store/widgets/filter_widget.dart';
import '../../../common/widgets/item_widget.dart';
import '../../../common/widgets/menu pop.dart';
import '../../../common/widgets/veg_filter_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/web_item_view.dart';
import '../../../common/widgets/web_item_widget.dart';
import '../../coupon/controllers/coupon_controller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

import '../../language/controllers/language_controller.dart';
import '../widgets/customizable_space_bar_widget.dart';
import '../widgets/store_banner_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;

  const StoreScreen({
    super.key,
    required this.store,
    required this.fromModule,
    this.slug = '',
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initDataCall();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> initDataCall() async {
    Get.find<StoreController>().resetFilter(isUpdate: false);
    if (Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>()
        .getStoreDetails(
          Store(id: widget.store!.id),
          widget.fromModule,
          slug: widget.slug,
        )
        .then((value) {
          Get.find<StoreController>().showButtonAnimation();
        });
    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
    );
    Get.find<StoreController>().getRestaurantRecommendedItemList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
      false,
    );
    Get.find<StoreController>().getStoreItemList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
      1,
      'all',
      false,
    );

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      } else {
        if (!Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          GetBuilder<StoreController>(
        builder: (storeController) {
          return GetBuilder<CategoryController>(
            builder: (categoryController) {
              Store? store;
              if (storeController.store != null &&
                  storeController.store!.name != null &&
                  categoryController.categoryList != null) {
                store = storeController.store;
                storeController.setCategoryList();
              }

              return (storeController.store != null &&
                      storeController.store!.name != null &&
                      categoryController.categoryList != null)
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      slivers: [
                        ResponsiveHelper.isDesktop(context)
                            ? SliverToBoxAdapter(
                                child: Container(
                                  color: const Color(0xFF171A29),
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge,
                                  ),
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                child: Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  15,
                                                                ),
                                                            bottomRight:
                                                                Radius.circular(
                                                                  15,
                                                                ),
                                                          ),
                                                      child: CustomImage(
                                                        fit: BoxFit.cover,
                                                        height: 240,
                                                        width: Get.width,
                                                        image:
                                                            store
                                                                ?.coverPhotoFullUrl ??
                                                            '',
                                                      ),
                                                    ),

                                                    store?.discount != null
                                                        ? Positioned(
                                                            bottom: 0,
                                                            left: 0,
                                                            right: 0,
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall,
                                                                  ),
                                                              child: Text(
                                                                '${store?.discount!.discountType == 'percent' ? '${store?.discount!.discount}%' : PriceConverter.convertPrice(store?.discount!.discount)} '
                                                                '${'discount_will_be_applicable_when_order_amount_exceeds_is_more_than'.tr} ${PriceConverter.convertPrice(store?.discount!.minPurchase)},'
                                                                ' ${'Max'.tr}: ${PriceConverter.convertPrice(store?.discount!.maxDiscount)} ${'discount_is_applicable'.tr}',
                                                                style: robotoMedium.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeLarge,
                                            ),

                                            Expanded(
                                              child: StoreDescriptionViewWidget(
                                                store: store,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SliverAppBar(
                                expandedHeight: 280,
                                toolbarHeight: 100,
                                pinned: false,
                                floating: false,
                                elevation: 0.5,
                                backgroundColor: Theme.of(context).cardColor,
                                leading: IconButton(
                                  icon: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                                flexibleSpace: FlexibleSpaceBar(
                                  titlePadding: EdgeInsets.zero,
                                  centerTitle: true,
                                  expandedTitleScale: 1.1,
                                  title: CustomizableSpaceBarWidget(
                                    builder: (context, scrollingRate) {
                                      return Container(
                                        height: store!.discount != null
                                            ? 100
                                            : 100,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(
                                                  Dimensions.radiusLarge,
                                                ),
                                              ),
                                        ),
                                        child: Column(
                                          children: [
                                          SizedBox(),

                                            Container(
                                              color: Colors.transparent,
                                              // color: Theme.of(context).cardColor.withValues(alpha: scrollingRate),
                                              padding: EdgeInsets.only(
                                                bottom: 0,
                                                left:
                                                    Get.find<
                                                          LocalizationController
                                                        >()
                                                        .isLtr
                                                    ? 40 * scrollingRate
                                                    : 0,
                                                right:
                                                    Get.find<
                                                          LocalizationController
                                                        >()
                                                        .isLtr
                                                    ? 0
                                                    : 40 * scrollingRate,
                                              ),
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Container(
                                                  height: 89,
                                                  color: Colors.transparent,
                                                  // color: Theme.of(context).cardColor.withValues(alpha: scrollingRate == 0.0 ? 0 : 0),
                                                  padding: EdgeInsets.only(
                                                    left:
                                                        Get.find<
                                                              LocalizationController
                                                            >()
                                                            .isLtr
                                                        ? 20
                                                        : 0,
                                                    right:
                                                        Get.find<
                                                              LocalizationController
                                                            >()
                                                            .isLtr
                                                        ? 0
                                                        : 20,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                        child: Stack(
                                                          children: [
                                                            CustomImage(
                                                              image:
                                                                  '${store.logoFullUrl}',
                                                              height:
                                                                  70 -
                                                                  (scrollingRate *
                                                                      15),
                                                              width:
                                                                  70 -
                                                                  (scrollingRate *
                                                                      15),
                                                              fit: BoxFit.cover,
                                                            ),

                                                            storeController.isStoreOpenNow(
                                                                  store.active!,
                                                                  store
                                                                      .schedules,
                                                                )
                                                                ? const SizedBox()
                                                                : Positioned(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child: Container(
                                                                      height:
                                                                          30,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: const BorderRadius.vertical(
                                                                          bottom: Radius.circular(
                                                                            Dimensions.radiusSmall,
                                                                          ),
                                                                        ),
                                                                        color: Colors
                                                                            .black
                                                                            .withValues(
                                                                              alpha: 0.6,
                                                                            ),
                                                                      ),
                                                                      child: Text(
                                                                        'closed_now'
                                                                            .tr,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: robotoRegular.copyWith(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              Dimensions.fontSizeSmall,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    store.name!,
                                                                    style: robotoMedium.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeLarge -
                                                                          (scrollingRate *
                                                                              3),
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).cardColor,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeSmall,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                            Text(
                                                              store.address ??
                                                                  '',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: robotoRegular.copyWith(
                                                                fontSize:
                                                                    Dimensions
                                                                        .fontSizeSmall -
                                                                    (scrollingRate *
                                                                        2),
                                                                color: Theme.of(
                                                                  context,
                                                                ).cardColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  ResponsiveHelper.isDesktop(
                                                                    context,
                                                                  )
                                                                  ? Dimensions
                                                                        .paddingSizeExtraSmall
                                                                  : 0,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    "Min Order",
                                                                    style: robotoRegular.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeExtraSmall -
                                                                          (scrollingRate *
                                                                              2),
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).cardColor,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),
                                                                Text(
                                                                  PriceConverter.convertPrice(
                                                                    store
                                                                        .minimumOrder,
                                                                  ),
                                                                  // textDirection: TextDirection.LTR,
                                                                  style: robotoBold.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeExtraSmall -
                                                                        (scrollingRate *
                                                                            2),
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

                                                      GetBuilder<
                                                        FavouriteController
                                                      >(
                                                        builder: (favouriteController) {
                                                          bool isWished =
                                                              favouriteController
                                                                  .wishStoreIdList
                                                                  .contains(
                                                                    store!.id,
                                                                  );
                                                          return InkWell(
                                                            onTap: () {
                                                              if (AuthHelper.isLoggedIn()) {
                                                                isWished
                                                                    ? favouriteController.removeFromFavouriteList(
                                                                        store!
                                                                            .id,
                                                                        true,
                                                                      )
                                                                    : favouriteController.addToFavouriteList(
                                                                        null,
                                                                        store
                                                                            ?.id,
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
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black87,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault,
                                                                    ),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall,
                                                                  ),
                                                              child: Icon(
                                                                isWished
                                                                    ? Icons
                                                                          .favorite
                                                                    : Icons
                                                                          .favorite_border,
                                                                color: isWished
                                                                    ? Theme.of(
                                                                        context,
                                                                      ).primaryColor
                                                                    : Theme.of(
                                                                        context,
                                                                      ).disabledColor,
                                                                size:
                                                                    24 -
                                                                    (scrollingRate *
                                                                        4),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),

                                                      AppConstants
                                                              .webHostedUrl
                                                              .isNotEmpty
                                                          ? InkWell(
                                                              onTap: () {
                                                                storeController
                                                                    .shareStore();
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black87,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusDefault,
                                                                      ),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                child: Icon(
                                                                  Icons.share,
                                                                  size:
                                                                      24 -
                                                                      (scrollingRate *
                                                                          4),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  background: Stack(
                                    children: [
                                      Container(
                                        height: 350,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(25),
                                            bottomLeft: Radius.circular(25),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(25),
                                            bottomLeft: Radius.circular(25),
                                          ),
                                          child: CustomImage(
                                            fit: BoxFit.cover,
                                            width: Get.width,
                                            image:
                                                '${store!.coverPhotoFullUrl}',
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        child: Container(
                                          height: 350,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(25),
                                              bottomLeft: Radius.circular(25),
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.black87,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: const [SizedBox()],
                              ),
                        store!.discount != null && !ResponsiveHelper.isDesktop(context)
                            ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Container(
                                  margin: EdgeInsets.only(top: 15),
                                                          width: double.infinity,
                                                          decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor,
                                borderRadius:
                                BorderRadius.circular(

                                    Dimensions
                                        .radiusLarge,

                                ),
                                                          ),
                                                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                          child: Text(
                                '${store.discount!.discountType == 'percent' ? '${store.discount!.discount}%' : PriceConverter.convertPrice(store.discount!.discount)} '
                                    '${'discount_will_be_applicable_when_order_amount_exceeds_is_more_than'.tr} ${PriceConverter.convertPrice(store.discount!.minPurchase)},'
                                    ' ${'Max'.tr}: ${PriceConverter.convertPrice(store.discount!.maxDiscount)} ${'discount_is_applicable'.tr} ${'discount_is_applicable'.tr}',
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions
                                      .fontSizeSmall,
                                  color: Colors.white
                                ),
                                textAlign:
                                TextAlign.center,
                                maxLines: 3,
                                overflow:
                                TextOverflow.ellipsis,
                                                          ),
                                                        ),
                              ),
                            )
                            : SliverToBoxAdapter(child: const SizedBox()),

                        (ResponsiveHelper.isDesktop(context) &&
                                storeController.recommendedItemModel != null &&
                                storeController
                                    .recommendedItemModel!
                                    .items!
                                    .isNotEmpty)
                            ? SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Container(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.10),
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        height:
                                            ResponsiveHelper.isDesktop(context)
                                            ? 325
                                            : 125,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            Text(
                                              'recommended_for_you'.tr,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              'here_is_what_you_might_like'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),

                                            SizedBox(
                                              height: 250,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: storeController
                                                    .recommendedItemModel!
                                                    .items!
                                                    .length,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    width: 225,
                                                    padding: const EdgeInsets.only(
                                                      right: Dimensions
                                                          .paddingSizeSmall,
                                                      left: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    child: WebItemWidget(
                                                      isStore: false,
                                                      item: storeController
                                                          .recommendedItemModel!
                                                          .items![index],
                                                      store: null,
                                                      index: index,
                                                      length: null,
                                                      isCampaign: false,
                                                      inStore: true,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SliverToBoxAdapter(child: SizedBox()),
                        // const SliverToBoxAdapter(
                        //   child: SizedBox(height: Dimensions.paddingSizeSmall),
                        // ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SliverDelegate(
                            height: 15,
                            child: Container(
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ),

                        ///web view..

                        ///mobile view..
                        ResponsiveHelper.isDesktop(context)
                            ? const SliverToBoxAdapter(child: SizedBox())
                            : SliverToBoxAdapter(
                                child: Container(
                                  width: Dimensions.webMaxWidth,
                                  color: Theme.of(context).cardColor,
                                  child: Column(
                                    children: [
                                      ResponsiveHelper.isDesktop(context)
                                          ? const SizedBox()
                                          : Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                child:
                                                    StoreDescriptionViewWidget(
                                                      store: store,
                                                    ),
                                              ),
                                            ),

                                      store?.announcementActive ?? false
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.05),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusDefault,
                                                    ),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.2),
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeSmall,
                                              ),
                                              margin: const EdgeInsets.only(
                                                top: 15,
                                              ),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    Images.announcement,
                                                    height: 20,
                                                    width: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall,
                                                  ),

                                                  Flexible(
                                                    child: Text(
                                                      store?.announcementMessage ??
                                                          '',
                                                      style: robotoRegular
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),

                                      StoreBannerWidget(
                                        storeController: storeController,
                                      ),

                                      (!ResponsiveHelper.isDesktop(context) &&
                                              storeController
                                                      .recommendedItemModel !=
                                                  null &&
                                              storeController
                                                  .recommendedItemModel!
                                                  .items!
                                                  .isNotEmpty)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'recommended_for_you'.tr,
                                                    style: robotoBold.copyWith(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  SizedBox(
                                                    height: 280,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: storeController
                                                          .recommendedItemModel!
                                                          .items!
                                                          .length,
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemBuilder: (context, index) {
                                                        return Padding(
                                                          padding:
                                                              ResponsiveHelper.isDesktop(
                                                                context,
                                                              )
                                                              ? const EdgeInsets.symmetric(
                                                                  vertical: 20,
                                                                )
                                                              : const EdgeInsets.symmetric(
                                                                  vertical: 10,
                                                                ),
                                                          child: Container(
                                                            width:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? 500
                                                                : 140,
                                                            padding: const EdgeInsets.only(
                                                              right: Dimensions
                                                                  .paddingSizeSmall,
                                                              left: Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                            margin: const EdgeInsets.only(
                                                              right: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                            child: ItemWidgetStore(
                                                              isStore: false,
                                                              item: storeController
                                                                  .recommendedItemModel!
                                                                  .items![index],
                                                              store: null,
                                                              index: index,
                                                              length: null,
                                                              isCampaign: false,
                                                              inStore: true,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SliverDelegate(
                            height: 15,
                            child: Container(
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ),

                        ResponsiveHelper.isDesktop(context)
                            ? const SliverToBoxAdapter(child: SizedBox())
                            : (storeController.categoryList!.isNotEmpty)
                            ? SliverPersistentHeader(
                                pinned: true,
                                delegate: SliverDelegate(
                                  height: 180,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withValues(
                                            alpha: 0.5,
                                          ),
                                          offset: Offset(
                                            0,
                                            4,
                                          ), // horizontal: 0, vertical: 4
                                          blurRadius: 6,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),

                                    child: Column(
                                      children: [
                                        Container(
                                          height: 55,
                                          width: Dimensions.webMaxWidth,
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          child: InkWell(
                                            onTap: () => Get.toNamed(
                                              RouteHelper.getSearchStoreItemRoute(
                                                store!.id,
                                              ),
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                                // border: Border.all(
                                                //   color: Theme.of(context)
                                                //       .primaryColor
                                                //       .withOpacity(0.2),
                                                //   width: 1,
                                                // ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        const SizedBox(
                                                          width: 10.0,
                                                          height: 100.0,
                                                        ),
                                                        Text(
                                                          'search_item_in_store'
                                                              .tr,
                                                          style: robotoRegular
                                                              .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
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
                                                      padding:
                                                          EdgeInsets.symmetric(
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

                                        /* SizedBox(height: 5),
                                        Container(
                                          height: 115,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: storeController
                                                .categoryList!
                                                .length,
                                            padding: const EdgeInsets.only(
                                              left: Dimensions.paddingSizeSmall,
                                            ),
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () => storeController
                                                    .setCategoryIndex(index),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 12.0,
                                                      ),
                                                  child: Column(
                                                    children: [
                                                      index == 0
                                                          ? SizedBox.shrink()
                                                          // Container(
                                                          //     height: 86,
                                                          //     width: 66,
                                                          //     decoration: BoxDecoration(
                                                          //       color:
                                                          //           index ==
                                                          //               storeController
                                                          //                   .categoryIndex
                                                          //           ? Colors
                                                          //                 .black
                                                          //           : Colors
                                                          //                 .white,
                                                          //       borderRadius:
                                                          //           BorderRadius.circular(
                                                          //             15,
                                                          //           ),
                                                          //       border: Border.all(
                                                          //         color:
                                                          //             index ==
                                                          //                 storeController
                                                          //                     .categoryIndex
                                                          //             ? Colors
                                                          //                   .black
                                                          //             : Colors
                                                          //                   .grey
                                                          //                   .shade300,
                                                          //         width: 1.5,
                                                          //       ),
                                                          //     ),
                                                          //     child: Icon(
                                                          //       BoxIcons
                                                          //           .bxs_dashboard,
                                                          //       color:
                                                          //           index ==
                                                          //               storeController
                                                          //                   .categoryIndex
                                                          //           ? Colors
                                                          //                 .white
                                                          //           : Colors
                                                          //                 .black,
                                                          //     ),
                                                          //   )
                                                        
                                                         
                                                           : Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault,
                                                                    ),
                                                                color:
                                                                    index ==
                                                                        storeController
                                                                            .categoryIndex
                                                                    ? Theme.of(
                                                                        context,
                                                                      ).primaryColor
                                                                    : Colors
                                                                          .transparent,
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      3.0,
                                                                    ),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault,
                                                                        ),
                                                                  ),
                                                                  child: Container(
                                                                    height:
                                                                        index ==
                                                                            storeController.categoryIndex
                                                                        ? 82
                                                                        : 80,
                                                                    width:
                                                                        index ==
                                                                            storeController.categoryIndex
                                                                        ? 82
                                                                        : 80,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                    ),
                                                                    child: ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                      child: CustomImage(
                                                                        image:
                                                                            storeController.categoryList![index].imageFullUrl ??
                                                                            "",
                                                                        height:
                                                                            index ==
                                                                                storeController.categoryIndex
                                                                            ? 82
                                                                            : 80,
                                                                        width:
                                                                            index ==
                                                                                storeController.categoryIndex
                                                                            ? 82
                                                                            : 80,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                              index == 0
                                                          ? "": storeController
                                                            .categoryList![index]
                                                            .name!,
                                                        style:
                                                            index ==
                                                                storeController
                                                                    .categoryIndex
                                                            ? robotoBold.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                              )
                                                            : robotoBold.copyWith(
                                                                fontSize:
                                                                    Dimensions
                                                                        .fontSizeSmall *
                                                                    1.02,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ), */
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SliverToBoxAdapter(child: SizedBox()),

                        ResponsiveHelper.isDesktop(context)
                            ? const SliverToBoxAdapter(child: SizedBox())
                            : SliverToBoxAdapter(
                                child: Container(
                                  width: Dimensions.webMaxWidth,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  child: PaginatedListView(
                                    scrollController: scrollController,
                                    onPaginate: (int? offset) async =>
                                        await storeController.getStoreItemList(
                                          widget.store!.id ??
                                              storeController.store!.id,
                                          offset!,
                                          storeController.type,
                                          false,
                                        ),
                                    totalSize: storeController
                                        .storeItemModel
                                        ?.totalSize,
                                    offset:
                                        storeController.storeItemModel?.offset,
                                    itemView: ItemsViewStore(
                                      isStore: false,
                                      stores: null,
                                      isScrollable: false,
                                      isGridView: false,
                                      backButton: scrollToTop,
                                      categoryname: storeController
                                          .categoryList![storeController.categoryIndex].name!,
                                      items:
                                          (storeController
                                                  .categoryList!
                                                  .isNotEmpty &&
                                              storeController.storeItemModel !=
                                                  null)
                                          ? storeController
                                                .storeItemModel!
                                                .items
                                          : null,
                                      inStorePage: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeSmall,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    )
                  : QuoteScreen();
            },
          );
        },
      ),
          GetBuilder<StoreController>(
            builder: (storeController) {
              return GetBuilder<CategoryController>(
                builder: (categoryController) {
                  bool isPharmacy = Get.find<SplashController>().module != null &&
                      Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
                          AppConstants.pharmacy.toLowerCase();

                  return (storeController.store != null &&
                          storeController.store!.name != null &&
                          categoryController.categoryList != null)
                      ? Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: SafeArea(
                            child: GetBuilder<CartController>(
                              builder: (cartController) {
                                return cartController.cartList.isNotEmpty &&
                                        !ResponsiveHelper.isDesktop(context)
                                    ? Container(
                                        margin: isPharmacy ? EdgeInsets.zero : EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A2A2A),
                                          borderRadius: isPharmacy
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(30.r),
                                                topRight: Radius.circular(30.r),
                                              )
                                            : BorderRadius.circular(Dimensions.radiusLarge),
                                          boxShadow: isPharmacy ? [] : [
                                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                                          ],
                                        ),
                                        child: const BottomCartWidgetStore(),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              );
            },
          ),
        ],
      ),

      floatingActionButton: GetBuilder<StoreController>(
        builder: (storeController) {
          bool showPrescription = storeController.showFavButton &&
                Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .orderAttachment! &&
                (storeController.store != null &&
                    storeController.store!.prescriptionOrder!) &&
                Get.find<SplashController>().configModel!.prescriptionStatus! &&
                AuthHelper.isLoggedIn();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showPrescription)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        width: storeController.currentState == true
                            ? 0
                            : ResponsiveHelper.isDesktop(context)
                            ? 180
                            : 150,
                        height: 30,
                        curve: Curves.linear,
                        child: Center(
                          child: Text(
                            'prescription_order'.tr,
                            textAlign: TextAlign.center,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Get.find<CheckoutController>().updateFirstTime();
                          Get.toNamed(
                            RouteHelper.getCheckoutRoute(
                              'prescription',
                              storeId: storeController.store!.id,
                            ),
                            arguments: CheckoutScreen(
                              fromCart: false,
                              cartList: null,
                              storeId: storeController.store!.id,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          child: Image.asset(
                            Images.prescriptionIcon,
                            height: 25,
                            width: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (showPrescription) const SizedBox(height: Dimensions.paddingSizeSmall),

              Visibility(
                visible: storeController.showFavButton,
                child: GestureDetector(
                  key: _menuKey,
                  onTap: () => showCategoryPopup(context, storeController, _menuKey),
                  child: Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF2D2D2D), Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 26),
                        const SizedBox(height: 2),
                        Text(
                          "MENU",
                          style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
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

      bottomNavigationBar: const SizedBox(),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;

  CategoryProduct(this.category, this.products);
}

class SearchWithMicField extends StatefulWidget {
  final TextEditingController controller;
  final String store;

  const SearchWithMicField({
    super.key,
    required this.controller,
    required this.store,
  });

  @override
  State<SearchWithMicField> createState() => _SearchWithMicFieldState();
}

class _SearchWithMicFieldState extends State<SearchWithMicField>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;
  double _soundLevel = 0.0;
  Timer? _silenceTimer;
  bool _noSpeechDetected = false;

  late AnimationController _rippleController;
  OverlayEntry? _overlayEntry;

  final List<Color> googleColors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: _handleStatus,
      onError: (error) {
        if (!mounted) return;
        _handleNoSpeech();
      },
    );
  }

  void _handleStatus(String status) {
    if (!mounted) return;
    if (status == 'done' || status == 'notListening') {
      _handleNoSpeech();
    }
  }

  Future<void> _toggleListening() async {
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (!_speechEnabled) {
      _showPermissionDialog();
      return;
    }

    if (_isListening) {
      _stopListening();
      return;
    }

    setState(() {
      _isListening = true;
      _noSpeechDetected = false;
    });

    _showListeningDialog();

    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 10), () {
      if (_soundLevel == 0 && mounted) {
        _handleNoSpeech();
      }
    });

    await _speech.listen(
      listenFor: const Duration(seconds: 60),
      onResult: (result) {
        if (!mounted) return;
        widget.controller.text = result.recognizedWords;

        if (result.finalResult && widget.controller.text.trim().isNotEmpty) {
          _stopListening();
          _searchItem(widget.controller.text.trim());
        }
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;
        setState(() => _soundLevel = level);
      },
    );
  }

  void _handleNoSpeech() {
    if (!mounted) return;

    try {
      _speech.stop();
    } catch (_) {}

    _silenceTimer?.cancel();
    _silenceTimer = null;

    if (!mounted) return;
    setState(() {
      _isListening = false;
      _noSpeechDetected = true;
    });

    _showListeningDialog();
  }

  void _stopListening() {
    try {
      _speech.stop();
    } catch (_) {}

    _silenceTimer?.cancel();
    _silenceTimer = null;

    if (!mounted) return;
    setState(() {
      _isListening = false;
      _soundLevel = 0;
    });

    _removeOverlay();
  }

  void _removeOverlay() {
    if (!mounted) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.cancel();
    _rippleController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'To use voice search, please enable microphone access in your app settings.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Enable'),
            onPressed: () async {
              Navigator.pop(context);
              await Permission.microphone.request();
              _initSpeech();
            },
          ),
        ],
      ),
    );
  }

  void _searchItem(String text) {
    Get.find<StoreController>().getStoreSearchItemList(
      text,
      widget.store.toString(),
      1,
      Get.find<StoreController>().searchType,
    );
  }

  void _showListeningDialog() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.white,
          elevation: 10,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _stopListening,
                  ),
                ),

                if (!_noSpeechDetected) ...[
                  _micAnimation(),
                  const SizedBox(height: 16),
                  const Text(
                    "Listening...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Speak now", style: TextStyle(color: Colors.grey)),
                ] else ...[
                  const Icon(Icons.mic_off, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text(
                    "Unable to hear your voice",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _removeOverlay();
                      _toggleListening();
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _micAnimation() {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 1; i <= 3; i++)
            AnimatedBuilder(
              animation: _rippleController,
              builder: (_, __) {
                return Transform.scale(
                  scale: 1 + (_rippleController.value * i * 0.4),
                  child: Container(
                    width: 60.0 * i,
                    height: 60.0 * i,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.2 / i),
                    ),
                  ),
                );
              },
            ),
          const Icon(CupertinoIcons.mic, size: 40, color: Colors.blue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return SizedBox(
          height: 55,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              controller: widget.controller,
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.search,
              cursorColor: Theme.of(context).primaryColor,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'search_item_in_store'.tr,
                filled: true,
                fillColor: Colors.grey.shade100,
                isDense: true,
                contentPadding: const EdgeInsets.all(8),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),

                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.search, size: 25),
                      onPressed: () {
                        final searchText = widget.controller.text.trim();
                        if (searchText.isNotEmpty) {
                          storeController.getStoreSearchItemList(
                            searchText,
                            widget.store.toString(),
                            1,
                            storeController.searchType,
                          );
                        }
                      },
                    ),
                    Container(
                      height: 25,
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                    IconButton(
                      icon: Icon(
                        _isListening
                            ? CupertinoIcons.mic
                            : CupertinoIcons.mic_fill,
                        color: Theme.of(context).primaryColor,
                        size: 25,
                      ),
                      onPressed: _toggleListening,
                    ),
                  ],
                ),
              ),

              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  storeController.getStoreSearchItemList(
                    text.trim(),
                    widget.store.toString(),
                    1,
                    storeController.searchType,
                  );
                }
              },

              onChanged: (text) {
                if (text.isEmpty) {
                  storeController.setSearching(false);
                  storeController.update();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // next quote trigger
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.format_quote,
                    size: 42,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    '"${AppConstants.appName}: Where speed meets quality in every single delivery."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// SUBTITLE — also italic like mockup
                  const Text(
                    '- Our Commitment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 55),

                  const Text(
                    'Tap for next quote',
                    style: TextStyle(fontSize: 14, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
