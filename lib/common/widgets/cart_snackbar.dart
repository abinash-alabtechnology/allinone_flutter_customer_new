import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

void showCartSnackBar() {
  final context = Get.context!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        right: ResponsiveHelper.isDesktop(context)
            ? context.width * 0.6
            : Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeLarge*5,
      ),
      content: const _CartSnackBarContent(),
    ),
  );
}

// void showCartSnackBar() {
//   ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
//     dismissDirection: DismissDirection.horizontal,
//     margin: EdgeInsets.only(
//       right: ResponsiveHelper.isDesktop(Get.context) ? Get.context!.width*0.7 : Dimensions.paddingSizeSmall,
//       top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall,
//     ),
//     duration: const Duration(seconds: 3),
//     backgroundColor: Colors.green,
//     behavior: SnackBarBehavior.floating,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
//     content: Text('item_added_to_cart'.tr, style: robotoMedium.copyWith(color: Colors.white)),
//     action: SnackBarAction(label: 'view_cart'.tr, onPressed: () => Get.toNamed(RouteHelper.getCartRoute()), textColor: Colors.white),
//   ));
// }


class _CartSnackBarContent extends StatefulWidget {
  const _CartSnackBarContent();

  @override
  State<_CartSnackBarContent> createState() => _CartSnackBarContentState();
}

class _CartSnackBarContentState extends State<_CartSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'item_added_to_cart'.tr,
              style: robotoMedium.copyWith(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),

          // ✅ View Cart Button
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Get.toNamed(RouteHelper.getCartRoute());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff4CAF50), Color(0xff66BB6A)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.shopping_cart,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
