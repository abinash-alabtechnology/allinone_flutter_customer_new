import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
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

class BottomSection extends StatefulWidget {
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
  final double price;
  final double addOns;
  final Widget? checkoutButton;
  final bool isPrescriptionRequired;
  final double referralDiscount;
  final double variationPrice;
  final double extraDiscount;

  const BottomSection({
    super.key,
    required this.checkoutController,
    required this.total,
    required this.module,
    required this.subTotal,
    required this.discount,
    required this.couponController,
    required this.taxIncluded,
    required this.tax,
    required this.deliveryCharge,
    required this.todayClosed,
    required this.tomorrowClosed,
    required this.orderAmount,
    this.maxCodOrderAmount,
    this.storeId,
    this.taxPercent,
    required this.price,
    required this.addOns,
    this.checkoutButton,
    required this.isPrescriptionRequired,
    required this.referralDiscount,
    required this.variationPrice,
    required this.extraDiscount,
  });

  @override
  State<BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool takeAway = widget.checkoutController.orderType == 'take_away';
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isLoggedIn() == false;

    double savings = widget.discount + widget.couponController.discount! + widget.referralDiscount;

    return Container(
      decoration: isDesktop ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [

        const SizedBox(height: Dimensions.paddingSizeDefault),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CheckoutCondition(),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            ExtraDiscountViewWidget(extraDiscount: widget.extraDiscount),
          ]),
        ),

        const SizedBox(height: Dimensions.paddingSizeDefault),

        if (isDesktop) Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: widget.checkoutButton,
        ),
      ]),
    );
  }

  Widget pricingView({required BuildContext context, required bool takeAway}) {
    return Column(children: [
      _priceRow('Item Total', widget.price + widget.addOns + widget.variationPrice),
      if (widget.discount > 0) _priceRow('Discount', widget.discount, isDiscount: true),
      if (widget.couponController.discount! > 0) _priceRow('Coupon Discount', widget.couponController.discount!, isDiscount: true),
      if (widget.referralDiscount > 0) _priceRow('Referral Discount', widget.referralDiscount, isDiscount: true),
      
      _priceRow('Delivery Fee', widget.deliveryCharge),
      
      if (widget.storeId == null && widget.checkoutController.store!.extraPackagingStatus! && Get.find<CartController>().needExtraPackage)
        _priceRow('Packaging Fee', widget.checkoutController.store!.extraPackagingAmount!),

      if (widget.storeId == null && widget.checkoutController.store!.otherchargeenabled == true)
        _priceRow((widget.checkoutController.store?.otherchargelabel ?? "Other Fee").capitalizeFirst!, widget.checkoutController.store!.otherchargeamount!),

      if (widget.tax > 0) _priceRow('VAT/Tax', widget.tax),
      if (!takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && widget.checkoutController.tips > 0)
        _priceRow('Delivery Man Tips', widget.checkoutController.tips),

      if (Get.find<SplashController>().configModel!.additionalChargeStatus!)
        _priceRow(Get.find<SplashController>().configModel!.additionalChargeName!, Get.find<SplashController>().configModel!.additionCharge!),
    ]);
  }

  Widget _priceRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            (isDiscount ? '(-) ' : '') + PriceConverter.convertPrice(amount),
            style: GoogleFonts.inter(
              color: isDiscount ? const Color(0xFF10B981) : const Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

