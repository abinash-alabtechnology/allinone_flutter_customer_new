import 'package:handy_allinone/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_tool_tip_widget.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/organic_tag.dart';
import 'package:handy_allinone/common/widgets/rating_bar.dart';

import '../../../common/widgets/add_favourite_view.dart';

class ItemTitleViewWidget extends StatelessWidget {
  final Item? item;
  final bool inStorePage;
  final bool isCampaign;
  final bool inStock;

  const ItemTitleViewWidget({
    super.key,
    required this.item,
    this.inStorePage = false,
    this.isCampaign = false,
    required this.inStock,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(inStock ? 'out_of_stock'.tr : 'in_stock'.tr);
    }
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isFood = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString().toLowerCase() ==
            AppConstants.food.toLowerCase();
    double? startingPrice;
    double? endingPrice;
    if (item!.variations != null && item!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in item!.variations!) {
        if (variation.price != null) {
          priceList.add(variation.price);
        }
      }
      if (priceList.isNotEmpty) {
        priceList.sort((a, b) => a!.compareTo(b!));
        startingPrice = priceList[0];
        if (priceList.length > 1 && priceList[0]! < priceList[priceList.length - 1]!) {
          endingPrice = priceList[priceList.length - 1];
        }
      } else {
        startingPrice = item!.price;
      }
    } else {
      startingPrice = item!.price;
    }

    double? discount = Get.find<ItemController>().item!.discount;
    String? discountType = Get.find<ItemController>().item!.discountType;

    return ResponsiveHelper.isDesktop(context)
        ? GetBuilder<ItemController>(
            builder: (itemController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        child: Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item?.name?.capitalizeFirst ?? '',
                                  style: robotoBold.copyWith(fontSize: 16.sp),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width:
                                    item!.isStoreHalalActive! &&
                                        item!.isHalalItem!
                                    ? Dimensions.paddingSizeSmall
                                    : 0,
                              ),

                              item!.isStoreHalalActive! && item!.isHalalItem!
                                  ? CustomToolTip(
                                      message: 'this_is_a_halal_food'.tr,
                                      preferredDirection: AxisDirection.up,
                                      child: const CustomAssetImageWidget(
                                        Images.halalTag,
                                        height: 35,
                                        width: 35,
                                      ),
                                    )
                                  : const SizedBox(),

                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),

                              ((Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .unit! &&
                                          item!.unitType != null) ||
                                      (isFood && Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .vegNonVeg! &&
                                          Get.find<SplashController>()
                                              .configModel!
                                              .toggleVegNonVeg!))
                                  ? Text(
                                      Get.find<SplashController>()
                                              .configModel!
                                              .moduleConfig!
                                              .module!
                                              .unit!
                                          ? '(${item!.unitType})'
                                          : item!.veg == 0
                                          ? '(${'non_veg'.tr})'
                                          : '(${'veg'.tr})',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      item!.availableTimeStarts != null
                          ? const SizedBox()
                          : AddFavouriteViewCom(item: item),
                      // Container(
                      //   padding: const EdgeInsets.all(8), alignment: Alignment.center,
                      //   decoration: BoxDecoration(
                      //     color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      //     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      //   ),
                      //   child: GetBuilder<FavouriteController>(
                      //       builder: (favouriteController) {
                      //         return InkWell(
                      //           onTap: () {
                      //             if(AuthHelper.isLoggedIn()){
                      //               if(favouriteController.wishItemIdList.contains(itemController.item!.id)) {
                      //                 favouriteController.removeFromFavouriteList(itemController.item!.id, false);
                      //               }else {
                      //                 favouriteController.addToFavouriteList(itemController.item, null, false);
                      //               }
                      //             }else {
                      //               showCustomSnackBar('you_are_not_logged_in'.tr);
                      //             }
                      //           },
                      //           child: Icon(
                      //             favouriteController.wishItemIdList.contains(itemController.item!.id) ? Icons.favorite : Icons.favorite_border, size: 25,
                      //             color: Theme.of(context).primaryColor,
                      //           ),
                      //         );
                      //       }
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  (itemController.item!.genericName != null &&
                          itemController.item!.genericName!.isNotEmpty)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: List.generate(
                                itemController.item!.genericName!.length,
                                (index) {
                                  return Text(
                                    '${itemController.item!.genericName![index]}${itemController.item!.genericName!.length - 1 == index ? '.' : ', '}',
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color
                                          ?.withValues(alpha: 0.5),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                        )
                      : const SizedBox(),
                  SizedBox(
                    height:
                        (itemController.item!.genericName != null &&
                            itemController.item!.genericName!.isNotEmpty)
                        ? Dimensions.paddingSizeSmall
                        : 0,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                        ),
                        child: Text(
                          inStock ? 'out_of_stock'.tr : 'in_stock'.tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).disabledColor,
                            fontSize: Dimensions.fontSizeOverSmall,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                       OrganicTag(item: item!, fromDetails: true),

                        item!.isSubscription! ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            'subscription available'.tr,
                            style: robotoRegular.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeOverSmall),
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: () {
                      if (inStorePage) {
                        Get.back();
                      } else {
                        Get.offNamed(
                          RouteHelper.getStoreRoute(
                            id: item!.storeId,
                            page: 'item',
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: Text(
                        item?.storeName?.capitalizeFirst ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                  ),

                  if (item!.ratingCount! > 0)
                    RatingBar(
                      rating: item!.avgRating,
                      ratingCount: item!.ratingCount,
                      size: 15,
                    ),
                  SizedBox(
                    height: item!.ratingCount! > 0
                        ? Dimensions.paddingSizeExtraSmall
                        : 0,
                  ),

                  Row(
                    children: [
                      Text(
                        '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                        '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              );
            },
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: GetBuilder<ItemController>(
              builder: (itemController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item?.name?.capitalizeFirst ?? '',
                                style: robotoBold.copyWith(
                                  fontSize: 22.sp,
                                  color: const Color(0xFF1A1A1A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item?.unitType != null)
                                Text(
                                  item!.unitType!,
                                  style: robotoRegular.copyWith(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        GetBuilder<FavouriteController>(
                          builder: (favouriteController) {
                            return AddFavouriteViewItemDetails(item: item);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          context,
                          icon: Images.checklist,
                          text: item!.storeName?.capitalizeFirst ?? "",
                          color: const Color(0xFFFFF7ED),
                          textColor: const Color(0xFFC2410C),
                          iconColor: const Color(0xFFEA580C),
                        ),
                        _buildBadge(
                          context,
                          isIconData: !inStock ? Icons.check : Icons.close,
                          text: !inStock ? 'in_stock'.tr : 'out_of_stock'.tr,
                          color: !inStock ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                          textColor: !inStock ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                        ),
                        if (item!.isSubscription!)
                          _buildBadge(
                            context,
                            text: 'Subscription Available'.tr,
                            color: const Color(0xFFEFF6FF),
                            textColor: const Color(0xFF1D4ED8),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType),
                                    style: robotoBold.copyWith(
                                      color: Colors.black,
                                      fontSize: 26.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),


                  ],
                );
              },
            ),
          );
  }

  Widget _buildBadge(BuildContext context, {String? text, String? icon, IconData? isIconData, Color? color, Color? textColor, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || isIconData != null) ...[
            isIconData != null
                ? Icon(isIconData, size: 14, color: textColor)
                : CustomAssetImageWidget(icon!, width: 16, height: 16, color: iconColor),
            const SizedBox(width: 6),
          ],
          Text(
            text ?? "",
            style: robotoMedium.copyWith(
              fontSize: 12.sp,
              color: textColor ?? Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }


}
