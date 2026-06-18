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
    if (!mounted) return;
    _slidableController.openEndActionPane();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _slidableController.close();
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? variationText = _setupVariationText(cart: widget.cart).$1;
    String addOnText = _setupAddonsText(cart: widget.cart) ?? '';

    int addonCount = widget.cart.addOnIds?.length ?? 0;
    int variationCount = _setupVariationText(cart: widget.cart).$2;

    double? discount = widget.cart.item!.discount;
    String? discountType = widget.cart.item!.discountType;

    bool isFood = widget.cart.item!.moduleType == 'food';
    double unitOriginalPrice;
    double totalOriginalPrice;
    double unitDiscountedPrice;
    double totalDiscountedPrice;

    if (isFood) {
      double basePrice = widget.cart.item!.price!;
      double unitVariationPrice = 0;
      if (widget.cart.foodVariations != null && widget.cart.foodVariations!.isNotEmpty) {
        for (int index = 0; index < widget.cart.item!.foodVariations!.length; index++) {
          for (int i = 0; i < widget.cart.item!.foodVariations![index].variationValues!.length; i++) {
            if (widget.cart.foodVariations![index][i]!) {
              unitVariationPrice += widget.cart.item!.foodVariations![index].variationValues![i].optionPrice!;
            }
          }
        }
      }
      double totalAddonPrice = 0;
      if (widget.cart.addOnIds != null && widget.cart.addOnIds!.isNotEmpty) {
        for (var addOnId in widget.cart.addOnIds!) {
          for (AddOns addOns in widget.cart.item!.addOns!) {
            if (addOns.id == addOnId.id) {
              totalAddonPrice += addOns.price! * addOnId.quantity!;
            }
          }
        }
      }

      unitOriginalPrice = basePrice + unitVariationPrice + (totalAddonPrice / widget.cart.quantity!);
      totalOriginalPrice = (basePrice + unitVariationPrice) * widget.cart.quantity! + totalAddonPrice;

      double unitDiscountedVariationPrice = 0;
      if (widget.cart.foodVariations != null && widget.cart.foodVariations!.isNotEmpty) {
        for (int index = 0; index < widget.cart.item!.foodVariations!.length; index++) {
          for (int i = 0; i < widget.cart.item!.foodVariations![index].variationValues!.length; i++) {
            if (widget.cart.foodVariations![index][i]!) {
              double optionPrice = widget.cart.item!.foodVariations![index].variationValues![i].optionPrice!;
              unitDiscountedVariationPrice += PriceConverter.convertWithDiscount(
                optionPrice,
                discount,
                discountType,
                isFoodVariation: true,
              )!;
            }
          }
        }
      }

      unitDiscountedPrice = PriceConverter.convertWithDiscount(basePrice, discount, discountType)! + unitDiscountedVariationPrice + (totalAddonPrice / widget.cart.quantity!);
      totalDiscountedPrice = (PriceConverter.convertWithDiscount(basePrice, discount, discountType)! + unitDiscountedVariationPrice) * widget.cart.quantity! + totalAddonPrice;
    } else {
      unitOriginalPrice = widget.cart.price ?? 0;
      totalOriginalPrice = unitOriginalPrice * widget.cart.quantity!;

      unitDiscountedPrice = PriceConverter.convertWithDiscount(unitOriginalPrice, discount, discountType) ?? 0;
      totalDiscountedPrice = unitDiscountedPrice * widget.cart.quantity!;
    }
    String genericName = '';

    if (widget.cart.item!.genericName != null &&
        widget.cart.item!.genericName!.isNotEmpty) {
      for (String name in widget.cart.item!.genericName!) {
        genericName += name;
      }
    }
    bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImage(
                  image: '${widget.cart.item!.imageFullUrl}',
                  height: 65,
                  width: 65,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.cart.item!.name!,
                      style: robotoBold.copyWith(fontSize: 14, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (variationText != null && variationText.isNotEmpty) ...[
                      Text(
                        variationText,
                        style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).disabledColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (addOnText.isNotEmpty) ...[
                      Text(
                        '${'addons'.tr}: $addOnText',
                        style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).disabledColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Row(
                      children: [
                        if (discount != null && discount > 0) ...[
                          CustomLineThroughText(
                            text: PriceConverter.convertPrice(unitOriginalPrice),
                            style: robotoRegular.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        ],
                        Text(
                          PriceConverter.convertPrice(unitDiscountedPrice),
                          style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    ),
                    Text(
                      widget.cart.quantity.toString(),
                      style: robotoBold.copyWith(fontSize: 13),
                    ),
                    QuantityButtonPharmacy(
                      onTap: () {
                        Get.find<CartController>().setQuantity(true, widget.cartIndex, widget.cart.stock, widget.cart.quantityLimit);
                      },
                      isIncrement: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Total Price and Remove
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.find<CartController>().removeFromCart(
                          widget.cartIndex,
                          item: widget.cart.item,
                        );
                      },
                      child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 8),
                    if (discount != null && discount > 0) ...[
                      CustomLineThroughText(
                        text: PriceConverter.convertPrice(totalOriginalPrice),
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      PriceConverter.convertPrice(totalDiscountedPrice),
                      style: robotoBold.copyWith(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          ),
      ],
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
