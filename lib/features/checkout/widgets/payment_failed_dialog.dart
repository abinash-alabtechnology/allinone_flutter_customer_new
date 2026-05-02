import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';

// class PaymentFailedDialog extends StatelessWidget {
//   final String? orderID;
//   final String? orderType;
//   final double? orderAmount;
//   final double? maxCodOrderAmount;
//   final bool? isCashOnDelivery;
//   final String guestId;
//   const PaymentFailedDialog({super.key, required this.orderID, required this.maxCodOrderAmount, required this.orderAmount, required this.orderType, required this.isCashOnDelivery, required this.guestId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
//       insetPadding: const EdgeInsets.all(30),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       child: SizedBox(width: 500, child: Padding(
//         padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//
//           Padding(
//             padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
//             child: Image.asset(Images.warning, width: 70, height: 70),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
//             child: Text(
//               'are_you_agree_with_this_order_fail'.tr, textAlign: TextAlign.center,
//               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
//             child: Text(
//               'if_you_do_not_pay'.tr,
//               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
//             ),
//           ),
//           const SizedBox(height: Dimensions.paddingSizeLarge),
//
//           GetBuilder<OrderController>(builder: (orderController) {
//             return !orderController.isLoading ? Column(children: [
//               isCashOnDelivery! ? CustomButton(
//                 buttonText: 'switch_to_cash_on_delivery'.tr,
//                 onPressed: () {
//                   if((((maxCodOrderAmount != null && orderAmount! < maxCodOrderAmount!) || maxCodOrderAmount == null || maxCodOrderAmount == 0) && orderType != 'parcel') || orderType == 'parcel'){
//                     orderController.switchToCOD(orderID, guestId: guestId.isNotEmpty ? guestId : null).then((success){
//                       if(success){
//                         double total = ((orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
//                         if(AuthHelper.isLoggedIn()) {
//                           Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
//                         }
//                       }
//                     });
//                   }else{
//                     if(Get.isDialogOpen!) {
//                       Get.back();
//                     }
//                     showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
//                   }
//                 },
//                 radius: Dimensions.radiusSmall, height: 40,
//               ) : const SizedBox(),
//               SizedBox(height: Get.find<SplashController>().configModel!.cashOnDelivery! ? Dimensions.paddingSizeLarge : 0),
//
//               TextButton(
//                 onPressed: () {
//                   Get.find<OrderController>().cancelOrder(int.parse(orderID!), 'Digital payment issue', guestId: guestId.isNotEmpty ? guestId : null).then((success) {
//                     if(success){
//                       Get.offAllNamed(RouteHelper.getInitialRoute());
//                     }
//                   });
//                 },
//                 style: TextButton.styleFrom(
//                   backgroundColor: Theme.of(context).disabledColor.withValues(alpha: 0.3), minimumSize: const Size(Dimensions.webMaxWidth, 40), padding: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
//                 ),
//                 child: Text('cancel_order'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
//               ),
//             ]) : const Center(child: CircularProgressIndicator());
//           }),
//
//         ]),
//       )),
//     );
//   }
// }
class PaymentFailedDialog extends StatelessWidget {
  final String? orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool? isCashOnDelivery;
  final String guestId;
  const PaymentFailedDialog({super.key, required this.orderID, required this.maxCodOrderAmount, required this.orderAmount, required this.orderType, required this.isCashOnDelivery, required this.guestId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      insetPadding: const EdgeInsets.all(30),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Images.warning,
                width: 70,
                height: 70,
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! The order has failed.',
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Pop first screen
                  Navigator.of(context).pop(); // Pop second screen
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),                child: Text(
                  'OK',
                  style: robotoBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
