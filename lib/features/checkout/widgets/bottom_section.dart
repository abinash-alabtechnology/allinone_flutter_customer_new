import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_tool_tip_widget.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/checkout/widgets/extra_discount_view_widget.dart';
import 'package:handy_allinone/features/checkout/widgets/prescription_image_picker_widget.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/common/models/config_model.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/checkout/widgets/condition_check_box.dart';
import 'package:handy_allinone/features/checkout/widgets/coupon_section.dart';
import 'package:handy_allinone/features/checkout/widgets/note_prescription_section.dart';
import 'package:handy_allinone/features/checkout/widgets/partial_pay_view.dart';

import '../../../helper/module_helper.dart';

class BottomSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double total;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int? storeId;
  final double? taxPercent;
  final  double price;
  final double addOns;
  final Widget? checkoutButton;
  final bool isPrescriptionRequired;
  final double referralDiscount;
  final double variationPrice;
  final double extraDiscount;



  const BottomSection({super.key, required this.checkoutController, required this.total, required this.module, required this.subTotal,
    required this.discount, required this.couponController, required this.taxIncluded, required this.tax,
    required this.deliveryCharge, required this.todayClosed, required this.tomorrowClosed,
    required this.orderAmount, this.maxCodOrderAmount, this.storeId, this.taxPercent, required this.price,
    required this.addOns, this.checkoutButton, required this.isPrescriptionRequired, required this.referralDiscount, required this.variationPrice, required this.extraDiscount});

  @override
  Widget build(BuildContext context) {
    bool takeAway = checkoutController.orderType == 'take_away';
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [

        isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Coupon
        isDesktop && !isGuestLoggedIn ? CouponSection(
          storeId: storeId, checkoutController: checkoutController, total: total, price: price,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge, variationPrice: variationPrice,
        ) : const SizedBox(),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            ///Additional Note & prescription..
            NoteAndPrescriptionSection(checkoutController: checkoutController, storeId: storeId),

            isDesktop && !isGuestLoggedIn ? PartialPayView(totalPrice: total, isPrescription: storeId != null) : const SizedBox(),

            !isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            // PrescriptionImagePickerWidget(checkoutController: checkoutController, storeId: storeId, isPrescriptionRequired: isPrescriptionRequired),

            const CheckoutCondition(),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            ExtraDiscountViewWidget(extraDiscount: extraDiscount),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text( 'total_amount'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                      storeId == null ? const SizedBox() : Text(
                        'Once_your_order_is_confirmed_you_will_receive'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                  storeId == null ? const SizedBox() : Text(
                    'a_notification_with_your_bill_total'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
              PriceConverter.convertAnimationPrice(
                checkoutController.viewTotalPrice,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: checkoutController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
            ]) : const SizedBox(),
          ]),
        ),

        ResponsiveHelper.isDesktop(context) ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: checkoutButton,
        ) : const SizedBox(),

      ]),
    );
  }

  Widget pricingView({required BuildContext context, required bool takeAway}) {
    return Column(children: [

      ResponsiveHelper.isDesktop(context) ? Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ),
      ) : const SizedBox(),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('item_price'.tr, style: robotoMedium.copyWith(color: Colors.grey.shade500)),
              PriceConverter.convertAnimationPrice(price, textStyle: robotoMedium.copyWith(color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('discount'.tr, style: robotoRegular.copyWith(color: Colors.green,fontWeight: FontWeight.w400)),
              Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular.copyWith(color: Colors.green,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr),
            ]) : const SizedBox(),

            SizedBox(height: variationPrice > 0
                ? Dimensions.paddingSizeSmall : 0),

            variationPrice > 0
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('variations'.tr, style: robotoMedium.copyWith(color: Colors.grey.shade500)),
                Text(
                  '(+) ${PriceConverter.convertPrice(variationPrice)}',
                  style: robotoMedium.copyWith(color: Colors.grey.shade500), textDirection: TextDirection.ltr,
                ),
              ],
            ) : const SizedBox(),
            SizedBox(height: addOns > 0
                ? Dimensions.paddingSizeSmall : 0),
            Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! && addOns>0 ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('addons'.tr, style: robotoMedium.copyWith(color: Colors.grey.shade500)),
                Row(children: [
                  Text('(+) ', style: robotoMedium.copyWith(color: Colors.grey.shade500)),
                  PriceConverter.convertAnimationPrice(addOns, textStyle: robotoMedium.copyWith(color:Colors.grey.shade500)),
                ]),
              ],
            ) : const SizedBox(),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // storeId == null ?
            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //   Text(module.addOn! ? 'subtotal'.tr : 'item_price'.tr, style: robotoRegular),
            //   Text(PriceConverter.convertPrice(subTotal), style: robotoRegular, textDirection: TextDirection.ltr),
            // ]) : const SizedBox(),
            // SizedBox(height: storeId == null ? Dimensions.paddingSizeSmall : 0),


            (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('coupon_discount'.tr, style: robotoRegular.copyWith(color: Colors.green,fontWeight: FontWeight.w400)),
                (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
                  'free_delivery'.tr, style: robotoRegular.copyWith(color: Colors.green,fontWeight: FontWeight.w400),
                ) : Text(
                  '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                  style: robotoRegular.copyWith(color: Colors.green,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]) : const SizedBox(),

            referralDiscount > 0 ? Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('referral_discount'.tr, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),

                Text(
                  '(-) ${PriceConverter.convertPrice(referralDiscount)}',
                  style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]) : const SizedBox(),

            ((checkoutController.taxIncluded == null) || taxIncluded || (checkoutController.orderTax == 0)) ? const SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('vat_tax'.tr, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
              Text(('(+) ') + PriceConverter.convertPrice(tax), style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr),
            ]),
            SizedBox(height: ((checkoutController.taxIncluded == null) || taxIncluded || (checkoutController.orderTax == 0)) ? 0 : Dimensions.paddingSizeSmall),

            (!takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('delivery_man_tips'.tr, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
                Text('(+) ${PriceConverter.convertPrice(checkoutController.tips)}', style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr),
              ],
            ) : const SizedBox.shrink(),
            SizedBox(height: !takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

            storeId == null ? (checkoutController.store!.extraPackagingStatus! && Get.find<CartController>().needExtraPackage) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('extra_packaging'.tr, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
                Text('(+) ${PriceConverter.convertPrice(checkoutController.store!.extraPackagingAmount!)}', style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr),
              ],
            ) : const SizedBox.shrink() : const SizedBox(),
            SizedBox(height: storeId == null ? (checkoutController.store!.extraPackagingStatus! && Get.find<CartController>().needExtraPackage) ? Dimensions.paddingSizeSmall : 0.0 : 0.0),

            //newly added
            storeId == null ? (checkoutController.store!.otherchargeenabled==true) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(checkoutController.store?.otherchargelabel??"", style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
                Text('(+) ${PriceConverter.convertPrice(checkoutController.store!.otherchargeamount!)}', style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr),
              ],
            ) : const SizedBox.shrink() : const SizedBox(),
            SizedBox(height: storeId == null ? (checkoutController.store!.otherchargeenabled==true) ? Dimensions.paddingSizeSmall : 0.0 : 0.0),

            (AuthHelper.isGuestLoggedIn() && checkoutController.guestAddress == null) ? const SizedBox() : Row( children: [
              Text('delivery_fee'.tr, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
              const SizedBox(width: 5),

              (checkoutController.orderType == 'delivery') && (checkoutController.store?.selfDeliverySystem == 0) && (checkoutController.surgePrice?.customerNoteStatus == 1) ? CustomToolTip(
                message: '${'this_delivery_fee_includes_all_the_applicable_charges_on_delivery'.tr} ${checkoutController.surgePrice?.customerNote ?? ''}',
              ) : const SizedBox(),

              const Spacer(),

              checkoutController.distance == -1 ? Text(
                'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
              ) : (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Text(
                'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
              ) : Text(
                '(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr,
              ),
            ]),

            SizedBox(height: Get.find<SplashController>().configModel!.additionalChargeStatus! && !(AuthHelper.isGuestLoggedIn() && checkoutController.guestAddress == null) ? Dimensions.paddingSizeSmall : 0),

            Get.find<SplashController>().configModel!.additionalChargeStatus! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
              Text(
                '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr,
              ),
            ]) : const SizedBox(),
            SizedBox(height: checkoutController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

            checkoutController.isPartialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('paid_by_wallet'.tr, style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400)),
              Text('(-) ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!)}', style: robotoRegular.copyWith(color: Colors.grey.shade500,fontWeight: FontWeight.w400), textDirection: TextDirection.ltr),
            ]) : const SizedBox(),
            SizedBox(height: checkoutController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

            checkoutController.isPartialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'due_payment'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
              PriceConverter.convertAnimationPrice(
                checkoutController.viewTotalPrice,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              )
            ]) : const SizedBox(),

            DottedBorder(
              options:
              CustomPathDottedBorderOptions(
                padding: const EdgeInsets.all(10),
                color: Colors.grey.shade400,
                strokeWidth: 1,
                dashPattern: [5, 5],
                customPath: (size) => Path()
                  ..moveTo(0, size.height)
                  ..relativeLineTo(size.width, 0),
              ),
              child: const SizedBox(
                width: double.infinity,
                height: 0,
              ),
            ),

          ],
        ),
      ),

    ]);
  }
}
