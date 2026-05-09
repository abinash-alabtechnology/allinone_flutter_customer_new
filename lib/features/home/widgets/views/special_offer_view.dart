import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/title_widget.dart';
import 'package:handy_allinone/common/widgets/card_design/item_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../common/widgets/cart_count_view.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../common/widgets/custom_ink_well.dart';
import '../../../../common/widgets/hover/on_hover.dart';
import '../../../../common/widgets/hover/text_hover.dart';
import '../../../../common/widgets/not_available_widget.dart';
import '../../../../helper/price_converter.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../util/styles.dart';
import '../../../splash/controllers/splash_controller.dart';

class SpecialOfferView extends StatelessWidget {
  final bool isFood;
  final bool isShop;

  const SpecialOfferView({
    super.key,
    required this.isFood,
    required this.isShop,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        List<Item>? discountedItemList = itemController.discountedItemList;

        return discountedItemList != null
            ? discountedItemList.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: isFood
                            ? const BorderRadius.all(Radius.circular(16.0))
                            : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: Color(0xFFFE8219),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeDefault,
                                    left: Dimensions.paddingSizeDefault,
                                    right: Dimensions.paddingSizeDefault,
                                  ),
                                  child: isShop
                                      ? TitleWidget1(
                                          title: "Lowest Prices",
                                          title1: " on Exotic",
                                          onTap: () => Get.toNamed(
                                            RouteHelper.getItemViewAllScreen(
                                              false,
                                              true,
                                            ),
                                          ),
                                        )
                                      : TitleWidget(
                                          title: 'special_offer'.tr,
                                          image: Images.discountOfferIcon,
                                          color: const Color(0xFF000080),
                                          onTap: () => Get.toNamed(
                                            RouteHelper.getItemViewAllScreen(
                                              false,
                                              true,
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                          GetBuilder<ItemController>(
                            builder: (itemController) {
                              List<Item>? discountedItemList =
                                  itemController.discountedItemList;
                              int resolveGridCount(double width) {
                                if (width < 600) return 3;
                                if (width < 1024) return 5;
                                return 7;
                              }

                              final bool isLoading = discountedItemList == null;

                              return Skeletonizer(
                                enabled: isLoading,
                                child:
                                    !isLoading && discountedItemList.isNotEmpty
                                    ? Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xFFFE8219),
                                                  Colors.orange.withValues(
                                                    alpha: 0.4,
                                                  ),
                                                  Colors.orange.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                ],
                                                stops: const [0.0, 0.25, 1.0],
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                  ),
                                              child: SizedBox(
                                                height: 500,
                                                width: Get.width,
                                                child: GridView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                                  physics: const ClampingScrollPhysics(),
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 12,
                                                      mainAxisExtent: 120.w,
                                                      crossAxisSpacing: 12,
                                                    ),
                                                  itemCount:
                                                      discountedItemList
                                                          .length,
                                                  itemBuilder: (context, index) {
                                                    final controller =
                                                        Get.find<
                                                          ItemController
                                                        >();
                                                    final item =
                                                        discountedItemList[index];
                                                    double? discount =
                                                        item.discount;
                                                    String? discountType =
                                                        item.discountType;
                                                    bool isPopularItem =
                                                        false;

                                                    bool isRightSide =
                                                        Get.find<
                                                              SplashController
                                                            >()
                                                            .configModel!
                                                            .currencySymbolDirection ==
                                                        'right';
                                                    String currencySymbol =
                                                        Get.find<
                                                              SplashController
                                                            >()
                                                            .configModel!
                                                            .currencySymbol!;
                                                    double originalPrice =
                                                        item.price!;
                                                    double offAmount = 0;

                                                    if (discountType ==
                                                        'percent') {
                                                      offAmount =
                                                          (originalPrice *
                                                              discount!) /
                                                          100;
                                                    } else {
                                                      offAmount = discount!;
                                                    }
                                                    final String badgeText =
                                                        discountType ==
                                                            'percent'
                                                        ? '${PriceConverter.convertPrice(offAmount)} ${'off'.tr}'
                                                        : '${PriceConverter.convertPrice(discount)} ${'off'.tr}';

                                                    if (!controller
                                                        .isAvailable(item)) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    return OnHover(
                                                      isItem: true,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusLarge,
                                                              ),
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: CustomInkWell(
                                                          onTap: () =>
                                                              Get.find<
                                                                    ItemController
                                                                  >()
                                                                  .navigateToItemPage(
                                                                    item,
                                                                    context,
                                                                  ),
                                                          radius: Dimensions
                                                              .radiusLarge,
                                                          child: TextHover(
                                                            builder: (isHovered) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Stack(
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius.circular(
                                                                          20.r,
                                                                        ),
                                                                        child: CustomImage(
                                                                          isHovered:
                                                                              isHovered,
                                                                          placeholder:
                                                                              Images.placeholder,
                                                                          image:
                                                                              '${item.imageFullUrl}',
                                                                          fit:
                                                                              BoxFit.cover,
                                                                          width:
                                                                              120.w,
                                                                          height:
                                                                              130.h,
                                                                        ),
                                                                      ),

                                                                      item.isStoreHalalActive! &&
                                                                              item.isHalalItem!
                                                                          ? const Positioned(
                                                                              top: 40,
                                                                              right: 15,
                                                                              child: CustomAssetImageWidget(
                                                                                Images.halalTag,
                                                                                height: 20,
                                                                                width: 20,
                                                                              ),
                                                                            )
                                                                          : const SizedBox(),
                                                                      (discount >
                                                                              0)
                                                                          ? Positioned(
                                                                              top: 0,
                                                                              left: 10,
                                                                              right: 10,
                                                                              child: DiscountBadge(
                                                                                badgeText: badgeText,
                                                                              ),
                                                                            )
                                                                          : const SizedBox(),

                                                                      // OrganicTag(
                                                                      //     item: item,
                                                                      //     placeInImage: false),
                                                                      isShop
                                                                          ? const SizedBox()
                                                                          : Positioned(
                                                                              bottom: 10,
                                                                              right: 10.w,
                                                                              child: CartCountViewGrocery(
                                                                                item: item,
                                                                                index: index,
                                                                              ),
                                                                            ),

                                                                      // (item.stock !=
                                                                      //             null &&
                                                                      //         item.stock! <
                                                                      //             0)
                                                                      //     ? Positioned.fill(
                                                                      //         bottom: 0,
                                                                      //         left: 0,
                                                                      //         child: Container(
                                                                      //           decoration: BoxDecoration(
                                                                      //             color: Colors.black54.withValues(
                                                                      //               alpha: 0.5,
                                                                      //             ),
                                                                      //             borderRadius: BorderRadius.circular(
                                                                      //               20.r,
                                                                      //             ),
                                                                      //           ),
                                                                      //           child: Center(
                                                                      //             child: Text(
                                                                      //               'out_of_stock'.tr,
                                                                      //               style: robotoRegular.copyWith(
                                                                      //                 color: Theme.of(
                                                                      //                   context,
                                                                      //                 ).cardColor,
                                                                      //                 fontSize: Dimensions.fontSizeSmall,
                                                                      //               ),
                                                                      //             ),
                                                                      //           ),
                                                                      //         ),
                                                                      //       )
                                                                      //     : const SizedBox(),
                                                                      Get.find<
                                                                                ItemController
                                                                              >()
                                                                              .isAvailable(item)
                                                                          ? const SizedBox()
                                                                          : NotAvailableWidget(
                                                                              radius: Dimensions.radiusLarge,
                                                                              isAllSideRound: isPopularItem,
                                                                            ),
                                                                    ],
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                      left: Dimensions
                                                                          .paddingSizeSmall,
                                                                      right:
                                                                          isShop
                                                                          ? 0
                                                                          : Dimensions.paddingSizeSmall,
                                                                      top: Dimensions
                                                                          .paddingSizeSmall,
                                                                      bottom:
                                                                          isShop
                                                                          ? 0
                                                                          : Dimensions.paddingSizeSmall,
                                                                    ),
                                                                    child: Stack(
                                                                      clipBehavior:
                                                                          Clip.none,
                                                                      children: [
                                                                        Align(
                                                                          alignment:
                                                                              isPopularItem
                                                                              ? Alignment.center
                                                                              : Alignment.centerLeft,
                                                                          child: Column(
                                                                            crossAxisAlignment: isPopularItem
                                                                                ? CrossAxisAlignment.center
                                                                                : CrossAxisAlignment.start,
                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Text(
                                                                                item.name ??
                                                                                    '',
                                                                                style: robotoBold.copyWith(
                                                                                  fontSize: 11.sp,
                                                                                ),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                              Gap(
                                                                                5,
                                                                              ),
                                                                              (isFood ||
                                                                                      isShop)
                                                                                  ? item.ratingCount! >
                                                                                            0
                                                                                        ? Row(
                                                                                            mainAxisAlignment: isPopularItem
                                                                                                ? MainAxisAlignment.center
                                                                                                : MainAxisAlignment.start,
                                                                                            children: [
                                                                                              Icon(
                                                                                                Icons.star,
                                                                                                size: 14,
                                                                                                color: Theme.of(
                                                                                                  context,
                                                                                                ).primaryColor,
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: Dimensions.paddingSizeExtraSmall,
                                                                                              ),
                                                                                              Text(
                                                                                                item.avgRating!.toStringAsFixed(
                                                                                                  1,
                                                                                                ),
                                                                                                style: robotoRegular.copyWith(
                                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: Dimensions.paddingSizeExtraSmall,
                                                                                              ),
                                                                                              Text(
                                                                                                "(${item.ratingCount})",
                                                                                                style: robotoRegular.copyWith(
                                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                                  color: Theme.of(
                                                                                                    context,
                                                                                                  ).disabledColor,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : const SizedBox()
                                                                                  : (Get.find<
                                                                                              SplashController
                                                                                            >()
                                                                                            .configModel!
                                                                                            .moduleConfig!
                                                                                            .module!
                                                                                            .unit! &&
                                                                                        item.unitType !=
                                                                                            null)
                                                                                  ? Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: Theme.of(
                                                                                          context,
                                                                                        ).cardColor,
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          8,
                                                                                        ),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.symmetric(
                                                                                          horizontal: 6.0,
                                                                                          vertical: 2.0,
                                                                                        ),
                                                                                        child: Text(
                                                                                          item.unitType ??
                                                                                              '',
                                                                                          style: robotoRegular.copyWith(
                                                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  : const SizedBox(),
                                                                              Gap(
                                                                                5,
                                                                              ),

                                                                              discount >
                                                                                      0
                                                                                  ? Row(
                                                                                      children: [
                                                                                        Text(
                                                                                          "MRP ",
                                                                                          style: robotoRegular.copyWith(
                                                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                                                            color: Theme.of(
                                                                                              context,
                                                                                            ).disabledColor,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          PriceConverter.convertPrice(
                                                                                            Get.find<
                                                                                                  ItemController
                                                                                                >()
                                                                                                .getStartingPrice(
                                                                                                  item,
                                                                                                ),
                                                                                          ),
                                                                                          style: robotoMedium.copyWith(
                                                                                            fontSize: Dimensions.fontSizeExtraSmall,
                                                                                            color: Theme.of(
                                                                                              context,
                                                                                            ).disabledColor,
                                                                                            decoration: TextDecoration.lineThrough,
                                                                                            height: 1.0,
                                                                                          ),
                                                                                          textDirection: TextDirection.ltr,
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : const SizedBox(),
                                                                              // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                                                              Gap(
                                                                                5,
                                                                              ),

                                                                              Text(
                                                                                PriceConverter.convertPrice(
                                                                                  Get.find<
                                                                                        ItemController
                                                                                      >()
                                                                                      .getStartingPrice(
                                                                                        item,
                                                                                      ),
                                                                                  discount: discount,
                                                                                  discountType: discountType,
                                                                                ),
                                                                                textDirection: TextDirection.ltr,
                                                                                style: robotoBold.copyWith(
                                                                                  fontSize: 13.sp,
                                                                                ),
                                                                              ),

                                                                              const SizedBox(
                                                                                height: Dimensions.paddingSizeExtraSmall,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        isShop
                                                                            ? Positioned(
                                                                                bottom: 0,
                                                                                right: 0,
                                                                                child: CartCountView(
                                                                                  item: item,
                                                                                  index: index,
                                                                                  child: Container(
                                                                                    height: 35,
                                                                                    width: 38,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Theme.of(
                                                                                        context,
                                                                                      ).primaryColor,
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        topLeft: Radius.circular(
                                                                                          Dimensions.radiusLarge,
                                                                                        ),
                                                                                        bottomRight: Radius.circular(
                                                                                          Dimensions.radiusLarge,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    child: Icon(
                                                                                      Icons.add,
                                                                                      color: Theme.of(
                                                                                        context,
                                                                                      ).cardColor,
                                                                                      size: 20,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : const SizedBox(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(), // when empty list
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            : const ItemShimmerView(isPopularItem: false);
      },
    );
  }
}

class SpecialOfferViewGrocery extends StatelessWidget {
  final bool isFood;
  final bool isShop;

  const SpecialOfferViewGrocery({
    super.key,
    required this.isFood,
    required this.isShop,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        List<Item>? discountedItemList = itemController.discountedItemList;
        int resolveGridCount(double width) {
          if (width < 600) return 3;
          if (width < 1024) return 5;
          return 7;
        }

        final bool isLoading = discountedItemList == null;

        return Skeletonizer(
          enabled: isLoading,
          child: !isLoading && discountedItemList.isNotEmpty
              ? Column(
                  children: [
                    InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getItemViewAllScreen(false, true),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                        child: CustomAssetImageWidget(
                          Images.weekmela,
                          width: Get.width,
                          height: 200.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor, // left green
                            Theme.of(context).primaryColor.withValues(alpha: 0.4),
                            Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          ],
                          stops: const [0.0, 0.25, 1.0], // uplifted mid-tone
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final gridCount = resolveGridCount(
                              constraints.maxWidth,
                            );
                            return SizedBox(
                                height: 480.h,
                                width: Get.width,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 120.w,
                                    crossAxisSpacing: 12,
                                  ),
                              itemCount: discountedItemList.length,
                              itemBuilder: (context, index) {
                                final controller = Get.find<ItemController>();
                                final item = discountedItemList[index];
                                double? discount = item.discount;
                                String? discountType = item.discountType;
                                bool isPopularItem = false;

                                bool isRightSide =
                                    Get.find<SplashController>()
                                        .configModel!
                                        .currencySymbolDirection ==
                                    'right';
                                String currencySymbol =
                                    Get.find<SplashController>()
                                        .configModel!
                                        .currencySymbol!;
                                double originalPrice = item.price!;
                                double offAmount = 0;

                                if (discountType == 'percent') {
                                  offAmount = (originalPrice * discount!) / 100;
                                } else {
                                  offAmount = discount!;
                                }
                                final String badgeText =
                                    discountType == 'percent'
                                    ? '${PriceConverter.convertPrice(offAmount)} ${'off'.tr}'
                                    : '${PriceConverter.convertPrice(discount)} ${'off'.tr}';

                                bool isOutOfStock(Item item) {
                                  return item.stock != null && item.stock! <= 0;
                                }

                                bool isItemAvailable(Item item) {
                                  return Get.find<ItemController>().isAvailable(
                                    item,
                                  );
                                }

                                final bool outOfStock = isOutOfStock(item);
                                final bool available = isItemAvailable(item);
                                final bool isDisabled =
                                    !available || outOfStock;

                                if (!controller.isAvailable(item)) {
                                  return const SizedBox.shrink();
                                }
                                return IgnorePointer(
                                  ignoring: isDisabled,
                                  child: Opacity(
                                    opacity: !isDisabled ? 1.0 : 0.55,
                                    child: ColorFiltered(
                                      colorFilter: !isDisabled
                                          ? const ColorFilter.mode(
                                              Colors.transparent,
                                              BlendMode.multiply,
                                            )
                                          : const ColorFilter.matrix(<double>[
                                              0.2126,
                                              0.7152,
                                              0.0722,
                                              0,
                                              0,
                                              0.2126,
                                              0.7152,
                                              0.0722,
                                              0,
                                              0,
                                              0.2126,
                                              0.7152,
                                              0.0722,
                                              0,
                                              0,
                                              0,
                                              0,
                                              0,
                                              1,
                                              0,
                                            ]),
                                      child: OnHover(
                                        isItem: true,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusLarge,
                                            ),
                                            color: Colors.transparent,
                                          ),
                                          child: CustomInkWell(
                                            onTap: () {
                                              Get.find<ItemController>()
                                                  .navigateToItemPage(
                                                    item,
                                                    context,
                                                  );
                                            },
                                            radius: Dimensions.radiusLarge,
                                            child: TextHover(
                                              builder: (isHovered) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20.r,
                                                              ),
                                                          child: CustomImage(
                                                            isHovered:
                                                                isHovered,
                                                            placeholder: Images
                                                                .placeholder,
                                                            image:
                                                                '${item.imageFullUrl}',
                                                            fit: BoxFit.cover,
                                                            width: 120.w,
                                                            height: 130.h,
                                                          ),
                                                        ),

                                                        item.isStoreHalalActive! &&
                                                                item.isHalalItem!
                                                            ? const Positioned(
                                                                top: 40,
                                                                right: 15,
                                                                child: CustomAssetImageWidget(
                                                                  Images
                                                                      .halalTag,
                                                                  height: 20,
                                                                  width: 20,
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                        (discount > 0)
                                                            ? Positioned(
                                                                top: 0,
                                                                left: 10,
                                                                right: 10,
                                                                child: DiscountBadge(
                                                                  badgeText:
                                                                      badgeText,
                                                                ),
                                                              )
                                                            : const SizedBox(),

                                                        // OrganicTag(
                                                        //     item: item,
                                                        //     placeInImage: false),
                                                        isShop
                                                            ? const SizedBox()
                                                            : Positioned(
                                                                bottom: 10,
                                                                right: 10.w,
                                                                child:
                                                                    CartCountViewGrocery(
                                                                      item:
                                                                          item,
                                                                      index:
                                                                          index,
                                                                    ),
                                                              ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: Dimensions
                                                            .paddingSizeSmall,
                                                        right: isShop
                                                            ? 0
                                                            : Dimensions
                                                                  .paddingSizeSmall,
                                                        top: Dimensions
                                                            .paddingSizeSmall,
                                                        bottom: isShop
                                                            ? 0
                                                            : Dimensions
                                                                  .paddingSizeSmall,
                                                      ),
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                isPopularItem
                                                                ? Alignment
                                                                      .center
                                                                : Alignment
                                                                      .centerLeft,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  isPopularItem
                                                                  ? CrossAxisAlignment
                                                                        .center
                                                                  : CrossAxisAlignment
                                                                        .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Text(
                                                                  item.name ??
                                                                      '',
                                                                  style: robotoBold
                                                                      .copyWith(
                                                                        fontSize:
                                                                            11.sp,
                                                                      ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                Gap(5),
                                                                (isFood ||
                                                                        isShop)
                                                                    ? item.ratingCount! >
                                                                              0
                                                                          ? Row(
                                                                              mainAxisAlignment: isPopularItem
                                                                                  ? MainAxisAlignment.center
                                                                                  : MainAxisAlignment.start,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.star,
                                                                                  size: 14,
                                                                                  color: Theme.of(
                                                                                    context,
                                                                                  ).primaryColor,
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: Dimensions.paddingSizeExtraSmall,
                                                                                ),
                                                                                Text(
                                                                                  item.avgRating!.toStringAsFixed(
                                                                                    1,
                                                                                  ),
                                                                                  style: robotoRegular.copyWith(
                                                                                    fontSize: Dimensions.fontSizeSmall,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: Dimensions.paddingSizeExtraSmall,
                                                                                ),
                                                                                Text(
                                                                                  "(${item.ratingCount})",
                                                                                  style: robotoRegular.copyWith(
                                                                                    fontSize: Dimensions.fontSizeSmall,
                                                                                    color: Theme.of(
                                                                                      context,
                                                                                    ).disabledColor,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : const SizedBox()
                                                                    : (Get.find<
                                                                                SplashController
                                                                              >()
                                                                              .configModel!
                                                                              .moduleConfig!
                                                                              .module!
                                                                              .unit! &&
                                                                          item.unitType !=
                                                                              null)
                                                                    ? Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).cardColor,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                6.0,
                                                                            vertical:
                                                                                2.0,
                                                                          ),
                                                                          child: Text(
                                                                            item.unitType ??
                                                                                '',
                                                                            style: robotoRegular.copyWith(
                                                                              fontSize: Dimensions.fontSizeExtraSmall,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : const SizedBox(),
                                                                Gap(5),

                                                                discount > 0
                                                                    ? Row(
                                                                        children: [
                                                                          Text(
                                                                            "MRP ",
                                                                            style: robotoRegular.copyWith(
                                                                              fontSize: Dimensions.fontSizeExtraSmall,
                                                                              color: Theme.of(
                                                                                context,
                                                                              ).disabledColor,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            PriceConverter.convertPrice(
                                                                              Get.find<
                                                                                    ItemController
                                                                                  >()
                                                                                  .getStartingPrice(
                                                                                    item,
                                                                                  ),
                                                                            ),
                                                                            style: robotoMedium.copyWith(
                                                                              fontSize: Dimensions.fontSizeExtraSmall,
                                                                              color: Theme.of(
                                                                                context,
                                                                              ).disabledColor,
                                                                              decoration: TextDecoration.lineThrough,
                                                                              height: 1.0,
                                                                            ),
                                                                            textDirection:
                                                                                TextDirection.ltr,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : const SizedBox(),
                                                                // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                                                Gap(5),

                                                                Text(
                                                                  PriceConverter.convertPrice(
                                                                    Get.find<
                                                                          ItemController
                                                                        >()
                                                                        .getStartingPrice(
                                                                          item,
                                                                        ),
                                                                    discount:
                                                                        discount,
                                                                    discountType:
                                                                        discountType,
                                                                  ),
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                  style: robotoBold
                                                                      .copyWith(
                                                                        fontSize:
                                                                            11.sp,
                                                                      ),
                                                                ),

                                                                const SizedBox(
                                                                  height: Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          isShop
                                                              ? Positioned(
                                                                  bottom: 0,
                                                                  right: 0,
                                                                  child: CartCountView(
                                                                    item: item,
                                                                    index:
                                                                        index,
                                                                    child: Container(
                                                                      height:
                                                                          35,
                                                                      width: double
                                                                          .infinity,
                                                                      decoration: BoxDecoration(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).primaryColor,
                                                                        borderRadius: const BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                            Dimensions.radiusLarge,
                                                                          ),
                                                                          bottomRight: Radius.circular(
                                                                            Dimensions.radiusLarge,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).cardColor,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                                )  );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(), // when empty list
        );
      },
    );
  }
}

class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;

  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: TitleWidget(
                title: isPopularItem
                    ? 'most_popular_items'.tr
                    : 'special_offer'.tr,
                image: isPopularItem
                    ? Images.mostPopularIcon
                    : Images.discountOfferIcon,
              ),
            ),
            SizedBox(
              height: 285,
              width: Get.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeDefault,
                    ),
                    child: Shimmer(
                      duration: const Duration(seconds: 2),
                      enabled: true,
                      child: Container(
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraSmall,
                        ),
                        height: 285,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusLarge,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusLarge,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).shadowColor,
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                    ),
                                    height: 15,
                                    width: 100,
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).shadowColor,
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall,
                                      ),
                                    ),
                                    height: 20,
                                    width: 200,
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                  Container(
                                    height: 15,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).shadowColor,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountBadge extends StatefulWidget {
  final String badgeText;

  const DiscountBadge({super.key, required this.badgeText});

  @override
  State<DiscountBadge> createState() => _DiscountBadgeState();
}

class _DiscountBadgeState extends State<DiscountBadge> {
  bool reverse = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      // 🎯 serial bulb timing
      tween: Tween(begin: reverse ? 0.5 : 0.0, end: reverse ? 0.0 : 0.5),
      curve: Curves.easeInOutCubic,
      // ⭐ soft glowing like festival lights
      onEnd: () => setState(() => reverse = !reverse),
      builder: (context, value, child) {
        // smooth ambient glow
        final Color bg = Color.lerp(Colors.green, Colors.white, value)!;
        final Color txt = Color.lerp(Colors.white, Colors.green, value)!;

        return ClipPath(
          clipper: FixedWidthWaveClipper(radius: 6, humpWidth: 7.w),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.badgeText,
                      style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: (ResponsiveHelper.isMobile(context) ? 8 : 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FixedWidthWaveClipper extends CustomClipper<Path> {
  final double radius; // single amplitude
  final double humpWidth; // preferred hump width

  FixedWidthWaveClipper({this.radius = 8, this.humpWidth = 8});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Compute exact number of humps that fit
    int humpCount = (size.width / humpWidth).ceil(); // use ceil to avoid cut
    double segment = size.width / humpCount; // adjust segment width dynamically

    final double baseY = size.height - radius;
    path.moveTo(0, 0);
    path.lineTo(0, baseY);

    double x = 0;
    bool isUp = true;

    for (int i = 0; i < humpCount; i++) {
      double xMid = x + segment / 2;
      double xEnd = x + segment;

      path.quadraticBezierTo(
        xMid,
        isUp ? size.height + radius : size.height - radius * 2,
        xEnd,
        baseY,
      );

      x = xEnd;
      isUp = !isUp;
    }

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
