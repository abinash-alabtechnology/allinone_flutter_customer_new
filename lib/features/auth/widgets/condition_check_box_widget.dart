import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBoxWidget extends StatelessWidget {
  final bool forDeliveryMan;
  final bool forSignUp;
  const ConditionCheckBoxWidget({super.key, this.forDeliveryMan = false, this.forSignUp = true});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [

      forDeliveryMan ?
      GetBuilder<DeliverymanRegistrationController>(builder: (dmRegController) {
        return GetBuilder<AuthController>(builder: (authController) {
          return Checkbox(
            activeColor: Theme.of(context).cardColor,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            value: forSignUp ? authController.acceptTerms : dmRegController.acceptTerms,
            onChanged: (bool? isChecked) => forSignUp ? authController.toggleTerms() : dmRegController.toggleTerms(),
          );
        });
      })
          : GetBuilder<AuthController>(
        builder: (authController) {
          return GestureDetector(
            onTap: () => authController.toggleTerms(),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: authController.acceptTerms ? Colors.green : Colors.transparent,
                  border: Border.all(
                    color: authController.acceptTerms ? Colors.green : Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: authController.acceptTerms
                    ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
                    : null,
              ),
            ),
          );
        },
      ),
const SizedBox(width: 5,),
      forDeliveryMan ? const SizedBox() : Text( '* ', style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),

      Flexible(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: forDeliveryMan ? 'i_agree_with_all_the'.tr :'i_agree_with_all_the'.tr,
              style: robotoRegular.copyWith(color: forDeliveryMan ? Theme.of(context).textTheme.bodyMedium!.color : kIsWeb?Theme.of(context).disabledColor:Theme.of(context).cardColor, fontSize: forDeliveryMan ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
              text: 'terms_conditions'.tr,
              style: robotoMedium.copyWith(color: kIsWeb?Theme.of(context).disabledColor:Theme.of(context).cardColor),
            ),
          ]),
        ),
      ),

    ]);
  }
}
