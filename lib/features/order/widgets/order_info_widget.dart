import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/notification/domain/models/notification_body_model.dart';
import 'package:handy_allinone/features/chat/domain/models/conversation_model.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/rating_bar.dart';
import 'package:handy_allinone/features/chat/widgets/image_dialog_widget.dart';
import 'package:handy_allinone/features/order/widgets/delivery_details_widget.dart';
import 'package:handy_allinone/features/payment/widgets/offline_info_edit_dialog_widget.dart';
import 'package:handy_allinone/features/order/widgets/order_banner_view_widget.dart';
import 'package:handy_allinone/features/order/widgets/order_item_widget.dart';
import 'package:handy_allinone/features/parcel/widgets/details_widget.dart';
import 'package:handy_allinone/features/review/widgets/review_dialog_widget.dart';
import 'package:ticket_clippers/ticket_clippers.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderInfoWidget extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final OrderController orderController;
  final Function timerCancel;
  final Function startApiCall;
  final bool showChatPermission;

  OrderInfoWidget({
    super.key,
    required this.order,
    required this.ongoing,
    required this.parcel,
    required this.prescriptionOrder,
    required this.orderController,
    required this.timerCancel,
    required this.startApiCall,
    required this.showChatPermission,
  });

  StatusThemeData getStatusThemeData(String status) {
    Color baseColor;
    String quote;

    switch (status) {
      case 'pending':
        baseColor = const Color(0xFFFCB900);
        quote = "Your order is queued and awaiting confirmation.";
        break;

      case 'accepted':
        baseColor = const Color(0xFF0BA5EC);
        quote = "Weâ€™ve green-lit your request â€” execution is underway.";
        break;

      case 'processing':
        baseColor = const Color(0xFF7F56D9);
        quote = "Our team is actively driving your order toward fulfillment.";
        break;

      case 'confirmed':
        baseColor = const Color(0xFF12BD5F);
        quote = "Your order is locked in and moving through our pipeline.";
        break;

      case 'handover':
        baseColor = const Color(0xFF36B37E);
        quote = "Your order is transitioning to the final delivery stage.";
        break;

      case 'picked_up':
        baseColor = const Color(0xFF2E90FA);
        quote = "Your package is now in transit â€” en route to your doorstep.";
        break;

      case 'delivered':
        baseColor = const Color(0xFF12BD5F);
        quote = "Order successfully completed â€” thank you for choosing us.";
        break;

      default:
        baseColor = Colors.grey;
        quote = "Status update not available.";
    }

    return StatusThemeData(
      base: baseColor,
      dark: baseColor.withValues(alpha: 0.85),
      light: baseColor.withValues(alpha: 0.25),
      quote: quote,
      circle1: baseColor.withValues(alpha: 0.25),
      circle2: baseColor.withValues(alpha: 0.60),
      circle3: baseColor.withValues(alpha: 0.40),
    );
  }

  Widget quoteStatusCard(BuildContext context, String status) {
    final theme = getStatusThemeData(status);

    return Stack(
      children: [
        Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.light.withAlpha(150), theme.dark.withAlpha(200)],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.base.withValues(alpha: 0.20),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(
                theme.quote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        Positioned(top: -18, right: 100, child: circle(theme.circle1)),
        Positioned(bottom: -18, left: 20, child: circle(theme.circle2)),
        Positioned(top: 30, left: 15, child: circle(theme.circle3)),
        Positioned(top: 10, right: 15, child: circle(theme.circle3)),
        Positioned(top: 30, right: 40, child: circle(theme.circle3)),
      ],
    );
  }

  Widget circle(Color color) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Color? getPaymentColor(String method) {
    switch (method) {
      case 'cash_on_delivery':
        return const Color(0xFF12BD5F); // green
      case 'wallet':
        return const Color(0xFF0BA5EC); // blue
      case 'partial_payment':
        return const Color(0xFF7F56D9); // purple
      default:
        return Colors.yellow;
    }
  }

  Map<String, OrderStatusConfig> orderStatusMap = {
    "pending": OrderStatusConfig(
      icon: Icons.hourglass_top_rounded,
      darkColor: Colors.orange,
      lightColor: Colors.orange.shade100,
    ),
    "confirmed": OrderStatusConfig(
      icon: Icons.verified_rounded,
      darkColor: Colors.blue,
      lightColor: Colors.blue.shade100,
    ),
    "processing": OrderStatusConfig(
      icon: Icons.sync_rounded,
      darkColor: Colors.amber,
      lightColor: Colors.amber.shade100,
    ),
    "out_for_delivery": OrderStatusConfig(
      icon: Icons.delivery_dining_rounded,
      darkColor: Colors.green,
      lightColor: Colors.green.shade100,
    ),
    "delivered": OrderStatusConfig(
      icon: Icons.check_circle_rounded,
      darkColor: Colors.green.shade700,
      lightColor: Colors.green.shade100,
    ),
    "canceled": OrderStatusConfig(
      icon: Icons.cancel_rounded,
      darkColor: Colors.red,
      lightColor: Colors.red.shade100,
    ),
  };

  OrderStatusConfig getStatusUI(String? status) {
    return orderStatusMap[status] ??
        OrderStatusConfig(
          icon: Icons.info_rounded,
          darkColor: Colors.grey,
          lightColor: Colors.grey.shade300,
        );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = getPaymentColor(order.paymentMethod ?? "");
    final statusUI = getStatusUI(order.orderStatus);
    final theme = getStatusThemeData(order.orderStatus ?? "");

    ExpansibleController controller = ExpansibleController();
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeExtraLarge)
              : const SizedBox(),
          // !isDesktop ? SizedBox(height: DateConverter.isBeforeTime(order.scheduleAt) && Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
          //     ? (order.orderStatus != 'delivered' && order.orderStatus != 'failed'
          //     && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested' && order.orderStatus != 'refunded'
          //     && order.orderStatus != 'refund_request_canceled' ) ? 280 : 140 :
          // parcel || prescriptionOrder || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'grocery')
          //     || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'ecommerce')
          //     || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'pharmacy')
          //     ? 0 : 0) : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: quoteStatusCard(context, order.orderStatus ?? ""),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFFF1F0EE),
              borderRadius: ResponsiveHelper.isMobile(context)
                  ? const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusExtraLarge),
                bottom: Radius.circular(Dimensions.radiusExtraLarge),

              )
                  : BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : 0,
                    ),
              boxShadow: [
                isDesktop
                    ? const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    : const BoxShadow(),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                  child: Column(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      isDesktop
                          ? OrderBannerViewWidget(
                              order: order,
                              orderController: orderController,
                              ongoing: ongoing,
                              parcel: parcel,
                              prescriptionOrder: prescriptionOrder,
                            )
                          : const SizedBox(),
                      isDesktop
                          ? const SizedBox(height: Dimensions.paddingSizeSmall)
                          : const SizedBox(),
                      Text(
                        order.createdAt != null ? DateConverter.dateTimeStringToDateTime(
                          order.createdAt!,
                        ) : '',
                        style: robotoBold,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            parcel ? 'delivery_id'.tr : 'order_id'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '#${order.id}',
                            style: robotoBold.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: statusUI.lightColor, // Light tone background
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: statusUI.darkColor.withOpacity(.2),
                          // Ripple effect
                          highlightColor: statusUI.darkColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: statusUI.darkColor.withOpacity(
                                            .15,
                                          ), // ripple bg
                                        ),
                                        child: Icon(
                                          statusUI.icon,
                                          size: 28,
                                          color: statusUI.darkColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      Expanded(
                                        child: Text(
                                          order.orderStatus.toString().tr,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: statusUI.darkColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                !isDesktop
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: isDesktop
                                              ? const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal: 12,
                                          ),
                                          child: IntrinsicWidth(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment: .center,
                                              children: [
                                                !isDesktop
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          order.paymentMethod ==
                                                                      'offline_payment' ||
                                                                  (order.paymentMethod ==
                                                                          'partial_payment' &&
                                                                      orderController
                                                                              .trackModel!
                                                                              .offlinePayment !=
                                                                          null)
                                                              ? Text(
                                                                  orderController
                                                                              .trackModel!
                                                                              .offlinePayment !=
                                                                          null
                                                                      ? (orderController
                                                                            .trackModel!
                                                                            .offlinePayment!
                                                                            .data?.status ?? '').tr
                                                                      : '',
                                                                  style: robotoMedium.copyWith(
                                                                    color:
                                                                        (orderController.trackModel!.offlinePayment !=
                                                                                null
                                                                            ? orderController.trackModel!.offlinePayment!.data?.status?.toString() ==
                                                                                  'denied'
                                                                            : false)
                                                                        ? Colors
                                                                              .red
                                                                        : Theme.of(
                                                                            context,
                                                                          ).primaryColor,
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                                (!isDesktop &&
                                                        order.paymentMethod !=
                                                            'offline_payment')
                                                    ? const SizedBox(height: 0)
                                                    : const SizedBox(),
                                                order.paymentMethod ==
                                                            'offline_payment' ||
                                                        (order.paymentMethod ==
                                                                'partial_payment' &&
                                                            orderController
                                                                    .trackModel!
                                                                    .offlinePayment !=
                                                                null)
                                                    ? offlineView(
                                                        context,
                                                        orderController,
                                                        controller,
                                                        ongoing,
                                                      )
                                                    : Row(
                                                        children: [
                                                          Image.asset(
                                                            order.paymentMethod ==
                                                                    'cash_on_delivery'
                                                                ? Images.cash
                                                                : order.paymentMethod ==
                                                                      'wallet'
                                                                ? Images.wallet
                                                                : order.paymentMethod ==
                                                                      'partial_payment'
                                                                ? Images
                                                                      .partialWallet
                                                                : Images
                                                                      .digitalPayment,
                                                            width: 25,
                                                            height: 25,
                                                            color: iconColor,
                                                          ),
                                                          const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall,
                                                          ),

                                                          Expanded(
                                                            child: Text(
                                                              order.paymentMethod ==
                                                                      'cash_on_delivery'
                                                                  ? 'COD'.tr
                                                                  : order.paymentMethod ==
                                                                        'wallet'
                                                                  ? 'wallet'.tr
                                                                  : order.paymentMethod ==
                                                                        'partial_payment'
                                                                  ? 'partial_payment'
                                                                        .tr
                                                                  : 'digital'
                                                                        .tr,
                                                              style: robotoBlack.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                color: Colors
                                                                    .grey
                                                                    .shade700,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.dark,
                                          theme.light.withAlpha(10),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Flexible(
                                    child: Text(
                                      theme.quote,
                                      textAlign: TextAlign.start,
                                      style: robotoRegular.copyWith(
                                        fontSize: 15,
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 15,
                            ),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: .spaceAround,
                                      crossAxisAlignment: .center,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          '${parcel ? 'charge_pay_by'.tr : 'item'.tr}',
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          parcel
                                              ? (order.chargePayer ?? '').tr
                                              : (orderController
                                                    .orderDetails?.length ?? 0)
                                                    .toString(),
                                          style: robotoBold.copyWith(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      order.scheduled == 1
                          ? Divider(
                              height: Dimensions.paddingSizeLarge,
                              color: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.30),
                            )
                          : const SizedBox(),
                      order.scheduled == 1
                          ? Row(
                              children: [
                                Text(
                                  '${'scheduled_at'.tr}:',
                                  style: robotoRegular,
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  order.scheduleAt != null ? DateConverter.dateTimeStringToDateTime(
                                    order.scheduleAt!,
                                  ) : '',
                                  style: robotoMedium,
                                ),
                              ],
                            )
                          : const SizedBox(),

                      (Get.find<SplashController>()
                              .configModel
                              ?.orderDeliveryVerification ?? false)
                          ?  Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.10))
                          : const SizedBox(),
                      (Get.find<SplashController>()
                              .configModel
                              ?.orderDeliveryVerification ?? false)
                          ? Row(
                              children: [
                                Text(
                                  '${'delivery_verification_code'.tr}:',
                                  style: robotoRegular,
                                ),
                                const Expanded(child: SizedBox()),
                                Text(order.otp ?? '', style: robotoMedium),
                              ],
                            )
                          : const SizedBox(),
                      Divider(
                        height: Dimensions.paddingSizeLarge,
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: 0.10),
                      ),

                      // Row(
                      //   children: [
                      //     Text(order.orderType!.tr, style: robotoMedium),
                      //     const Expanded(child: SizedBox()),
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: Dimensions.paddingSizeSmall,
                      //         vertical: Dimensions.paddingSizeExtraSmall,
                      //       ),
                      //       decoration: BoxDecoration(
                      //         color: Theme.of(
                      //           context,
                      //         ).primaryColor.withValues(alpha: 0.1),
                      //         borderRadius: BorderRadius.circular(
                      //           Dimensions.radiusSmall,
                      //         ),
                      //       ),
                      //       child: Text(
                      //         order.paymentMethod == 'cash_on_delivery'
                      //             ? 'cash_on_delivery'.tr
                      //             : order.paymentMethod == 'wallet'
                      //             ? 'wallet_payment'.tr
                      //             : order.paymentMethod == 'partial_payment'
                      //             ? 'partial_payment'.tr
                      //             : order.paymentMethod == 'offline_payment'
                      //             ? 'offline_payment'.tr
                      //             : 'digital_payment'.tr,
                      //         style: robotoMedium.copyWith(
                      //           color: Theme.of(context).primaryColor,
                      //           fontSize: Dimensions.fontSizeExtraSmall,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Divider(
                      //   height: Dimensions.paddingSizeLarge,
                      //   color: Theme.of(
                      //     context,
                      //   ).disabledColor.withValues(alpha: 0.30),
                      // ),

                      (Get.find<SplashController>()
                              .getModuleConfig(order.moduleType)
                              .newVariation ?? false)
                          ? Column(
                              children: [
                                Divider(
                                  height: Dimensions.paddingSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.30),
                                ),

                                Row(
                                  children: [
                                    Text(
                                      '${'cutlery'.tr}: ',
                                      style: robotoRegular,
                                    ),
                                    const Expanded(child: SizedBox()),

                                    Text(
                                      (order.cutlery ?? false) ? 'yes'.tr : 'no'.tr,
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),

                      order.unavailableItemNote != null
                          ? Column(
                              children: [
                                Divider(
                                  height: Dimensions.paddingSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.30),
                                ),

                                Row(
                                  children: [
                                    Text(
                                      '${'unavailable_item_note'.tr}: ',
                                      style: robotoMedium,
                                    ),

                                    Text(
                                      order.unavailableItemNote!,
                                      style: robotoRegular,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),

                      order.deliveryInstruction != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  height: Dimensions.paddingSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.30),
                                ),

                                RichText(
                                  text: TextSpan(
                                    text: '${'delivery_instruction'.tr}: ',
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: order.deliveryInstruction!,
                                        style: robotoRegular,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      SizedBox(
                        height: order.deliveryInstruction != null
                            ? Dimensions.paddingSizeSmall
                            : 0,
                      ),

                      order.orderStatus == 'canceled'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  height: Dimensions.paddingSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.30),
                                ),
                                Text(
                                  '${'cancellation_note'.tr}:',
                                  style: robotoMedium,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                InkWell(
                                  onTap: () => Get.dialog(
                                    ReviewDialogWidget(
                                      review: ReviewModel(
                                        comment: order.cancellationReason,
                                      ),
                                      fromOrderDetails: true,
                                    ),
                                  ),
                                  child: Text(
                                    order.cancellationReason ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),

                      (order.orderStatus == 'refund_requested' ||
                              order.orderStatus == 'refund_request_canceled')
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  height: Dimensions.paddingSizeLarge,
                                  color: Theme.of(
                                    context,
                                  ).disabledColor.withValues(alpha: 0.30),
                                ),

                                order.orderStatus == 'refund_requested'
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '${'refund_note'.tr}:',
                                                  style: robotoMedium.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).textTheme.bodyLarge!.color,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '(${(order.refund != null) ? order.refund!.customerReason : ''})',
                                                  style: robotoRegular.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).textTheme.bodyLarge!.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),

                                          (order.refund != null &&
                                                  order.refund!.customerNote !=
                                                      null)
                                              ? InkWell(
                                                  onTap: () => Get.dialog(
                                                    ReviewDialogWidget(
                                                      review: ReviewModel(
                                                        comment: order
                                                            .refund!
                                                            .customerNote,
                                                      ),
                                                      fromOrderDetails: true,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${order.refund!.customerNote}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: robotoRegular.copyWith(
                                                      color: Theme.of(
                                                        context,
                                                      ).disabledColor,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                          SizedBox(
                                            height:
                                                (order.refund != null &&
                                                    order.refund!.imageFullUrl !=
                                                        null)
                                                ? Dimensions.paddingSizeSmall
                                                : 0,
                                          ),

                                          (order.refund != null &&
                                                  order.refund!.imageFullUrl !=
                                                      null &&
                                                  order
                                                      .refund!
                                                      .imageFullUrl!
                                                      .isNotEmpty)
                                              ? InkWell(
                                                  onTap: () => showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return ImageDialogWidget(
                                                        imageUrl:
                                                            order
                                                                .refund!
                                                                .imageFullUrl!
                                                                .isNotEmpty
                                                            ? order
                                                                  .refund!
                                                                  .imageFullUrl![0]
                                                            : '',
                                                      );
                                                    },
                                                  ),
                                                  child: CustomImage(
                                                    height: 40,
                                                    width: 40,
                                                    fit: BoxFit.cover,
                                                    image: order.refund != null
                                                        ? order
                                                                  .refund!
                                                                  .imageFullUrl!
                                                                  .isNotEmpty
                                                              ? order
                                                                    .refund!
                                                                    .imageFullUrl![0]
                                                              : ''
                                                        : '',
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${'refund_cancellation_note'.tr}:',
                                            style: robotoMedium,
                                          ),
                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),

                                          InkWell(
                                            onTap: () => Get.dialog(
                                              ReviewDialogWidget(
                                                review: ReviewModel(
                                                  comment:
                                                      order.refund!.adminNote,
                                                ),
                                                fromOrderDetails: true,
                                              ),
                                            ),
                                            child: Text(
                                              '${order.refund != null ? order.refund!.adminNote : ''}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          isDesktop
              ? const SizedBox()
              : const SizedBox(height: Dimensions.paddingSizeSmall),
          !isDesktop
              ? (parcel || orderController.orderDetails!.isNotEmpty)
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: parcel
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DetailsWidget(
                                    title: 'sender_details'.tr,
                                    address: order.deliveryAddress,
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),
                                  DetailsWidget(
                                    title: 'receiver_details'.tr,
                                    address: order.receiverDetails,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Item Information'.tr,
                                          style: robotoMedium.copyWith(color: Colors.grey.shade400, fontSize: 16)),
                                      SizedBox(width: 10,),
                                      Expanded(child: Container(height: 2,width: double.infinity,color: Colors.grey.shade300,)),
                                      SizedBox(width: 10,),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        orderController.orderDetails!.length,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall,
                                    ),
                                    itemBuilder: (context, index) {
                                      return OrderItemWidget(
                                        order: order,
                                        orderDetails: orderController
                                            .orderDetails![index],
                                      );
                                    },
                                  ),
                                ],
                              ),
                      )
                    : const SizedBox()
              : const SizedBox(),

          (isDesktop &&
                  (Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment ?? false) &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),

          (isDesktop &&
                  (Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment ?? false) &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? Text('prescription'.tr, style: robotoMedium)
              : const SizedBox(),

          (isDesktop &&
                  (Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment ?? false) &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),

          ((Get.find<SplashController>()
                      .getModuleConfig(order.moduleType)
                      .orderAttachment ?? false) &&
                  order.orderAttachmentFullUrl != null &&
                  order.orderAttachmentFullUrl!.isNotEmpty)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : 0,
                    ),
                    boxShadow: [
                      isDesktop
                          ? const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          : const BoxShadow(),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isDesktop
                          ? Text('prescription'.tr, style: robotoRegular)
                          : const SizedBox(),
                      !isDesktop
                          ? const SizedBox(height: Dimensions.paddingSizeSmall)
                          : const SizedBox(),
                      SizedBox(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisCount: isDesktop ? 8 : 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 5,
                              ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.orderAttachmentFullUrl!.length,
                          itemBuilder: (BuildContext context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => openDialog(
                                  context,
                                  '${order.orderAttachmentFullUrl![index]}',
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    child: CustomImage(
                                      image:
                                          '${order.orderAttachmentFullUrl![index]}',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      SizedBox(
                        width:
                            ((Get.find<SplashController>()
                                    .getModuleConfig(order.moduleType)
                                    .orderAttachment ?? false) &&
                                order.orderAttachmentFullUrl != null &&
                                order.orderAttachmentFullUrl!.isNotEmpty)
                            ? Dimensions.paddingSizeSmall
                            : 0,
                      ),

                      (order.orderNote != null && order.orderNote!.isNotEmpty)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'additional_note'.tr,
                                  style: robotoRegular,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),

                                InkWell(
                                  onTap: () => Get.dialog(
                                    ReviewDialogWidget(
                                      review: ReviewModel(
                                        comment: order.orderNote,
                                      ),
                                      fromOrderDetails: true,
                                    ),
                                  ),
                                  child: Text(
                                    order.orderNote!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                )
              : const SizedBox(),
          SizedBox(
            height:
                (Get.find<SplashController>()
                        .getModuleConfig(order.moduleType)
                        .orderAttachment ?? false) &&
                    order.orderAttachmentFullUrl != null &&
                    order.orderAttachmentFullUrl!.isNotEmpty
                ? Dimensions.paddingSizeSmall
                : 0,
          ),

          (order.orderStatus == 'delivered' &&
                  order.orderProofFullUrl != null &&
                  order.orderProofFullUrl!.isNotEmpty)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('order_proof'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.5,
                          crossAxisCount: ResponsiveHelper.isTab(context)
                              ? 5
                              : 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.orderProofFullUrl!.length,
                        itemBuilder: (BuildContext context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => openDialog(
                                context,
                                order.orderProofFullUrl![index],
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  child: CustomImage(
                                    image: order.orderProofFullUrl![index],
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                  ),
                )
              : const SizedBox(),

          (order.deliveryMan != null && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          (order.deliveryMan != null && isDesktop)
              ? Text('Delivery Hero Details'.toUpperCase(), style: robotoMedium)
              : const SizedBox(),
          (order.deliveryMan != null && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),
          order.deliveryMan != null
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : Dimensions.radiusDefault,
                    ),
                    boxShadow: [
                      isDesktop
                          ? const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          : const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Hero Details'.toUpperCase(), style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Divider(color:Colors.grey.shade600),

                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color:Colors.black,
                                  shape: BoxShape.circle
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipOval(
                                    child: CustomImage(
                                      image: '${order.deliveryMan!.imageFullUrl}',
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape:BoxShape.circle,
                                    color:Colors.white,

                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(Icons.check_circle,size:14,color: Colors.green,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: .start,
                              children: [
                                Row(
                                  mainAxisAlignment: .spaceBetween,
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(
                                      '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.grey.withValues(alpha: 0.2),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                        vertical: Dimensions.paddingSizeExtraSmall,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.verified,size:14,color: Colors.green.shade400,),
                                          SizedBox(width:10),
                                          Text("Verified",
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
                                RatingBar(
                                  rating: order.deliveryMan!.avgRating,
                                  size: 13,
                                  ratingCount: order.deliveryMan!.ratingCount,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Icon(Icons.info_outline,size:14,color:Colors.grey.shade400),
                          SizedBox(width: 10,),
                          Text("Chat for and secure communication",
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).disabledColor,),
                            ),

                        ],
                      ),

                      SizedBox(height: 10,),

                      (order.orderStatus != 'delivered' &&
                          order.orderStatus != 'failed' &&
                          order.orderStatus != 'canceled' &&
                          order.orderStatus != 'refunded')
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          showChatPermission
                              ? InkWell(
                            onTap: () async {
                              timerCancel();
                              await Get.toNamed(
                                RouteHelper.getChatRoute(
                                  notificationBody:
                                  NotificationBodyModel(
                                    deliverymanId: order
                                        .deliveryMan!
                                        .id,
                                    orderId: int.parse(
                                      order.id.toString(),
                                    ),
                                  ),
                                  user: User(
                                    id: order.deliveryMan!.id,
                                    fName: order
                                        .deliveryMan!
                                        .fName,
                                    lName: order
                                        .deliveryMan!
                                        .lName,
                                    imageFullUrl: order
                                        .deliveryMan!
                                        .imageFullUrl,
                                  ),
                                ),
                              );
                              startApiCall();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IntrinsicWidth(
                                child: Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: 30.w,vertical: 15.h),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        Images.chatOrderDetails,
                                        height:30,
                                        width: 30,
                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        mainAxisAlignment: .center,
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text("Chat Now",style: robotoBold.copyWith(color:Colors.white,fontSize: 12,fontWeight: FontWeight.w600),),
                                          SizedBox(height: 5,),
                                          Text("Preferred",style: robotoRegular.copyWith(color:Colors.grey,fontSize: 10,fontWeight: FontWeight.w200),)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                              : const SizedBox(),
                          SizedBox(
                            width: showChatPermission
                                ? Dimensions.paddingSizeSmall
                                : 0,
                          ),

                          InkWell(
                            onTap: () async {
                              if (await canLaunchUrlString(
                                'tel:${order.deliveryMan!.phone}',
                              )) {
                                launchUrlString(
                                  'tel:${order.deliveryMan!.phone}',
                                  mode:
                                  LaunchMode.externalApplication,
                                );
                              } else {
                                showCustomSnackBar(
                                  '${'can_not_launch'.tr} ${order.deliveryMan!.phone}',
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:Border.all(color:Colors.green)
                              ),
                              child: IntrinsicWidth(
                                child: Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        Images.phoneOrderDetails,
                                        height: 22,
                                        width: 25,
                                      ),
                                      SizedBox(height: 5,),
                                      Row(
                                        mainAxisAlignment: .center,
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text("Call Me!",style: robotoBold.copyWith(color:Colors.green,fontSize: 12,fontWeight: FontWeight.w600),),
                                          SizedBox(width: 10,),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: Colors.green.withValues(alpha: 0.1)
                                            ),
                                              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                              child: Text("secure",style: robotoRegular.copyWith(color:Colors.green,fontSize: 10,fontWeight: FontWeight.w400),))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : const SizedBox(),
                    ],
                  ),
                )
              : const SizedBox(),
          SizedBox(
            height: order.deliveryMan != null ? Dimensions.paddingSizeLarge : 0,
          ),

          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          (parcel && isDesktop)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : 0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DetailsWidget(
                        title: 'sender_details'.tr,
                        address: order.deliveryAddress,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      DetailsWidget(
                        title: 'receiver_details'.tr,
                        address: order.receiverDetails,
                      ),
                    ],
                  ),
                )
              : const SizedBox(),

          (!parcel && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          (!parcel && isDesktop)
              ? Text('delivery_details'.tr, style: robotoMedium)
              : const SizedBox(),
          (!parcel && isDesktop)
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),

          (!parcel && order.store != null)
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : 0,
                    ),
                    boxShadow: isDesktop
                        ? const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isDesktop
                          ? Text('delivery_details'.tr.toUpperCase(), style: robotoMedium)
                          : const SizedBox(),
                      !isDesktop
                          ? const SizedBox(height: Dimensions.paddingSizeSmall)
                          : const SizedBox(),

                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      DeliveryDetailsWidget(
                        from: true,
                        address: order.store!.address,
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      DeliveryDetailsWidget(
                        from: false,
                        address: order.deliveryAddress?.address,
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          SizedBox(height: !parcel ? Dimensions.paddingSizeSmall : 0),

          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeDefault)
              : const SizedBox(),
          isDesktop
              ? Text(
                  parcel
                      ? 'parcel_category'.tr
                      : (Get.find<SplashController>()
                            .getModuleConfig(order.moduleType)
                            .showRestaurantText ?? false)
                      ? 'restaurant_details'.tr
                      : 'store_details'.tr.toUpperCase(),
                  style: robotoMedium,
                )
              : const SizedBox(),
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeDefault)
              : const SizedBox(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                isDesktop ? Dimensions.radiusDefault : Dimensions.radiusDefault,
              ),
              boxShadow: isDesktop
                  ? const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !isDesktop
                    ? Row(
                      children: [
                        Text(
                            parcel
                                ? 'parcel_category'.tr
                                : (Get.find<SplashController>()
                                      .getModuleConfig(order.moduleType)
                                      .showRestaurantText ?? false)
                                ? 'restaurant_details'.tr
                                : 'store_details'.tr,
                            style: robotoMedium.copyWith(color: Colors.grey.shade400, fontSize: 16)
                          ),
                        SizedBox(width: 10,),
                        Expanded(child: Container(height: 2,width: double.infinity,color: Colors.grey.shade300,)),
                        SizedBox(width: 10,),
                      ],
                    )
                    : const SizedBox(),
                !isDesktop
                    ? const SizedBox(height: Dimensions.paddingSizeSmall)
                    : const SizedBox(),

                (parcel && order.parcelCategory == null)
                    ? Text(
                        'no_parcel_category_data_found'.tr,
                        style: robotoMedium,
                      )
                    : (!parcel && order.store == null)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Text(
                            'no_restaurant_data_found'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      )
                    : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border:Border.all(color:Colors.grey.shade100),
                  ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color:Colors.grey.shade300)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CustomImage(
                                    image: parcel
                                        ? '${order.parcelCategory!.imageFullUrl}'
                                        : '${order.store!.logoFullUrl}',
                                    height: 55,
                                    width: 55,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: .start,
                                  children: [
                                    Text(
                                      parcel
                                          ? (order.parcelCategory!.name ?? '')
                                          : (order.store!.name ?? ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(
                                        fontSize:14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      parcel
                                          ? (order.parcelCategory!.description ?? '')
                                          : (order.store?.address ?? ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              (!parcel &&
                                      order.orderType == 'take_away' &&
                                      (order.orderStatus == 'pending' ||
                                          order.orderStatus == 'accepted' ||
                                          order.orderStatus == 'confirmed' ||
                                          order.orderStatus == 'processing' ||
                                          order.orderStatus == 'handover' ||
                                          order.orderStatus == 'picked_up'))
                                  ? TextButton.icon(
                                      onPressed: () async {
                                        if (!parcel) {
                                          String url =
                                              'https://www.google.com/maps/dir/?api=1&destination=${order.store!.latitude}'
                                              ',${order.store!.longitude}&mode=d';
                                          if (await canLaunchUrlString(url)) {
                                            await launchUrlString(url);
                                          } else {
                                            showCustomSnackBar(
                                              'unable_to_launch_google_map'.tr,
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.directions),
                                      label: Text('direction'.tr),
                                    )
                                  : const SizedBox(),

                              (showChatPermission &&
                                      !parcel &&
                                      order.orderStatus != 'delivered' &&
                                      order.orderStatus != 'failed' &&
                                      order.orderStatus != 'canceled' &&
                                      order.orderStatus != 'refunded')
                                  ? InkWell(
                                      onTap: () async {
                                        await Get.toNamed(
                                          RouteHelper.getChatRoute(
                                            notificationBody: NotificationBodyModel(
                                              orderId: order.id,
                                              restaurantId: order.store!.vendorId,
                                            ),
                                            user: User(
                                              id: order.store!.vendorId,
                                              fName: order.store!.name,
                                              lName: '',
                                              imageFullUrl:
                                                  order.store!.logoFullUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.asset(
                                        Images.storechat,
                                        color:Colors.green,
                                        height: 40,
                                        width: 40,
                                      ),
                                    )
                                  : const SizedBox(),

                              !isGuestLoggedIn &&
                                      (Get.find<SplashController>()
                                              .configModel
                                              ?.refundActiveStatus ?? false) &&
                                          order.orderStatus == 'delivered' &&
                                          !parcel &&
                                          (parcel ||
                                              (orderController.orderDetails != null &&
                                               orderController.orderDetails!.isNotEmpty &&
                                                  orderController
                                                          .orderDetails![0]
                                                          .itemCampaignId ==
                                                      null))
                                  ? InkWell(
                                      onTap: () => Get.toNamed(
                                        RouteHelper.getRefundRequestRoute(
                                          order.id.toString(),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).primaryColor,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeExtraSmall,
                                          vertical: Dimensions.paddingSizeSmall,
                                        ),
                                        child: Text(
                                          'refund_this_order'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeSmall)
              : const SizedBox(),
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('payment_method'.tr, style: robotoMedium),
                    order.paymentMethod == 'offline_payment'
                        ? Text(
                            orderController.trackModel!.offlinePayment != null
                                ? (orderController
                                      .trackModel!
                                      .offlinePayment!
                                      .data?.status ?? '').tr
                                : '',
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : const SizedBox(),
                  ],
                )
              : const SizedBox(),
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),
          isDesktop
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      isDesktop ? Dimensions.radiusDefault : 0,
                    ),
                    boxShadow: isDesktop
                        ? const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !isDesktop
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('payment_method'.tr, style: robotoMedium),

                                order.paymentMethod == 'offline_payment' ||
                                        (order.paymentMethod ==
                                                'partial_payment' &&
                                            orderController
                                                    .trackModel!
                                                    .offlinePayment !=
                                                null)
                                    ? Text(
                                        orderController
                                                    .trackModel!
                                                    .offlinePayment !=
                                                null
                                            ? (orderController
                                                  .trackModel!
                                                  .offlinePayment!
                                                  .data?.status ?? '').tr
                                            : '',
                                        style: robotoMedium.copyWith(
                                          color:
                                              (orderController
                                                          .trackModel!
                                                          .offlinePayment !=
                                                      null
                                                  ? orderController
                                                            .trackModel!
                                                            .offlinePayment!
                                                            .data?.status
                                                            ?.toString() ==
                                                        'denied'
                                                  : false)
                                              ? Colors.red
                                              : Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            )
                          : const SizedBox(),
                      (!isDesktop && order.paymentMethod != 'offline_payment')
                          ? const SizedBox(height: Dimensions.paddingSizeSmall)
                          : const SizedBox(),
                      order.paymentMethod == 'offline_payment' ||
                              (order.paymentMethod == 'partial_payment' &&
                                  orderController.trackModel!.offlinePayment !=
                                      null)
                          ? offlineView(
                              context,
                              orderController,
                              controller,
                              ongoing,
                            )
                          : Row(
                              children: [
                                Image.asset(
                                  order.paymentMethod == 'cash_on_delivery'
                                      ? Images.cash
                                      : order.paymentMethod == 'wallet'
                                      ? Images.wallet
                                      : order.paymentMethod == 'partial_payment'
                                      ? Images.partialWallet
                                      : Images.digitalPayment,
                                  width: 20,
                                  height: 20,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.color,
                                ),
                                const SizedBox(
                                  width: Dimensions.paddingSizeSmall,
                                ),

                                Expanded(
                                  child: Text(
                                    order.paymentMethod == 'cash_on_delivery'
                                        ? 'COD'.tr
                                        : order.paymentMethod == 'wallet'
                                        ? 'wallet'.tr
                                        : order.paymentMethod ==
                                              'partial_payment'
                                        ? 'partial_payment'.tr
                                        : 'digital'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                )
              : SizedBox(),
          SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),
        ],
      ),
    );
  }
}

Widget offlineView(
  BuildContext context,
  OrderController orderController,
  ExpansibleController controller,
  bool ongoing,
) {
  return ListTileTheme(
    contentPadding: const EdgeInsets.all(0),
    dense: true,
    horizontalTitleGap: 5.0,
    minLeadingWidth: 0,
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controller: controller,
        leading: Image.asset(
          Images.cash,
          width: 20,
          height: 20,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
        title: Text(
          'offline_payment'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
        trailing: Icon(
          !orderController.isExpanded ? Icons.expand_more : Icons.expand_less,
          size: 18,
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        onExpansionChanged: (value) => orderController.expandedUpdate(value),

        children: [
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'seller_payment_info'.tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          (orderController.trackModel!.offlinePayment != null && orderController.trackModel!.offlinePayment!.methodFields != null)
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController
                      .trackModel!
                      .offlinePayment!
                      .methodFields!
                      .length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${orderController.trackModel!.offlinePayment!.methodFields![index].inputName.toString().replaceAll('_', ' ')} : ',
                            style: robotoRegular,
                          ),
                          Text(
                            '${orderController.trackModel!.offlinePayment!.methodFields![index].inputData}',
                            style: robotoRegular,
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Text('no_data_found'.tr),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'my_payment_info'.tr,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),

              (ongoing &&
                      orderController.trackModel!.offlinePayment != null &&
                      orderController
                              .trackModel!
                              .offlinePayment!
                              .data?.status !=
                          'verified')
                  ? InkWell(
                      onTap: () {
                        Get.dialog(
                          OfflineInfoEditDialogWidget(
                            offlinePayment:
                                orderController.trackModel!.offlinePayment!,
                            orderId: orderController.trackModel!.id!,
                          ),
                          barrierDismissible: true,
                        );
                      },
                      child: Text(
                        'edit_details'.tr,
                        style: robotoBold.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          (orderController.trackModel!.offlinePayment != null && orderController.trackModel!.offlinePayment!.input != null)
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      orderController.trackModel!.offlinePayment!.input!.length,
                  itemBuilder: (context, index) {
                    Input data = orderController
                        .trackModel!
                        .offlinePayment!
                        .input![index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${data.userInput.toString().replaceAll('_', ' ')}: ',
                            style: robotoRegular,
                          ),
                          Text(data.userData.toString(), style: robotoRegular),
                        ],
                      ),
                    );
                  },
                )
              : const SizedBox(),
          // const SizedBox(height: Dimensions.paddingSizeSmall),
        ],
      ),
    ),
  );
}

void openDialog(BuildContext context, String imageUrl) => showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              splashRadius: 5,
              onPressed: () => Get.back(),
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  },
);

class StatusThemeData {
  final Color base;
  final Color dark;
  final Color light;
  final String quote;
  final Color circle1;
  final Color circle2;
  final Color circle3;

  StatusThemeData({
    required this.base,
    required this.dark,
    required this.light,
    required this.quote,
    required this.circle1,
    required this.circle2,
    required this.circle3,
  });
}

class OrderStatusConfig {
  final IconData icon;
  final Color darkColor;
  final Color lightColor;

  OrderStatusConfig({
    required this.icon,
    required this.darkColor,
    required this.lightColor,
  });
}
