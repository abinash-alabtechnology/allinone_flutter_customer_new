import 'dart:async';
import 'package:photo_view/photo_view.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/features/order/domain/models/order_details_model.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/confirmation_dialog.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_dialog.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/features/checkout/widgets/offline_success_dialog.dart';
import 'package:handy_allinone/features/order/widgets/cancellation_dialogue_widget.dart';
import 'package:handy_allinone/features/order/widgets/order_calcuation_widget.dart';
import 'package:handy_allinone/features/order/widgets/order_info_widget.dart';
import 'package:handy_allinone/features/review/screens/rate_review_screen.dart';
import 'package:handy_allinone/features/order/widgets/tracking_stepper_widget.dart';
import 'package:handy_allinone/features/order/widgets/traking_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   final OrderModel? orderModel;
//   final int? orderId;
//   final bool fromNotification;
//   final bool fromOfflinePayment;
//   final String? contactNumber;
//   const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.fromNotification = false, this.fromOfflinePayment = false, this.contactNumber});
//
//   @override
//   OrderDetailsScreenState createState() => OrderDetailsScreenState();
// }
//
// class OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   Timer? _timer;
//   double? _maxCodOrderAmount;
//   bool? _isCashOnDeliveryActive = false;
//   final ScrollController scrollController = ScrollController();
//
//   void _loadData(BuildContext context, bool reload) async {
//     await Get.find<OrderController>().trackOrder(widget.orderId.toString(), reload ? null : widget.orderModel, false, contactNumber: widget.contactNumber).then((value) {
//       if(widget.fromOfflinePayment) {
//         Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
//       }
//     });
//     Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: widget.contactNumber);
//     Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
//   }
//
//   void _startApiCall(){
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
//       await Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: widget.contactNumber);
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     _loadData(context, false);
//
//     _startApiCall();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: Navigator.canPop(context),
//       onPopInvokedWithResult: (didPop, result) async {
//         if(widget.fromNotification || widget.fromOfflinePayment) {
//           Get.offAllNamed(RouteHelper.getInitialRoute());
//         } else {
//           return;
//         }
//       },
//       child: Scaffold(
//         appBar: CustomAppBar3(
//           iconcolor: Theme.of(context).cardColor,
//             textcolor: Theme.of(context).cardColor,
//             bgcolor: Theme.of(context).primaryColor,
//             title: "Order Id : ${widget.orderId}", onBackPressed: () {
//           if(widget.fromNotification || widget.fromOfflinePayment) {
//             Get.offAllNamed(RouteHelper.getInitialRoute());
//           } else {
//             Get.back();
//           }
//         }),
//         endDrawer: const MenuDrawer(),
//         endDrawerEnableOpenDragGesture: false,
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         body: SafeArea(child: GetBuilder<OrderController>(builder: (orderController) {
//           double deliveryCharge = 0;
//           double itemsPrice = 0;
//           double discount = 0;
class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromNotification;
  final bool fromOfflinePayment;
  final String? contactNumber;
  const OrderDetailsScreen({super.key, required this.orderModel, required this.orderId, this.fromNotification = false, this.fromOfflinePayment = false, this.contactNumber});

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer? _timer;
  double? _maxCodOrderAmount;
  bool? _isCashOnDeliveryActive = false;
  final ScrollController scrollController = ScrollController();

  void _loadData(BuildContext context, bool reload) async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), null, false, contactNumber: widget.contactNumber).then((value) {
      if(widget.fromOfflinePayment) {
        Future.delayed(const Duration(seconds: 2), () => showAnimatedDialog(Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      }
    });
    Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: widget.contactNumber);
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
  }

  void _startApiCall(){
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await Get.find<OrderController>().timerTrackOrder(widget.orderId.toString(), contactNumber: widget.contactNumber);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData(context, false);

    _startApiCall();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }
  @override
  Size get preferredSize =>
      Size(Get.width, GetPlatform.isDesktop ? 100 : 60);
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromNotification || widget.fromOfflinePayment) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          leading: InkWell(
            onTap:(){
              Get.back();
            },
              child: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).cardColor)),
          title: Text( 'order_details'.tr,
              style: robotoBold.copyWith(color: Theme.of(context).cardColor)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.message_rounded, color: Theme.of(context).cardColor),
              onPressed: () {
                Get.toNamed(RouteHelper.getSupportRoute());
              },
            ),
          ],
        ),

        // CustomAppBar(title: 'order_details'.tr, onBackPressed: () {
        //   if(widget.fromNotification || widget.fromOfflinePayment) {
        //     Get.offAllNamed(RouteHelper.getInitialRoute());
        //   } else {
        //     Get.back();
        //   }
        // }),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(child: GetBuilder<OrderController>(builder: (orderController) {
          double deliveryCharge = 0;
          double itemsPrice = 0;
          double discount = 0;
          double couponDiscount = 0;
          double tax = 0;
          double addOns = 0;
          double dmTips = 0;
          double additionalCharge = 0;
          double extraPackagingCharge = 0;
          double otherCharge = 0;
          String otherchargelabel="";
          double referrerBonusAmount = 0;
          OrderModel? order = orderController.trackModel;
          bool parcel = false;
          bool prescriptionOrder = false;
          bool taxIncluded = false;
          bool ongoing = false;
          bool showChatPermission = true;


          if(orderController.orderDetails != null  && order != null) {
            parcel = order.orderType == 'parcel';
            prescriptionOrder = order.prescriptionOrder!;
            deliveryCharge = order.deliveryCharge!;
            couponDiscount = order.couponDiscountAmount!;
            discount = order.storeDiscountAmount! + order.flashAdminDiscountAmount! + order.flashStoreDiscountAmount!;
            tax = order.totalTaxAmount!;
            dmTips = order.dmTips!;
            taxIncluded = order.taxStatus!;
            additionalCharge = order.additionalCharge!;
            extraPackagingCharge = order.extraPackagingAmount!;
            otherCharge=order.otherCharge??0;
            otherchargelabel=order.otherChargelabel??"";
            referrerBonusAmount = order.referrerBonusAmount!;
            if(prescriptionOrder) {
              double orderAmount = order.orderAmount ?? 0;
              itemsPrice = (orderAmount + discount) - ((taxIncluded ? 0 : tax) + deliveryCharge) - dmTips - additionalCharge;
            } else{
              for(OrderDetailsModel orderDetails in orderController.orderDetails!) {
                for(AddOn addOn in orderDetails.addOns!) {
                  addOns = addOns + (addOn.price! * addOn.quantity!);
                }
                itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
              }
            }

            if(!parcel && order.store != null) {
              for(ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
                if(zData.id == order.store!.zoneId){
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
                for(Modules m in zData.modules!) {
                  if(m.id == order.store!.moduleId) {
                    _maxCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                    break;
                  }
                }
              }
            }

            if (order.store != null) {
              if (order.store!.storeBusinessModel == 'commission') {
                showChatPermission = true;
              } else if (order.store!.storeSubscription != null && order.store!.storeBusinessModel == 'subscription') {
                showChatPermission = order.store!.storeSubscription!.chat == 1;
              } else {
                showChatPermission = false;
              }
            } else {
              showChatPermission = AuthHelper.isLoggedIn();
            }

            ongoing = (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested'
                && order.orderStatus != 'refunded' && order.orderStatus != 'refund_request_canceled');

          }
          bool isDelivar = (Get.find<SplashController>().configModel?.delivarBooking ?? false) || (order?.delivarBooking ?? false);
          if(!isDelivar && orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty) {
            for(var detail in orderController.orderDetails!) {
              if(detail.delivarBooking ?? false) {
                isDelivar = true;
                break;
              }
            }
          }

          double subTotal = itemsPrice + addOns;
          double total = itemsPrice + addOns - discount + (taxIncluded ? 0 : tax) + deliveryCharge - couponDiscount + dmTips + additionalCharge + otherCharge+ extraPackagingCharge - referrerBonusAmount;

          return orderController.orderDetails != null && order != null && orderController.trackModel != null ? Column(children: [
            ResponsiveHelper.isDesktop(context) ? Container(
              height: 64,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
              child: Center(child: Text('order_details'.tr, style: robotoMedium)),
            ) : const SizedBox(),

            Expanded(
                child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column (
                children: [

                  if(!isDelivar && ongoing)
                    Stack(children: [
                      TrackingMapWidget(track: order),
                      Positioned(
                        top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                        child: TrackingStepperWidget(status: order.orderStatus, takeAway: order.orderType == 'take_away'),
                      ),
                    ]),

                  ResponsiveHelper.isDesktop(context) ?
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      flex: 6,
                      child : OrderInfoWidget(
                        order: order, ongoing: ongoing, parcel: parcel, prescriptionOrder: prescriptionOrder,
                        timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                        orderController: orderController, showChatPermission: showChatPermission,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    Expanded(
                      flex: 4,
                      child: OrderCalculationWidget(
                        orderController: orderController, order: order, ongoing: ongoing, parcel: parcel,
                        prescriptionOrder: prescriptionOrder, deliveryCharge: deliveryCharge, itemsPrice: itemsPrice,
                        discount: discount, couponDiscount: couponDiscount, tax: tax, addOns: addOns, dmTips: dmTips,
                        taxIncluded: taxIncluded, subTotal: subTotal, total: total,
                        bottomView: _bottomView(orderController, order, parcel, total, isDelivar, ongoing), extraPackagingAmount: extraPackagingCharge,
                        othercharge: otherCharge,otherchargelabel: otherchargelabel,
                        referrerBonusAmount: referrerBonusAmount, timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                      ),
                    ),
                  ]) : const SizedBox(),

                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : OrderInfoWidget(
                    order: order, ongoing: ongoing, parcel: parcel, prescriptionOrder: prescriptionOrder,
                    timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                    orderController: orderController, showChatPermission: showChatPermission,
                  ),

                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : OrderCalculationWidget(
                    orderController: orderController, order: order, ongoing: ongoing, parcel: parcel,
                    prescriptionOrder: prescriptionOrder, deliveryCharge: deliveryCharge, itemsPrice: itemsPrice,
                    discount: discount, couponDiscount: couponDiscount, tax: tax, addOns: addOns, dmTips: dmTips, taxIncluded: taxIncluded, subTotal: subTotal, total: total,
                    bottomView: _bottomView(orderController, order, parcel, total, isDelivar, ongoing), extraPackagingAmount: extraPackagingCharge, referrerBonusAmount: referrerBonusAmount,
                    othercharge: otherCharge,otherchargelabel: otherchargelabel,
                    timerCancel : () => _timer?.cancel(), startApiCall : () =>  _startApiCall(),
                  ),

                ],
              ))),
            )),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : _bottomView(orderController, order, parcel, total, isDelivar, ongoing),

          ]) : const Center(child: CircularProgressIndicator());
        })),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.cancel, color: Colors.red),
          )),

        ]),
      );
    },
  );

  Widget _bottomView(OrderController orderController, OrderModel order, bool parcel, double totalPrice, bool isDelivar, bool ongoing) {
    return Column(children: [
      !orderController.showCancelled ? Center(
        child: SizedBox(
            width: Dimensions.webMaxWidth,
            child:
            ResponsiveHelper.isDesktop(context)?
            Column(children: [
              ((order.orderStatus == 'pending' && order.paymentMethod != 'digital_payment') || order.orderStatus == 'accepted' || order.orderStatus == 'confirmed'
                  || order.orderStatus == 'processing' || order.orderStatus == 'handover'|| order.orderStatus == 'picked_up') ? CustomButton(
                buttonText: parcel ? 'track_delivery'.tr : 'track_order'.tr,
                margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                onPressed: () async{
                  _timer?.cancel();
                  
                  // Check for Delivar booking in the config OR main OrderModel OR in the individual items
                  bool isDelivar = (Get.find<SplashController>().configModel?.delivarBooking ?? false) || (order.delivarBooking ?? false);
                  String? trackingId = order.publicTrackingId;

                  if(!isDelivar && orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty) {
                    for(var detail in orderController.orderDetails!) {
                      if(detail.delivarBooking ?? false) {
                        isDelivar = true;
                        trackingId = detail.publicTrackingId;
                        break;
                      }
                    }
                  }

                  if(isDelivar) {
                    String? baseUrl = Get.find<SplashController>().configModel?.deliverurl;
                    if(baseUrl != null && baseUrl.isNotEmpty && trackingId != null && trackingId.isNotEmpty) {
                      String fullUrl = baseUrl.endsWith('/') ? '$baseUrl$trackingId' : '$baseUrl/$trackingId';
                      debugPrint('Generating Delivar Tracking URL: $fullUrl');
                      await Get.toNamed(RouteHelper.getDelivarTrackingRoute(fullUrl))?.whenComplete(() {
                        _startApiCall();
                      });
                    } else {
                      await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, widget.contactNumber))?.whenComplete(() {
                        _startApiCall();
                      });
                    }
                  } else {
                    // Integrated tracking is already shown at the top, scroll to it
                    if(scrollController.hasClients) {
                      scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }
                  }
                },
              ) : const SizedBox(),

              (order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' && order.paymentMethod == 'digital_payment' && _isCashOnDeliveryActive!) ? CustomButton(
                buttonText: 'switch_to_cod'.tr,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                onPressed: () {
                  Get.dialog(ConfirmationDialog(
                      icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                      onYesPressed: () {

                        if((((_maxCodOrderAmount != null && totalPrice < _maxCodOrderAmount!) || _maxCodOrderAmount == null || _maxCodOrderAmount == 0) && !parcel) || parcel){
                          orderController.switchToCOD(order.id.toString());
                        }else{
                          if(Get.isDialogOpen!) {
                            Get.back();
                          }
                          showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(_maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                        }
                      }
                  ));
                },
              ): const SizedBox(),

              (order.orderStatus == 'pending' && (Get.find<AuthController>().isLoggedIn() ? true : (orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty  && orderController.orderDetails?[0].isGuest == 1 ? true : false))) ? Padding(
                padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: CustomButton(
                  isBorder: true,
                  color: Colors.transparent,
                  onPressed: () {
                    orderController.setOrderCancelReason('');
                    Get.dialog(CancellationDialogueWidget(orderId: order.id, contactNumber: widget.contactNumber));
                  },
                  buttonText: parcel ? 'cancel_delivery'.tr : 'cancel_order'.tr,
                  textColor: Theme.of(context).disabledColor,
                ),
              ) : const SizedBox(),

            ]):
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Track Order Button
                if (((order.orderStatus == 'pending' && order.paymentMethod != 'digital_payment') ||
                    order.orderStatus == 'accepted' ||
                    order.orderStatus == 'confirmed' ||
                    order.orderStatus == 'processing' ||
                    order.orderStatus == 'handover' ||
                    order.orderStatus == 'picked_up') && isDelivar)
                Expanded(
  flex: 1,
  child: CustomButton(
    buttonText: parcel ? 'track_delivery'.tr : 'track_order'.tr,
    margin: const EdgeInsets.symmetric(
      horizontal: Dimensions.paddingSizeDefault,
      vertical: Dimensions.paddingSizeSmall,
    ),
    onPressed: () async {
      _timer?.cancel();

      bool isDelivar =
          (Get.find<SplashController>().configModel?.delivarBooking ?? false) ||
          (order.delivarBooking ?? false);

      String? trackingId = order.publicTrackingId;

      if (!isDelivar &&
          orderController.orderDetails != null &&
          orderController.orderDetails!.isNotEmpty) {
        for (var detail in orderController.orderDetails!) {
          if (detail.delivarBooking ?? false) {
            isDelivar = true;
            trackingId = detail.publicTrackingId;
            break;
          }
        }
      }

      debugPrint(
          "=====> Is Delivar Booking: $isDelivar | Tracking ID: $trackingId");

      if (isDelivar) {
        String? baseUrl =
            Get.find<SplashController>().configModel?.deliverurl;

        print("=====> Delivar Base URL: $baseUrl");

        /// ONLY navigate if baseUrl exists
        if (baseUrl != null &&
            baseUrl.isNotEmpty &&
            trackingId != null &&
            trackingId.isNotEmpty) {
          String fullUrl = baseUrl.endsWith('/')
              ? '$baseUrl$trackingId'
              : '$baseUrl/$trackingId';

          debugPrint('Generating Delivar Tracking URL: $fullUrl');

          await Get.toNamed(
            RouteHelper.getDelivarTrackingRoute(fullUrl),
          )?.whenComplete(() {
            _startApiCall();
          });
        } else {
          debugPrint(
              'Delivar booking but baseUrl or trackingId missing → No navigation');
        }
      } else {
        /// Integrated tracking is already shown at the top, scroll to it
        if(scrollController.hasClients) {
          scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      }
    },
  ),
),

                if ((order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' &&
                    order.paymentMethod == 'digital_payment' && _isCashOnDeliveryActive!))
                  const SizedBox(width: 15),

                // Switch to COD Button
                if ((order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' &&
                    order.paymentMethod == 'digital_payment' && _isCashOnDeliveryActive!))
                  Expanded(
                    flex: 1,
                    child: CustomButton(
                      buttonText: 'switch_to_cod'.tr,
                      margin: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall),
                      onPressed: () {
                        Get.dialog(ConfirmationDialog(
                          icon: Images.warning,
                          description: 'are_you_sure_to_switch'.tr,
                          onYesPressed: () {
                            if ((((_maxCodOrderAmount != null && totalPrice < _maxCodOrderAmount!) ||
                                _maxCodOrderAmount == null ||
                                _maxCodOrderAmount == 0) &&
                                !parcel) ||
                                parcel) {
                              orderController.switchToCOD(order.id.toString());
                            } else {
                              if (Get.isDialogOpen!) Get.back();
                              showCustomSnackBar(
                                '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(_maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}',
                              );
                            }
                          },
                        ));
                      },
                    ),
                  ),

                if ((order.orderStatus == 'pending' &&
                    (Get.find<AuthController>().isLoggedIn()
                        ? true
                        : (orderController.orderDetails != null &&
                        orderController.orderDetails!.isNotEmpty &&
                        orderController.orderDetails?[0].isGuest == 1))) &&
                    (((order.orderStatus == 'pending' && order.paymentMethod != 'digital_payment') ||
                        order.orderStatus == 'accepted' ||
                        order.orderStatus == 'confirmed' ||
                        order.orderStatus == 'processing' ||
                        order.orderStatus == 'handover' ||
                        order.orderStatus == 'picked_up') && isDelivar ||
                        (order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' &&
                            order.paymentMethod == 'digital_payment' && _isCashOnDeliveryActive!)))
                  const SizedBox(width: 15),

                // Cancel Order Button
                if ((order.orderStatus == 'pending' &&
                    (Get.find<AuthController>().isLoggedIn()
                        ? true
                        : (orderController.orderDetails != null &&
                        orderController.orderDetails!.isNotEmpty &&
                        orderController.orderDetails?[0].isGuest == 1))))
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall),
                      child: CustomButton(
                        isBorder: true,
                        color: Colors.transparent,
                        onPressed: () {
                          orderController.setOrderCancelReason('');
                          Get.dialog(CancellationDialogueWidget(
                              orderId: order.id, contactNumber: widget.contactNumber));
                        },
                        buttonText: parcel ? 'cancel_delivery'.tr : 'cancel_order'.tr,
                        textColor: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
              ],
            )

//               Row(children: [
//                 ((order.orderStatus == 'pending' && order.paymentMethod != 'digital_payment') || order.orderStatus == 'accepted' || order.orderStatus == 'confirmed'
//                     || order.orderStatus == 'processing' || order.orderStatus == 'handover'|| order.orderStatus == 'picked_up') ? Container(
//                   width: Get.width/2.2,
//                       child: CustomButton(
//                                         buttonText: parcel ? 'track_delivery'.tr : 'track_order'.tr,
//                                         margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
//                                         onPressed: () async{
//                       _timer?.cancel();
//                       await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id, widget.contactNumber))?.whenComplete(() {
//                         _startApiCall();
//                       });
//                                         },
//                                       ),
//                     ) : const SizedBox(),
//                 SizedBox(width: 15,),
//
//                 (order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' && order.paymentMethod == 'digital_payment' && _isCashOnDeliveryActive!) ? Container(
//                   width: Get.width/2.2,
//
//                   child: CustomButton(
//                     buttonText: 'switch_to_cod'.tr,
//                     margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
//                     onPressed: () {
//                       Get.dialog(ConfirmationDialog(
//                           icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
//                           onYesPressed: () {
//
//                             if((((_maxCodOrderAmount != null && totalPrice < _maxCodOrderAmount!) || _maxCodOrderAmount == null || _maxCodOrderAmount == 0) && !parcel) || parcel){
//                               orderController.switchToCOD(order.id.toString());
//                             }else{
//                               if(Get.isDialogOpen!) {
//                                 Get.back();
//                               }
//                               showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(_maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
//                             }
//                           }
//                       ));
//                     },
//                   ),
//                 ): const SizedBox(),
// SizedBox(width: 15,),
//                 (order.orderStatus == 'pending' && (Get.find<AuthController>().isLoggedIn() ? true : (orderController.orderDetails != null && orderController.orderDetails!.isNotEmpty  && orderController.orderDetails?[0].isGuest == 1 ? true : false))) ? Container(
//                   width: Get.width/2.2,
//                   child: Padding(
//                     padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
//                     child: CustomButton(
//                       isBorder: true,
//                       color: Colors.transparent,
//                       onPressed: () {
//                         orderController.setOrderCancelReason('');
//                         Get.dialog(CancellationDialogueWidget(orderId: order.id, contactNumber: widget.contactNumber));
//                       },
//                       buttonText: parcel ? 'cancel_delivery'.tr : 'cancel_order'.tr,
//                       textColor: Theme.of(context).disabledColor,
//                     ),
//                   ),
//                 ) : const SizedBox(),
//
//               ]),
        ),
      ) : Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          height: 50,
          margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text('order_cancelled'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
        ),
      ),

      !AuthHelper.isGuestLoggedIn() && (order.orderStatus == 'delivered' && (parcel ? order.deliveryMan != null : (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemCampaignId == null))) ? Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: CustomButton(
            buttonText: 'review'.tr,
            onPressed: () {
              List<OrderDetailsModel> orderDetailsList = [];
              List<int?> orderDetailsIdList = [];
              for (var orderDetail in orderController.orderDetails!) {
                if(!orderDetailsIdList.contains(orderDetail.itemDetails!.id)) {
                  orderDetailsList.add(orderDetail);
                  orderDetailsIdList.add(orderDetail.itemDetails!.id);
                }
              }
              Get.toNamed(RouteHelper.getReviewRoute(), arguments: RateReviewScreen(
                orderDetailsList: orderDetailsList, deliveryMan: order.deliveryMan, orderID: order.id,
              ));
            },
          ),
        ),
      ) : const SizedBox(),

      (order.orderStatus == 'failed' && Get.find<SplashController>().configModel!.cashOnDelivery!) ? Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: CustomButton(
            buttonText: 'switch_to_cash_on_delivery'.tr,
            onPressed: () {
              Get.dialog(ConfirmationDialog(
                  icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                  onYesPressed: () {
                    orderController.switchToCOD(order.id.toString()).then((isSuccess) {
                      Get.back();
                      if(isSuccess) {
                        Get.back();
                      }
                    });
                  }
              ));
            },
          ),
        ),
      ) : const SizedBox(),
    ]);
  }
}
