import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/add_favourite_view.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/discount_tag.dart';
import 'package:handy_allinone/common/widgets/hover/on_hover.dart';
import 'package:handy_allinone/common/widgets/not_available_widget.dart';
import 'package:handy_allinone/common/widgets/organic_tag.dart';
import 'package:handy_allinone/common/widgets/subscription_tag.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const ItemCard({
    super.key,
    required this.item,
    this.isPopularItem = false,
    required this.isFood,
    required this.isShop,
    this.isPopularItemCart = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;

    return OnHover(
      isItem: true,
      child: Stack(
        children: [
          Container(
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor,
            ),
            child: CustomInkWell(
              onTap: () =>
                  Get.find<ItemController>().navigateToItemPage(item, context),
              radius: Dimensions.radiusLarge,
              child: TextHover(
                builder: (isHovered) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: isPopularItem
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0,
                                left: isPopularItem
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0,
                                right: isPopularItem
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                  topRight: const Radius.circular(
                                    Dimensions.radiusLarge,
                                  ),
                                  bottomLeft: Radius.circular(
                                    isPopularItem ? Dimensions.radiusLarge : 0,
                                  ),
                                  bottomRight: Radius.circular(
                                    isPopularItem ? Dimensions.radiusLarge : 0,
                                  ),
                                ),
                                child: CustomImage(
                                  isHovered: isHovered,
                                  placeholder: Images.placeholder,
                                  image: '${item.imageFullUrl}',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),

                            AddFavouriteView(item: item),

                            item.isStoreHalalActive! && item.isHalalItem!
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

                            DiscountTag(
                              discount: discount,
                              discountType: discountType,
                              freeDelivery: false,
                            ),

                            OrganicTag(item: item, placeInImage: false),

                            (item.stock != null && item.stock! < 0)
                                ? Positioned(
                                    bottom: 10,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.5),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(
                                            Dimensions.radiusLarge,
                                          ),
                                          bottomRight: Radius.circular(
                                            Dimensions.radiusLarge,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'out_of_stock'.tr,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).cardColor,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            isShop
                                ? const SizedBox()
                                : Positioned(
                                    bottom: 10,
                                    right: 20,
                                    child: CartCountView(
                                      item: item,
                                      index: index,
                                    ),
                                  ),

                            Get.find<ItemController>().isAvailable(item)
                                ? const SizedBox()
                                : NotAvailableWidget(
                                    radius: Dimensions.radiusLarge,
                                    isAllSideRound: isPopularItem,
                                  ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: Dimensions.paddingSizeSmall,
                            right: isShop ? 0 : Dimensions.paddingSizeSmall,
                            top: Dimensions.paddingSizeSmall,
                            bottom: isShop ? 0 : Dimensions.paddingSizeSmall,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: isPopularItem
                                    ? Alignment.center
                                    : Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: isPopularItem
                                      ? CrossAxisAlignment.center
                                      : CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    (isFood || isShop)
                                        ? Text(
                                            item.storeName ?? '',
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                            ),
                                          )
                                        : Text(
                                            item.name ?? '',
                                            style: robotoBold,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                    item.isSubscription! ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      ),
                                      child: Text(
                                        'subscription'.tr,
                                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
                                      ),
                                    ) : const SizedBox(),

                                    (isFood || isShop)
                                        ? Flexible(
                                            child: Text(
                                              item.name ?? '',
                                              style: robotoBold,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : item.ratingCount! > 0
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
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),

                                              Text(
                                                item.avgRating!.toStringAsFixed(
                                                  1,
                                                ),
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),

                                              Text(
                                                "(${item.ratingCount})",
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(
                                                    context,
                                                  ).disabledColor,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),

                                    // showUnitOrRattings(context);
                                    (isFood || isShop)
                                        ? item.ratingCount! > 0
                                              ? Row(
                                                  mainAxisAlignment:
                                                      isPopularItem
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
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Text(
                                                      item.avgRating!
                                                          .toStringAsFixed(1),
                                                      style: robotoRegular
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Text(
                                                      "(${item.ratingCount})",
                                                      style: robotoRegular
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox()
                                        : (Get.find<SplashController>()
                                                  .configModel!
                                                  .moduleConfig!
                                                  .module!
                                                  .unit! &&
                                              item.unitType != null)
                                        ? Text(
                                            '(${item.unitType ?? ''})',
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraSmall,
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          )
                                        : const SizedBox(),

                                    discount != null && discount > 0
                                        ? Text(
                                            PriceConverter.convertPrice(
                                              Get.find<ItemController>()
                                                  .getStartingPrice(item),
                                            ),
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraSmall,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              height: 1.0,
                                            ),
                                            textDirection: TextDirection.ltr,
                                          )
                                        : const SizedBox(),

                                    // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>()
                                            .getStartingPrice(item),
                                        discount: discount,
                                        discountType: discountType,
                                      ),
                                      textDirection: TextDirection.ltr,
                                      style: robotoMedium,
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
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                    Dimensions.radiusLarge,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    Dimensions.radiusLarge,
                                                  ),
                                                ),
                                          ),
                                          child: Icon(
                                            isPopularItemCart
                                                ? Icons.add_shopping_cart
                                                : Icons.add,
                                            color: Theme.of(context).cardColor,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
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
        ],
      ),
    );
  }
}

class MostSellItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const MostSellItemCard({
    super.key,
    required this.item,
    this.isPopularItem = false,
    required this.isFood,
    required this.isShop,
    this.isPopularItemCart = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;
    bool isOutOfStock(Item item) {
      return item.stock != null && item.stock! <= 0;
    }

    bool isItemAvailable(Item item) {
      return Get.find<ItemController>().isAvailable(item);
    }

    final bool outOfStock = isOutOfStock(item);
    final bool available = isItemAvailable(item);
    final bool isDisabled = !available || (!isFood && outOfStock);

    return IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: !isDisabled ? 1.0 : 0.55,
        child: ColorFiltered(
          colorFilter: !isDisabled
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
          child: OnHover(
            isItem: true,
            child: Stack(
              children: [
                Container(
                  width: 120.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    color: isFood
                        ? Colors.transparent
                        : Theme.of(context).cardColor,
                  ),
                  child: CustomInkWell(
                    onTap: () => Get.find<ItemController>()
                        .navigateToItemPage(item, context),
                    radius: Dimensions.radiusLarge,
                    child: TextHover(
                      builder: (isHovered) {
                        return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: isPopularItem
                                        ? Dimensions.paddingSizeExtraSmall
                                        : 0,
                                    left: isPopularItem
                                        ? Dimensions.paddingSizeExtraSmall
                                        : 0,
                                    right: isPopularItem
                                        ? Dimensions.paddingSizeExtraSmall
                                        : 0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(
                                        Dimensions.radiusLarge,
                                      ),
                                      topRight: const Radius.circular(
                                        Dimensions.radiusLarge,
                                      ),
                                      bottomLeft: Radius.circular(
                                        isPopularItem
                                            ? Dimensions.radiusLarge
                                            : 0,
                                      ),
                                      bottomRight: Radius.circular(
                                        isPopularItem
                                            ? Dimensions.radiusLarge
                                            : 0,
                                      ),
                                    ),
                                    child: CustomImage(
                                      isHovered: isHovered,
                                      placeholder: Images.placeholder,
                                      image: '${item.imageFullUrl}',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),

                                AddFavouriteView(item: item),

                                item.isStoreHalalActive! && item.isHalalItem!
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

                                // DiscountTag(
                                //   discount: discount,
                                //   discountType: discountType,
                                //   freeDelivery: false,
                                // ),

                                // OrganicTag(item: item, placeInImage: false),
                                isShop
                                    ? const SizedBox()
                                    : Positioned(
                                        bottom: 10.h,
                                        right: 10.w,
                                        child: CartCountViewGrocery(
                                          item: item,
                                          index: index,
                                        ),
                                      ),
                                (item.stock != null && item.stock! < 0)
                                    ? Positioned.fill(
                                        bottom: 0,
                                        left: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54.withValues(
                                              alpha: 0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusLarge,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'out_of_stock'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                Get.find<ItemController>().isAvailable(item)
                                    ? const SizedBox()
                                    : NotAvailableWidget(
                                        radius: Dimensions.radiusLarge,
                                        isAllSideRound: isPopularItem,
                                      ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall,
                                right: isShop ? 0 : Dimensions.paddingSizeSmall,
                                top: Dimensions.paddingSizeSmall,
                                bottom: isShop
                                    ? 0
                                    : Dimensions.paddingSizeSmall,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Align(
                                    alignment: isPopularItem
                                        ? Alignment.center
                                        : Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      mainAxisAlignment: .start,
                                      children: [
                                        // (isFood || isShop) ? Text(item.storeName ?? '', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor))
                                        //     : Text(item.name ?? '', style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Row(
                                          mainAxisAlignment: .start,
                                          crossAxisAlignment: .start,
                                          children: [
                                            (Get.find<SplashController>()
                                                        .configModel!
                                                        .moduleConfig!
                                                        .module!
                                                        .unit! &&
                                                    item.unitType != null)
                                                ? Flexible(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6.r,
                                                          ),
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8.0,
                                                            vertical: 4,
                                                          ),
                                                      child: Text(
                                                        '${item.unitType ?? ''}',
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeExtraSmall,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                : const SizedBox(),
                                            if (!isFood) SizedBox(width: 10.w),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5.r),
                                                color: Colors.green.withValues(
                                                  alpha: 0.1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 4,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      size: 12.sp,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      '15 Mins',
                                                      style: robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeExtraSmall,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (!isFood) SizedBox(height: 8.h),
                                        Text(
                                          item.name ?? '',
                                          style: robotoBold.copyWith(
                                            fontSize: 11.sp,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        item.isSubscription! ? Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          ),
                                          child: Text(
                                            'subscription'.tr,
                                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
                                          ),
                                        ) : const SizedBox(),
                                        SizedBox(height: 8.h),

                                        // (isFood || isShop) ? Flexible(
                                        //   child: Text(
                                        //     item.name ?? '',
                                        //     style: robotoBold.copyWith(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                        //   ),
                                        // ) : item.ratingCount! > 0 ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                                        //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                        //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        //
                                        // Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                        // const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                        //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                        // ]) : const SizedBox(),

                                        // showUnitOrRattings(context);
                                        // (isFood || isShop) ? item.ratingCount! > 0 ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                                        //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                        //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        //
                                        //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                        //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        //
                                        //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                        //
                                        // ]) : const SizedBox() :

                                        // discount != null && discount > 0  ? Text(
                                        //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                                        //   style: robotoMedium.copyWith(
                                        //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                        //     decoration: TextDecoration.lineThrough,
                                        //   ), textDirection: TextDirection.ltr,
                                        // ) : const SizedBox(),
                                        // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                        Text(
                                          PriceConverter.convertPrice(
                                            Get.find<ItemController>()
                                                .getStartingPrice(item),
                                            discount: discount,
                                            discountType: discountType,
                                          ),
                                          textDirection: TextDirection.ltr,
                                          style: robotoMedium.copyWith(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        Dimensions.radiusLarge,
                                                      ),
                                                      bottomRight:
                                                          Radius.circular(
                                                            Dimensions
                                                                .radiusLarge,
                                                          ),
                                                    ),
                                              ),
                                              child: Icon(
                                                isPopularItemCart
                                                    ? Icons.add_shopping_cart
                                                    : Icons.add,
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
            ],
          ),
        ),
      ),
    ),
  );
  }
}
