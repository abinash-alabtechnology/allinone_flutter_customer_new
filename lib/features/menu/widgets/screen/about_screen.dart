import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';

import '../../../../helper/route_helper.dart';
import '../../../splash/controllers/splash_controller.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar2(title: "About Us"),
      body: ListView.builder(
        itemCount: aboutItems.length,
        itemBuilder: (context, index) {
          final item = aboutItems[index];
          return navBar(
            title: item.title,
            onTap: item.onTap,
            color: item.color,
          );
        },
      ),
    );
  }

  Widget navBar({required String title, VoidCallback? onTap, Color? color}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.black,
      ),
    );
  }
}

class AboutItem {
  final String title;
  final VoidCallback? onTap;
  final Color color;

  AboutItem({
    required this.title,
    this.onTap,
    this.color = Colors.black,
  });
}

final List<AboutItem> aboutItems = [
  // AboutItem(title: "FAQ", onTap: () {}),
  // AboutItem(title: "Mobile number", onTap: () {}),
  AboutItem(title: 'about_us'.tr, onTap: () =>Get.toNamed(RouteHelper.getHtmlRoute('about-us'))),
  // AboutItem(title: "Live Chat", onTap: () {
  //   Get.back();
  //   Get.toNamed(RouteHelper.getConversationRoute());
  // }),
  // AboutItem(title: 'help_and_support'.tr, onTap: () => Get.toNamed(RouteHelper.getSupportRoute())),
  AboutItem(title: "Terms & Condition", onTap: () => Get.toNamed(RouteHelper.getHtmlRoute(
      'terms-and-condition'))),
  AboutItem(title: 'privacy_policy'.tr, onTap: ()  => Get.toNamed( RouteHelper.getHtmlRoute(
      'privacy-policy'))),
  if (Get.find<SplashController>().configModel!.refundPolicyStatus == 1)
  AboutItem(title: 'refund_policy'.tr, onTap: () => Get.toNamed(RouteHelper.getHtmlRoute(
      'refund-policy'))),
  if(Get.find<SplashController>()
      .configModel!
      .shippingPolicyStatus ==
      1)
  AboutItem(title: 'shipping_policy'.tr, onTap: () => Get.toNamed( RouteHelper.getHtmlRoute(
'shipping-policy'),)),
  // AboutItem(
  //   title: "Delete Account",
  //   onTap: () => Get.to(() => const AboutLogoutScreen()),
  //   color: Colors.red,
  // ),
];
