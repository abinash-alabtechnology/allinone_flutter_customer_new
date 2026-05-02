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
  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.total;

    return widget.storeId == null ? GetBuilder<CouponController>(
      builder: (couponController) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Colors.black12.withValues(alpha: 0.08),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.7), width: 1),
              ),
              padding: const EdgeInsets.only(left: 5),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: widget.checkoutController.couponController,
                      style: robotoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                      decoration: InputDecoration(
                        hintText: 'enter_promo_code'.tr,
                        hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                        isDense: true,
                        filled: true,
                        enabled: couponController.discount == 0,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                            right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all( 15),
                          child: Icon(Icons.discount,color: Colors.black87,)
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  // onTap: () {
                  //   if (ResponsiveHelper.isDesktop(context)) {
                  //     Get.dialog(Dialog(
                  //         child: CouponBottomSheet(
                  //             storeId: Get.find<StoreController>()
                  //                 .store!
                  //                 .id,
                  //             checkoutController:
                  //             widget.checkoutController)))
                  //         .then((value) {
                  //       if (value != null) {
                  //         widget.checkoutController.couponController
                  //             .text = value.toString();
                  //       }
                  //     });
                  //   } else {
                  //     showModalBottomSheet(
                  //       context: context,
                  //       isScrollControlled: true,
                  //       backgroundColor: Colors.transparent,
                  //       builder: (con) => CouponBottomSheet(
                  //           storeId:
                  //           Get.find<StoreController>().store!.id,
                  //           checkoutController: widget.checkoutController),
                  //     ).then((value) async {
                  //       debugPrint("jshjhs${value}");
                  //       if (value != null) {
                  //         if (value != null) {
                  //           widget.checkoutController.couponController
                  //               .text = value.toString();
                  //         }
                  //         if (widget.checkoutController.couponController
                  //             .text.isNotEmpty) {
                  //           if (Get.find<CouponController>().discount! <
                  //               1 &&
                  //               !Get.find<CouponController>()
                  //                   .freeDelivery) {
                  //             if (widget.checkoutController
                  //                 .couponController
                  //                 .text
                  //                 .isNotEmpty &&
                  //                 !Get.find<CouponController>()
                  //                     .isLoading) {
                  //               Get.find<CouponController>()
                  //                   .applyCoupon(
                  //                   widget.checkoutController
                  //                       .couponController.text,
                  //                   (widget.price -
                  //                       widget.discount) +
                  //                       widget.addOns,
                  //                   widget.deliveryCharge,
                  //                   Get.find<StoreController>()
                  //                       .store!
                  //                       .id)
                  //                   .then((discount) {
                  //                 debugPrint("skjss$discount");
                  //
                  //                 if (discount! > 0) {
                  //                   widget.checkoutController
                  //                       .couponController
                  //                       .text = 'coupon_applied'.tr;
                  //                   debugPrint("skjss");
                  //                   showCouponAppliedDialog(
                  //                       'Coupon',
                  //                       PriceConverter.convertPrice(
                  //                           discount));
                  //
                  //                   /* showCustomSnackBar(
                  //                   '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                  //                   isError: false,
                  //                 );*/
                  //                   if (widget.checkoutController
                  //                       .isPartialPay ||
                  //                       widget.checkoutController
                  //                           .paymentMethodIndex ==
                  //                           1) {
                  //                     totalPrice =
                  //                         totalPrice - discount;
                  //                     widget.checkoutController
                  //                         .checkBalanceStatus(
                  //                         totalPrice, 0);
                  //                   }
                  //                 }
                  //               });
                  //             } else if (widget.checkoutController
                  //                 .couponController.text.isEmpty) {
                  //               showCustomSnackBar(
                  //                   'enter_a_coupon_code'.tr);
                  //             }
                  //           } else {
                  //             Get.find<CouponController>()
                  //                 .removeCouponData(true);
                  //             widget.checkoutController.couponController
                  //                 .text = '';
                  //           }
                  //         }
                  //       }
                  //     });
                  //   }
                  // },
///
                  onTap: () async {
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
                                                          discount,),context);
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
                  },
                  child: Container(
                    height: 45, width: (couponController.discount! <= 0 && !couponController.freeDelivery) ? 100 : 50,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: (couponController.discount! <= 0 && !couponController.freeDelivery) ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: (couponController.discount! <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                      'apply'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                    ) : const SizedBox(
                      height: 30, width: 30,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                        : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            InkWell(
              onTap: () {
                if(ResponsiveHelper.isDesktop(context)){
                  Get.dialog(Dialog(child: CouponBottomSheet(storeId: Get.find<StoreController>().store!.id, checkoutController: widget.checkoutController,total: widget.total,price: widget.price,discount: widget.discount,addOns: widget.addOns,variationPrice: widget.variationPrice,deliveryCharge: widget.deliveryCharge,)));
                }else{
                  showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (con) => CouponBottomSheet(storeId: Get.find<StoreController>().store!.id,  checkoutController: widget.checkoutController,total: widget.total,price: widget.price,discount: widget.discount,addOns: widget.addOns,variationPrice: widget.variationPrice,deliveryCharge: widget.deliveryCharge,),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(children: [
                  Icon(Icons.list_alt, size: 15, color: Colors.black54),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text("View Available Coupons", style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black54)),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

          ]),
        );
      },
    ) : const SizedBox();
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

