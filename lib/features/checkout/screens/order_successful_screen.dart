import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/features/auth/widgets/auth_dialog_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:handy_allinone/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/helper/price_converter.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final String? contactPersonNumber;
  final bool? createAccount;
  final String guestId;
  const OrderSuccessfulScreen({super.key, required this.orderID, this.contactPersonNumber, this.createAccount = false, required this.guestId});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {

  bool? _isCashOnDeliveryActive = false;
  String? orderId;

  @override
  void initState() {
    super.initState();
    debugPrint("Navigated to the success screen");
    Future.delayed(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedOrderId = prefs.getString('order_id');
      String orderIdToUse;
      if (savedOrderId != null && savedOrderId.isNotEmpty) {
        orderIdToUse = savedOrderId;
        orderId=savedOrderId;
        debugPrint("✅ Using order ID from SharedPreferences: $orderIdToUse");
      }
      else {
        orderIdToUse = widget.orderID ?? '';
        orderId=widget.orderID;

        if (orderIdToUse.contains('?')) {
          var parts = orderIdToUse.split('?');
          orderIdToUse = parts[0].trim();
        }
        debugPrint("⚠️ Using order ID from widget: $orderIdToUse");
      }
      Get.find<OrderController>().trackOrder(
        orderIdToUse,
        null,
        false,
        contactNumber: widget.contactPersonNumber,
      );
      Get.find<OrderController>().getOrderDetails(orderIdToUse);
    });
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: Container(
          color: Theme.of(context).cardColor,
          child: GetBuilder<OrderController>(builder: (orderController){
            double total = 0;
            bool success = true;
            bool parcel = false;
            double? maximumCodOrderAmount;
            if(orderController.trackModel != null) {
              debugPrint(orderController.trackModel!.paymentStatus);
              debugPrint("dsfsfsdf");
              total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
              success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery' || orderController.trackModel!.paymentMethod == 'partial_payment';
              parcel = orderController.trackModel!.paymentMethod == 'parcel';
              for(ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
                int currentModuleId = Get.find<SplashController>().module?.id ?? Get.find<SplashController>().getHandymanModuleId();
                for(Modules m in zData.modules!) {
                  if(m.id == currentModuleId) {
                    maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                    break;
                  }
                }
                if(zData.id ==  AddressHelper.getUserAddressFromSharedPref()!.zoneId){
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
              }

              if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
                Future.delayed(const Duration(seconds: 1), () {
                  Get.dialog(PaymentFailedDialog(
                    orderID: orderId, isCashOnDelivery: _isCashOnDeliveryActive, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount,
                    orderType: parcel ? 'parcel' : 'delivery', guestId: widget.guestId,
                  ), barrierDismissible: false);
                });
              }
            }

            bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';

            return orderController.trackModel != null ? Center(
              child: isPharmacy ? _pharmacySuccessView(orderController) : SingleChildScrollView(
                child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  success?Stack(
                    children: [
                      Lottie.asset(
                        "assets/animation/tick.json",
                        height: 200,width: 200
                      ),
                      // Lottie.asset(
                      //     "assets/animation/c.json",
                      //     height: 200,width: 200
                      // ),
                    ],
                  ):
                  Image.asset(success ? Images.checked : Images.warning, width: 100, height: 100),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(
                    success ? parcel ? 'you_placed_the_parcel_request_successfully'.tr
                        : 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge,color: Colors.green.shade600,fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(
                    padding:  EdgeInsets.symmetric(vertical:Dimensions.paddingSizeLarge*2,horizontal: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white,
                        Colors.green.shade100,
                        Colors.white
                      ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 1)],
                        ),
                        child: Column(
                          children: [

                            widget.createAccount! ? Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(
                                  'and_create_account_successfully'.tr,
                                  style: robotoMedium,
                                ),
                                InkWell(
                                  onTap: () {
                                    if(ResponsiveHelper.isDesktop(context)){
                                      Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: false, backFromThis: false)));
                                    }else{
                                      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                    child: Text('sign_in'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                                  ),
                                ),
                              ]),
                            ) : const SizedBox(),

                            AuthHelper.isGuestLoggedIn() ? const SizedBox():SelectableText(
                                (orderId != null && orderId != "null")
                                    ? '${'order_id'.tr}: $orderId'
                                    : "",
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                              child: Text(
                                success ? parcel ? 'your_parcel_request_is_placed_successfully'.tr
                                    : 'your_order_is_placed_successfully'.tr : 'your_order_is_failed_to_place_because'.tr,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  ResponsiveHelper.isDesktop(context) && (success && Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && total.floor() > 0 ) && AuthHelper.isLoggedIn()  ? Column(children: [

                    Image.asset(Get.find<ThemeController>().darkTheme ? Images.congratulationDark : Images.congratulationLight, width: 150, height: 150),

                    Text('congratulations'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Text(
                        '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).disabledColor),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ]) : const SizedBox.shrink() ,
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 600; // Responsive breakpoint

                        return isWide
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomButton(
                                buttonText: 'track_order'.tr,
                                icon:Icons.delivery_dining,
                                onPressed: () async {
                                  final int orderIdInt = int.tryParse(orderId ?? '0') ?? 0;
                                  if (AuthHelper.isLoggedIn()) {
                                    bool isDelivar = (Get.find<SplashController>().configModel?.delivarBooking ?? false) || (orderController.trackModel!.delivarBooking ?? false);
                                    String? trackingId = orderController.trackModel!.publicTrackingId;

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
                                        await Get.toNamed(RouteHelper.getDelivarTrackingRoute(fullUrl));
                                      } else {
                                        await Get.toNamed(RouteHelper.getOrderTrackingRoute(orderIdInt, null));
                                      }
                                    } else {
                                      await Get.toNamed(RouteHelper.getOrderTrackingRoute(orderIdInt, null));
                                    }
                                  }
                                  Get.offAllNamed(RouteHelper.getInitialRoute());
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                icon: Icons.home,
                                buttonText: 'back_to_home'.tr,
                                onPressed: () {
                                  if (AuthHelper.isLoggedIn()) {
                                    Get.find<AuthController>()
                                        .saveEarningPoint(total.toStringAsFixed(0));
                                  }
                                  Get.offAllNamed(RouteHelper.getInitialRoute());
                                },
                              ),
                            ),
                          ],
                        )
                            : Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                icon:Icons.delivery_dining,
                                radius: 12,
                                buttonText: 'track_order'.tr,
                                onPressed: () async {
                                  final int orderIdInt = int.tryParse(orderId ?? '0') ?? 0;
                                  if (AuthHelper.isLoggedIn()) {
                                    bool isDelivar = (Get.find<SplashController>().configModel?.delivarBooking ?? false) || (orderController.trackModel!.delivarBooking ?? false);
                                    String? trackingId = orderController.trackModel!.publicTrackingId;

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
                                        await Get.toNamed(RouteHelper.getDelivarTrackingRoute(fullUrl));
                                      } else {
                                        await Get.toNamed(RouteHelper.getOrderTrackingRoute(orderIdInt, null));
                                      }
                                    } else {
                                      await Get.toNamed(RouteHelper.getOrderTrackingRoute(orderIdInt, null));
                                    }
                                  }
                                  Get.offAllNamed(RouteHelper.getInitialRoute());
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomButton(
                                color: Colors.black87,
                                radius: 12,
                                icon:Icons.home,
                                buttonText: 'back_to_home'.tr,
                                onPressed: () {
                                  if (AuthHelper.isLoggedIn()) {
                                    Get.find<AuthController>()
                                        .saveEarningPoint(total.toStringAsFixed(0));
                                  }
                                  Get.offAllNamed(RouteHelper.getInitialRoute());
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),


                  // Padding(
                  //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  //   child: Row(
                  //     children: [
                  //       CustomButton(
                  //       width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                  //       buttonText: 'back_to_home'.tr, onPressed: () {
                  //         if(AuthHelper.isLoggedIn()) {
                  //           Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
                  //         }
                  //         Get.offAllNamed(RouteHelper.getInitialRoute());
                  //       }),
                  //       SizedBox(width: 10,),
                  //       CustomButton(
                  //           width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                  //           buttonText: 'track_order'.tr, onPressed: () async {
                  //         final int orderIdInt = int.tryParse(orderId ?? '0') ?? 0;
                  //         if(AuthHelper.isLoggedIn()) {
                  //           await Get.toNamed(RouteHelper.getOrderTrackingRoute(orderIdInt,null));
                  //         }
                  //         Get.offAllNamed(RouteHelper.getInitialRoute());
                  //       })
                  //     ],
                  //   ),
                  // ),
                ]))),
              ),
            ) : const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }

  Widget _pharmacySuccessView(OrderController orderController) {
    String? orderIdToUse = orderId ?? widget.orderID;
    var trackModel = orderController.trackModel!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 40),
        
        // Large Check Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 80, color: Color(0xFF16A34A)),
        ),
        const SizedBox(height: 24),

        Text(
          'Order Confirmed!',
          style: robotoBold.copyWith(fontSize: 24, color: Colors.black),
        ),
        const SizedBox(height: 8),

        Text(
          'Order ID: ${orderIdToUse ?? ""}',
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        Text(
          'We have received your order and it will be delivered soon.',
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),

        // Info Card
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          ),
          child: Column(children: [
            _buildInfoRow('Delivery in', '${trackModel.processingTime ?? "30-40"} mins', isBoldValue: true, valueColor: const Color(0xFF16A34A)),
            const Divider(height: 32, color: Color(0xFFF3F4F6)),
            _buildInfoRow('Deliver to', trackModel.deliveryAddress?.address ?? 'Home'),
            const Divider(height: 32, color: Color(0xFFF3F4F6)),
            if (trackModel.deliveryInstruction != null && trackModel.deliveryInstruction!.isNotEmpty) ...[
              _buildInfoRow('Delivery Instruction', trackModel.deliveryInstruction!),
              const Divider(height: 32, color: Color(0xFFF3F4F6)),
            ],
            _buildInfoRow(
              'Payment',
              'Paid via ${trackModel.paymentMethod?.replaceAll('_', ' ').capitalizeFirst ?? "Digital Payment"}',
              trailing: Text(PriceConverter.convertPrice(trackModel.orderAmount), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        Text(
          'You will receive order updates on\nWhatsApp & SMS',
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey),
        ),
        const SizedBox(height: 48),

        // Track Order Button
        CustomButton(
          buttonText: 'track_order'.tr,
          radius: 12,
          onPressed: () async {
            final int orderIdInt = int.tryParse(orderIdToUse ?? '0') ?? 0;
            if (AuthHelper.isLoggedIn()) {
              await Get.toNamed(RouteHelper.getOrderTrackingRoute(orderIdInt, null));
            }
            Get.offAllNamed(RouteHelper.getInitialRoute());
          },
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
          child: Text(
            'Continue Shopping',
            style: robotoBold.copyWith(color: const Color(0xFF374151), fontSize: Dimensions.fontSizeDefault),
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBoldValue = false, Color? valueColor, Widget? trailing}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: robotoRegular.copyWith(color: Colors.grey, fontSize: Dimensions.fontSizeExtraSmall)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text(
            value,
            style: isBoldValue 
                ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: valueColor ?? Colors.black)
                : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.black),
          ),
        ),
        if (trailing != null) trailing,
      ]),
    ]);
  }
}
