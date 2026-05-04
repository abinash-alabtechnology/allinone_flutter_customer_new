import 'dart:math' as math;
import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/features/home/widgets/category_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../helper/auth_helper.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../category_view.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return GetBuilder<SplashController>(
      builder: (splashController) {
        bool isPharmacy =
            splashController.module != null &&
            splashController.module!.moduleType.toString() == 'pharmacy';
        bool isFood =
            splashController.module != null &&
            splashController.module!.moduleType.toString() == 'food';
        bool isMeat =
            splashController.module != null &&
            splashController.module!.moduleName.toString().toLowerCase() ==
                "meat";

        return GetBuilder<CategoryController>(
          builder: (categoryController) {
            return (categoryController.categoryList != null &&
                    categoryController.categoryList!.isEmpty)
                ? const SizedBox()
                : isPharmacy
                ? PharmacyCategoryView(categoryController: categoryController)
                : isFood
                ? FoodCategoryView(categoryController: categoryController)
                : Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: categoryController.categoryList != null
                                ? ListView.builder(
                                    controller: scrollController,
                                    itemCount:
                                        categoryController
                                                .categoryList!
                                                .length >
                                            15
                                        ? 15
                                        : categoryController
                                              .categoryList!
                                              .length,
                                    padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall,
                                      top: Dimensions.paddingSizeDefault,
                                    ),
                                    primary: false,
                                    physics: const ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final category = categoryController
                                          .categoryList![index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 1,
                                          vertical:
                                              Dimensions.paddingSizeDefault,
                                        ),
                                        child: InkWell(
                                          onTap: () => Get.toNamed(
                                            RouteHelper.getCategoryItemRoute(
                                              category.id,
                                              category.name!,
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: 60,
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  margin: EdgeInsets.only(
                                                    left: index == 0
                                                        ? 0
                                                        : Dimensions
                                                              .paddingSizeExtraSmall,
                                                    right: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall,
                                                        ),
                                                    child: CustomImage(
                                                      image:
                                                          category
                                                              .imageFullUrl ??
                                                          '',
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: index == 0
                                                        ? Dimensions
                                                              .paddingSizeExtraSmall
                                                        : 0,
                                                  ),
                                                  child: Text(
                                                    category.name!,
                                                    style: robotoMedium
                                                        .copyWith(fontSize: 11),
                                                    maxLines:
                                                        Get.find<
                                                              LocalizationController
                                                            >()
                                                            .isLtr
                                                        ? 2
                                                        : 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : CategoryShimmer(
                                    categoryController: categoryController,
                                  ),
                          ),

                          // View All Button for Web/Desktop
                          ResponsiveHelper.isMobile(context)
                              ? const SizedBox()
                              : categoryController.categoryList != null
                              ? Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (con) => Dialog(
                                            child: SizedBox(
                                              height: 550,
                                              width: 600,
                                              child: CategoryPopUp(
                                                categoryController:
                                                    categoryController,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeSmall,
                                        ),
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                          child: Text(
                                            'view_all'.tr,
                                            style: TextStyle(
                                              fontSize:
                                                  Dimensions.paddingSizeDefault,
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : CategoryAllShimmer(
                                  categoryController: categoryController,
                                ),
                        ],
                      ),
                    ],
                  );
          },
        );
      },
    );
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final CategoryController categoryController;

  const PharmacyCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shop by Category', style: robotoBold.copyWith(fontSize: 18, color: Colors.black87)),
              TextButton(
                onPressed: () {
                  Get.toNamed(RouteHelper.getCategoryRoute());
                },
                child: Text('View all', style: robotoMedium.copyWith(color: const Color(0xFF1B5E5E), fontSize: 14)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: categoryController.categoryList != null
              ? ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemCount: categoryController.categoryList!.length,
                  itemBuilder: (context, index) {
                    final category = categoryController.categoryList![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(RouteHelper.getCategoryItemRoute(category.id, category.name!));
                        },
                        child: Column(
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: CustomImage(
                                image: category.imageFullUrl ?? '',
                                height: 35,
                                width: 35,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 80,
                              child: Text(
                                category.name ?? '',
                                style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey.shade700, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}

class FoodCategoryView extends StatelessWidget {
  final CategoryController categoryController;

  const FoodCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    final ScrollController scrollController = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(0.4),
                  ),
                ),
              ),
              Text(
                "   WHATS IN YOUR MIND   ",
                style: robotoBold.copyWith(
                  fontSize: 18.sp,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child:
        //       //  Row(
        //       //   children: [
        //       Row(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         "Hey! ",
        //         style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        //       ),
        //       const WavingHandAnimated(),
        //       Flexible(
        //         child: Text(
        //           "${isLoggedIn ? Get.find<ProfileController>().userInfoModel?.fName ?? '' : ''}  What's on your mind?",
        //           style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        //           maxLines: 1,
        //           overflow: TextOverflow.ellipsis,
        //         ),
        //       ),
        //     ],
        //   ),
        //   // const SizedBox(width: 5),
        //   // Expanded(
        //   //   child: Container(
        //   //     height: 1,
        //   //     decoration: const BoxDecoration(
        //   //       gradient: LinearGradient(
        //   //         begin: Alignment.centerLeft,
        //   //         end: Alignment.centerRight,
        //   //         colors: [Colors.black, Colors.transparent],
        //   //         stops: [0.2, 0.6], // Positions where the colors change
        //   //       ),
        //   //     ),
        //   //   ),
        //   // ),
        //   //   ],
        //   // ),
        // ),
        SizedBox(
          height: 290,
          width: MediaQuery.of(context).size.width,
          child: Skeletonizer(
            enabled: categoryController.categoryList == null,
            child: GridView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisExtent: 100,
              ),

              itemCount: categoryController.categoryList?.length ?? 8,

              itemBuilder: (context, index) {
                final list = categoryController.categoryList;
                final category = list != null ? list[index] : null; // <— safe
                final isLoading = category == null;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    top: Dimensions.paddingSizeDefault,
                  ),
                  child: InkWell(
                    onTap: isLoading
                        ? null
                        : () {
                            Get.toNamed(
                              RouteHelper.getCategoryItemRoute(
                                category.id,
                                category.name!,
                              ),
                            );
                          },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                          child: CustomImage(
                            image:
                                categoryController
                                    .categoryList?[index]
                                    .imageFullUrl ??
                                'default_image_url',
                            fit: BoxFit.fill,
                            height: 90,
                            width: 90,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            isLoading ? "Loading..." : category.name ?? "",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    // Stack(children: [
    //   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 20),
    //       child:
    //           //  Row(
    //           //   children: [
    //           Row(
    //         children: [
    //           Text(
    //             "Hey! ",
    //             style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
    //           ),
    //           const WavingHandAnimated(),
    //           Text(
    //             "${isLoggedIn ? Get.find<ProfileController>().userInfoModel?.fName ?? '' : ''}  What's on your mind?",
    //             style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
    //             maxLines: 2,
    //             overflow: TextOverflow.ellipsis,
    //           ),
    //         ],
    //       ),
    //       // const SizedBox(width: 5),
    //       // Expanded(
    //       //   child: Container(
    //       //     height: 1,
    //       //     decoration: const BoxDecoration(
    //       //       gradient: LinearGradient(
    //       //         begin: Alignment.centerLeft,
    //       //         end: Alignment.centerRight,
    //       //         colors: [Colors.black, Colors.transparent],
    //       //         stops: [0.2, 0.6], // Positions where the colors change
    //       //       ),
    //       //     ),
    //       //   ),
    //       // ),
    //       //   ],
    //       // ),
    //     ),
    //     SizedBox(
    //       height: 290,
    //       width: MediaQuery.of(context).size.width,
    //       child: categoryController.categoryList != null
    //           ? GridView.builder(
    //               controller: scrollController,
    //               physics: const BouncingScrollPhysics(),
    //               shrinkWrap: true,
    //               scrollDirection: Axis.horizontal,
    //               padding: const EdgeInsets.only(
    //                   left: Dimensions.paddingSizeDefault),
    //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                   crossAxisCount: 2, // Number of items per row
    //                   childAspectRatio: 1,
    //                   mainAxisExtent: 100 // Adjust the aspect ratio as needed
    //                   ),
    //               itemCount: categoryController.categoryList!.length,
    //               itemBuilder: (context, index) {
    //                 return Padding(
    //                   padding: const EdgeInsets.only(
    //                     bottom: Dimensions.paddingSizeDefault,
    //                     right: Dimensions.paddingSizeDefault,
    //                     top: Dimensions.paddingSizeDefault,
    //                   ),
    //                   child: InkWell(
    //                     onTap: () {
    //                       Get.toNamed(RouteHelper.getCategoryItemRoute(
    //                         categoryController.categoryList![index].id,
    //                         categoryController.categoryList![index].name!,
    //                       ));
    //                     },
    //                     borderRadius:
    //                         BorderRadius.circular(Dimensions.radiusSmall),
    //                     child: SizedBox(
    //                       child: Column(
    //                         children: [
    //                           ClipRRect(
    //                             borderRadius: const BorderRadius.all(
    //                               Radius.circular(100),
    //                             ),
    //                             child: CustomImage(
    //                               image: categoryController
    //                                       .categoryList?[index].imageFullUrl ??
    //                                   'default_image_url',
    //                               fit: BoxFit.fill,
    //                               height: 90,
    //                               width: 90,
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                               height: Dimensions.paddingSizeSmall),
    //                           Expanded(
    //                             child: Text(
    //                               categoryController
    //                                       .categoryList?[index]?.name ??
    //                                   '',
    //                               // categoryController
    //                               //         .categoryList![index].name ??
    //                               //     '',
    //                               style: robotoMedium.copyWith(
    //                                 fontSize: Dimensions.fontSizeSmall,
    //                                 color: Theme.of(context)
    //                                     .textTheme
    //                                     .bodyMedium!
    //                                     .color,
    //                               ),
    //                               maxLines: 2,
    //                               overflow: TextOverflow.ellipsis,
    //                               textAlign: TextAlign.center,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //               },
    //             )
    //           : FoodCategoryShimmer(categoryController: categoryController),
    //     ),
    //   ]),
    // ]);
    //   Stack(children: [
    //   Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //     SizedBox(
    //       height: 160,
    //       child: categoryController.categoryList != null ? ListView.builder(
    //         controller: scrollController,
    //         physics: const BouncingScrollPhysics(),
    //         shrinkWrap: true,
    //         scrollDirection: Axis.horizontal,
    //         padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
    //         itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
    //         itemBuilder: (context, index) {
    //           return Padding(
    //             padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
    //             child: InkWell(
    //               onTap: () {
    //                 if(index == 9 && categoryController.categoryList!.length > 10) {
    //                   Get.toNamed(RouteHelper.getCategoryRoute());
    //                 } else {
    //                   Get.toNamed(RouteHelper.getCategoryItemRoute(
    //                     categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
    //                   ));
    //                 }
    //               },
    //               borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
    //               child: SizedBox(
    //                 width: 60,
    //                 child: Column(children: [
    //
    //                   Stack(
    //                     children: [
    //                       ClipRRect(
    //                         borderRadius: const BorderRadius.all(Radius.circular(100)),
    //                         child: CustomImage(
    //                           image: '${categoryController.categoryList![index].imageFullUrl}',
    //                           height: 60, width: double.infinity, fit: BoxFit.cover,
    //                         ),
    //                       ),
    //
    //                       (index == 9 && categoryController.categoryList!.length > 10) ? Positioned(
    //                         right: 0, left: 0, top: 0, bottom: 0,
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                             borderRadius: const BorderRadius.all(Radius.circular(100)),
    //                             gradient: LinearGradient(
    //                               begin: Alignment.topCenter,
    //                               end: Alignment.bottomCenter,
    //                               colors: [
    //                                 Theme.of(context).primaryColor.withValues(alpha: 0.4),
    //                                 Theme.of(context).primaryColor.withValues(alpha: 0.6),
    //                                 Theme.of(context).primaryColor.withValues(alpha: 0.4),
    //                               ],
    //                             ),
    //                           ),
    //                           child: Center(
    //                             child: Text(
    //                               '+${categoryController.categoryList!.length - 10}',
    //                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
    //                               maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
    //                             ),
    //                           )
    //                         ),
    //                       ) : const SizedBox(),
    //                     ],
    //                   ),
    //                   const SizedBox(height: Dimensions.paddingSizeSmall),
    //
    //                   Expanded(child: Text(
    //                     (index == 9 && categoryController.categoryList!.length > 10) ?  'see_all'.tr : categoryController.categoryList![index].name ?? '',
    //                     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: (index == 9 && categoryController.categoryList!.length > 10) ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
    //                     maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
    //                   )),
    //                 ]),
    //               ),
    //             ),
    //           );
    //         },
    //       ) : FoodCategoryShimmer(categoryController: categoryController),
    //     ),
    //   ]),
    //
    // ]);
  }
}

class GreetingText extends StatefulWidget {
  final bool isLoggedIn;

  const GreetingText({super.key, required this.isLoggedIn});

  @override
  State<GreetingText> createState() => _GreetingTextState();
}

class _GreetingTextState extends State<GreetingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _rotation = Tween<double>(
      begin: -0.25,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.isLoggedIn
        ? Get.find<ProfileController>().userInfoModel?.fName ?? ''
        : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _rotation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotation.value * math.pi / 8,
              child: const Text("👋", style: TextStyle(fontSize: 26)),
            );
          },
        ),
        const SizedBox(width: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Hey! ",
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                TextSpan(
                  text: userName.isNotEmpty ? "$userName " : "",
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const TextSpan(
                  text: "What's on your mind?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;

  const CategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        top: Dimensions.paddingSizeDefault,
      ),
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 1,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  Container(
                    height: 75,
                    width: 75,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                      right: Dimensions.paddingSizeExtraSmall,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Padding(
                    padding: EdgeInsets.only(
                      right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0,
                    ),
                    child: Container(
                      height: 10,
                      width: 50,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FoodCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;

  const FoodCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            top: Dimensions.paddingSizeDefault,
          ),
          child: SizedBox(
            width: 60,
            child: Column(
              children: [
                ClipOval(
                  child: Shimmer(
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Shimmer(
                    child: Container(
                      height: 10,
                      width: 50,
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PharmacyCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;

  const PharmacyCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            top: Dimensions.paddingSizeDefault,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                      ),
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Container(
                      height: 10,
                      width: 50,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WavingHandAnimated extends StatefulWidget {
  const WavingHandAnimated({super.key});

  @override
  State<WavingHandAnimated> createState() => _WavingHandAnimatedState();
}

class _WavingHandAnimatedState extends State<WavingHandAnimated> {
  bool _isTilted = false;

  @override
  void initState() {
    super.initState();
    _startWaving();
  }

  void _startWaving() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _isTilted = !_isTilted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      transform: Matrix4.rotationZ(_isTilted ? -pi / 8 : pi / 8),
      transformAlignment: Alignment.center,
      child: const Text(
        "👋",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
