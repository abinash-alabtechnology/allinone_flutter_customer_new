import 'package:flutter/gestures.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutCondition extends StatelessWidget {
  final bool isParcel;
  const CheckoutCondition({super.key,  this.isParcel = false});

  @override
  Widget build(BuildContext context) {
    bool activeRefund = Get.find<SplashController>().configModel!.refundPolicyStatus == 1;

    Widget buildCheckboxRow({
      required bool acceptTerms,
      required VoidCallback toggleTerms,
    }) {
      return Row(children: [
        SizedBox(
          width: 24.0,
          height: 24.0,
          child: Checkbox(
            activeColor: Theme.of(context).primaryColor,
            value: acceptTerms,
            onChanged: (bool? isChecked) => toggleTerms(),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
              text: '${'i_have_read_and_agreed_with'.tr} ',
              style: robotoRegular.copyWith(color: Colors.grey.shade600,fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'privacy_policy'.tr, style: robotoMedium.copyWith(color: Colors.black87),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
            ),
            !isParcel && activeRefund ? TextSpan(
              text: ', ',
              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
            ) : TextSpan(
              text: ' ${'and'.tr} ',
              style: robotoRegular.copyWith(color: Colors.grey.shade600,fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'terms_conditions'.tr, style: robotoMedium.copyWith(color: Colors.black87),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
            ),
            !isParcel && activeRefund ? TextSpan(text: ' ${'and'.tr} ', style: robotoRegular.copyWith(color: Colors.grey.shade600,fontWeight: FontWeight.w400),
          ) : const TextSpan(),

            !isParcel && activeRefund ? TextSpan(
              text: 'refund_policy'.tr, style: robotoMedium.copyWith(color: Colors.black87),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('refund-policy')),
            ) : const TextSpan(),
          ]), textAlign: TextAlign.start, maxLines: 3),
        ),
      ]);
    }

    return isParcel ? GetBuilder<ParcelController>(builder: (parcelController) {
      return buildCheckboxRow(
        acceptTerms: parcelController.acceptTerms,
        toggleTerms: () => parcelController.toggleTerms(),
      );
    }) : GetBuilder<CheckoutController>(builder: (checkoutController) {
      return buildCheckboxRow(
        acceptTerms: checkoutController.acceptTerms,
        toggleTerms: () => checkoutController.toggleTerms(),
      );
    });
  }
}
