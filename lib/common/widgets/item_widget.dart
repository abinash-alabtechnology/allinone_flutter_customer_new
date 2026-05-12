import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';
import 'package:handy_allinone/common/widgets/corner_banner/banner.dart';
import 'package:handy_allinone/common/widgets/corner_banner/corner_discount_tag.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_favourite_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
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
import 'package:handy_allinone/util/images.dart';
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
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.12), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
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
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                        child: CustomImage(
                                          isHovered: hovered,
                                          image:
                                              '${isStore
                                                  ? store != null
                                                        ? store!.logoFullUrl
                                                        : ''
                                                  : item!.imageFullUrl}',
                                          height:
                                              imageHeight ??
                                              (desktop
                                                  ? 120
                                                  : 120),
                                          width:
                                              imageWidth ??
                                              (desktop ? 120 : 120),
                                          fit: BoxFit.cover,
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
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),

                                      Positioned(
                                        top: 5,
                                        left: 5,
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
                                    ],
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                isStore
                                                    ? store!.name!
                                                    : item!.name!,
                                                style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeDefault,
                                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),

                                            (!isStore &&
                                                    Get.find<SplashController>()
                                                        .configModel!
                                                        .moduleConfig!
                                                        .module!
                                                        .vegNonVeg! &&
                                                    Get.find<SplashController>()
                                                        .configModel!
                                                        .toggleVegNonVeg! &&
                                                    !((Get.find<SplashController>().module?.moduleName?.toLowerCase().contains('meat') ?? false) ||
                                                        (Get.find<SplashController>().module?.moduleName?.toLowerCase().contains('fish') ?? false) ||
                                                        (Get.find<SplashController>().module?.moduleType?.toLowerCase() == 'meat')))
                                                ? CustomAssetImageWidget(
                                                    item != null &&
                                                            item!.veg == 0
                                                        ? Images.nonVegImage
                                                        : Images.vegImage,
                                                    height: 10,
                                                    width: 10,
                                                    fit: BoxFit.contain,
                                                  )
                                                : const SizedBox(),

                                            (Get.find<SplashController>()
                                                        .configModel!
                                                        .moduleConfig!
                                                        .module!
                                                        .unit! &&
                                                    item != null &&
                                                    item!.unitType != null)
                                                ? Text(
                                                    '(${item!.unitType ?? ''})',
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Theme.of(
                                                        context,
                                                      ).hintColor,
                                                    ),
                                                  )
                                                : const SizedBox(),

                                            SizedBox(
                                              width:
                                                  item!.isStoreHalalActive! &&
                                                      item!.isHalalItem!
                                                  ? Dimensions
                                                        .paddingSizeExtraSmall
                                                  : 0,
                                            ),

                                            !isStore &&
                                                    item!.isStoreHalalActive! &&
                                                    item!.isHalalItem!
                                                ? const CustomAssetImageWidget(
                                                    Images.halalTag,
                                                    height: 13,
                                                    width: 13,
                                                  )
                                                : const SizedBox(),

                                            SizedBox(
                                              width:
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  )
                                                  ? 20
                                                  : 0,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),

                                        inStore
                                            ? const SizedBox()
                                            : (isStore
                                                  ? store!.address != null
                                                  : item!.storeName != null)
                                            ? Text(
                                                isStore
                                                    ? store!.address ?? ''
                                                    : item!.storeName ?? '',
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeExtraSmall,
                                                  color: Theme.of(
                                                    context,
                                                  ).disabledColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : const SizedBox(),

                                        (genericName.isNotEmpty)
                                            ? Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5.0,
                                                      ),
                                                  child: Text(
                                                    genericName,
                                                    style: robotoMedium
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(
                                                            context,
                                                          ).disabledColor,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        SizedBox(
                                          height:
                                              ((desktop || isStore) &&
                                                  (isStore
                                                      ? store!.address != null
                                                      : item!.storeName !=
                                                            null))
                                              ? 3
                                              : 3,
                                        ),

                                        !isStore && (item!.ratingCount! > 0)
                                            ? Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    item!.avgRating!
                                                        .toStringAsFixed(1),
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    '(${item!.ratingCount})',
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(
                                                            context,
                                                          ).hintColor,
                                                        ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(),

                                        SizedBox(
                                          height:
                                              (!isStore && desktop) ||
                                                  (!isStore &&
                                                      (item!.ratingCount! > 0))
                                              ? 3
                                              : 0,
                                        ),

                                        isStore &&
                                                (store != null &&
                                                    store!.ratingCount! > 0)
                                            ? Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    store!.avgRating!
                                                        .toStringAsFixed(1),
                                                    style: robotoBold,
                                                  ),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Text(
                                                    '(${store!.ratingCount})',
                                                    style: robotoRegular
                                                        .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Theme.of(
                                                            context,
                                                          ).hintColor,
                                                        ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                      item!.price,
                                                      discount: discount,
                                                      discountType:
                                                          discountType,
                                                    ),
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                    textDirection:
                                                        TextDirection.ltr,
                                                  ),
                                                  SizedBox(
                                                    width: discount! > 0
                                                        ? Dimensions
                                                              .paddingSizeExtraSmall
                                                        : 0,
                                                  ),

                                                  discount > 0
                                                      ? Text(
                                                          PriceConverter.convertPrice(
                                                            item!.price,
                                                          ),
                                                          style: robotoMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraSmall,
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          ),
                                                          textDirection:
                                                              TextDirection.ltr,
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    mainAxisAlignment: isStore
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(),

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
                // height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
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
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                                      child: CustomImage(
                                        isHovered: hovered,
                                        image: '${isStore ? store != null ? store!.logoFullUrl : '' : item!.imageFullUrl}',
                                        height: imageHeight ?? (desktop ? 140 : 140),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
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

                                 if (item!.avgRating! > 0)
                                 Positioned(
                                   bottom: 8,
                                   left: 8,
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(6),
                                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(Icons.star, size: 12, color: Theme.of(context).primaryColor),
                                         const SizedBox(width: 2),
                                         Text(
                                           item!.avgRating!.toStringAsFixed(1),
                                           style: robotoBold.copyWith(fontSize: 10, color: Colors.black87),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                              ],
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          isStore ? store!.name! : item!.name!,
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),

                                (genericName.isNotEmpty)
                                    ? Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 5.0,
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: Text(
                                            genericName,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                SizedBox(
                                  height:
                                      ((desktop || isStore) &&
                                          (isStore
                                              ? store!.address != null
                                              : item!.storeName != null))
                                      ? 3
                                      : 3,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            PriceConverter.convertPrice(item!.price, discount: discount, discountType: discountType),
                                            style: robotoBold.copyWith(fontSize: 16, color: Colors.black),
                                            textDirection: TextDirection.ltr,
                                          ),
                                          if (discount! > 0)
                                            Text(
                                              PriceConverter.convertPrice(item!.price),
                                              style: robotoRegular.copyWith(
                                                fontSize: Dimensions.fontSizeExtraSmall,
                                                color: Theme.of(context).disabledColor,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                              textDirection: TextDirection.ltr,
                                            ),
                                        ],
                                      ),
                                      
                                      if (!isStore && !fromCartSuggestion)
                                      CartCountViewStore(
                                        item: item!,
                                        index: index,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (fromCartSuggestion)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Center(
                                  child: CartCountView(
                                    item: item!,
                                    index: index,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'Add',
                                        style: robotoBold.copyWith(color: Colors.deepOrange, fontSize: Dimensions.fontSizeSmall),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
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
    );
  }
}
