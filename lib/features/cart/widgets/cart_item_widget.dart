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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        InkWell(
                          onTap: () {
                            Get.find<CartController>().removeFromCart(
                              widget.cartIndex,
                              item: widget.cart.item,
                            );
                          },
                          child: const Icon(Icons.close, size: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType),
                      style: robotoRegular.copyWith(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
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
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Text(
                PriceConverter.convertPrice((startingPrice ?? 0) * widget.cart.quantity!, discount: discount, discountType: discountType),
                style: robotoBold.copyWith(fontSize: 16),
              ),
            ],
          ),
          if (addOnText.isNotEmpty || variationText!.isNotEmpty) ...[
            const SizedBox(height: 8),
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
          if (showAddonsVariations) ...[
            const SizedBox(height: 4),
            if (addOnText.isNotEmpty)
              Text('${'addons'.tr}: $addOnText', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            if (variationText!.isNotEmpty)
              Text('${'variations'.tr}: $variationText', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
          ],
        ],
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
