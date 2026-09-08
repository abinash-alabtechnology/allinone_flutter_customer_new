import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/card_design/item_card.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/home/widgets/views/special_offer_view.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../util/styles.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const MostPopularItemView({
    super.key,
    required this.isFood,
    required this.isShop,
  });

  @override
  Widget build(BuildContext context) {
    bool isShop =
        Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;

    return GetBuilder<ItemController>(
      builder: (itemController) {
        List<Item>? itemList = itemController.popularItemList;

        return (itemList != null)
            ? itemList.isNotEmpty
                  ? Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ClipPath(
                          clipper: SmartWaveClipper(radius: 9, humpWidth: 22),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow.withValues(alpha: 0.1),
                            ),
                            // color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            child: Column(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                                //   child: TitleWidget(
                                //     title: isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr,
                                //     image: Images.mostPopularIcon,
                                //     color: const Color(0xFF000080),
                                //     onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(true, false)),
                                //   ),
                                // ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 15.h),
                                     Padding(
                                       padding: const EdgeInsets.symmetric(
                                         vertical: 8,
                                       ),
                                       child: Column(
                                         mainAxisSize: MainAxisSize.min,
                                         crossAxisAlignment:
                                             CrossAxisAlignment.center,
                                         children: [
                                           Text(
                                             "Trending near you 📈",
                                             style: robotoBold.copyWith(
                                               fontSize: 18.sp,
                                               color: Colors.orange.shade800,
                                             ),
                                           ),
                                           SizedBox(height: 4.h),
                                           Text(
                                             "Popular products in your area",
                                             style: robotoMedium.copyWith(
                                               fontSize: 12.sp,
                                               color: Colors.orange.shade700,
                                             ),
                                             textAlign: TextAlign.center,
                                           ),
                                           SizedBox(height: 8.h),
                                           Container(
                                             height: 2,
                                             width: 180.w,
                                             color: Colors.orange,
                                           ),
                                         ],
                                       ),
                                     ),
                                  ],
                                ),

                                SizedBox(
                                  height: 460.h,
                                  width: Get.width,
                                  child: Skeletonizer(
                                    enabled:
                                        Get.find<ItemController>().isLoading,
                                    child: GridView.builder(
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 12,
                                            mainAxisExtent: 120.w,
                                            crossAxisSpacing: 12,
                                          ),
                                      padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeDefault,
                                      ),
                                      itemCount: itemList.length,
                                      physics: const ClampingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Get.find<ItemController>()
                                                .isAvailable(itemList[index])
                                            ? Container(
                                                child: TrendingItemCard(
                                                  isPopularItem: isShop
                                                      ? false
                                                      : true,
                                                  isPopularItemCart: true,
                                                  item: itemList[index],
                                                  isShop: isShop,
                                                  isFood: isFood,
                                                ),
                                              )
                                            : const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () => Get.toNamed(
                                      RouteHelper.getItemViewAllScreen(
                                        true,
                                        false,
                                      ),
                                    ),
                                    child: Container(
                                      height: 45.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_outlined,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            size: 18.h,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            'View More',
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
            : SizedBox();
      },
    );
  }
}

// class MostPopularItemView extends StatelessWidget {
//   final bool isFood;
//   final bool isShop;
//   const MostPopularItemView({super.key, required this.isFood, required this.isShop});
//
//   @override
//   Widget build(BuildContext context) {
//     bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
//       child: GetBuilder<ItemController>(builder: (itemController) {
//         List<Item>? itemList = itemController.popularItemList;
//
//           return (itemList != null) ? itemList.isNotEmpty ? Container(
//             color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
//             child: Column(children: [
//
//               Padding(
//                 padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
//                 child: TitleWidget(
//                   title: isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr,
//                   image: Images.mostPopularIcon,
//                   onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(true, false)),
//                 ),
//               ),
//
//               SizedBox(
//                 height: 285, width: Get.width,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   physics: const BouncingScrollPhysics(),
//                   padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
//                   itemCount: itemList.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
//                       child: ItemCard(
//                         isPopularItem: isShop ? false : true,
//                         isPopularItemCart: true,
//                         item: itemList[index],
//                         isShop: isShop,
//                         isFood: isFood,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//             ]),
//           ) : const SizedBox() : const ItemShimmerView(isPopularItem: true);
//         }
//       ),
//     );
//   }
// }

class SmartWaveClipper extends CustomClipper<Path> {
  final double radius;
  final double humpWidth;

  SmartWaveClipper({this.radius = 12, this.humpWidth = 22});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Drop the wave inside by "radius" amount
    double topY = radius;
    double x = 0;
    int humpCount = (size.width / humpWidth).ceil();
    bool down = true;

    // Move to start
    path.moveTo(0, topY);

    while (x < size.width) {
      double xMid = x + humpWidth / 2;
      double xEnd = x + humpWidth;

      path.quadraticBezierTo(
        xMid,
        down ? topY + radius : topY - radius,
        xEnd,
        topY,
      );

      down = !down;
      x += humpWidth;
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
