import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/home/widgets/components/review_item_card_widget.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/common/widgets/title_widget.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../../../util/images.dart';

class BestReviewItemView extends StatefulWidget {
  const BestReviewItemView({super.key});

  @override
  State<BestReviewItemView> createState() => _BestReviewItemViewState();
}

class _BestReviewItemViewState extends State<BestReviewItemView> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        List<Item>? reviewItemList = itemController.reviewedItemList;
        int reviewOffset = 1;

        return reviewItemList != null
            ? reviewItemList.isNotEmpty
                  ? Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                        //   child: TitleWidget(
                        //     title: 'best_reviewed_item'.tr,
                        //     onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(false, false)),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(
                                alpha: 0.1,
                              ), // light beige
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: .center,
                              mainAxisAlignment: .center,
                              children: [
                                CustomAssetImageWidget(
                                  Images.thump,
                                  height: 35.h,
                                  width: 40.w,
                                ),
                                SizedBox(width: 10.w),
                                RichText(
                                  text: TextSpan(
                                    style:  robotoBold.copyWith(
                                      fontSize: 13.sp,
                                      color: Color(0xFF2C2C2C),
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Highly ',
                                        style: robotoBold.copyWith(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Reviewed ',
                                        style: robotoBold.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Products,\n',
                                        style: robotoBold.copyWith(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Curated for Quality',
                                        style: robotoBold.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double width = constraints.maxWidth;
                                int crossAxisCount = 2;

                                if (width >= 600 && width < 950) {
                                  crossAxisCount = 3;
                                } else if (width >= 950 && width < 1200) {
                                  crossAxisCount = 4;
                                } else if (width >= 1200) {
                                  crossAxisCount = 5;
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                    vertical: Dimensions.paddingSizeDefault,
                                  ),
                                  itemCount: reviewItemList.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                                    mainAxisExtent: 290.h
                                  ),
                                  itemBuilder: (context, index) {
                                    return CustomInkWell(
                                      onTap: () => Get.find<ItemController>().navigateToItemPage(
                                        reviewItemList[index],
                                        context,
                                      ),
                                      child: ReviewItemCard(
                                        item: itemController.reviewedItemList![index],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                             SizedBox(height: 10.h),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              child: Container(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    reviewOffset++;
                                    await Get.find<ItemController>().getReviewedItemList(offset: reviewOffset.toString());
                                  },
                                  child: Text(
                                    "See More",
                                    style: robotoBold.copyWith(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),

                          ],
                        )
                      ],
                    )
                  : const SizedBox()
            : const BestReviewItemShimmer();
      },
    );
  }
}

class BestReviewItemViewFood extends StatefulWidget {
  const BestReviewItemViewFood({super.key});

  @override
  State<BestReviewItemViewFood> createState() => _BestReviewItemViewFoodState();
}

class _BestReviewItemViewFoodState extends State<BestReviewItemViewFood> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        List<Item>? reviewItemList = itemController.reviewedItemList;

        return reviewItemList != null
            ? reviewItemList.isNotEmpty
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: TitleWidget(
                            title: 'best_reviewed_item'.tr,
                            image: Images.sparkle,
                            onTap: () => Get.toNamed(
                              RouteHelper.getItemViewAllScreen(false, false),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 285,
                          width: Get.width,
                          child: ListView.builder(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: Dimensions.paddingSizeDefault,
                            ),
                            itemCount: reviewItemList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeDefault,
                                  right: Dimensions.paddingSizeDefault,
                                  top: Dimensions.paddingSizeDefault,
                                ),
                                child: CustomInkWell(
                                  onTap: () => Get.find<ItemController>()
                                      .navigateToItemPage(
                                        reviewItemList[index],
                                        context,
                                      ),
                                  child: ReviewItemCardFood(
                                    item:
                                        itemController.reviewedItemList![index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox()
            : const BestReviewItemShimmer();
      },
    );
  }
}

class BestReviewItemShimmer extends StatelessWidget {
  const BestReviewItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer(
                child: Container(
                  height: 20,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).shadowColor,
                  ),
                ),
              ),

              Shimmer(
                child: Container(
                  height: 20,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).shadowColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 285,
          width: Get.width,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  top: Dimensions.paddingSizeDefault,
                ),
                child: Shimmer(
                  duration: const Duration(seconds: 2),
                  enabled: true,
                  child: Container(
                    width: 210,
                    height: 285,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      color: Theme.of(context).shadowColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Container(
                                    color: Theme.of(context).shadowColor,
                                    width: 210,
                                    height: 285,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 10,
                                right: 10,
                                child: Icon(
                                  Icons.favorite,
                                  size: 20,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),

                              Positioned(
                                bottom: 5,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeDefault,
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: 100,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                            topRight: Radius.circular(
                                              Dimensions.radiusDefault,
                                            ),
                                          ),
                                          color: Theme.of(
                                            context,
                                          ).cardColor.withValues(alpha: 0.7),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 10,
                                              color: Theme.of(
                                                context,
                                              ).shadowColor,
                                            ),

                                            Container(
                                              width: 100,
                                              height: 10,
                                              color: Theme.of(
                                                context,
                                              ).shadowColor,
                                            ),

                                            Container(
                                              width: 100,
                                              height: 10,
                                              color: Theme.of(
                                                context,
                                              ).shadowColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
