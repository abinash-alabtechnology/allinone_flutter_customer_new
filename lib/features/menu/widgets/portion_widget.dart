import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PortionWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Color iconcolor;
  final Function()? onTap;
  const PortionWidget({super.key, required this.icon, required this.title, required this.route, this.hideDivider = false, this.suffix, this.onTap, required this.iconcolor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Get.toNamed(route),
      child: Container(
        child: Column(children: [
          Row(children: [
            Container(
              decoration:BoxDecoration(color:iconcolor.withValues(alpha: 0.15),borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(icon,color: iconcolor, height: 16, width: 16),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(child:
            Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)
            )),

            suffix != null ? Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
              child: Text(suffix!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, ), textDirection: TextDirection.ltr),
            ) :
            Icon(Icons.arrow_forward_ios_rounded,size:15,color: Colors.grey.shade600,),
          ]),
          hideDivider ? const SizedBox() : Padding(
            padding: const EdgeInsets.all(1.0),
            child: Divider(color: Colors.grey.shade100,),
          )
        ]),
      ),
    );
  }
}
class PortionWidget2 extends StatelessWidget {
  final String icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Color? color;
  final Function()? onTap;
  const PortionWidget2(
      {super.key,
        required this.icon,
        required this.title,
        required this.route,
        this.hideDivider = false,
        this.suffix,
        this.color,
        this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Get.toNamed(route),
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.only(
          left: Dimensions.paddingSizeSmall,
          right: Dimensions.paddingSizeSmall,
          top: 10,
          bottom: 10,
        ),
        margin: const EdgeInsets.only(
          top: 10,
        ),
        child: Column(children: [
          Row(
            children: [
              icon.endsWith('svg')
                  ? SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
              )
                  : Image.asset(
                icon,
                height: 24,
                width: 24,
                color: color ?? Colors.black,
              ),
              const SizedBox(
                width: Dimensions.paddingSizeSmall,
              ),
              Expanded(
                child: Text(
                  title,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.w500,
                    color: color ?? Colors.black,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
              )
            ],
          ),
        ]),
      ),
    );
  }
}