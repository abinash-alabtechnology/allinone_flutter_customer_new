import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../../util/app_constants.dart';
import '../../../util/images.dart';

class DetailsAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const DetailsAppBarWidget({super.key});

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Row(
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              width: 30,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: Theme.of(context).textTheme.bodyLarge!.color),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAssetImageWidget(
                Images.logo,
                width: 60.w,
                height: 30.h,
                fit: BoxFit.fill,
              ),
              Text(
                AppConstants.developedby,
                style: robotoMedium.copyWith(
                  fontSize: 8.r,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ],
          ),
        ],
      ),
      leadingWidth: 180.w,
      actions: [
      AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offsetAnimation.value, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, RouteHelper.getCartRoute()),
            child: Row(
              children: [
                Text("Cart  ", style: robotoBold.copyWith(fontSize: 16.r)),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: GetBuilder<CartController>(
                    builder: (cartController) => FittedBox(
                      child: Text(
                        cartController.cartList.length.toString(),
                        style: robotoMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
        SizedBox(width: 5,)
      ],
    );
  }
}
