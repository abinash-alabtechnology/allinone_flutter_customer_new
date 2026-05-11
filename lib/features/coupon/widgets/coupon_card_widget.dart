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
    String discountText = "";
    if (coupon.couponType == 'free_delivery') {
      discountText = "FREE";
    } else {
      discountText = coupon.discountType == 'percent'
          ? "${coupon.discount?.toInt()}%"
          : PriceConverter.convertPrice(coupon.discount);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 130,
          child: Row(
            children: [
              // Left Section - Reward Info
              Container(
                width: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      left: -20,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            discountText,
                            style: robotoBlack.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            coupon.couponType == 'free_delivery' ? "DELIVERY" : "OFF",
                            style: robotoMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider with Notches
              CustomPaint(
                size: const Size(20, 130),
                painter: TicketDividerPainter(color: Colors.white),
              ),

              // Right Section - Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coupon.title ?? "",
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${'min_purchase'.tr}: ${PriceConverter.convertPrice(coupon.minPurchase)}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              coupon.code ?? "",
                              style: robotoBlack.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Action logic is handled by parent InkWell in CouponBottomSheet
                              // but we keep the visual button here.
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                fromdialog ? "Apply" : "Copy",
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
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
                        child: Container(
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

class TicketDividerPainter extends CustomPainter {
  final Color color;
  TicketDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Draw the notches
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    
    // Bottom notch
    path.addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: 10));
    // Top notch
    path.addOval(Rect.fromCircle(center: Offset(size.width / 2, 0), radius: 10));

    canvas.drawPath(path, paint);

    // Draw dotted line
    final dashPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startY = 15;
    while (startY < size.height - 15) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + 5), dashPaint);
      startY += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
