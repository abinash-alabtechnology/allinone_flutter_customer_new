import 'package:gap/gap.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class ConfirmationDialog extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;
  const ConfirmationDialog({super.key, required this.icon, this.title, required this.description, required this.onYesPressed,
    this.isLogOut = false, this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge*1.2)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(width: 500, child:
        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: Get.width,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Center(
              child: Card(
                elevation: 3,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Image.asset(icon, width: 50, height: 50, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),



          Padding(
            padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                title != null ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    title!, textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
                  ),
                ) : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(description, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Colors.grey.shade600), textAlign: TextAlign.center),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                GetBuilder<OrderController>(builder: (orderController) {
                  return !orderController.isLoading ? Row(children: [
                    Expanded(child: TextButton(
                      onPressed: () => isLogOut ? onYesPressed() : onNoPressed != null ? onNoPressed!() : Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3), minimumSize: const Size(Dimensions.webMaxWidth, 50), padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                      ),
                      child: Text(
                        isLogOut ? 'yes'.tr : 'no'.tr, textAlign: TextAlign.center,
                        style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    Expanded(child: CustomButton(
                      buttonText: isLogOut ? 'no'.tr : 'yes'.tr,
                      onPressed: () => isLogOut ? Get.back() : onYesPressed(),
                      radius: Dimensions.radiusLarge, height: 50,
                    )),
                  ]) : const Center(child: CircularProgressIndicator());
                }),

              ],
            ),
          ),
          Gap(10),

        ])),
      ),
    );
  }
}
