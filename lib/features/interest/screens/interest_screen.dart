import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/no_data_screen.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<CategoryController>().getCategoryList(true, allCategory: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<CategoryController>(builder: (categoryController) {
          return categoryController.categoryList != null
              ? categoryController.categoryList!.isNotEmpty
              ? Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              padding:
              const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                        height: Dimensions.paddingSizeLarge),
                    Text('Help us personalize your experience? 😋',
                        style: robotoBold.copyWith(fontSize: 28)),
                    // const SizedBox(
                    //     height: Dimensions.paddingSizeSmall),
                    // Text('get_personalized_recommendations'.tr,
                    //     style: robotoRegular.copyWith(
                    //         color: Theme.of(context).disabledColor)),
                    const SizedBox(
                        height: Dimensions.paddingSizeLarge),
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                        categoryController.categoryList!.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          ResponsiveHelper.isDesktop(context)
                              ? 4
                              : ResponsiveHelper.isTab(context)
                              ? 3
                              : 3,
                          mainAxisExtent: 135.h
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => categoryController
                                .addInterestSelection(index),
                            child: Container(
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: categoryController
                                    .interestSelectedList![index]
                                    ? Colors.grey.shade800
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0,left: 8.0,right: 8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(
                                            16),
                                        child: CustomImage(
                                          image:
                                          '${categoryController.categoryList![index].imageFullUrl}',
                                          height: 95,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets
                                          .symmetric(
                                        horizontal: Dimensions
                                            .paddingSizeSmall,
                                      ),
                                      child: Text(
                                        categoryController
                                            .categoryList![index]
                                            .name!,
                                        textAlign: TextAlign.center,
                                        style:
                                        robotoMedium.copyWith(
                                          fontSize:12,
                                          color: categoryController
                                              .interestSelectedList![
                                          index]
                                              ? Theme.of(context)
                                              .cardColor
                                              : Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    CustomButton(
                      buttonText: 'save_and_continue'.tr,
                      isLoading: categoryController.isLoading,
                      onPressed: () {
                        List<int?> interests = [];
                        for (int index = 0;
                        index <
                            categoryController
                                .categoryList!.length;
                        index++) {
                          if (categoryController
                              .interestSelectedList![index]) {
                            interests.add(categoryController
                                .categoryList![index].id);
                          }
                        }
                        categoryController
                            .saveInterest(interests)
                            .then((isSuccess) {
                          if (isSuccess) {
                            if (ResponsiveHelper.isDesktop(context)) {
                              Get.offAllNamed(
                                  RouteHelper.getInitialRoute());
                            } else {
                              Get.back();
                            }
                          }
                        });
                      },
                    ),
                  ]),
            ),
          )
              : NoDataScreen(text: 'no_category_found'.tr)
              : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}

class OverlappingTextClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(size.width * 0.7, 0); // Draw straight to 70% of the width

    // Create a curved shape on the right side
    path.quadraticBezierTo(
      size.width, size.height * 0.2, // Control point
      size.width, size.height * 0.5, // End point (50% height down)
    );

    // Complete the rectangle at the bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height); // Back to the bottom left
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// class InterestScreen extends StatefulWidget {
//   const InterestScreen({super.key});
//
//   @override
//   State<InterestScreen> createState() => _InterestScreenState();
// }
//
// class _InterestScreenState extends State<InterestScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     Get.find<CategoryController>().getCategoryList(true, allCategory: false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
//       endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
//       body: SafeArea(
//         child: GetBuilder<CategoryController>(builder: (categoryController) {
//           return categoryController.categoryList != null ? categoryController.categoryList!.isNotEmpty ? Center(
//             child: Container(
//               width: Dimensions.webMaxWidth,
//               padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                 Text('choose_your_interests'.tr, style: robotoMedium.copyWith(fontSize: 22)),
//                 const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                 Text('get_personalized_recommendations'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
//                 const SizedBox(height: Dimensions.paddingSizeLarge),
//
//                 Expanded(
//                   child: GridView.builder(
//                     physics: const BouncingScrollPhysics(),
//                     itemCount: categoryController.categoryList!.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
//                       childAspectRatio: (1/0.35),
//                     ),
//                     itemBuilder: (context, index) {
//                       return InkWell(
//                         onTap: () => categoryController.addInterestSelection(index),
//                         child: Container(
//                           margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                           padding: const EdgeInsets.symmetric(
//                             vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall,
//                           ),
//                           decoration: BoxDecoration(
//                             color: categoryController.interestSelectedList![index] ? Theme.of(context).primaryColor
//                                 : Theme.of(context).cardColor,
//                             borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                             boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                           ),
//                           alignment: Alignment.center,
//                           child: Row(children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                               child: CustomImage(
//                                 image: '${categoryController.categoryList![index].imageFullUrl}',
//                                 height: 30, width: 30,
//                               ),
//                             ),
//                             const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                             Flexible(child: Text(
//                               categoryController.categoryList![index].name!,
//                               style: robotoMedium.copyWith(
//                                 fontSize: Dimensions.fontSizeSmall,
//                                 color: categoryController.interestSelectedList![index] ? Theme.of(context).cardColor
//                                     : Theme.of(context).textTheme.bodyLarge!.color,
//                               ),
//                               maxLines: 2, overflow: TextOverflow.ellipsis,
//                             )),
//                           ]),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 CustomButton(
//                   buttonText: 'save_and_continue'.tr,
//                   isLoading: categoryController.isLoading,
//                   onPressed: () {
//                     List<int?> interests = [];
//                     for(int index=0; index<categoryController.categoryList!.length; index++) {
//                       if(categoryController.interestSelectedList![index]) {
//                         interests.add(categoryController.categoryList![index].id);
//                       }
//                     }
//                     categoryController.saveInterest(interests).then((isSuccess) {
//                       if(isSuccess) {
//                         if(ResponsiveHelper.isDesktop(Get.context)) {
//                           Get.offAllNamed(RouteHelper.getInitialRoute());
//                         } else {
//                           Get.back();
//                         }
//                       }
//                     });
//                   },
//                 ),
//
//               ]),
//             ),
//           ) : NoDataScreen(text: 'no_category_found'.tr) : const Center(child: CircularProgressIndicator());
//         }),
//       ),
//     );
//   }
// }
