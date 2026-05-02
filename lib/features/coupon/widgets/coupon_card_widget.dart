import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/features/coupon/domain/models/coupon_model.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:lottie/lottie.dart';
import 'package:scratcher/widgets.dart';
import 'package:ticket_clippers/ticket_clippers.dart';

import '../../../common/widgets/custom_snackbar.dart';
import '../../store/controllers/store_controller.dart';
import '../controllers/coupon_controller.dart';

class CouponCardWidget extends StatelessWidget {
  final bool fromdialog;
  final CouponModel coupon;
  final int index;

  const CouponCardWidget({
    super.key,
    required this.coupon,
    required this.index,
    required this.fromdialog,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        TicketShapeContainer(
          height: ResponsiveHelper.isMobilePhone() ? 120 : 150,
          borderRadius: 8,
          notchRadius: 10,
          borderColor: Colors.grey.shade300,
          borderWidth: 1,
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            height: ResponsiveHelper.isMobilePhone() ? 120 : 150,
            alignment: Alignment.center,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              coupon.discountType == 'percent'
                                  ? Images.percentCouponOffer
                                  : coupon.couponType == 'free_delivery'
                                  ? Images.freeDelivery
                                  : Images.money,
                              height: 18,
                              width: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${coupon.title}',
                          style: robotoBold,
                          textDirection: TextDirection.ltr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Row(
                          children: [
                            Text(
                              'Expiry Date :',
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              coupon.expireDate ?? "N/A",
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${'min_purchase'.tr} :',
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              PriceConverter.convertPrice(coupon.minPurchase),
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Maximum Discount :',
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              PriceConverter.convertPrice(coupon.maxDiscount),
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                borderPadding: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                color: Colors.green.shade800,
                                radius: const Radius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 3,
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      CustomAssetImageWidget(
                                        Images.discountOfferIcon,
                                        color: Colors.green.shade500,
                                        height: 15,
                                        width: 15,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        coupon.code ?? "N/A",
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.blue.shade900,
                                  ),
                                  child: IntrinsicWidth(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                      ),
                                      child: Center(
                                        child: Text(
                                          fromdialog == true ? "Apply" : "Copy",
                                          style: robotoBold.copyWith(
                                            color: Theme.of(context).cardColor,
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ResponsiveHelper.isDesktop(context)
            ? Positioned(
                top: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeSmall,
                child: JustTheTooltip(
                  backgroundColor: Theme.of(context).cardColor,
                  controller: coupon.toolTip,
                  preferredDirection: AxisDirection.up,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  triggerMode: TooltipTriggerMode.manual,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'code_copied'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                        coupon.toolTip?.showTooltip();
                        Clipboard.setData(ClipboardData(text: coupon.code!));
                        Future.delayed(const Duration(milliseconds: 750), () {
                          coupon.toolTip?.hideTooltip();
                        });
                      },
                    child: Image.asset(
                      Images.copyCoupon,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
  void showCouponAppliedDialog(
      String code,
      String savedAmount,
      BuildContext parentContext,
      ) {
    bool scratchCompleted = false;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: scratchCompleted
                    ? Center(
                  child: Container(
                    width: 320,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/animation/done.json',
                                width: 110,
                                height: 110,
                                repeat: false,
                              ),
                              const SizedBox(height: 10),
                              Text('$code applied', style: robotoMedium),
                              const SizedBox(height: 6),
                              Text('You saved $savedAmount', style: robotoBold),
                              const SizedBox(height: 6),
                              const Text('Enjoy your savings 🎉'),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Lottie.asset(
                              'assets/animation/coupon.json',
                              fit: BoxFit.cover,
                              repeat: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Scratcher(
                  brushSize: 50,
                  threshold: 35,
                  image: Image.asset(
                    'assets/image/scratch_card.jpg',
                    fit: BoxFit.cover,
                  ),
                  onThreshold: () {
                    setDialogState(() {
                      scratchCompleted = true;
                    });

                    Future.delayed(const Duration(seconds: 3), () {
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }
                    });
                  },
                  child:Container(
                    width: 320,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/animation/done.json',
                            width: 110,
                            height: 110,
                            repeat: false,
                          ),
                          const SizedBox(height: 10),
                          Text('$code applied', style: robotoMedium),
                          const SizedBox(height: 6),
                          Text('You saved $savedAmount', style: robotoBold),
                          const SizedBox(height: 6),
                          const Text('Enjoy your savings 🎉'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TicketShapeContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;
  final double notchRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;

  const TicketShapeContainer({
    super.key,
    required this.child,
    this.height = 120,
    this.borderRadius = 12,
    this.notchRadius = 14,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TicketOutlinePainter(
        borderRadius: borderRadius,
        notchRadius: notchRadius,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: ClipPath(
        clipper: _TicketClipper(
          borderRadius: borderRadius,
          notchRadius: notchRadius,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(color: backgroundColor),
          child: child,
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchRadius;

  const _TicketClipper({required this.borderRadius, required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();

    final midY = size.height / 2;

    // Top-left corner
    path.moveTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);

    // Top-right corner
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);

    // Right notch
    path.lineTo(size.width, midY - notchRadius);
    path.arcToPoint(
      Offset(size.width, midY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Bottom-right corner
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - borderRadius,
      size.height,
    );

    // Bottom-left corner
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);

    // Left notch
    path.lineTo(0, midY + notchRadius);
    path.arcToPoint(
      Offset(0, midY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) =>
      borderRadius != oldClipper.borderRadius ||
      notchRadius != oldClipper.notchRadius;
}

class _TicketOutlinePainter extends CustomPainter {
  final double borderRadius;
  final double notchRadius;
  final Color borderColor;
  final double borderWidth;

  const _TicketOutlinePainter({
    required this.borderRadius,
    required this.notchRadius,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _TicketClipper(
      borderRadius: borderRadius,
      notchRadius: notchRadius,
    ).getClip(size);

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TicketOutlinePainter oldDelegate) =>
      borderColor != oldDelegate.borderColor ||
      borderWidth != oldDelegate.borderWidth ||
      borderRadius != oldDelegate.borderRadius ||
      notchRadius != oldDelegate.notchRadius;
}
