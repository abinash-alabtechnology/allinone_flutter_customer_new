import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/card_design/item_card.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../util/styles.dart';

class FreshItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const FreshItemView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? itemList = itemController.freshItemList;

      return (itemList != null) ? itemList.isNotEmpty ?
      Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top:8.0),
          child: Container(
            decoration: BoxDecoration(
               color: Colors.green.withValues(alpha: 0.05),
               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 15.h,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Fresh and Daily",
                          style: robotoBold.copyWith(
                            fontSize: 18.sp,
                            color: Colors.green.shade800,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          height: 2,
                          width: 180.w,
                          color: Colors.green.shade400,
                        ),
                      ],
                    ),
                  )
                ],
              ),

              SizedBox(
                height: 230.h,
                width: Get.width,
                child: Skeletonizer(
                  enabled: Get.find<ItemController>().isLoading,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                    itemCount: itemList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 12.w, bottom: 10.h),
                        child: SizedBox(
                          width: 140.w,
                          child: MostSellItemCard(
                            isPopularItem: false,
                            isPopularItemCart: true,
                            item: itemList[index],
                            isShop: isShop,
                            isFood: isFood,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(false, false, isFresh: true)),
                  child: Container(
                    height: 40.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.shade400, width: 1),
                      borderRadius: BorderRadius.circular(12.r)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_outlined,
                          color: Colors.green.shade600,
                          size: 18.h,),
                        SizedBox(width: 10.w,),
                        Text(
                          'View More',
                          style: robotoRegular.copyWith(
                            color: Colors.green.shade600,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ) : const SizedBox() : const SizedBox();
    });
  }
}
