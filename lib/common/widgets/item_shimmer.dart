import 'package:shimmer/shimmer.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:get/get.dart';

import 'custom_image.dart';

// class ItemShimmer extends StatelessWidget {
//   final bool isEnabled;
//   final bool isStore;
//   final bool hasDivider;
//   const ItemShimmer({super.key, required this.isEnabled, required this.hasDivider, this.isStore = false});
//
//   @override
//   Widget build(BuildContext context) {
//     bool desktop = ResponsiveHelper.isDesktop(context);
//
//     return Container(
//       padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//         color: Theme.of(context).cardColor,
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
//               child: Row(children: [
//
//                 Container(
//                   height: desktop ? 120 : 80, width: desktop ? 120 : 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                     color: Theme.of(context).shadowColor,
//                   ),
//                 ),
//                 const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                 Expanded(
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
//
//                     Container(height: desktop ? 20 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor),
//                     const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                     Container(
//                       height: desktop ? 15 : 10, width: double.maxFinite, color: Theme.of(context).shadowColor,
//                       margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
//                     ),
//                     SizedBox(height: isStore ? Dimensions.paddingSizeSmall : 0),
//
//                     !isStore ? Row(
//                       children: List.generate(5, (index) {
//                         return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 12);
//                       }),
//                     ) : const SizedBox(),
//                     isStore ? Row(
//                       children: List.generate(5, (index) {
//                         return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 12);
//                       }),
//                     ) : Row(children: [
//                       Container(height: desktop ? 20 : 15, width: 30, color: Theme.of(context).shadowColor),
//                       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                       Container(height: desktop ? 15 : 10, width: 20, color: Theme.of(context).shadowColor),
//                     ]),
//
//                   ]),
//                 ),
//
//                 Column(mainAxisAlignment: isStore ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween, children: [
//                   const SizedBox(),
//
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
//                     child: Icon(
//                       Icons.favorite_border,  size: desktop ? 30 : 25,
//                       color: Theme.of(context).shadowColor,
//                     ),
//                   ),
//                 ]),
//
//               ]),
//             ),
//           ),
//           desktop ? const SizedBox() : Padding(
//             padding: EdgeInsets.only(left: desktop ? 130 : 90),
//             child: Divider(color: hasDivider ? Theme.of(context).shadowColor : Colors.transparent),
//           ),
//         ],
//       ),
//     );
//   }
// }




class ItemShimmer extends StatelessWidget {
  final bool hasDivider;
  final bool isStore;
    final bool isEnabled;

  const ItemShimmer({super.key, this.hasDivider = true, required this.isStore, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.pharmacy.toLowerCase();

    return isPharmacy ? Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ) : Column(
      children: [
        Skeletonizer(
          enabled: true,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 60, color: Colors.grey.shade300),
                const SizedBox(height: 4),
                Container(height: 10, width: 100, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
