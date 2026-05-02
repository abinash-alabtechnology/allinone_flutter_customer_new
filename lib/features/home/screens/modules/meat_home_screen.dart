import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:handy_allinone/features/home/widgets/views/category_view.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:handy_allinone/features/home/widgets/views/most_popular_item_view.dart';
import 'package:handy_allinone/features/home/widgets/views/special_offer_view.dart';
import 'package:handy_allinone/features/home/widgets/views/visit_again_view.dart';
import 'package:handy_allinone/features/home/widgets/banner_view.dart';
import 'package:handy_allinone/util/styles.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/dimensions.dart';
import '../../../category/controllers/category_controller.dart';
import '../../widgets/bad_weather_widget.dart';
import '../../widgets/views/promotional_banner_view.dart';

class MeatHomeScreen extends StatefulWidget {
  const MeatHomeScreen({super.key,});

  @override
  _MeatHomeScreenState createState() => _MeatHomeScreenState();
}

class _MeatHomeScreenState extends State<MeatHomeScreen> {

  void openNotificationSettings() {
    AppSettings.openAppSettings();
  }



  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Reset scroll to top whenever this screen is rebuilt/shown
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (widget.scrollController?.hasClients ?? false) {
  //       widget.scrollController?.jumpTo(0);
  //     }
  //   });
  // }

  // @override
  // void dispose() {
  //   widget.scrollController?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).disabledColor.withOpacity(0.1),
            child: Column(
              children: [
                BadWeatherWidget(),
                const BannerView(isFeatured: false),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: openNotificationSettings,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 1.5,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enable Push Notifications",
                            style: robotoBold.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap here to never miss out on our exciting deals & offers",
                            maxLines: 2,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: openNotificationSettings,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GetBuilder<CategoryController>(
            builder: (categoryController) {
              if (categoryController.categoryList == null) {
                return CategoryShimmer(categoryController: categoryController);
              }

              return SizedBox(
                width: Get.width,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final int itemCount = categoryController.categoryList!.length > 15
                        ? 15
                        : categoryController.categoryList!.length;

                    final int crossAxisCount =
                    ResponsiveHelper.isDesktop(context) ? 5 : 3;

                    const double itemHeight = 160;
                    const double spacing = 20;
                    final int rowCount = (itemCount / crossAxisCount).ceil();
                    final double totalHeight =
                        (rowCount * itemHeight) + ((rowCount - 1) * spacing);

                    return SizedBox(
                      height: totalHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeDefault,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          mainAxisExtent: 150,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          final category = categoryController.categoryList![index];
                          return InkWell(
                            onTap: () => Get.toNamed(
                              RouteHelper.getCategoryItemRoute(
                                category.id,
                                category.name!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(Dimensions.radiusDefault),
                                  child: Container(
                                    height: 120,
                                    width: double.infinity,
                                    color: Theme.of(context).cardColor,
                                    child: CustomImage(
                                      image: category.imageFullUrl ?? '',
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    category.name!,
                                    style: robotoMedium.copyWith(fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // const CategoryView(),
          isLoggedIn ? const VisitAgainView() : const SizedBox(),
          const SpecialOfferView(isFood: false, isShop: false),
          const MostPopularItemView(isFood: false, isShop: false),
          const BestReviewItemView(),
          const PromotionalBannerView(),
        ],
      ),
    );
  }
}

// class MeatHomeScreen extends StatelessWidget {
//   const MeatHomeScreen({super.key});
//
//   void openNotificationSettings() {
//     AppSettings.openAppSettings();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isLoggedIn = AuthHelper.isLoggedIn();
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Container(
//         width: MediaQuery.of(context).size.width,
//         color: Theme.of(context).disabledColor.withOpacity(0.1),
//         child: Column(
//           children: [
//             BadWeatherWidget(),
//             const BannerView(isFeatured: false),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(8),
//           onTap: () async {
//             openNotificationSettings();
//           },
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 width: 1.5,
//                 color: Theme.of(context).disabledColor,
//               ),
//             ),
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Enable Push Notifications",
//                         style: robotoBold.copyWith(
//                           color: Theme.of(context).primaryColor,
//                           fontSize: Dimensions.fontSizeLarge,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Tap here to never miss out on our exciting deals & offers",
//                         maxLines: 2,
//                         style: robotoRegular.copyWith(
//                           fontSize: Dimensions.fontSizeSmall,
//                           color: Theme.of(context).hintColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 InkWell(
//                   borderRadius: BorderRadius.circular(50),
//                   onTap: openNotificationSettings,
//                   child: Container(
//                     height: 40,
//                     width: 40,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.notifications_active,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//
//       const CategoryView(),
//       isLoggedIn ? const VisitAgainView() : const SizedBox(),
//       const SpecialOfferView(isFood: false, isShop: false),
//       // const HighlightWidget(),
//       // const FlashSaleViewWidget(),
//       // const BestStoreNearbyView(),
//       const MostPopularItemView(isFood: false, isShop: false),
//       // const MiddleSectionBannerView(),
//       const BestReviewItemView(),
//       // const JustForYouView(),
//       // const ItemThatYouLoveView(forShop: false),
//       // isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
//       // const NewOnMartView(isPharmacy: false, isShop: false),
//       const PromotionalBannerView(),
//       // SizedBox(
//       //   height: 100,
//       // )
//     ]);
//   }
// }