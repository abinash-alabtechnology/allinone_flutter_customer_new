import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
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
    bool isVeg = item.veg == 1;

    return OnHover(
      isItem: true,
      child: Container(
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
                        Container(
                          margin: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                            border: Border.all(color: Colors.grey.shade100, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
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

                        if (isFood && item.veg != null)
                          Positioned(
                            top: 8.h,
                            left: 8.w,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                              child: Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                  shape: BoxShape.circle,
                                ),
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

                        OrganicTag(item: item, placeInImage: false),

                        (item.stock != null && item.stock! <= 0)
                            ? Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'out_of_stock'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).cardColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),

                        isShop
                            ? const SizedBox()
                            : Positioned(
                                bottom: 8.h,
                                right: 8.w,
                                child: CartCountViewGrocery(
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
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                PriceConverter.convertPrice(
                                  Get.find<ItemController>().getStartingPrice(item),
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
                                Center(child: Text(
                                  PriceConverter.convertPrice(
                                    Get.find<ItemController>().getStartingPrice(item),
                                  ),
                                  style: robotoMedium.copyWith(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
                                  ),
                                  textAlign: TextAlign.center,
                                ),),
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

                          Text(
                            item.name ?? '',
                            style: robotoMedium.copyWith(
                              fontSize: 11.sp,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null)
                            Text(
                              item.unitType ?? '1 unit',
                              style: robotoRegular.copyWith(
                                fontSize: 9.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),

                          Row(
                            children: [
                              ...List.generate(5, (starIdx) {
                                int filled = item.avgRating?.round() ?? 5;
                                return Icon(
                                  Icons.star,
                                  size: 10.sp,
                                  color: starIdx < filled ? Colors.amber : Colors.grey.shade300,
                                );
                              }),
                              SizedBox(width: 4.w),
                              Text(
                                item.ratingCount != null && item.ratingCount! > 0
                                    ? '(${item.ratingCount})'
                                    : '(12,280)',
                                style: robotoRegular.copyWith(
                                  fontSize: 8.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                size: 10.sp,
                                color: Colors.grey.shade500,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${((item.id ?? index ?? 1) % 2 == 0) ? 15 : 30} mins',
                                style: robotoMedium.copyWith(
                                  fontSize: 9.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (item.stock != null && item.stock! <= 5 && item.stock! > 0)
                                Container(
                                  margin: EdgeInsets.only(left: 6.w),
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(color: Colors.red.shade200, width: 0.5),
                                  ),
                                  child: Text(
                                    '${item.stock} left',
                                    style: robotoBold.copyWith(
                                      fontSize: 7.sp,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
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
    bool isVeg = item.veg == 1;

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
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
          child: OnHover(
            isItem: true,
            child: Container(
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
                              Container(
                                margin: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  border: Border.all(color: Colors.grey.shade100, width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
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

                              if (isFood && item.veg != null)
                                Positioned(
                                  top: 8.h,
                                  left: 8.w,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                    child: Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        shape: BoxShape.circle,
                                      ),
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

                              OrganicTag(item: item, placeInImage: false),

                              (item.stock != null && item.stock! <= 0)
                                  ? Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'out_of_stock'.tr,
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(context).cardColor,
                                              fontSize: Dimensions.fontSizeSmall,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),

                              isShop
                                  ? const SizedBox()
                                  : Positioned(
                                      bottom: 8.h,
                                      right: 8.w,
                                      child: CartCountViewGrocery(
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
                          flex: 6,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>().getStartingPrice(item),
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
                                      Text(
                                        PriceConverter.convertPrice(
                                          Get.find<ItemController>().getStartingPrice(item),
                                        ),
                                        style: robotoMedium.copyWith(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
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

                                Text(
                                  item.name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                if (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null)
                                  Text(
                                    item.unitType ?? '1 unit',
                                    style: robotoRegular.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                Row(
                                  children: [
                                    ...List.generate(5, (starIdx) {
                                      int filled = item.avgRating?.round() ?? 5;
                                      return Icon(
                                        Icons.star,
                                        size: 10.sp,
                                        color: starIdx < filled ? Colors.amber : Colors.grey.shade300,
                                      );
                                    }),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item.ratingCount != null && item.ratingCount! > 0
                                          ? '(${item.ratingCount})'
                                          : '(12,280)',
                                      style: robotoRegular.copyWith(
                                        fontSize: 8.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      size: 10.sp,
                                      color: Colors.grey.shade50,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '${((item.id ?? index ?? 1) % 2 == 0) ? 15 : 30} mins',
                                      style: robotoMedium.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (item.stock != null && item.stock! <= 5 && item.stock! > 0)
                                      Container(
                                        margin: EdgeInsets.only(left: 6.w),
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4.r),
                                          border: Border.all(color: Colors.red.shade200, width: 0.5),
                                        ),
                                        child: Text(
                                          '${item.stock} left',
                                          style: robotoBold.copyWith(
                                            fontSize: 7.sp,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
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
          ),
        ),
      ),
    );
  }
}

class CartCountViewSubscription extends StatelessWidget {
  final Item item;
  final int? index;
  const CartCountViewSubscription({super.key, required this.item, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      Color themeBlue = Colors.blue.shade700;
      
      return cartQty != 0 ? Center(
        child: Container(
          width: 89.w,
          decoration: BoxDecoration(
            color: themeBlue,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                } else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBlue),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: themeBlue,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 1.5))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBlue),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: themeBlue,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                height: 30,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBlue),
                  color: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: SizedBox(
                    height: 14.h,
                    width: 14.w,
                    child: CircularProgressIndicator(color: themeBlue, strokeWidth: 2),
                  ),
                ),
              )
            : Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBlue),
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                    child: Text("ADD", style: robotoBold.copyWith(
                      fontSize: 11.sp,
                      color: themeBlue,
                    )),
                  ),
                ),
              ),
      );
    });
  }
}

class CartCountViewTrending extends StatelessWidget {
  final Item item;
  final int? index;
  const CartCountViewTrending({super.key, required this.item, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      Color themeOrange = Colors.orange.shade800;

      return cartQty != 0 ? Center(
        child: Container(
          width: 89.w,
          decoration: BoxDecoration(
            color: themeOrange,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                } else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeOrange),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: themeOrange,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 1.5))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeOrange),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: themeOrange,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                height: 30,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeOrange),
                  color: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: SizedBox(
                    height: 14.h,
                    width: 14.w,
                    child: CircularProgressIndicator(color: themeOrange, strokeWidth: 2),
                  ),
                ),
              )
            : Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeOrange),
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                    child: Text("ADD", style: robotoBold.copyWith(
                      fontSize: 11.sp,
                      color: themeOrange,
                    )),
                  ),
                ),
              ),
      );
    });
  }
}

class CartCountViewSpecial extends StatelessWidget {
  final Item item;
  final int? index;
  const CartCountViewSpecial({super.key, required this.item, this.index = -1});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(item.id!);
      int cartIndex = cartController.isExistInCart(item.id, cartController.cartVariant(item.id!), false, null);
      Color themeBrown = Colors.brown.shade700;

      return cartQty != 0 ? Center(
        child: Container(
          width: 89.w,
          decoration: BoxDecoration(
            color: themeBrown,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartController.isLoading ? null : () {
                if (cartController.cartList[cartIndex].quantity! > 1) {
                  cartController.setDirectlyAddToCartIndex(index);
                  cartController.setQuantity(false, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].item!.quantityLimit);
                } else {
                  cartController.removeFromCart(cartIndex);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBrown),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16.h, color: themeBrown,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: cartController.isLoading && cartController.loadingItemId == item.id
                  ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator(color: Theme.of(context).cardColor, strokeWidth: 1.5))
                  : Text(cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) ,
            ),

            InkWell(
              onTap: cartController.isLoading ? null : () {
                cartController.setDirectlyAddToCartIndex(index);
                cartController.setQuantity(true, cartIndex, cartController.cartList[cartIndex].stock, cartController.cartList[cartIndex].quantityLimit);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBrown),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: themeBrown,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: cartController.isLoading ? null : () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: cartController.isLoading && cartController.loadingItemId == item.id
            ? Container(
                height: 30,
                width: 50.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBrown),
                  color: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: SizedBox(
                    height: 14.h,
                    width: 14.w,
                    child: CircularProgressIndicator(color: themeBrown, strokeWidth: 2),
                  ),
                ),
              )
            : Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: themeBrown),
                  color: Theme.of(context).cardColor,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                    child: Text("ADD", style: robotoBold.copyWith(
                      fontSize: 11.sp,
                      color: themeBrown,
                    )),
                  ),
                ),
              ),
      );
    });
  }
}

class FreshItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const FreshItemCard({
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
    bool isVeg = item.veg == 1;

    final bool outOfStock = item.stock != null && item.stock! <= 0;
    final bool available = Get.find<ItemController>().isAvailable(item);
    final bool isDisabled = !available || (!isFood && outOfStock);

    return IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: !isDisabled ? 1.0 : 0.55,
        child: OnHover(
          isItem: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(color: Colors.green.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade500.withOpacity(0.07),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomInkWell(
              onTap: () =>
                  Get.find<ItemController>().navigateToItemPage(item, context),
              radius: 16,
              child: TextHover(
                builder: (isHovered) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── IMAGE ────────────────────────────────────
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
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

                            // Gradient overlay
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.5, 1.0],
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Veg dot (food only)
                            if (isFood && item.veg != null)
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: isVeg
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                  child: Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                      color: isVeg
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),

                            // Discount badge
                            if (discount != null && discount > 0)
                              Positioned(
                                top: (isFood && item.veg != null) ? 26.h : 8.h,
                                left: 8.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Text(
                                    discountType == 'amount'
                                        ? '₹${discount.toStringAsFixed(0)} OFF'
                                        : '${discount.toStringAsFixed(0)}% OFF',
                                    style: robotoBold.copyWith(
                                      fontSize: 8.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            // Wishlist
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: AddFavouriteView(item: item),
                            ),

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

                            OrganicTag(item: item, placeInImage: false),

                            if (outOfStock)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Container(
                                    color: Colors.black54.withValues(alpha: 0.5),
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          'out_of_stock'.tr,
                                          style: robotoBold.copyWith(
                                            color: Colors.red.shade700,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            isShop
                                ? const SizedBox()
                                : Positioned(
                                    bottom: 6.h,
                                    right: 6.w,
                                    child: CartCountViewGreen(
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

                      // ── TEXT ─────────────────────────────────────
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(9.w, 7.h, 9.w, 6.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Price
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    PriceConverter.convertPrice(
                                      Get.find<ItemController>()
                                          .getStartingPrice(item),
                                      discount: discount,
                                      discountType: discountType,
                                    ),
                                    style: robotoBold.copyWith(
                                      fontSize: 14.sp,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                  if (discount != null && discount > 0) ...[
                                    SizedBox(width: 4.w),
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>()
                                            .getStartingPrice(item),
                                      ),
                                      style: robotoMedium.copyWith(
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade400,
                                        decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),

                              // Name
                              Text(
                                item.name ?? '',
                                style: robotoMedium.copyWith(
                                  fontSize: 12.sp,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Unit
                              if (Get.find<SplashController>()
                                      .configModel!
                                      .moduleConfig!
                                      .module!
                                      .unit! &&
                                  item.unitType != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    item.unitType ?? '',
                                    style: robotoRegular.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),

                              // Rating + time
                              Row(
                                children: [
                                  Icon(Icons.star_rounded,
                                      size: 11.sp,
                                      color: Colors.green.shade600),
                                  SizedBox(width: 2.w),
                                  Text(
                                    item.ratingCount != null &&
                                            item.ratingCount! > 0
                                        ? '${item.avgRating?.toStringAsFixed(1) ?? "4.5"}'
                                        : '4.5',
                                    style: robotoBold.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.access_time_rounded,
                                      size: 10.sp,
                                      color: Colors.grey.shade400),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '${((item.id ?? index ?? 1) % 2 == 0) ? 15 : 30}m',
                                    style: robotoRegular.copyWith(
                                      fontSize: 8.5.sp,
                                      color: Colors.grey.shade500,
                                    ),
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
        ),
      ),
    );
  }
}


class SubscriptionItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const SubscriptionItemCard({
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
    bool isVeg = item.veg == 1;

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
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
          child: OnHover(
            isItem: true,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.blue.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade500.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ],
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
                              Container(
                                margin: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  border: Border.all(color: Colors.blue.shade50, width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
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

                              // Veg/Non-veg Dot
                              if (isFood && item.veg != null)
                                Positioned(
                                  top: 8.h,
                                  left: 8.w,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                    child: Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),



                              // Wishlist
                              Positioned(
                                top: 32.h,
                                right: 8.w,
                                child: AddFavouriteView(item: item),
                              ),

                              item.isStoreHalalActive! && item.isHalalItem!
                                  ? const Positioned(
                                      top: 64,
                                      right: 15,
                                      child: CustomAssetImageWidget(
                                        Images.halalTag,
                                        height: 20,
                                        width: 20,
                                      ),
                                    )
                                  : const SizedBox(),

                              OrganicTag(item: item, placeInImage: false),

                              if (outOfStock)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'out_of_stock'.tr,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).cardColor,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              isShop
                                  ? const SizedBox()
                                  : Positioned(
                                      bottom: 8.h,
                                      right: 8.w,
                                      child: CartCountViewSubscription(
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
                          flex: 6,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>().getStartingPrice(item),
                                        discount: discount,
                                        discountType: discountType,
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: 13.sp,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    if (discount != null && discount > 0) ...[
                                      SizedBox(width: 4.w),
                                      Text(
                                        PriceConverter.convertPrice(
                                          Get.find<ItemController>().getStartingPrice(item),
                                        ),
                                        style: robotoMedium.copyWith(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
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
                                        : '${discount.toStringAsFixed(0)}% OFF ON PLAN',
                                    style: robotoBold.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),

                                Text(
                                  item.name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                if (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      item.unitType ?? '1 unit',
                                      style: robotoRegular.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),

                                Row(
                                  children: [
                                    ...List.generate(5, (starIdx) {
                                      int filled = item.avgRating?.round() ?? 5;
                                      return Icon(
                                        Icons.star,
                                        size: 10.sp,
                                        color: starIdx < filled ? Colors.blue.shade600 : Colors.grey.shade300,
                                      );
                                    }),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item.ratingCount != null && item.ratingCount! > 0
                                          ? '(${item.ratingCount})'
                                          : '(8,510)',
                                      style: robotoRegular.copyWith(
                                        fontSize: 8.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 10.sp,
                                      color: Colors.blue.shade600,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Daily / Custom',
                                      style: robotoMedium.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (item.stock != null && item.stock! <= 5 && item.stock! > 0)
                                      Container(
                                        margin: EdgeInsets.only(left: 6.w),
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4.r),
                                          border: Border.all(color: Colors.red.shade200, width: 0.5),
                                        ),
                                        child: Text(
                                          '${item.stock} left',
                                          style: robotoBold.copyWith(
                                            fontSize: 7.sp,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
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
          ),
        ),
      ),
    );
  }
}

class TrendingItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const TrendingItemCard({
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
    bool isVeg = item.veg == 1;

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
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
          child: OnHover(
            isItem: true,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.orange.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade500.withOpacity(0.06),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ],
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
                              Container(
                                margin: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  border: Border.all(color: Colors.orange.shade50, width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
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

                              // Veg/Non-veg Dot
                              if (isFood && item.veg != null)
                                Positioned(
                                  top: 8.h,
                                  left: 8.w,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                    child: Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),



                              // Wishlist
                              Positioned(
                                top: 32.h,
                                right: 8.w,
                                child: AddFavouriteView(item: item),
                              ),

                              item.isStoreHalalActive! && item.isHalalItem!
                                  ? const Positioned(
                                      top: 64,
                                      right: 15,
                                      child: CustomAssetImageWidget(
                                        Images.halalTag,
                                        height: 20,
                                        width: 20,
                                      ),
                                    )
                                  : const SizedBox(),

                              OrganicTag(item: item, placeInImage: false),

                              if (outOfStock)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'out_of_stock'.tr,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).cardColor,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              isShop
                                  ? const SizedBox()
                                  : Positioned(
                                      bottom: 8.h,
                                      right: 8.w,
                                      child: CartCountViewTrending(
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
                          flex: 6,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>().getStartingPrice(item),
                                        discount: discount,
                                        discountType: discountType,
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: 13.sp,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    if (discount != null && discount > 0) ...[
                                      SizedBox(width: 4.w),
                                      Text(
                                        PriceConverter.convertPrice(
                                          Get.find<ItemController>().getStartingPrice(item),
                                        ),
                                        style: robotoMedium.copyWith(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
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
                                        : '${discount.toStringAsFixed(0)}% OFF',
                                    style: robotoBold.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),

                                Text(
                                  item.name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                if (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      item.unitType ?? '1 unit',
                                      style: robotoRegular.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),

                                Row(
                                  children: [
                                    ...List.generate(5, (starIdx) {
                                      int filled = item.avgRating?.round() ?? 5;
                                      return Icon(
                                        Icons.star,
                                        size: 10.sp,
                                        color: starIdx < filled ? Colors.amber : Colors.grey.shade300,
                                      );
                                    }),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item.ratingCount != null && item.ratingCount! > 0
                                          ? '(${item.ratingCount})'
                                          : '(14,830)',
                                      style: robotoRegular.copyWith(
                                        fontSize: 8.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.flash_on_rounded,
                                      size: 10.sp,
                                      color: Colors.orange.shade800,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '${((item.id ?? index ?? 1) % 2 == 0) ? 10 : 20} mins',
                                      style: robotoMedium.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (item.stock != null && item.stock! <= 5 && item.stock! > 0)
                                      Container(
                                        margin: EdgeInsets.only(left: 6.w),
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4.r),
                                          border: Border.all(color: Colors.red.shade200, width: 0.5),
                                        ),
                                        child: Text(
                                          '${item.stock} left',
                                          style: robotoBold.copyWith(
                                            fontSize: 7.sp,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
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
          ),
        ),
      ),
    );
  }
}

class SpecialOfferItemCard extends StatelessWidget {
  final Item item;
  final bool isPopularItem;
  final bool isFood;
  final bool isShop;
  final bool isPopularItemCart;
  final int? index;

  const SpecialOfferItemCard({
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
    bool isVeg = item.veg == 1;

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
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
          child: OnHover(
            isItem: true,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.brown.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.shade500.withOpacity(0.06),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ],
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
                              Container(
                                margin: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade50.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                  border: Border.all(color: Colors.brown.shade50, width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
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

                              // Veg/Non-veg Dot
                              if (isFood && item.veg != null)
                                Positioned(
                                  top: 8.h,
                                  left: 8.w,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                    child: Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        color: isVeg ? Colors.green.shade600 : Colors.red.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),



                              // Wishlist
                              Positioned(
                                top: 32.h,
                                right: 8.w,
                                child: AddFavouriteView(item: item),
                              ),

                              item.isStoreHalalActive! && item.isHalalItem!
                                  ? const Positioned(
                                      top: 64,
                                      right: 15,
                                      child: CustomAssetImageWidget(
                                        Images.halalTag,
                                        height: 20,
                                        width: 20,
                                      ),
                                    )
                                  : const SizedBox(),

                              OrganicTag(item: item, placeInImage: false),

                              if (outOfStock)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'out_of_stock'.tr,
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).cardColor,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              isShop
                                  ? const SizedBox()
                                  : Positioned(
                                      bottom: 8.h,
                                      right: 8.w,
                                      child: CartCountViewSpecial(
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
                          flex: 6,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>().getStartingPrice(item),
                                        discount: discount,
                                        discountType: discountType,
                                      ),
                                      style: robotoBold.copyWith(
                                        fontSize: 13.sp,
                                        color: Colors.brown.shade900,
                                      ),
                                    ),
                                    if (discount != null && discount > 0) ...[
                                      SizedBox(width: 4.w),
                                      Text(
                                        PriceConverter.convertPrice(
                                          Get.find<ItemController>().getStartingPrice(item),
                                        ),
                                        style: robotoMedium.copyWith(
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
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
                                        : '${discount.toStringAsFixed(0)}% OFF',
                                    style: robotoBold.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),

                                Text(
                                  item.name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                if (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: Colors.brown.shade50,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      item.unitType ?? '1 unit',
                                      style: robotoRegular.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.brown.shade800,
                                      ),
                                    ),
                                  ),

                                Row(
                                  children: [
                                    ...List.generate(5, (starIdx) {
                                      int filled = item.avgRating?.round() ?? 5;
                                      return Icon(
                                        Icons.star,
                                        size: 10.sp,
                                        color: starIdx < filled ? Colors.brown.shade600 : Colors.grey.shade300,
                                      );
                                    }),
                                    SizedBox(width: 4.w),
                                    Text(
                                      item.ratingCount != null && item.ratingCount! > 0
                                          ? '(${item.ratingCount})'
                                          : '(6,420)',
                                      style: robotoRegular.copyWith(
                                        fontSize: 8.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_cafe_rounded,
                                      size: 10.sp,
                                      color: Colors.brown.shade700,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      '${((item.id ?? index ?? 1) % 2 == 0) ? 15 : 25} mins',
                                      style: robotoMedium.copyWith(
                                        fontSize: 9.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (item.stock != null && item.stock! <= 5 && item.stock! > 0)
                                      Container(
                                        margin: EdgeInsets.only(left: 6.w),
                                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4.r),
                                          border: Border.all(color: Colors.red.shade200, width: 0.5),
                                        ),
                                        child: Text(
                                          '${item.stock} left',
                                          style: robotoBold.copyWith(
                                            fontSize: 7.sp,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
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
          ),
        ),
      ),
    );
  }
}
