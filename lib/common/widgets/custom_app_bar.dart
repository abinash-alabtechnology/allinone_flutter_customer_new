import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/cart_widget.dart';
import 'package:handy_allinone/common/widgets/veg_filter_widget.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  final Color? bgcolor;
  final Color? textcolor;
  final Color? iconcolor;

  const CustomAppBar({super.key, required this.title, this.backButton = true, this.onBackPressed, this.showCart = false, this.leadingIcon, this.onVegFilterTap, this.type, this.bgcolor, this.textcolor, this.iconcolor});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? const WebMenuBar() :
    AppBar(
      title: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600, color: textcolor??Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: backButton ? IconButton(
        icon: leadingIcon != null ? Image.asset(leadingIcon!, height: 22, width: 22) : const Icon(Icons.arrow_back_ios),
        color: iconcolor??Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
      ) : const SizedBox(),
      backgroundColor:bgcolor?? Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
      elevation: 2,
      actions: showCart || onVegFilterTap != null ? [
        showCart ? IconButton(
          onPressed: () {
            Get.find<CartController>().getCartDataOnline();
            Get.toNamed(RouteHelper.getCartRoute());
          },
          icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
        ) : const SizedBox(),

        onVegFilterTap != null ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
        ) : const SizedBox(),

      ] : [const SizedBox()],
    )
    ;
  }

  @override
  Size get preferredSize => Size(Get.width, 50);
}

class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  const CustomAppBar2(
      {super.key,
        required this.title,
        this.backButton = true,
        this.onBackPressed,
        this.showCart = false,
        this.leadingIcon,
        this.onVegFilterTap,
        this.type});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? const WebMenuBar()
        : AppBar(
      title: Text(title,
          style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: backButton
          ? IconButton(
        icon: leadingIcon != null
            ? Image.asset(leadingIcon!, height: 22, width: 22)
            : const Icon(Icons.arrow_back),
        color: Theme.of(context).textTheme.bodyLarge!.color,
        onPressed: () => onBackPressed != null
            ? onBackPressed!()
            : Navigator.pop(context),
      )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Theme.of(context).disabledColor.withOpacity(0.5),
      elevation: 2,
      actions: showCart || onVegFilterTap != null
          ? [
        showCart
            ? IconButton(
          onPressed: () {
            Get.find<CartController>().getCartDataOnline();
            Get.toNamed(RouteHelper.getCartRoute());
          },
          icon: CartWidget(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color,
              size: 25),
        )
            : const SizedBox(),
        onVegFilterTap != null
            ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
        )
            : const SizedBox(),
      ]
          : [const SizedBox()],
    );
  }

  @override
  Size get preferredSize => Size(Get.width, 50);
}
class CustomAppBar3 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  final Color? bgcolor;
  final Color? textcolor;
  final Color? iconcolor;

  const CustomAppBar3({
    super.key,
    required this.title,
    this.backButton = true,
    this.onBackPressed,
    this.showCart = false,
    this.leadingIcon,
    this.onVegFilterTap,
    this.type,
    this.bgcolor,
    this.textcolor,
    this.iconcolor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? const WebMenuBar()
        : AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: bgcolor ?? Theme.of(context).primaryColor,
            surfaceTintColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),

      title: Text(
        title.toUpperCase(),
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraLarge,
          fontWeight: FontWeight.w900,
          color: textcolor ?? Colors.white,
        ),
      ),

      leading: backButton
          ? IconButton(
        icon: leadingIcon != null
            ? Image.asset(leadingIcon!, height: 22, width: 22)
            : const Icon(Icons.arrow_back_ios),
        color: iconcolor ?? Colors.white,
        onPressed: () => onBackPressed != null
            ? onBackPressed!()
            : Navigator.pop(context),
      )
          : const SizedBox(),

      actions: showCart || onVegFilterTap != null
          ? [
        showCart
            ? IconButton(
          onPressed: () {
            Get.find<CartController>().getCartDataOnline();
            Get.toNamed(RouteHelper.getCartRoute());
          },
          icon: CartWidget(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color,
              size: 25),
        )
            : const SizedBox(),
        onVegFilterTap != null
            ? VegFilterWidget(
          type: type,
          onSelected: onVegFilterTap,
          fromAppBar: true,
        )
            : const SizedBox(),
      ]
          : [const SizedBox()],
    );
  }

  @override
  Size get preferredSize =>
      Size(Get.width, GetPlatform.isDesktop ? 100 : 60);
}
