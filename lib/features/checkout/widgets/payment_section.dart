import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../splash/controllers/splash_controller.dart';

// class PaymentSection extends StatelessWidget {
//   final int? storeId;
//   final bool isCashOnDeliveryActive;
//   final bool isDigitalPaymentActive;
//   final bool isWalletActive;
//   final double total;
//   final CheckoutController checkoutController;
//   final bool isOfflinePaymentActive;
//   const PaymentSection({super.key, this.storeId, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
//     required this.isWalletActive, required this.total, required this.checkoutController, required this.isOfflinePaymentActive,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//         Text(storeId != null ? 'payment_method'.tr : 'choose_payment_method'.tr, style: robotoMedium),
//
//
//         storeId == null && !ResponsiveHelper.isDesktop(context) ? InkWell(
//           onTap: (){
//             Get.bottomSheet(
//               PaymentMethodBottomSheet(
//                 isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
//                 isWalletActive: isWalletActive, storeId: storeId, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
//               ),
//               backgroundColor: Colors.transparent, isScrollControlled: true,
//             );
//
//           },
//           child: Image.asset(Images.paymentSelect, height: 24, width: 24),
//         ) : const SizedBox(),
//       ]),
//
//       !ResponsiveHelper.isDesktop(context) ? const Divider() : const SizedBox(height: Dimensions.paddingSizeSmall),
//       SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),
//
//       Container(
//         decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
//           borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//           color: Theme.of(context).cardColor,
//           border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), width: 1),
//         ) : const BoxDecoration(),
//         padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.radiusDefault) : EdgeInsets.zero,
//         child: storeId != null ? checkoutController.paymentMethodIndex == 0 ? Row(children: [
//           Image.asset(Images.cash , width: 20, height: 20,
//             color: Theme.of(context).textTheme.bodyMedium!.color,
//           ),
//           const SizedBox(width: Dimensions.paddingSizeSmall),
//
//           Expanded(child: Text('cash_on_delivery'.tr,
//             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
//           )),
//
//           Text(
//             PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
//             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
//           )
//
//         ]) : const SizedBox() : InkWell(
//           onTap: () {
//             if(ResponsiveHelper.isDesktop(context) && checkoutController.paymentMethodIndex == -1){
//               Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
//                 isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
//                 isWalletActive: isWalletActive, storeId: storeId, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
//               )));
//             }
//           },
//           child: Row(children: [
//             checkoutController.paymentMethodIndex != -1 ? Image.asset(
//               checkoutController.paymentMethodIndex == 0 ? Images.cash
//                   : checkoutController.paymentMethodIndex == 1 ? Images.wallet
//                   : checkoutController.paymentMethodIndex == 2 ? Images.digitalPayment
//                   : Images.cash,
//               width: 20, height: 20,
//               color: Theme.of(context).textTheme.bodyMedium!.color,
//             ) : Icon(
//               !ResponsiveHelper.isDesktop(context) ? Icons.wallet_outlined : Icons.add_circle_outline_sharp,
//               size: 18, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
//             ),
//             const SizedBox(width: Dimensions.paddingSizeSmall),
//
//             Expanded(
//               child: Row(children: [
//                 Builder(
//                   builder: (context) {
//                     //print('=======pay: ${checkoutController.paymentMethodIndex}==== ${checkoutController.isPartialPay}');
//                     return Text(
//                       checkoutController.paymentMethodIndex == 0 ? '${'cash_on_delivery'.tr} ${checkoutController.isPartialPay ? '(${'partial'.tr})' : ''}'
//                           : checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay ? 'wallet_payment'.tr
//                           : checkoutController.paymentMethodIndex == 2 ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''} - ${checkoutController.isPartialPay ? 'partial'.tr : ''})'
//                           : checkoutController.paymentMethodIndex == 3 ? '${'offline_payment'.tr}(${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName} - ${checkoutController.isPartialPay ? 'partial'.tr : ''})'
//                           : !ResponsiveHelper.isDesktop(context) ? 'select_payment_method'.tr : 'add_payment_method'.tr,
//                       style: robotoMedium.copyWith(
//                         fontSize: Dimensions.fontSizeSmall,
//                         color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).disabledColor
//                             : checkoutController.paymentMethodIndex == -1 ? Theme.of(context).primaryColor
//                             : Theme.of(context).disabledColor,
//                       ),
//                     );
//                   }
//                 ),
//
//                 checkoutController.paymentMethodIndex == -1 && !ResponsiveHelper.isDesktop(context) ? Padding(
//                   padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
//                   child: Icon(Icons.warning_rounded, size: 16, color: Theme.of(context).colorScheme.error),
//                 ) : const SizedBox(),
//               ])
//             ),
//             checkoutController.paymentMethodIndex != -1 ? PriceConverter.convertAnimationPrice(
//               checkoutController.viewTotalPrice,
//               textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
//             ) : const SizedBox(),
//             // Text(
//             //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
//             //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
//             // ),
//             SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),
//
//             storeId == null && ResponsiveHelper.isDesktop(context) ? InkWell(
//               onTap: (){
//                 Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
//                   isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
//                   isWalletActive: isWalletActive, storeId: storeId, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
//                 )));
//               },
//               child: Image.asset(Images.paymentSelect, height: 24, width: 24),
//             ) : const SizedBox(),
//           ]),
//         ),
//       ),
//
//     ]);
//   }
// }
class PaymentSection extends StatefulWidget {
  final int? storeId;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final CheckoutController checkoutController;
  final bool isOfflinePaymentActive;
  const PaymentSection({
    super.key,
    this.storeId,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  bool notHideCod = true;
  bool canSelectWallet = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
  final userController = Get.find<ProfileController>();
  int selectedindex = -1;

  @override
  void initState() {
    super.initState();
    double? walletBalance =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;
    if (walletBalance < widget.total) {
      canSelectWallet = false;
    }
    if (Get.find<CheckoutController>().isPartialPay) {
      notHideWallet = false;
      if (Get.find<SplashController>().configModel!.partialPaymentMethod! ==
          'cod') {
        notHideCod = true;
        notHideDigital = false;
      } else if (Get.find<SplashController>()
          .configModel!
          .partialPaymentMethod! ==
          'digital_payment') {
        notHideCod = false;
        notHideDigital = true;
      } else if (Get.find<SplashController>()
          .configModel!
          .partialPaymentMethod! ==
          'both') {
        notHideCod = true;
        notHideDigital = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double walletBalance =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0.0;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          notHideCod
              ? Text('choose_payment_method'.tr,
              style:
              robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault))
              : const SizedBox(),
          const SizedBox(width: 10),
        ],
      ),
      SizedBox(height: notHideCod ? Dimensions.paddingSizeExtraSmall : 0),
      Row(children: [
        if (widget.isCashOnDeliveryActive && notHideCod)
          Expanded(
            child: PaymentButtonNew(
              icon: Images.codIcon,
              title: "COD",
              isSelected: selectedindex == 0, // Will not be selected initially
              onTap: () {
                setState(() {
                  selectedindex = 0;
                });
                widget.checkoutController.setPaymentMethod(0);
                print(widget.checkoutController.paymentMethodIndex);
              },
            ),
          )
        else
          const SizedBox(),
        SizedBox(
            width: widget.storeId == null &&
                widget.isDigitalPaymentActive &&
                notHideDigital
                ? Dimensions.paddingSizeLarge
                : 0),
        widget.isDigitalPaymentActive && notHideDigital
            ? Expanded(
          child: PaymentButtonNew(
            icon: Images.digitalPay,
            title: "Online",
            isSelected:
            selectedindex == 2, // Will not be selected initially
            onTap: () {
              setState(() {
                selectedindex = 2;
              });
              widget.checkoutController.setPaymentMethod(2);
              widget.checkoutController.changeDigitalPaymentName('razor_pay');
              print(widget.checkoutController.paymentMethodIndex);
              // showModalBottomSheet(
              //   context: context,
              //   isScrollControlled: true,
              //   backgroundColor: Colors.transparent,
              //   builder: (con) => PaymentMethodBottomSheet(
              //     isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
              //     isDigitalPaymentActive: widget.isDigitalPaymentActive,
              //     isWalletActive: widget.isWalletActive,
              //     storeId: widget.storeId,
              //     totalPrice: widget.total,
              //     isOfflinePaymentActive: widget.isOfflinePaymentActive,
              //   ),
              // );
            },
          ),
        )
            : const SizedBox(),
        SizedBox(
            width:
            widget.storeId == null && widget.isWalletActive && notHideWallet
                ? Dimensions.paddingSizeLarge
                : 0),
        widget.storeId == null && widget.isWalletActive && notHideWallet
            ? Expanded(
          child: PaymentButtonNew(
            icon: Images.partialWallet,
            title: "Wallet",
            isSelected:
            selectedindex == 1, // Will not be selected initially
            onTap: () {
              if (canSelectWallet) {
                widget.checkoutController.setPaymentMethod(1);
                setState(() {
                  selectedindex = 1;
                });
                print(widget.checkoutController.paymentMethodIndex);
              } else if (widget.checkoutController.isPartialPay) {
                // CoolAlert.show(
                //   context: context,
                //   type: CoolAlertType.error,
                //   text:
                //   'you_can_not_user_wallet_in_partial_payment'.tr,
                // );
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.scale,
                  title: 'Error',
                  desc:
                    'you_can_not_user_wallet_in_partial_payment'.tr,
                  btnOkOnPress: () {},
                  btnOkColor: Theme.of(context).primaryColor,
                ).show();

              } else {
                if (widget.storeId == null &&
                    widget.isWalletActive &&
                    notHideWallet) {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.scale,
                    title: 'Error',
                    desc:
                    "Wallet Amount: ${PriceConverter.convertPrice(walletBalance)}\n${'your_wallet_have_not_sufficient_balance'.tr}",
                    btnOkOnPress: () {},
                    btnOkColor: Theme.of(context).primaryColor,
                  ).show();

                }
              }
            },
          ),
        )
            : const SizedBox(),
      ]),
    ]);
  }
}


class PaymentButtonNew extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;
  const PaymentButtonNew(
      {super.key,
        required this.isSelected,
        required this.icon,
        required this.title,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Stack(
        children: [
          // isSelected
          //     ? Positioned(
          //   top: 5,
          //   right: 5,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Theme.of(context).primaryColor,
          //     ),
          //     padding: const EdgeInsets.all(2),
          //     child:
          //     const Icon(Icons.check, color: Colors.white, size: 18),
          //   ),
          // )
          //     : const SizedBox(),
          Container(
            decoration: BoxDecoration(
              color: isSelected?Theme.of(context).primaryColor:Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor.withOpacity(0.5))),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Image.asset(
                icon,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                  color: isSelected?Theme.of(context).cardColor:Theme.of(context).textTheme.titleLarge?.backgroundColor,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}


/// AUTHORE : SARAVANAN JR
/// PURPOSE : CUSTOM PAYMENT BUTTON
class PaymentButtonNewCustom extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;
  final String subTitle;
  const PaymentButtonNewCustom({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.subTitle,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault + 3.0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.5),
          ),
        ),
        padding: EdgeInsets.symmetric(
            vertical: paymentMethod == PaymentMethod.online
                ? 0
                : Dimensions.paddingSizeExtraSmall),
        child: paymentButton(paymentMethod, context),
      ),
    );
  }

  Widget paymentButton(PaymentMethod paymentMethod, BuildContext context) =>
      switch (paymentMethod) {
        PaymentMethod.cod => Row(
          children: [
            IgnorePointer(
              child: Checkbox(
                shape: const CircleBorder(),
                value: isSelected,
                onChanged: (_) => onTap,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: .start,
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Colors.black54,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (subTitle.isNotEmpty)  Text(
                    subTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        PaymentMethod.wallet => Row(
          children: [
            IgnorePointer(
              child: Checkbox(
                shape: const CircleBorder(),
                value: isSelected,
                onChanged: (_) => onTap,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.black45,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                ],
              ),
            ),

          ],
        ),
        _ => Row(
          children: [
            IgnorePointer(
              child: Checkbox(
                shape: const CircleBorder(),
                value: isSelected,
                onChanged: (_) => onTap,
              ),
            ),
            Image.asset(
              height: 60,
              Images.paymentImages,
            ),
          ],
        ),
      };
}

enum PaymentMethod { cod, wallet, online }


