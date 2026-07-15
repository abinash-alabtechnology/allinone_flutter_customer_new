import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';
import 'package:handy_allinone/common/widgets/corner_banner/banner.dart';
import 'package:handy_allinone/common/widgets/corner_banner/corner_discount_tag.dart';
import 'package:handy_allinone/common/widgets/custom_favourite_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
import 'package:handy_allinone/common/widgets/hover/on_hover.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/common/models/module_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/discount_tag.dart';
import 'package:handy_allinone/common/widgets/not_available_widget.dart';
import 'package:handy_allinone/common/widgets/organic_tag.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/app_constants.dart';

class ItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  final double? imageHeight;
  final double? imageWidth;
  final bool? isCornerTag;

  const ItemWidget({
    super.key,
    required this.item,
    required this.isStore,
    required this.store,
    required this.index,
    required this.length,
    this.inStore = false,
    this.isCampaign = false,
    this.isFeatured = false,
    this.fromCartSuggestion = false,
    this.imageHeight,
    this.imageWidth,
    this.isCornerTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    bool desktop = ResponsiveHelper.isDesktop(context);
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.pharmacy.toLowerCase();
    bool isFood = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.food.toLowerCase();
    double? discount;
    String? discountType;
    bool isAvailable;
    String genericName = '';

    if (!isStore &&
        item!.genericName != null &&
        item!.genericName!.isNotEmpty) {
      for (String name in item!.genericName!) {
        genericName += name;
      }
    }
    if (isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType = store!.discount != null
          ? store!.discount!.discountType
          : 'percent';
      isAvailable = store!.open == 1 && store!.active!;
    } else {
      discount = item!.discount;
      discountType = item!.discountType;
      isAvailable = DateConverter.isAvailable(
        item!.availableTimeStarts,
        item!.availableTimeEnds,
      );
    }

    return IgnorePointer(
      ignoring: !isAvailable,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.55,
        child: ColorFiltered(
          colorFilter: isAvailable
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
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
          child: Stack(
            children: [
              Container(
                margin: ResponsiveHelper.isDesktop(context)
                    ? null
                    : const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.grey.shade100, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomInkWell(
                  onTap: isAvailable
                      ? () {
                          if (isStore) {
                            if (store != null) {
                              if (isFeatured &&
                                  Get.find<SplashController>().moduleList !=
                                      null) {
                                for (ModuleModel module
                                    in Get.find<SplashController>()
                                        .moduleList!) {
                                  if (module.id == store!.moduleId) {
                                    Get.find<SplashController>().setModule(
                                      module,
                                    );
                                    break;
                                  }
                                }
                              }
                              Get.toNamed(
                                RouteHelper.getStoreRoute(
                                  id: store!.id,
                                  page: isFeatured ? 'module' : 'item',
                                ),
                                arguments: StoreScreen(
                                  store: store,
                                  fromModule: isFeatured,
                                ),
                              );
                            }
                          } else {
                            if (isFeatured &&
                                Get.find<SplashController>().moduleList !=
                                    null) {
                              for (ModuleModel module
                                  in Get.find<SplashController>().moduleList!) {
                                if (module.id == item!.moduleId) {
                                  Get.find<SplashController>().setModule(
                                    module,
                                  );
                                  break;
                                }
                              }
                            }
                            Get.find<ItemController>().navigateToItemPage(
                              item,
                              context,
                              inStore: inStore,
                              isCampaign: isCampaign,
                            );
                          }
                        }
                      : () {},
                  radius: Dimensions.radiusDefault,
                  padding: ResponsiveHelper.isDesktop(context)
                      ? EdgeInsets.all(
                          fromCartSuggestion
                              ? Dimensions.paddingSizeExtraSmall
                              : Dimensions.paddingSizeSmall,
                        )
                      : const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                  child: TextHover(
                    builder: (hovered) {
                      return isPharmacy ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: desktop
                                    ? 0
                                    : 2,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: imageHeight ?? (desktop ? 120 : 90),
                                    width: imageWidth ?? (desktop ? 120 : 90),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade100),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CustomImage(
                                        isHovered: hovered,
                                        image: '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isStore ? store!.name! : item!.name!,
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),

                                        !isStore && item!.genericName != null && item!.genericName!.isNotEmpty ? Text(
                                          item!.genericName!.join(', '),
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ) : const SizedBox(),

                                        !isStore && item!.unitType != null ? Text(
                                          '${item!.unitType}',
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.grey.shade500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ) : const SizedBox(),

                                        const SizedBox(height: 2),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              isStore ? '' : PriceConverter.convertPrice(item!.price, discount: discount, discountType: discountType),
                                              style: robotoBold.copyWith(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),

                                            !isStore ? CartCountViewPharmacy(
                                              item: item!,
                                              index: index,
                                            ) : const SizedBox(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          index == length!-1 ? const SizedBox() : Padding(
                            padding: EdgeInsets.only(left: desktop ? 130 : 100),
                            child: Divider(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), thickness: 1),
                          ),
                        ],
                      ) : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: desktop
                                    ? 0
                                    : Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(color: Colors.grey.shade100, width: 1),
                                        ),
                                        padding: EdgeInsets.all(4.w),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.r),
                                          child: CustomImage(
                                            isHovered: hovered,
                                            image: '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                                            height: imageHeight ?? (desktop ? 120 : 100.h),
                                            width: imageWidth ?? (desktop ? 120 : 100.w),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      if (isFood && !isStore && item != null && item!.veg != null)
                                        Positioned(
                                          top: 8.h,
                                          left: 8.w,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: (item!.veg == 1) ? Colors.green.shade600 : Colors.red.shade600,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(2.r),
                                            ),
                                            child: Container(
                                              width: 6.w,
                                              height: 6.w,
                                              decoration: BoxDecoration(
                                                color: (item!.veg == 1) ? Colors.green.shade600 : Colors.red.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),

                                      (isStore || isCornerTag!)
                                          ? DiscountTag(
                                              discount: discount,
                                              discountType: discountType,
                                              freeDelivery: isStore
                                                  ? store!.freeDelivery
                                                  : false,
                                            )
                                          : const SizedBox(),

                                      !isStore
                                          ? OrganicTag(
                                              item: item!,
                                              placeInImage: true,
                                            )
                                          : const SizedBox(),

                                      isAvailable
                                          ? const SizedBox()
                                          : isStore
                                          ? NotAvailableWidget(isStore: isStore)
                                          : Positioned.fill(
                                              child: Center(
                                                child: Text(
                                                  item!.availableTimeStarts!=null?"Next Available At ${item!.availableTimeStarts}":"",
                                                  textAlign: TextAlign.center,
                                                  style: robotoBold.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                            ),

                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: GetBuilder<FavouriteController>(
                                            builder: (favouriteController) {
                                              bool isWished = isStore
                                                  ? favouriteController
                                                        .wishStoreIdList
                                                        .contains(store!.id)
                                                  : favouriteController
                                                        .wishItemIdList
                                                        .contains(item!.id);
                                              return CustomFavouriteWidget(
                                                isWished: isWished,
                                                isStore: isStore,
                                                store: store,
                                                item: item,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          isStore ? store!.name! : item!.name!,
                                          style: robotoBold.copyWith(
                                            fontSize: 13.sp,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        if (isStore && store!.address != null)
                                          Text(
                                            store!.address ?? '',
                                            style: robotoRegular.copyWith(
                                              fontSize: 10.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                        if (!isStore && item!.storeName != null)
                                          Text(
                                            item!.storeName ?? '',
                                            style: robotoRegular.copyWith(
                                              fontSize: 10.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                        if (!isStore && Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item!.unitType != null)
                                          Text(
                                            item!.unitType ?? '1 unit',
                                            style: robotoRegular.copyWith(
                                              fontSize: 10.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),

                                        if (genericName.isNotEmpty)
                                          Text(
                                            genericName,
                                            style: robotoMedium.copyWith(
                                              fontSize: 10.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                        if (!isStore) ...[
                                          Row(
                                            children: [
                                              ...List.generate(5, (starIdx) {
                                                int filled = item!.avgRating?.round() ?? 5;
                                                return Icon(
                                                  Icons.star,
                                                  size: 11.sp,
                                                  color: starIdx < filled ? Colors.amber : Colors.grey.shade300,
                                                );
                                              }),
                                              const SizedBox(width: 4),
                                              Text(
                                                item!.ratingCount != null && item!.ratingCount! > 0
                                                    ? '(${item!.ratingCount})'
                                                    : '(12,280)',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 9.sp,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],

                                        if (isStore && store != null && store!.ratingCount! > 0)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 11.sp,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                store!.avgRating!.toStringAsFixed(1),
                                                style: robotoBold.copyWith(fontSize: 10.sp),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '(${store!.ratingCount})',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 9.sp,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),

                                        if (!isStore) ...[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                PriceConverter.convertPrice(
                                                  item!.price,
                                                  discount: discount,
                                                  discountType: discountType,
                                                ),
                                                style: robotoBold.copyWith(
                                                  fontSize: 14.sp,
                                                  color: Colors.black87,
                                                ),
                                                textDirection: TextDirection.ltr,
                                              ),
                                              if (discount != null && discount > 0) ...[
                                                const SizedBox(width: 6),
                                                Center(child: CustomLineThroughText(
                                                   text: PriceConverter.convertPrice(item!.price),
                                                   style: robotoMedium.copyWith(
                                                     fontSize: 10.sp,
                                                     color: Colors.grey,
                                                   ),
                                                   textAlign: TextAlign.center,
                                                   textDirection: TextDirection.ltr,
                                                 )),
                                              ],
                                            ],
                                          ),
                                          if (discount != null && discount > 0)
                                            Text(
                                              discountType == 'amount'
                                                  ? '₹${discount.toStringAsFixed(0)} OFF'
                                                  : '${discount.toStringAsFixed(0)}% OFF on MRP',
                                              style: robotoBold.copyWith(
                                                fontSize: 9.sp,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  if (!isStore)
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CartCountViewStore(
                                          item: item!,
                                          index: index,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              (!isStore && isCornerTag! == false)
                  ? Positioned(
                      right: ltr ? 0 : null,
                      left: ltr ? null : 0,
                      child: CornerDiscountTag(
                        bannerPosition: ltr
                            ? CornerBannerPosition.topRight
                            : CornerBannerPosition.topLeft,
                        elevation: 0,
                        discount: discount,
                        discountType: discountType,
                        freeDelivery: isStore ? store!.freeDelivery : false,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemWidgetStore extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  final double? imageHeight;
  final double? imageWidth;
  final bool? isCornerTag;

  const ItemWidgetStore({
    super.key,
    required this.item,
    required this.isStore,
    required this.store,
    required this.index,
    required this.length,
    this.inStore = false,
    this.isCampaign = false,
    this.isFeatured = false,
    this.fromCartSuggestion = false,
    this.imageHeight,
    this.imageWidth,
    this.isCornerTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    bool desktop = ResponsiveHelper.isDesktop(context);
    bool isFood = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.food.toLowerCase();
    double? discount;
    String? discountType;
    bool isAvailable;
    String genericName = '';

    if (!isStore &&
        item!.genericName != null &&
        item!.genericName!.isNotEmpty) {
      for (String name in item!.genericName!) {
        genericName += name;
      }
    }
    if (isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType = store!.discount != null
          ? store!.discount!.discountType
          : 'percent';
      isAvailable = store!.open == 1 && store!.active!;
    } else {
      discount = item!.discount;
      discountType = item!.discountType;
      isAvailable = DateConverter.isAvailable(
        item!.availableTimeStarts,
        item!.availableTimeEnds,
      );
    }

    return IgnorePointer(
      ignoring: !isAvailable,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.55,
        child: ColorFiltered(
          colorFilter: isAvailable
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
          child: OnHover(
            isItem: true,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomInkWell(
                    onTap: isAvailable
                        ? () {
                            if (isStore) {
                              if (store != null) {
                                if (isFeatured &&
                                    Get.find<SplashController>().moduleList !=
                                        null) {
                                  for (ModuleModel module
                                      in Get.find<SplashController>()
                                          .moduleList!) {
                                    if (module.id == store!.moduleId) {
                                      Get.find<SplashController>().setModule(
                                        module,
                                      );
                                      break;
                                    }
                                  }
                                }
                                Get.toNamed(
                                  RouteHelper.getStoreRoute(
                                    id: store!.id,
                                    page: isFeatured ? 'module' : 'item',
                                  ),
                                  arguments: StoreScreen(
                                    store: store,
                                    fromModule: isFeatured,
                                  ),
                                );
                              }
                            } else {
                              if (isFeatured &&
                                  Get.find<SplashController>().moduleList !=
                                      null) {
                                for (ModuleModel module
                                    in Get.find<SplashController>().moduleList!) {
                                  if (module.id == item!.moduleId) {
                                    Get.find<SplashController>().setModule(
                                      module,
                                    );
                                    break;
                                  }
                                }
                              }
                              Get.find<ItemController>().navigateToItemPage(
                                item,
                                context,
                                inStore: inStore,
                                isCampaign: isCampaign,
                              );
                            }
                          }
                        : () {},
                    radius: Dimensions.radiusDefault,
                    child: TextHover(
                      builder: (hovered) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Colors.grey.shade100, width: 1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: CustomImage(
                                        isHovered: hovered,
                                        image: '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                                        height: imageHeight ?? (desktop ? 140 : 120.h),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  if (isFood && !isStore && item != null && item!.veg != null)
                                    Positioned(
                                      top: 8.h,
                                      left: 8.w,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: (item!.veg == 1) ? Colors.green.shade600 : Colors.red.shade600,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(2.r),
                                        ),
                                        child: Container(
                                          width: 6.w,
                                          height: 6.w,
                                          decoration: BoxDecoration(
                                            color: (item!.veg == 1) ? Colors.green.shade600 : Colors.red.shade600,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),

                                  (isStore || isCornerTag!)
                                      ? DiscountTag(
                                          discount: discount,
                                          discountType: discountType,
                                          freeDelivery: isStore
                                              ? store!.freeDelivery
                                              : false,
                                        )
                                      : const SizedBox(),

                                  !isStore
                                      ? OrganicTag(
                                          item: item!,
                                          placeInImage: true,
                                        )
                                      : const SizedBox(),

                                  isAvailable
                                      ? const SizedBox()
                                      : NotAvailableWidget(
                                          isStore: isStore,
                                          store: store,
                                          item: item,
                                          radius: 15,
                                        ),

                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: GetBuilder<FavouriteController>(
                                        builder: (favouriteController) {
                                          bool isWished = isStore
                                              ? favouriteController.wishStoreIdList.contains(store!.id)
                                              : favouriteController.wishItemIdList.contains(item!.id);
                                          return CustomFavouriteWidget(
                                            isWished: isWished,
                                            isStore: isStore,
                                            store: store,
                                            item: item,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  if (!isStore && !fromCartSuggestion)
                                    Positioned(
                                      bottom: 8.h,
                                      right: 8.w,
                                      child: CartCountViewStore(
                                        item: item!,
                                        index: index,
                                      ),
                                    ),
                                ],
                              ),                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
 
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!isStore) ...[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            PriceConverter.convertPrice(
                                              item!.price,
                                              discount: discount,
                                              discountType: discountType,
                                            ),
                                            style: robotoBold.copyWith(
                                              fontSize: 13.sp,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (discount != null && discount > 0) ...[
                                            SizedBox(width: 4.w),
                                            CustomLineThroughText(
                                              text: PriceConverter.convertPrice(item!.price),
                                              style: robotoMedium.copyWith(
                                                fontSize: 10.sp,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (discount != null && discount > 0)
                                        Text(
                                          discountType == 'amount'
                                              ? '₹${discount.toStringAsFixed(0)} OFF'
                                              : '${discount.toStringAsFixed(0)}% OFF on MRP',
                                          style: robotoBold.copyWith(
                                            fontSize: 9.sp,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                    ],
 
                                    Text(
                                      isStore ? store!.name ?? '' : item!.name ?? '',
                                      style: robotoMedium.copyWith(
                                        fontSize: 11.sp,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
 
                                    if (isStore && store!.address != null)
                                      Text(
                                        store!.address ?? '',
                                        style: robotoRegular.copyWith(
                                          fontSize: 9.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
 
                                    if (!isStore && item!.storeName != null)
                                      Text(
                                        item!.storeName ?? '',
                                        style: robotoRegular.copyWith(
                                          fontSize: 9.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
 
                                    if (!isStore && Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item!.unitType != null)
                                      Text(
                                        item!.unitType ?? '1 unit',
                                        style: robotoRegular.copyWith(
                                          fontSize: 9.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
 
                                    if (genericName.isNotEmpty)
                                      Text(
                                        genericName,
                                        style: robotoMedium.copyWith(
                                          fontSize: 9.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
 
                                    if (!isStore) ...[
                                      Row(
                                        children: [
                                          ...List.generate(5, (starIdx) {
                                            int filled = item!.avgRating?.round() ?? 5;
                                            return Icon(
                                              Icons.star,
                                              size: 10.sp,
                                              color: starIdx < filled ? Colors.amber : Colors.grey.shade300,
                                            );
                                          }),
                                          const SizedBox(width: 4),
                                          Text(
                                            item!.ratingCount != null && item!.ratingCount! > 0
                                                ? '(${item!.ratingCount})'
                                                : '(12,280)',
                                            style: robotoRegular.copyWith(
                                              fontSize: 9.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
 
                                    if (isStore && store != null && store!.ratingCount! > 0)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 10.sp,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            store!.avgRating!.toStringAsFixed(1),
                                            style: robotoBold.copyWith(fontSize: 9.sp),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${store!.ratingCount})',
                                            style: robotoRegular.copyWith(
                                              fontSize: 9.sp,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                (!isStore && isCornerTag! == false)
                    ? Positioned(
                        right: ltr ? 0 : null,
                        left: ltr ? null : 0,
                        child: CornerDiscountTag(
                          bannerPosition: ltr
                              ? CornerBannerPosition.topRight
                              : CornerBannerPosition.topLeft,
                          elevation: 0,
                          discount: discount,
                          discountType: discountType,
                          freeDelivery: isStore ? store!.freeDelivery : false,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
