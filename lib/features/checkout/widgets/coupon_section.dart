import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/features/checkout/widgets/coupon_bottom_sheet.dart';
import 'package:lottie/lottie.dart';
import 'package:scratcher/widgets.dart';
import 'package:handy_allinone/features/coupon/domain/models/coupon_model.dart';

class CouponSection extends StatefulWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final double total;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double variationPrice;
  const CouponSection({super.key, this.storeId, required this.checkoutController, required this.total, required this.price, required this.discount,
    required this.addOns, required this.deliveryCharge, required this.variationPrice});

  @override
  State<CouponSection> createState() => _CouponSectionState();
}

class _CouponSectionState extends State<CouponSection> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void _applyCoupon(String couponCode, CouponController couponController) {
    if (couponCode.isNotEmpty && !couponController.isLoading) {
      couponController.applyCoupon(
        couponCode,
        (widget.price - widget.discount) + widget.addOns + widget.variationPrice,
        widget.deliveryCharge,
        widget.storeId ?? Get.find<StoreController>().store?.id,
      ).then((discount) {
        if (discount != null && discount > 0) {
          widget.checkoutController.couponController.text = couponCode;
          showCouponAppliedDialog('Coupon', PriceConverter.convertPrice(discount), context);
          if (widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
            double total = widget.total - discount;
            widget.checkoutController.checkBalanceStatus(total, discount);
          }
        }
      });
    } else if (couponCode.isEmpty) {
      showCustomSnackBar('enter_a_coupon_code'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.total;

    return GetBuilder<CouponController>(
      builder: (couponController) {
        List<CouponModel>? coupons = widget.storeId != null ? couponController.couponRestList : couponController.couponList;
        bool hasCoupons = coupons != null && coupons.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F9F3),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: const Color(0xFFD1EADC), width: 1),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00853E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.percent, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasCoupons ? 'Best offers for you' : 'Save more with coupons!',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: hasCoupons ? const Color(0xFF00853E) : Colors.black),
                            ),
                            if (!hasCoupons)
                              Text(
                                'Use coupons & save on this order',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (hasCoupons) ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: coupons!.length > 3 ? 3 : coupons.length,
                      itemBuilder: (context, index) {
                        CouponModel coupon = coupons[index];
                        bool isSelected = widget.checkoutController.couponController.text == coupon.code;
                        
                        return InkWell(
                          onTap: () {
                            if (!isSelected) {
                              widget.checkoutController.couponController.text = coupon.code!;
                              _applyCoupon(coupon.code!, couponController);
                            } else {
                              widget.checkoutController.couponController.text = '';
                              couponController.removeCouponData(true);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: isSelected ? const Color(0xFFFF7A5C) : Colors.grey.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Text(
                                    coupon.code ?? '',
                                    style: robotoMedium.copyWith(color: const Color(0xFF00853E), fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Text(
                                    '${'Save'.tr} ${PriceConverter.convertPrice(coupon.discount)} ${coupon.discountType == 'percent' ? '%' : ''} ${'on orders above'.tr} ${PriceConverter.convertPrice(coupon.minPurchase)}',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  height: 20, width: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSelected ? const Color(0xFFFF7A5C) : Colors.grey, width: 1.5),
                                  ),
                                  child: isSelected ? Center(
                                    child: Container(
                                      height: 10, width: 10,
                                      decoration: const BoxDecoration(color: Color(0xFFFF7A5C), shape: BoxShape.circle),
                                    ),
                                  ) : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Align(
                    alignment: hasCoupons ? Alignment.center : Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        if (ResponsiveHelper.isDesktop(context)) {
                          Get.dialog(Dialog(child: CouponBottomSheet(
                            storeId: widget.storeId ?? Get.find<StoreController>().store?.id,
                            checkoutController: widget.checkoutController,
                            total: widget.total, price: widget.price, discount: widget.discount,
                            addOns: widget.addOns, variationPrice: widget.variationPrice, deliveryCharge: widget.deliveryCharge,
                          )));
                        } else {
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (con) => CouponBottomSheet(
                              storeId: widget.storeId ?? Get.find<StoreController>().store?.id,
                              checkoutController: widget.checkoutController,
                              total: widget.total, price: widget.price, discount: widget.discount,
                              addOns: widget.addOns, variationPrice: widget.variationPrice, deliveryCharge: widget.deliveryCharge,
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View all coupons',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFFFF7A5C)),
                            ),
                            const SizedBox(width: 4),
                            Icon(hasCoupons ? Icons.arrow_forward : Icons.arrow_forward_ios, size: 14, color: const Color(0xFFFF7A5C)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (couponController.discount! <= 0 && !couponController.freeDelivery)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: widget.checkoutController.couponController,
                        style: robotoRegular,
                        decoration: InputDecoration(
                          hintText: 'enter_promo_code'.tr,
                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _applyCoupon(widget.checkoutController.couponController.text, couponController),
                      child: Container(
                        height: 40, width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: !couponController.isLoading ? Text(
                          'apply'.tr,
                          style: robotoMedium.copyWith(color: Colors.white),
                        ) : const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        );
      },
    );
  }

  void showCouponAppliedDialog(
      String code,
      String savedAmount,
      BuildContext parentContext,
      ) {
    bool scratchCompleted = false;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: scratchCompleted
                    ? Center(
                  child: Container(
                    width: 320,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/animation/done.json',
                                width: 110,
                                height: 110,
                                repeat: false,
                              ),
                              const SizedBox(height: 10),
                              Text('$code applied', style: robotoMedium),
                              const SizedBox(height: 6),
                              Text('You saved $savedAmount', style: robotoBold),
                              const SizedBox(height: 6),
                              const Text('Enjoy your savings 🎉'),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Lottie.asset(
                              'assets/animation/coupon.json',
                              fit: BoxFit.cover,
                              repeat: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Scratcher(
                  brushSize: 50,
                  threshold: 35,
                  image: Image.asset(
                    'assets/image/scratch_card.jpg',
                    fit: BoxFit.cover,
                  ),
                  onThreshold: () {
                    setDialogState(() {
                      scratchCompleted = true;
                    });

                    Future.delayed(const Duration(seconds: 3), () {
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                    });
                  },
                  child:Container(
                    width: 320,
                    height: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/animation/done.json',
                            width: 110,
                            height: 110,
                            repeat: false,
                          ),
                          const SizedBox(height: 10),
                          Text('$code applied', style: robotoMedium),
                          const SizedBox(height: 6),
                          Text('You saved $savedAmount', style: robotoBold),
                          const SizedBox(height: 6),
                          const Text('Enjoy your savings 🎉'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


}

