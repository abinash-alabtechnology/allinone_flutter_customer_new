import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:lottie/lottie.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/custom_text_field.dart';
import 'package:handy_allinone/features/checkout/widgets/tips_widget.dart';

// class DeliveryManTipsSection extends StatefulWidget {
//   final bool takeAway;
//   final JustTheController tooltipController3;
//   final double totalPrice;
//   final Function(double x) onTotalChange;
//   final int? storeId;
//   const DeliveryManTipsSection({ super.key, required this.takeAway, required this.tooltipController3, required this.totalPrice, required this.onTotalChange, this.storeId});
//
//   @override
//   State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
// }
//
// class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
//   bool canCheckSmall = false;
//
//   @override
//   Widget build(BuildContext context) {
//     double total = widget.totalPrice;
//     return GetBuilder<CheckoutController>(
//       builder: (checkoutController) {
//         return Column(
//           children: [
//             (!widget.takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
//               ),
//               padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//                 Row(children: [
//                   Text('delivery_man_tips'.tr, style: robotoMedium),
//
//                   JustTheTooltip(
//                     backgroundColor: Colors.black87,
//                     controller: widget.tooltipController3,
//                     preferredDirection: AxisDirection.right,
//                     tailLength: 14,
//                     tailBaseWidth: 20,
//                     content: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text('it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'.tr,style: robotoRegular.copyWith(color: Colors.white)),
//                     ),
//                     child: InkWell(
//                       onTap: () => widget.tooltipController3.showTooltip(),
//                       child: const Icon(Icons.info_outline),
//                     ),
//                   ),
//
//                 ]),
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                 SizedBox(
//                   height: (checkoutController.selectedTips == AppConstants.tips.length-1) && checkoutController.canShowTipsField
//                       ? 0 : ResponsiveHelper.isDesktop(context) ? 80 : 60,
//                   child: (checkoutController.selectedTips == AppConstants.tips.length-1) && checkoutController.canShowTipsField
//                   ? const SizedBox() : ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     shrinkWrap: true,
//                     physics: const BouncingScrollPhysics(),
//                     itemCount: AppConstants.tips.length,
//                     itemBuilder: (context, index) {
//                       return TipsWidget(
//                         title: AppConstants.tips[index] == '0' ? 'not_now'.tr : (index != AppConstants.tips.length -1) ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()), forDM: true) : AppConstants.tips[index].tr,
//                         isSelected: checkoutController.selectedTips == index,
//                         isSuggested: index != 0 && AppConstants.tips[index] == checkoutController.mostDmTipAmount.toString(),
//                         onTap: () async {
//                           total = total - checkoutController.tips;
//                           checkoutController.updateTips(index);
//                           if(checkoutController.selectedTips != AppConstants.tips.length-1) {
//                             checkoutController.addTips(double.parse(AppConstants.tips[index]));
//                           }
//                           if(checkoutController.selectedTips == AppConstants.tips.length-1) {
//                             checkoutController.showTipsField();
//                           }
//                           checkoutController.tipController.text = checkoutController.tips.toString();
//
//                           if(checkoutController.isPartialPay || checkoutController.paymentMethodIndex == 1) {
//
//                             checkoutController.checkBalanceStatus((total + checkoutController.tips), 0);
//                           }
//
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: (checkoutController.selectedTips == AppConstants.tips.length-1) && checkoutController.canShowTipsField ? Dimensions.paddingSizeExtraSmall : 0),
//
//                 checkoutController.selectedTips == AppConstants.tips.length-1 ? const SizedBox() : ListTile(
//                   onTap: () => checkoutController.toggleDmTipSave(),
//                   leading: Checkbox(
//                     visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
//                     activeColor: Theme.of(context).primaryColor,
//                     value: checkoutController.isDmTipSave,
//                     onChanged: (bool? isChecked) => checkoutController.toggleDmTipSave(),
//                   ),
//                   title: Text('save_for_later'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
//                   contentPadding: EdgeInsets.zero,
//                   visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
//                   dense: true,
//                   horizontalTitleGap: 0,
//                 ),
//                 SizedBox(height: checkoutController.selectedTips == AppConstants.tips.length-1 ? Dimensions.paddingSizeDefault : 0),
//
//                 checkoutController.selectedTips == AppConstants.tips.length-1 ? Row(children: [
//                   Expanded(
//                     child: CustomTextField(
//                       titleText: 'enter_amount'.tr,
//                       controller: checkoutController.tipController,
//                       inputAction: TextInputAction.done,
//                       inputType: TextInputType.number,
//                       onChanged: (String value) async {
//                         if(value.isNotEmpty) {
//                           try {
//                             if(double.parse(value) >= 0){
//                               if(AuthHelper.isLoggedIn()) {
//                                 total = total - checkoutController.tips;
//                                 await checkoutController.addTips(double.parse(value));
//                                 total = total + checkoutController.tips;
//                                 widget.onTotalChange(total);
//                                 if(Get.find<ProfileController>().userInfoModel!.walletBalance! < total && checkoutController.paymentMethodIndex == 1){
//                                   checkoutController.checkBalanceStatus(total, 0);
//                                   canCheckSmall = true;
//                                 } else if(Get.find<ProfileController>().userInfoModel!.walletBalance! > total && canCheckSmall && checkoutController.isPartialPay){
//                                   checkoutController.checkBalanceStatus(total, 0);
//                                 }
//                               } else {
//                                 checkoutController.addTips(double.parse(value));
//                               }
//
//                             }else{
//                               showCustomSnackBar('tips_can_not_be_negative'.tr);
//                             }
//                           }catch(e) {
//                             showCustomSnackBar('invalid_input'.tr);
//                             checkoutController.addTips(0.0);
//                             checkoutController.tipController.text = checkoutController.tipController.text.substring(0, checkoutController.tipController.text.length-1);
//                             checkoutController.tipController.selection = TextSelection.collapsed(offset: checkoutController.tipController.text.length);
//                           }
//                         }else {
//                           checkoutController.addTips(0.0);
//                         }
//                       },
//
//                     ),
//                   ),
//                   const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                   InkWell(
//                     onTap: () {
//                       checkoutController.updateTips(0);
//                       checkoutController.showTipsField();
//                       if(checkoutController.isPartialPay) {
//                         checkoutController.changePartialPayment();
//                       }
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
//                       ),
//                       padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                       child: const Icon(Icons.clear),
//                     ),
//                   ),
//
//                 ]) : const SizedBox(),
//
//               ]),
//             ) : const SizedBox.shrink(),
//
//             SizedBox(height: (!widget.takeAway && widget.storeId == null && Get.find<SplashController>().configModel!.dmTipsStatus == 1)
//                 ? Dimensions.paddingSizeSmall : 0),
//           ],
//         );
//       }
//     );
//   }
// }


///
class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;

  const DeliveryManTipsSection({
    super.key,
    required this.takeAway,
    required this.tooltipController3,
    required this.totalPrice,
    required this.onTotalChange,
    this.storeId,
  });

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;
  bool isConfettiVisible = false;
  late Timer _timer = Timer(Duration.zero, () {});

  void _showConfetti() {
    setState(() {
      isConfettiVisible = true;
    });

    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        isConfettiVisible = false;
      });
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Stack(
        children: [
          Column(
            children: [
              (!widget.takeAway &&
                  Get.find<SplashController>().configModel!.dmTipsStatus ==
                      1)
                  ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall,
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('delivery_man_tips'.tr, style: robotoBold.copyWith(fontSize: 16)),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: widget.tooltipController3,
                          preferredDirection: AxisDirection.right,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'
                                  .tr,
                              style: robotoRegular.copyWith(
                                  color: Colors.white),
                            ),
                          ),
                          child: InkWell(
                            onTap: () =>
                                widget.tooltipController3.showTooltip(),
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                         Expanded(
                          flex: 3,
                          child: Text(
                            "Day & night our delivery partners bring your "
                                "favourite meals. Thank them with a tip",
                            style: robotoRegular.copyWith(color: Colors.grey.shade700,fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                    ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.asset(
                              'assets/image/delivery_tip.png',
                              fit: BoxFit.fill,
                              height:65,width: 75,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      height: (checkoutController.selectedTips ==
                          AppConstants.tips.length - 1) &&
                          checkoutController.canShowTipsField
                          ? 0
                          : ResponsiveHelper.isDesktop(context)
                          ? 90
                          : 70,
                      child: (checkoutController.selectedTips ==
                          AppConstants.tips.length - 1) &&
                          checkoutController.canShowTipsField
                          ? const SizedBox()
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: AppConstants.tips.length,
                        itemBuilder: (context, index) {
                          return TipsWidget(
                            title: AppConstants.tips[index] == '0'
                                ? 'not_now'.tr
                                : (index !=
                                AppConstants.tips.length -
                                    1)
                                ? PriceConverter.convertPrice(
                              double.parse(AppConstants
                                  .tips[index]
                                  .toString()),
                              forDM: true,
                            )
                                : AppConstants.tips[index].tr,
                            isSelected:
                            checkoutController.selectedTips ==
                                index,
                            isSuggested: index != 0 &&
                                AppConstants.tips[index] ==
                                    checkoutController
                                        .mostDmTipAmount
                                        .toString(),
                            onTap: () async {
                              index == 0 ? null : _showConfetti();
                              total -= checkoutController.tips;
                              checkoutController.updateTips(index);
                              if (checkoutController.selectedTips !=
                                  AppConstants.tips.length - 1) {
                                checkoutController.addTips(
                                  double.parse(
                                      AppConstants.tips[index]),
                                );
                              }
                              if (checkoutController.selectedTips ==
                                  AppConstants.tips.length - 1) {
                                checkoutController.showTipsField();
                              }
                              checkoutController
                                  .tipController.text =
                                  checkoutController.tips
                                      .toString();

                              if (checkoutController.isPartialPay ||
                                  checkoutController
                                      .paymentMethodIndex ==
                                      1) {
                                checkoutController
                                    .checkBalanceStatus(
                                  (total + checkoutController.tips),
                                  0,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: (checkoutController.selectedTips ==
                          AppConstants.tips.length - 1) &&
                          checkoutController.canShowTipsField
                          ? Dimensions.paddingSizeExtraSmall
                          : 0,
                    ),
                    checkoutController.selectedTips ==
                        AppConstants.tips.length - 1
                        ? const SizedBox()
                        : Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () =>
                                checkoutController.toggleDmTipSave(),
                            leading: Checkbox(
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: -4),
                              activeColor: Theme.of(context).primaryColor,
                              value: checkoutController.isDmTipSave,
                              onChanged: (bool? isChecked) =>
                                  checkoutController.toggleDmTipSave(),
                            ),
                            title: Text(
                              'save_for_later'.tr,
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor),
                            ),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            dense: true,
                            horizontalTitleGap: 0,
                          ),
                        ),
                    SizedBox(
                      height: checkoutController.selectedTips ==
                          AppConstants.tips.length - 1
                          ? Dimensions.paddingSizeDefault
                          : 0,
                    ),
                    checkoutController.selectedTips ==
                        AppConstants.tips.length - 1
                        ? Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            titleText: 'enter_amount'.tr,
                            controller:
                            checkoutController.tipController,
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.number,
                            onChanged: (String value) async {
                              if (value.isNotEmpty) {
                                try {
                                  double parsedValue =
                                  double.parse(value);
                                  if (parsedValue >= 0) {
                                    if (AuthHelper.isLoggedIn()) {
                                      total -=
                                          checkoutController.tips;
                                      await checkoutController
                                          .addTips(parsedValue);
                                      total +=
                                          checkoutController.tips;
                                      widget.onTotalChange(total);
                                      if (Get.find<ProfileController>()
                                          .userInfoModel!
                                          .walletBalance! <
                                          total &&
                                          checkoutController
                                              .paymentMethodIndex ==
                                              1) {
                                        checkoutController
                                            .checkBalanceStatus(
                                            total, 0);
                                        canCheckSmall = true;
                                      } else if (Get.find<
                                          ProfileController>()
                                          .userInfoModel!
                                          .walletBalance! >
                                          total &&
                                          canCheckSmall &&
                                          checkoutController
                                              .isPartialPay) {
                                        checkoutController
                                            .checkBalanceStatus(
                                            total, 0);
                                      }
                                    } else {
                                      checkoutController
                                          .addTips(parsedValue);
                                    }
                                  } else {
                                    showCustomSnackBar(
                                        'tips_can_not_be_negative'
                                            .tr);
                                  }
                                } catch (e) {
                                  showCustomSnackBar(
                                      'invalid_input'.tr);
                                  checkoutController.addTips(0.0);
                                  total -= checkoutController.tips;
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                            width: Dimensions.paddingSizeLarge),
                      ],
                    )
                        : const SizedBox(),
                  ],
                ),
              )
                  : const SizedBox(),
            ],
          ),
          if (isConfettiVisible)
            Positioned(
              left: 0,
              bottom: -40,
              right: 0,
              child: Lottie.asset(
                'assets/animation/c.json',
                repeat: false,
                animate: true,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
        ],
      );
    });
  }
}

