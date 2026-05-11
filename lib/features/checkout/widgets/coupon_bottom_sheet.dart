import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/coupon/domain/models/coupon_model.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/coupon/widgets/coupon_card_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:scratcher/widgets.dart';

import '../../../common/widgets/custom_snackbar.dart';
import '../../../helper/price_converter.dart';
import '../../store/controllers/store_controller.dart';

class CouponBottomSheet extends StatefulWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final double total;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double variationPrice;
  const CouponBottomSheet({super.key, required this.storeId, required this.checkoutController, required this.total, required this.price, required this.discount, required this.addOns, required this.deliveryCharge, required this.variationPrice});

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.total;

    return Container(
      width: Dimensions.webMaxWidth,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [

          !ResponsiveHelper.isDesktop(context) ? Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
          ) : const SizedBox(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Offers",
                      style: robotoBlack.copyWith(
                        fontSize: 32,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 25,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Exclusive rewards for your order",
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),

          GetBuilder<CouponController>(builder: (couponController) {
            List<CouponModel>? couponList;
            if(couponController.couponList != null) {
              couponList = [];
              for(CouponModel coupon in couponController.couponList!) {
                if(coupon.storeId == null || (coupon.couponType != 'store_wise' && coupon.couponType != 'default' && coupon.couponType != 'free_delivery') || coupon.storeId == widget.storeId) {
                  couponList.add(coupon);
                }
              }
            }
            return couponList != null ? couponList.isNotEmpty ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                // mainAxisSpacing: Dimensions.paddingSizeSmall,
                // crossAxisSpacing: Dimensions.paddingSizeSmall,
                mainAxisExtent: ResponsiveHelper.isMobilePhone() ? 130 : 160,
                // childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
              ),
              itemCount: couponList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeLarge),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if(couponList![index].code != null) {
                      widget.checkoutController.couponController.text = couponList[index].code.toString();
                      if(widget.checkoutController.couponController.text.isNotEmpty){
                        if(Get.find<CouponController>().discount! < 1 && !Get.find<CouponController>().freeDelivery) {
                          if(widget.checkoutController.couponController.text.isNotEmpty && !Get.find<CouponController>().isLoading) {
                            Get.find<CouponController>().applyCoupon(widget.checkoutController.couponController.text, (widget.price-widget.discount)+widget.addOns + widget.variationPrice, widget.deliveryCharge,
                                Get.find<StoreController>().store!.id).then((discount) {
                              //checkoutController.couponController.text = 'coupon_applied'.tr;
                              if (discount! > 0) {

                                showCouponAppliedDialog(
                                    'Coupon',
                                    PriceConverter.convertPrice(
                                      discount,));
                                // showCustomSnackBar(
                                //   '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                //   isError: false,
                                // );
                                if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                                  totalPrice = totalPrice - discount;
                                  widget.checkoutController.checkBalanceStatus(totalPrice, discount);
                                }
                              }
                            });
                          } else if(widget.checkoutController.couponController.text.isEmpty) {
                            showCustomSnackBar('enter_a_coupon_code'.tr);
                          }
                        } else {
                          totalPrice = totalPrice + couponController.discount!;
                          Get.find<CouponController>().removeCouponData(true);
                          widget.checkoutController.couponController.text = '';
                          if(widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1){
                            widget.checkoutController.checkBalanceStatus(totalPrice, 0);
                          }
                        }
                      }else {
                        showCustomSnackBar('enter_a_coupon_code'.tr);
                      }
                    }
                    Get.back();
                  },
                  child: CouponCardWidget(coupon: couponList![index], index: index,fromdialog: true,),
                );
              },
            ) : Column(children: [
              Image.asset(Images.noCoupon, height: 70),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('no_promo_available'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                '${'please_add_manually_or_collect_promo_from'.tr} ${Get.find<SplashController>().configModel!.businessName!}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: 50),
            ]) : const Center(child: CircularProgressIndicator());
          })

        ]),
      ),
    );
  }

  void showCouponAppliedDialog(
      String code,
      String savedAmount,
      ) {
    bool scratchCompleted = false;

    showDialog(
      context: Get.context!,
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
