import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/common/widgets/corner_banner/banner.dart';
import 'package:handy_allinone/common/widgets/corner_banner/corner_discount_tag.dart';
import 'package:handy_allinone/common/widgets/title_widget.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/not_available_widget.dart';
import 'package:handy_allinone/common/widgets/organic_tag.dart';
import 'package:handy_allinone/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_asset_image_widget.dart';

class PopularItemView extends StatelessWidget {
  final bool isPopular;
  const PopularItemView({super.key, required this.isPopular});

  @override
  Widget build(BuildContext context) {
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString().toLowerCase() == AppConstants.food.toLowerCase();
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? itemList = isPopular ? itemController.popularItemList : itemController.reviewedItemList;

      return (itemList != null && itemList.isEmpty) ? const SizedBox() : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: TitleWidget(
              title: isPopular ? 'popular_items_nearby'.tr : 'best_reviewed_item'.tr,
              onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(isPopular, false)),
            ),
          ),

          SizedBox(
            height: Get.find<LocalizationController>().isLtr ? 90 : 100,
            child: itemList != null ? ListView.builder(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              itemCount: itemList.length > 10 ? 10 : itemList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, Dimensions.paddingSizeSmall, 2),
                  child: InkWell(
                    onTap: () {
                      Get.find<ItemController>().navigateToItemPage(itemList[index], context);
                    },
                    child: Stack(
                      children: [
                        Container(
                          height: Get.find<LocalizationController>().isLtr ? 90 : 100, width: 250,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                            Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImage(
                                  image: '${itemList[index].imageFullUrl}',
                                  height: 80, width: 80, fit: BoxFit.cover,
                                ),
                              ),

                              OrganicTag(item: itemList[index], placeInImage: true),

                              itemController.isAvailable(itemList[index]) ? const SizedBox() : const NotAvailableWidget(),
                            ]),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Wrap(children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          itemList[index].name!,
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 20)
                                    ]),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    (isFood && Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                                        ? CustomAssetImageWidget(itemList[index].veg == 0 ? Images.nonVegImage : Images.vegImage,
                                        height: 10, width: 10, fit: BoxFit.contain) : const SizedBox(),
                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text(
                                    itemList[index].storeName!,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),

                                  RatingBar(
                                    rating: itemList[index].avgRating, size: 12,
                                    ratingCount: itemList[index].ratingCount,
                                  ),

                                  (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && itemList[index].unitType != null) ? Text(
                                    '(${ itemList[index].unitType ?? ''})',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                  ) : const SizedBox(),

                                  Row(children: [
                                    Expanded(
                                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                        Text(
                                          PriceConverter.convertPrice(
                                            itemController.getStartingPrice(itemList[index]),
                                            discount: itemList[index].discount,
                                            discountType: itemList[index].discountType,
                                          ), textDirection: TextDirection.ltr,
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        ),
                                        SizedBox(width: itemList[index].discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                        itemList[index].discount! > 0  ? Flexible(child: Text(
                                          PriceConverter.convertPrice(itemController.getStartingPrice(itemList[index])),
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                            decoration: TextDecoration.lineThrough, decorationThickness: 2.0, decorationStyle: TextDecorationStyle.solid,
                                          ),
                                          textAlign: TextAlign.center, textDirection: TextDirection.ltr,
                                        )) : const SizedBox(),
                                      ]),
                                    ),
                                    const Icon(Icons.add, size: 20),
                                  ]),
                                ]),
                              ),
                            ),

                          ]),
                        ),

                        Positioned(
                          right: Get.find<LocalizationController>().isLtr ? 0 : null, left: Get.find<LocalizationController>().isLtr ? null : 0,
                          child: CornerDiscountTag(
                            bannerPosition: Get.find<LocalizationController>().isLtr ? CornerBannerPosition.topRight : CornerBannerPosition.topLeft,
                            elevation: 0,
                            discount: itemController.getDiscount(itemList[index]),
                            discountType: itemController.getDiscountType(itemList[index]),
                          ),

                        ),
                      ],
                    ),
                  ),
                );
              },
            ) : PopularItemShimmer(enabled: itemList == null),
          ),
        ],
      );
    });
  }
}

class PopularItemShimmer extends StatelessWidget {
  final bool enabled;
  const PopularItemShimmer({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      itemCount: 10,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, Dimensions.paddingSizeSmall, 2),
          child: Container(
            height: 90, width: 250,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(
                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!,
                blurRadius: 5, spreadRadius: 1,
              )],
            ),
            child: Shimmer(
              duration: const Duration(seconds: 1),
              interval: const Duration(seconds: 1),
              enabled: enabled,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Colors.grey[300],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(height: 15, width: 100, color: Colors.grey[300]),
                      const SizedBox(height: 5),

                      Container(height: 10, width: 130, color: Colors.grey[300]),
                      const SizedBox(height: 5),

                      const RatingBar(rating: 0, size: 12, ratingCount: 0),

                      Row(children: [
                        Expanded(
                          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Container(height: 15, width: 50, color: Colors.grey[300]),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Container(height: 10, width: 50, color: Colors.grey[300]),
                          ]),
                        ),
                        const Icon(Icons.add, size: 20),
                      ]),
                    ]),
                  ),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}

