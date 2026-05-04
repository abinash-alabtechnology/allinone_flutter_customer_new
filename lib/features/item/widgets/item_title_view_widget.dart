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
                                      (Get.find<SplashController>()
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
                      discount! > 0
                          ? Flexible(
                              child: Text(
                                '${PriceConverter.convertPrice(startingPrice)}'
                                '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                textDirection: TextDirection.ltr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(width: discount > 0 ? 10 : 0),

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
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: GetBuilder<ItemController>(
              builder: (itemController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: .start,
                            crossAxisAlignment: .start,
                            children: [
                              Flexible(
                                child: Text(
                                  item?.name?.capitalizeFirst ?? '',
                                  style: robotoBold.copyWith(fontSize: 16.r),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width:
                                    item!.isStoreHalalActive! &&
                                        item!.isHalalItem!
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0,
                              ),

                              item!.isStoreHalalActive! && item!.isHalalItem!
                                  ? CustomToolTip(
                                      message: 'this_is_a_halal_food'.tr,
                                      preferredDirection: AxisDirection.up,
                                      child: const CustomAssetImageWidget(
                                        Images.halalTag,
                                        height: 30,
                                        width: 30,
                                      ),
                                    )
                                  : const SizedBox(),
                              /*item!.availableTimeStarts != null ? const SizedBox() : */
                            ],
                          ),
                        ),

                        GetBuilder<FavouriteController>(
                          builder: (favouriteController) {
                            return AddFavouriteViewItemDetails(item: item);
                            //   InkWell(
                            //   onTap: () {
                            //     if(isLoggedIn){
                            //       if(favouriteController.wishItemIdList.contains(item!.id)) {
                            //         favouriteController.removeFromFavouriteList(item!.id, false);
                            //       }else {
                            //         favouriteController.addToFavouriteList(item, null, false);
                            //       }
                            //     }else {
                            //       showCustomSnackBar('you_are_not_logged_in'.tr);
                            //     }
                            //   },
                            //   child: Icon(
                            //     favouriteController.wishItemIdList.contains(item!.id) ? Icons.favorite : Icons.favorite_border, size: 30,
                            //     color: favouriteController.wishItemIdList.contains(item!.id) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                            //   ),
                            // );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    (item!.genericName != null && item!.genericName!.isNotEmpty)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: List.generate(
                                  item!.genericName!.length,
                                  (index) {
                                    return Text(
                                      '${item!.genericName![index]}${item!.genericName!.length - 1 == index ? '.' : ', '}',
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
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),
                            ],
                          )
                        : const SizedBox(),
                    SizedBox(height: 10.h),
                    Wrap(
                      alignment: .start,
                      runSpacing: 10.h,
                      children: [
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
                          child: Container(
                            height: 33,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: Color(0xFFFFF2DF),
                            ),
                            child: IntrinsicWidth(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    5,
                                    5,
                                    5,
                                  ),
                                  child: IntrinsicWidth(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 5.w),
                                          CustomAssetImageWidget(
                                            Images.checklist,
                                            width: 18.w,
                                            height: 18.h,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            item!.storeName?.capitalizeFirst ??
                                                "",
                                            style: robotoRegular.copyWith(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          height: 33,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: inStock
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: IntrinsicWidth(
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color: inStock
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Icon(
                                      inStock ? Icons.close : Icons.check,
                                      size: 10,
                                      color: inStock
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  inStock ? 'out_of_stock'.tr : 'in_stock'.tr,
                                  style: robotoRegular.copyWith(
                                    color: inStock ? Colors.red : Colors.green,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),

                        item!.isSubscription! ? Container(
                          height: 33,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: IntrinsicWidth(child: Center(
                            child: Text(
                              'Subscription Available'.tr,
                              style: robotoRegular.copyWith(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500),
                            ),
                          )),
                        ) : const SizedBox(),
                        item!.isSubscription! ? SizedBox(width: 10.w) : const SizedBox(),

                        (Get.find<SplashController>()
                                    .configModel!
                                    .moduleConfig!
                                    .module!
                                    .unit! &&
                                item!.unitType != null)
                            ? Container(
                                height: 35,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: IntrinsicWidth(
                                  child: Center(
                                    child: Text(
                                      item?.unitType ?? "",
                                      style: robotoRegular.copyWith(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MRP:",
                                style: robotoBold.copyWith(
                                  color: Colors.grey.shade500,
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              discount! > 0
                                  ? Row(
                                children: [
                                  Text(
                                    '${PriceConverter.convertPrice(startingPrice)}'
                                        '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                    textDirection: TextDirection.ltr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize:
                                      12.sp,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'MRP (incl. of all taxes)',
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor,
                                      decoration: TextDecoration.none,
                                      // no strike-through
                                      fontSize:
                                      12.sp,
                                    ),
                                  ),
                                ],
                              )
                                  : const SizedBox(),
                              SizedBox(height: discount > 0 ? 5 : 0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                                    '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                                    style: robotoBold.copyWith(
                                      color: Colors.black,
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  const SizedBox(width: 6),
                                  discount! > 0
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade700,
                                            borderRadius: BorderRadius.circular(8.r)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              '${discount.toStringAsFixed(0)}% OFF',
                                              style: robotoBold.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).cardColor,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2E9FF), // same purple shade from screenshot
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomAssetImageWidget(
                                          Images.card,
                                          color: const Color(0xFF4CAF50), // green icon like screenshot
                                          height: 25,
                                          width: 25,
                                          fit: BoxFit.fill,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Secure payments",
                                              style: robotoBold.copyWith(
                                                fontSize: 10.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              "100% protected checkout",
                                              style: robotoRegular.copyWith(
                                                fontSize: 6,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9FFE9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomAssetImageWidget(
                                          Images.approve,
                                          color: const Color(0xFF4CAF50),
                                          height: 25,
                                          width: 25,
                                          fit: BoxFit.fill,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Original products",
                                              style: robotoBold.copyWith(
                                                fontSize: 12.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              "Trusted and verified brands",
                                              style: robotoRegular.copyWith(
                                                fontSize: 6.sp,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),

                        Column(
                          children: [
                            // ((Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item!.unitType != null)
                            // || (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)) ? Container(
                            //   padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            //     color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            //   ),
                            //   child: Text(
                            //     Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! ? item!.unitType ?? ''
                            //         : item!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                            //     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            //   ),
                            // ) : const SizedBox(),
                            // const SizedBox(height: Dimensions.paddingSizeDefault),

                            // OrganicTag(item: item!, fromDetails: true),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
  }
}
