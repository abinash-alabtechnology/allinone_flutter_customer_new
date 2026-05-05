import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/cart/domain/models/cart_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/item_bottom_sheet.dart';
import 'package:handy_allinone/common/widgets/quantity_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../coupon/controllers/coupon_controller.dart';

class CartItemWidget extends StatefulWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  final bool showDivider;
  final bool? fromCheckout;

  const CartItemWidget({
    super.key,
    required this.cart,
    required this.cartIndex,
    required this.isAvailable,
    required this.addOns,
    required this.showDivider,
    this.fromCheckout = false,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget>
    with SingleTickerProviderStateMixin {
  bool showAddonsVariations = false;
  late final SlidableController _slidableController;
  bool _hintShown = false;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSlideHint();
    });
  }

  Future<void> _showSlideHint() async {
    if (_hintShown) return;
    _hintShown = true;

    await Future.delayed(const Duration(milliseconds: 400));
    _slidableController.openEndActionPane();

    await Future.delayed(const Duration(milliseconds: 700));
    _slidableController.close();
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? startingPrice = _calculatePrice(item: widget.cart.item);
    double? endingPrice = _calculatePrice(
      item: widget.cart.item,
      isStartingPrice: false,
    );
    String? variationText = _setupVariationText(cart: widget.cart).$1;
    String addOnText = _setupAddonsText(cart: widget.cart) ?? '';

    int addonCount = widget.cart.addOnIds?.length ?? 0;
    int variationCount = _setupVariationText(cart: widget.cart).$2;

    double? discount = widget.cart.item!.discount;
    String? discountType = widget.cart.item!.discountType;
    String genericName = '';

    if (widget.cart.item!.genericName != null &&
        widget.cart.item!.genericName!.isNotEmpty) {
      for (String name in widget.cart.item!.genericName!) {
        genericName += name;
      }
    }

    bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';

    if (isPharmacy) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(
                image: '${widget.cart.item!.imageFullUrl}',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.cart.item!.name!,
                          style: robotoBold.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      widget.fromCheckout! ? const SizedBox() : IconButton(
                        onPressed: () {
                          Get.find<CartController>().removeFromCart(
                            widget.cartIndex,
                            item: widget.cart.item,
                          );
                        },
                        icon: const Icon(CupertinoIcons.delete, size: 18, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    widget.cart.item!.unitType ?? '',
                    style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType),
                        style: robotoBold.copyWith(fontSize: 16),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: widget.fromCheckout! ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            'x${widget.cart.quantity}',
                            style: robotoBold.copyWith(fontSize: 14, color: Theme.of(context).primaryColor),
                          ),
                        ) : Row(
                          children: [
                            QuantityButtonPharmacy(
                              onTap: () {
                                if (widget.cart.quantity! > 1) {
                                  Get.find<CartController>().setQuantity(false, widget.cartIndex, widget.cart.stock, widget.cart.quantityLimit);
                                } else {
                                  Get.find<CartController>().removeFromCart(widget.cartIndex, item: widget.cart.item);
                                }
                              },
                              isIncrement: false,
                              fromcart: true,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                widget.cart.quantity.toString(),
                                style: robotoBold.copyWith(fontSize: 14),
                              ),
                            ),
                            QuantityButtonPharmacy(
                              onTap: () {
                                Get.find<CartController>().setQuantity(true, widget.cartIndex, widget.cart.stock, widget.cart.quantityLimit);
                              },
                              isIncrement: true,
                              fromcart: true,
                            ),
                          ],
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
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Slidable(
        controller: _slidableController,
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              spacing: 4,
              onPressed: (context) {
                Get.find<CartController>().removeFromCart(
                  widget.cartIndex,
                  item: widget.cart.item,
                );
              },
              backgroundColor: Colors.red.shade900,
              borderRadius: BorderRadius.circular(15),
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
            horizontal: Dimensions.paddingSizeExtraSmall,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomInkWell(
              onTap: (widget.fromCheckout != false) ? () {} : () {
                ResponsiveHelper.isMobile(context)
                    ? showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (con) => ItemBottomSheet(
                          itemId: widget.cart.item!.id!,
                          cartIndex: widget.cartIndex,
                          cart: widget.cart,
                        ),
                      )
                    : showDialog(
                        context: context,
                        builder: (con) => Dialog(
                          child: ItemBottomSheet(
                            itemId: widget.cart.item!.id!,
                            cartIndex: widget.cartIndex,
                            cart: widget.cart,
                          ),
                        ),
                      );
              },
              radius: Dimensions.radiusDefault,
              padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeExtraSmall,
                horizontal: Dimensions.paddingSizeExtraSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: '${widget.cart.item!.imageFullUrl}',
                              height: ResponsiveHelper.isDesktop(context) ? 80 : 70,
                              width: ResponsiveHelper.isDesktop(context) ? 80 : 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          widget.isAvailable
                              ? const SizedBox()
                              : Positioned(
                                  top: 0, left: 0, bottom: 0, right: 0,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      color: Colors.black.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                          (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! &&
                                  Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                              ? Positioned(
                                  top: 5,
                                  right: 5,
                                  child: CustomAssetImageWidget(
                                    widget.cart.item!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                                    height: 11,
                                    width: 11,
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.cart.item!.name!,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              if (widget.cart.item!.unitType != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  ),
                                  child: Text(
                                    widget.cart.item!.unitType!,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Wrap(
                                children: [
                                  Text(
                                    PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType),
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                  if (discount! > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      PriceConverter.convertPrice(startingPrice),
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).disabledColor,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (addOnText.isNotEmpty || variationText!.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      showAddonsVariations = !showAddonsVariations;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        '${variationCount > 0 ? '$variationCount ${'variations'.tr} ' : ''}${addonCount > 0 ? '$addonCount ${'addons'.tr}' : ''}',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                      ),
                                      Icon(
                                        showAddonsVariations ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        size: 16, color: Theme.of(context).disabledColor,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      GetBuilder<CartController>(builder: (cartController) {
                        return Row(
                          children: [
                            QuantityButton3(
                              onTap: () {
                                if (widget.fromCheckout == true && (Get.find<CouponController>().discount ?? 0.0) > 0.0) {
                                  Get.find<CouponController>().removeCouponData(true);
                                }
                                if (widget.cart.quantity! > 1) {
                                  cartController.setQuantity(false, widget.cartIndex, widget.cart.stock, widget.cart.quantityLimit);
                                } else {
                                  cartController.removeFromCart(widget.cartIndex, item: widget.cart.item);
                                }
                              },
                              isIncrement: false,
                              showRemoveIcon: widget.cart.quantity! == 1,
                              fromcart: true,
                            ),
                            Text(widget.cart.quantity.toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                            QuantityButton3(
                              onTap: () {
                                if (widget.fromCheckout == true && (Get.find<CouponController>().discount ?? 0.0) > 0.0) {
                                  Get.find<CouponController>().removeCouponData(true);
                                }
                                cartController.setQuantity(true, widget.cartIndex, widget.cart.stock, widget.cart.quantityLimit);
                              },
                              isIncrement: true,
                              fromcart: true,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  if (showAddonsVariations)
                    Padding(
                      padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? 100 : 70),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (addOnText.isNotEmpty)
                            Text('${'addons'.tr}: $addOnText', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                          if (variationText!.isNotEmpty)
                            Text('${'variations'.tr}: $variationText', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double? _calculatePrice({required Item? item, bool isStartingPrice = true}) {
    double? startingPrice;
    double? endingPrice;
    bool newVariation = Get.find<SplashController>().getModuleConfig(item!.moduleType).newVariation ?? false;

    if (item.variations!.isNotEmpty && !newVariation) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if (priceList[0]! < priceList[priceList.length - 1]!) {
        endingPrice = priceList[priceList.length - 1];
      }
    } else {
      startingPrice = item.price;
    }
    return isStartingPrice ? startingPrice : endingPrice;
  }

  (String?, int) _setupVariationText({required CartModel cart}) {
    String? variationText = '';
    int count = 0;
    if (Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
      if (cart.foodVariations!.isNotEmpty) {
        for (int index = 0; index < cart.foodVariations!.length; index++) {
          if (cart.foodVariations![index].contains(true)) {
            variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![index].name} (';
            for (int i = 0; i < cart.foodVariations![index].length; i++) {
              if (cart.foodVariations![index][i]!) {
                variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![index].variationValues![i].level}';
                count++;
              }
            }
            variationText = '${variationText!})';
          }
        }
      }
    } else {
      if (cart.variation!.isNotEmpty) {
        List<String> variationTypes = cart.variation![0].type!.split('-');
        if (variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText = '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0++;
            count++;
          }
        } else {
          variationText = cart.item!.variations![0].type;
        }
      }
    }
    return (variationText, count);
  }

  String? _setupAddonsText({required CartModel cart}) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.item!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText = '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0++;
      }
    }
    return addOnText;
  }
}
