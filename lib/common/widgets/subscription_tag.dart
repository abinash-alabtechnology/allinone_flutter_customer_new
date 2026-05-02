import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class SubscriptionTag extends StatelessWidget {
  final double? top, left, right;
  const SubscriptionTag({super.key, this.top = 10, this.left, this.right = 0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusLarge),
            bottomLeft: Radius.circular(Dimensions.radiusLarge),
          ),
        ),
        child: Text(
          'subscription'.tr,
          style: robotoMedium.copyWith(color: Colors.white, fontSize: 8),
        ),
      ),
    );
  }
}
