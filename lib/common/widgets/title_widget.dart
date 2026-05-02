import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';

import '../../util/images.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  final Color? color;
  final bool? islottie;
  final Color? Titlecolor;
  const TitleWidget(
      {super.key,
      required this.title,
      this.onTap,
      this.image,
      this.color,
      this.Titlecolor, this.islottie});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: .center,
        children: [
          Row(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(
                  color: Titlecolor,
                  fontSize: ResponsiveHelper.isDesktop(context)
                      ? Dimensions.fontSizeLarge
                      : Dimensions.fontSizeLarge)),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          if (image != null)
            Align(
              alignment: Alignment.topCenter,
              child: islottie == true
                  ? Lottie.asset(
                image!,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              )
                  : Image.asset(
                image!,
                height: image == Images.sparkle ? 35 : 20,
                width: image == Images.sparkle ? 35 : 20,
                fit: BoxFit.contain,
                color: image == Images.sparkle
                    ? Colors.red.shade900
                    : null,
              ),
            ),
        ],
      ),
      (onTap != null)
          ? InkWell(
              onTap: onTap as void Function()?,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r)
                ),
                child: Padding(
                    padding:EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "View All",
                            style: robotoMedium.copyWith(
                              fontSize: 12.sp,
                            ),
                          ),
                          const SizedBox(
                              width: 4),
                          Icon(
                            Icons.arrow_forward_rounded, // Cupertino-style arrow
                            size: 18.h,
                          ),
                        ],
                      ),
                    )),
              ),
            )
          : const SizedBox(),
    ]);
  }
}
// class TitleWidget extends StatelessWidget {
//   final String title;
//   final Function? onTap;
//   final String? image;
//
//   const TitleWidget({super.key, required this.title, this.onTap, this.image});
//
//   @override
//   Widget build(BuildContext context) {
//     final bool ltr = Get.find<LocalizationController>().isLtr;
//
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Expanded(
//         child: Row(
//           children: [
//             Text(title,
//                 style: robotoBold.copyWith(
//                     fontSize: ResponsiveHelper.isDesktop(context)
//                         ? Dimensions.fontSizeLarge
//                         : Dimensions.fontSizeLarge)),
//             const SizedBox(width: Dimensions.paddingSizeSmall),
//             image != null
//                 ? Image.asset(image!, height: 20, width: 20)
//                 : const SizedBox(),
//             const SizedBox(width: 5),
//             // Expanded(
//             //   child: Container(
//             //     height: 1,
//             //     decoration: const BoxDecoration(
//             //       gradient: LinearGradient(
//             //         begin: Alignment.centerLeft,
//             //         end: Alignment.centerRight,
//             //         colors: [Colors.black, Colors.transparent],
//             //         stops: [0.2, 0.6], // Positions where the colors change
//             //       ),
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//       (onTap != null)
//           ? InkWell(
//               onTap: onTap as void Function()?,
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(ltr ? 10 : 0, 5, ltr ? 0 : 10, 5),
//                 child: Row(
//                   children: [
//                     Text(
//                       'see_all'.tr,
//                       style: robotoMedium.copyWith(
//                         fontSize: Dimensions.fontSizeSmall,
//                         color: Theme.of(context).primaryColor,
//                         decorationColor:
//                             Theme.of(context).primaryColor, // underline color
//                       ),
//                     ),
//                     const SizedBox(width: 5),
//                     Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       color: Theme.of(context).primaryColor,
//                       size: 15,
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           : const SizedBox(),
//     ]);
//   }
// }

class TitleWidget1 extends StatelessWidget {
  final String title;
  final String title1;
  final Function? onTap;
  final String? image;
final double? fontsize;
  const TitleWidget1(
      {super.key,
      required this.title,
      required this.title1,
      this.onTap,
      this.image,this.fontsize});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: robotoBold.copyWith(
              fontSize: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.fontSizeLarge
                  : fontsize??Dimensions.fontSizeLarge,
            ),
            children: [
              TextSpan(
                text: title, // first part
                style: robotoBold.copyWith(
                    color: Colors.grey.shade800,
                    fontSize: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeLarge
                        : fontsize??Dimensions.fontSizeLarge), // custom color
              ),
              TextSpan(
                text: title1, // second part
                style: robotoBold.copyWith(
                    color: Colors.green,
                    fontSize: ResponsiveHelper.isDesktop(context)
                        ? Dimensions.fontSizeLarge
                        : fontsize??Dimensions.fontSizeLarge),
              ),
            ],
          ),
        ),
      ),
      (onTap != null)
          ? InkWell(
              onTap: onTap as void Function()?,
              child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(ltr ? 10 : 0, 5, ltr ? 0 : 10, 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'see_all'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).primaryColor,
                          // decorationColor: Theme.of(context).primaryColor, // underline color
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(
                          width: 4), // small space between text and arrow
                      Icon(
                        Icons
                            .arrow_forward_ios_rounded, // Cupertino-style arrow
                        size: 20, // adjust size to match text
                        color: Theme.of(context)
                            .primaryColor, // or Theme.of(context).primaryColor
                      ),
                    ],
                  )),
            )
          : const SizedBox(),
    ]);
  }
}
// class TitleWidget extends StatelessWidget {
//   final String title;
//   final Function? onTap;
//   final String? image;
//   const TitleWidget({super.key, required this.title, this.onTap, this.image});
//
//   @override
//   Widget build(BuildContext context) {
//
//     final bool ltr = Get.find<LocalizationController>().isLtr;
//
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Row(children: [
//         Text(title, style: robotoBold.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeLarge)),
//         const SizedBox(width: Dimensions.paddingSizeSmall),
//
//         image != null ? Image.asset(image!, height: 20, width: 20) : const SizedBox(),
//         ],
//       ),
//       (onTap != null) ? InkWell(
//         onTap: onTap as void Function()?,
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(ltr ? 10 : 0, 5, ltr ? 0 : 10, 5),
//           child: Text(
//             'see_all'.tr,
//             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
//           ),
//         ),
//       ) : const SizedBox(),
//     ]);
//   }
// }
