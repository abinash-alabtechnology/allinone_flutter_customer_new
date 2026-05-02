// ignore_for_file: slash_for_doc_comments


import 'package:handy_allinone/common/widgets/custom_tool_tip_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryOptionButtonWidget extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  const DeliveryOptionButtonWidget({super.key, required this.value, required this.title, required this.charge, required this.isFree,
    this.fromWeb = false, required this.total, required this.deliveryChargeForView, required this.badWeatherCharge, required this.extraChargeForToolTip});

  @override
  State<DeliveryOptionButtonWidget> createState() => _DeliveryOptionButtonWidgetState();
}

class _DeliveryOptionButtonWidgetState extends State<DeliveryOptionButtonWidget> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), (){
      Get.find<CheckoutController>().setOrderType(Get.find<SplashController>().configModel!.homeDeliveryStatus == 1
          && Get.find<CheckoutController>().store!.delivery! ? 'delivery' : 'take_away', notify: true);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      bool select = checkoutController.orderType == widget.value;

      return InkWell(
        onTap: () {
          checkoutController.setOrderType(widget.value);
          checkoutController.setInstruction(-1);

          if(checkoutController.orderType == 'take_away') {
            if(checkoutController.isPartialPay) {
              double tips = 0;
              try{
                tips = double.parse(checkoutController.tipController.text);
              } catch(_) {}
              checkoutController.checkBalanceStatus(widget.total, widget.charge! + tips);
            }
          } else {
            if(checkoutController.isPartialPay){
              checkoutController.changePartialPayment();
            } else {
              checkoutController.setPaymentMethod(-1);
            }

          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: select  ? widget.fromWeb ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: select ? Theme.of(context).primaryColor : Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          child: Row(
            children: [
              Radio(
                value: widget.value,
                groupValue: checkoutController.orderType,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (String? value) {
                  checkoutController.setOrderType(value);
                },
                activeColor: Theme.of(context).primaryColor,
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: robotoMedium.copyWith(color: select ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color)),

                Row(children: [
                  Text(widget.value == 'delivery' ? '${'charge'.tr}: +${widget.deliveryChargeForView}' : 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color)),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  widget.deliveryChargeForView != PriceConverter.convertPrice(0) && widget.value == 'delivery' && checkoutController.extraCharge != null && (widget.deliveryChargeForView != '0') && widget.extraChargeForToolTip > 0 ? CustomToolTip(
                    message: '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(widget.extraChargeForToolTip)}',
                    preferredDirection: AxisDirection.right,
                    child: const Icon(Icons.info, color: Colors.blue, size: 14),
                  ) : const SizedBox(),
                ]),

              ]),
              const SizedBox(width: Dimensions.paddingSizeSmall),

            ],
          ),
        ),
      );
    });
  }
}


enum DeliveryType { delivery, takeaway }

class DeliveryOptionWidgetTab extends StatefulWidget {
  final double? deliveryCharge;
  final double? takeAwayCharge;
  final double total;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final bool? isFree;
  const DeliveryOptionWidgetTab(
      {super.key,
      required this.total,
      required this.deliveryChargeForView,
      required this.badWeatherCharge,
      required this.extraChargeForToolTip,
      required this.deliveryCharge,
      required this.takeAwayCharge,
      required this.isFree});

  @override
  State<DeliveryOptionWidgetTab> createState() =>
      _DeliveryOptionButtonWidgetTabState();
}

class _DeliveryOptionButtonWidgetTabState extends State<DeliveryOptionWidgetTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isDelivery = true;

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 370),
    );
  }

  @override
  void initState() {
    _initializeAnimation();

    _initialTypes();
    super.initState();
  }

  void _initialTypes() {
    Future.delayed(const Duration(milliseconds: 200), () {
      final String type =
          Get.find<SplashController>().configModel!.homeDeliveryStatus == 1 &&
                  Get.find<CheckoutController>().store!.delivery!
              ? 'delivery'
              : 'take_away';
      Get.find<CheckoutController>().setOrderType(type, notify: true);
      _toggle(type);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle(String type) {
    if (type == "take_away") {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, parent) {
        double halfWidth = (parent.maxWidth / 2) - 6.5;
        return Container(
          width: parent.maxWidth,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.all(4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DeliveryOptionButton2Widget(
                        onTap: _toggle,
                        value: 'delivery',
                        title: 'home_delivery'.tr,
                        charge: widget.deliveryCharge,
                        isFree: widget.isFree,
                        total: widget.total,
                        deliveryChargeForView: widget.deliveryChargeForView,
                        badWeatherCharge: widget.badWeatherCharge,
                        extraChargeForToolTip: widget.extraChargeForToolTip,
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                      child: VerticalDivider(
                        color: Colors.white,
                        thickness: 1,
                        radius: BorderRadius.all(Radius.circular(5)),
                        width: 5,
                      ),
                    ),
                    Expanded(
                      child: DeliveryOptionButton2Widget(
                        onTap: _toggle,
                        value: 'take_away',
                        title: 'take_away'.tr,
                        charge: widget.takeAwayCharge,
                        isFree: true,
                        total: widget.total,
                        deliveryChargeForView: widget.deliveryChargeForView,
                        badWeatherCharge: widget.badWeatherCharge,
                        extraChargeForToolTip: widget.extraChargeForToolTip,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    double slideX =
                        _animationController.value * (halfWidth + 6) + 15;
                    return Transform.translate(
                      offset: Offset(slideX, 0),
                      child: Container(
                        width: halfWidth - 20,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 0.2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(Dimensions.radiusSmall)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DeliveryOptionButton2Widget extends StatefulWidget {
  final void Function(String s) onTap;
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  const DeliveryOptionButton2Widget(
      {super.key,
      required this.onTap,
      required this.value,
      required this.title,
      required this.charge,
      required this.isFree,
      this.fromWeb = false,
      required this.total,
      required this.deliveryChargeForView,
      required this.badWeatherCharge,
      required this.extraChargeForToolTip});

  @override
  State<DeliveryOptionButton2Widget> createState() =>
      _DeliveryOptionButton2WidgetState();
}

class _DeliveryOptionButton2WidgetState
    extends State<DeliveryOptionButton2Widget> {
  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = checkoutController.orderType == widget.value;

        return InkWell(
          onTap: () {
            checkoutController.setOrderType(widget.value);
            widget.onTap(checkoutController.orderType!);
            checkoutController.setInstruction(-1);
            if (checkoutController.orderType == 'take_away') {
              if (checkoutController.isPartialPay) {
                double tips = 0;
                try {
                  tips = double.parse(checkoutController.tipController.text);
                } catch (_) {}
                checkoutController.checkBalanceStatus(
                    widget.total, widget.charge! + tips);
              }
            } else {
              if (checkoutController.isPartialPay) {
                checkoutController.changePartialPayment();
              } else {
                checkoutController.setPaymentMethod(-1);
              }
            }
          },
          child: Transform.scale(
            scale: select ? 1 : 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: robotoMedium.copyWith(
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        widget.value == 'delivery'
                            ? '${'charge'.tr}: +${widget.deliveryChargeForView}'
                            : 'free'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.white,
                        )),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    // conditions for free delivery charge and extra charge tooltip
                    widget.deliveryChargeForView !=
                                PriceConverter.convertPrice(0) &&
                            widget.value == 'delivery' &&
                            checkoutController.extraCharge != null &&
                            (widget.deliveryChargeForView != '0') &&
                            widget.extraChargeForToolTip > 0
                        ? CustomToolTip(
                            message:
                                '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(widget.extraChargeForToolTip)}',
                            preferredDirection: AxisDirection.right,
                            child: const Icon(Icons.info,
                                color: Colors.blue, size: 14),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}





class DeliveryOptionButtonWidgetfinal extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  const DeliveryOptionButtonWidgetfinal({super.key, required this.value, required this.title, required this.charge, required this.isFree,
    this.fromWeb = false, required this.total, required this.deliveryChargeForView, required this.badWeatherCharge, required this.extraChargeForToolTip});

  @override
  State<DeliveryOptionButtonWidgetfinal> createState() => _DeliveryOptionButtonWidgetfinalState();
}

class _DeliveryOptionButtonWidgetfinalState extends State<DeliveryOptionButtonWidgetfinal> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), (){
      Get.find<CheckoutController>().setOrderType(Get.find<SplashController>().configModel!.homeDeliveryStatus == 1
          && Get.find<CheckoutController>().store!.delivery! ? 'delivery' : 'take_away', notify: true);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      bool select = checkoutController.orderType == widget.value;

      return InkWell(
        onTap: () {
          checkoutController.setOrderType(widget.value);
          checkoutController.setInstruction(-1);

          if(checkoutController.orderType == 'take_away') {
            if(checkoutController.isPartialPay) {
              double tips = 0;
              try{
                tips = double.parse(checkoutController.tipController.text);
              } catch(_) {}
              checkoutController.checkBalanceStatus(widget.total, widget.charge! + tips);
            }
          } else {
            if(checkoutController.isPartialPay){
              checkoutController.changePartialPayment();
            } else {
              checkoutController.setPaymentMethod(-1);
            }

          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            width: widget.fromWeb?300:double.infinity,
            decoration: BoxDecoration(
              color: select  ? widget.fromWeb ? Colors.orange : Colors.orange : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .center,
              children: [
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Radio(
                  value: widget.value,
                  groupValue: checkoutController.orderType,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (String? value) {
                    checkoutController.setOrderType(value);
                  },
                  activeColor: Colors.black,
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: .center, children: [
                        Text(widget.title, style: robotoBold.copyWith(color: select ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).textTheme.bodyMedium!.color,fontSize: 12)),
                        Row(children: [
                          Text(widget.value == 'delivery' ? '${'charge'.tr}: +${widget.deliveryChargeForView}' : 'free'.tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium!.color)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          widget.deliveryChargeForView != PriceConverter.convertPrice(0) && widget.value == 'delivery' && checkoutController.extraCharge != null && (widget.deliveryChargeForView != '0') && widget.extraChargeForToolTip > 0 ? CustomToolTip(
                            message: '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(widget.extraChargeForToolTip)}',
                            preferredDirection: AxisDirection.right,
                            child: const Icon(Icons.info, color: Colors.blue, size: 14),
                          ) : const SizedBox(),
                        ]),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        ),
      );
    });
  }
}
