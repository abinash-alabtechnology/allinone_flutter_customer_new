import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/add_favourite_view.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/discount_tag.dart';
import 'package:handy_allinone/common/widgets/hover/on_hover.dart';
import 'package:handy_allinone/common/widgets/organic_tag.dart';

class ReviewItemCard extends StatelessWidget {
  final bool isFeatured;
  final Item? item;
  const ReviewItemCard({super.key, this.isFeatured = false, this.item});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    double? discount = item?.discount;
    String? discountType = item?.discountType;

    return TextHover(
      builder: (hovered) {
        return OnHover(
          isItem: true,
          child: isShop ? Container(
            width: 160.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
            ),
            child: CustomInkWell(
              onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
              radius: Dimensions.radiusDefault,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Expanded(
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                        child: CustomImage(
                          isHovered: hovered,
                          placeholder: Images.placeholder,
                          image: '${item!.imageFullUrl}',
                          fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                        ),
                      ),
                    ),

                   AddFavouriteView(
                          item: item!,
                    ),

                    DiscountTag(
                      isFloating: true,
                      discount: Get.find<ItemController>().getDiscount(item!),
                      discountType: Get.find<ItemController>().getDiscountType(item!),
                    ),
                  ],
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(
                        crossAxisAlignment: isFeatured ? CrossAxisAlignment.start : CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        item!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                      ),

                      Text(item!.storeName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),

                      item!.ratingCount! > 0 ?
                      Row(mainAxisAlignment: isFeatured ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
                        Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(item!.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text("(${item!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      ]) : const SizedBox(),

                      Wrap(crossAxisAlignment: WrapCrossAlignment.center, alignment: WrapAlignment.start, children: [
                        item!.discount != null && item!.discount! > 0  ? CustomLineThroughText(
                          text: PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item!)),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                          ),
                          textAlign: TextAlign.center,
                        ) : const SizedBox(),
                        SizedBox(width: item!.discount != null && item!.discount! > 0  ? Dimensions.paddingSizeExtraSmall : 0),

                        Text(
                          PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item!), discount: item!.discount,
                              discountType: item!.discountType),
                          style: robotoMedium, textDirection: TextDirection.ltr,
                        ),
                      ]),
                      // SizedBox(height: item!.discount != null && item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),


                    ]),
                  ),
                ),
              ]),
            ),
          ) :
          Container(
            width: 210.w, height: 290.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Theme.of(context).cardColor,
              border: Border.all(color: Colors.grey.shade100)
              // boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: .start, children: [

              Expanded(
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                    child: CustomImage(
                      isHovered: hovered,
                      placeholder: Images.placeholder,
                      image: '${item!.imageFullUrl}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                    ),
                  ),
                  Positioned(
                      bottom: 10,left: 0,right:0,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 2.h),
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5.r)
                        ),
                        child: Row(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Icon(Icons.timer,color: Colors.green.shade400,size: 14,)),
                                  )),
                            ),
                            SizedBox(width: 3.w,),
                            Column(
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .start,
                              children: [
                                Text("10- 20 Mins",
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.green.shade400),
                                ),
                                Text(item?.storeName??"",
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.blueGrey.shade500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),


                  Positioned(
                    top:10,right: 10,
                    child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.4), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))]),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: AddFavouriteViewCom(
                        item: item!,
                      ),
                    ),),
                  ),

                  item!.isStoreHalalActive! && item!.isHalalItem! ?  Positioned(
                    top: 35, right: 10,
                    child: CustomAssetImageWidget(
                      Images.halalTag,
                      height: 20, width: 20,
                    ),
                  ) : const SizedBox(),

                  // DiscountTag(
                  //   isFloating: true,
                  //   discount: Get.find<ItemController>().getDiscount(item!),
                  //   discountType: Get.find<ItemController>().getDiscountType(item!),
                  // ),
                  //
                  // OrganicTag(item: item!, placeInImage: false),


                ]),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius:  BorderRadius.only(bottomLeft: Radius.circular(15.r), bottomRight: Radius.circular(15.r)),
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
                ),
                child: isFood ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    item?.storeName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ),

                  Text(item?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold),

                  item!.ratingCount! > 0 ? Row(mainAxisAlignment: isFeatured ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
                    Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(item!.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text("(${item!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  ]) : const SizedBox(),

                  Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    discount != null && discount > 0 ? CustomLineThroughText(
                      text: PriceConverter.convertPrice(
                        Get.find<ItemController>().getStartingPrice(item!),
                      ),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ) : const SizedBox(),
                    SizedBox(width: item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                    Text(
                      PriceConverter.convertPrice(
                        Get.find<ItemController>().getStartingPrice(item!),
                        discount: discount,
                        discountType: discountType,
                      ),
                      style: robotoMedium, textDirection: TextDirection.ltr,
                    ),
                  ]),
                ],
                ) :
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      item!.ratingCount! > 0 ? Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r),
                              color: Colors.orangeAccent.withValues(alpha: 0.1),
                              border:Border.all(color: Colors.orange.shade100)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(FontAwesome.star_solid, size: 10, color: Colors.orange.shade300),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(item!.avgRating!.toStringAsFixed(1), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall,)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text("(${item!.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                        ]),
                      )) : const SizedBox(),


                    ],
                  ),
                  SizedBox(height: 10.h,),

                  Text(
                      item!.name!,
                      style: robotoMedium.copyWith(fontSize: 13.sp), maxLines: 2, overflow: TextOverflow.ellipsis),

                  SizedBox(height: 10.h,),



                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // SizedBox(height: item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                    Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .center,
                      children: [
                        Column(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .start,
                          children: [
                            discount != null && discount > 0 ? CustomLineThroughText(
                              text: PriceConverter.convertPrice(
                                Get.find<ItemController>().getStartingPrice(item!),
                              ),
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                              ),
                              textAlign: TextAlign.center,
                            ) : const SizedBox(),
                            Text(
                              PriceConverter.convertPrice(
                                Get.find<ItemController>().getStartingPrice(item!),
                                discount: discount,
                                discountType: discountType,
                              ),
                              style: robotoMedium, textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                        CartCountViewGreen(
                          item: item!,
                        ),
                      ],
                    ),
                  ]),
                ],
                ),
              ),

            ]),
          ),
        );
      }
    );
  }
}
class ReviewItemCardFood extends StatelessWidget {
  final bool isFeatured;
  final Item? item;

  const ReviewItemCardFood({super.key, this.isFeatured = false, this.item});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;
    bool isFood = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.food;

    return OnHover(
      isItem: true,
      child: isShop
          ? Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1))
          ],
        ),
        child: InkWell(
          hoverColor: Colors.transparent,
          onTap: () => Get.find<ItemController>()
              .navigateToItemPage(item, context),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeSmall,
                            left: Dimensions.paddingSizeSmall,
                            right: Dimensions.paddingSizeSmall),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(Dimensions.radiusDefault)),
                          child: CustomImage(
                            placeholder: Images.placeholder,
                            image: '${item!.imageFullUrl}',

                            // image:
                            // '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                            //     '/${item!.image}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      AddFavouriteView(
                        item: item!,
                      ),
                      DiscountTag(
                        isFloating: true,
                        discount:
                        Get.find<ItemController>().getDiscount(item!),
                        discountType: Get.find<ItemController>()
                            .getDiscountType(item!),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(
                      crossAxisAlignment: isFeatured
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item!.storeName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeSmall),
                        ),

                        Text(item!.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),

                        Row(
                            mainAxisAlignment: isFeatured
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star,
                                  size: 14,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(
                                  width:
                                  Dimensions.paddingSizeExtraSmall),
                              Text(item!.avgRating!.toStringAsFixed(1),
                                  style: robotoRegular.copyWith(
                                      fontSize:
                                      Dimensions.fontSizeSmall)),
                              const SizedBox(
                                  width:
                                  Dimensions.paddingSizeExtraSmall),
                              Text("(${item!.ratingCount})",
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context)
                                          .disabledColor)),
                            ]),

                        item!.discount != null && item!.discount! > 0
                            ? CustomLineThroughText(
                          text: PriceConverter.convertPrice(
                              Get.find<ItemController>()
                                  .getStartingPrice(item!)),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                          textAlign: TextAlign.center,
                        )
                            : const SizedBox(),
                        // SizedBox(height: item!.discount != null && item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                        Text(
                          PriceConverter.convertPrice(
                              Get.find<ItemController>()
                                  .getStartingPrice(item!),
                              discount: item!.discount,
                              discountType: item!.discountType),
                          style: robotoMedium,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ),
      )
          : Container(
        width: 210,
        height: 285,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Dimensions.radiusDefault)),
                    child: CustomImage(
                      placeholder: Images.placeholder,
                      image: '${item!.imageFullUrl}',

                      // image:
                      // '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                      //     '/${item!.image}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // DiscountTag1(
                  //   isFloating: true,
                  //   discount:
                  //   Get.find<ItemController>().getDiscount(item!),
                  //   discountType:
                  //   Get.find<ItemController>().getDiscountType(item!),
                  // ),
                  OrganicTag(item: item!, placeInImage: false),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radiusLarge),
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: isFood
                              ? Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                  height: Dimensions
                                      .paddingSizeExtraSmall),
                              StarRatingIndicator(
                                rating: item!.avgRating!,
                                ratingCount: item!.ratingCount!,
                              ),
                              Container(
                                height: 2, // Height of the divider
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                item!.name!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: robotoBlack.copyWith(
                                    color:
                                    Theme.of(context).cardColor,
                                    fontSize: Dimensions
                                        .fontSizeDefault),
                              ),
                              // const SizedBox(
                              //   height: 3,
                              // ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item!.storeName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(
                                          color:
                                          Theme.of(context).cardColor,
                                          fontSize:
                                          Dimensions.fontSizeSmall),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        item!.discount! > 0
                                            ? CustomLineThroughText(
                                          text: PriceConverter
                                              .convertPrice(
                                            Get.find<
                                                ItemController>()
                                                .getStartingPrice(
                                                item!),
                                          ),
                                          style: robotoRegular
                                              .copyWith(
                                            fontSize: Dimensions
                                                .fontSizeExtraSmall,
                                            color: Theme.of(
                                                context)
                                                .disabledColor,
                                          ),
                                        )
                                            : const SizedBox(),
                                        SizedBox(
                                            width: item!.discount! > 0
                                                ? Dimensions
                                                .paddingSizeExtraSmall
                                                : 0),
                                        Text(
                                          PriceConverter.convertPrice(
                                            Get.find<ItemController>()
                                                .getStartingPrice(
                                                item!),
                                            discount: item!.discount,
                                            discountType:
                                            item!.discountType,
                                          ),
                                          style: robotoBold.copyWith(
                                            color: Theme.of(context)
                                                .cardColor,
                                            fontSize: Dimensions
                                                .fontSizeDefault,
                                          ),
                                          textDirection:
                                          TextDirection.ltr,
                                        ),
                                      ]),
                                ],
                              ),


                              // Row(
                              //     mainAxisAlignment: isFeatured
                              //         ? MainAxisAlignment.start
                              //         : MainAxisAlignment.start,
                              //     children: [
                              //       Icon(Icons.star,
                              //           size: 20,
                              //           color: Theme.of(context)
                              //               .primaryColor),
                              //       const SizedBox(
                              //           width: Dimensions
                              //               .paddingSizeExtraSmall),
                              //       Text(
                              //         item!.avgRating!
                              //             .toStringAsFixed(1),
                              //         style: robotoBold.copyWith(
                              //             color: Theme.of(context)
                              //                 .cardColor,
                              //             fontSize: Dimensions
                              //                 .fontSizeDefault),
                              //       ),
                              //       const SizedBox(
                              //           width: Dimensions
                              //               .paddingSizeExtraSmall),
                              //       Text(
                              //         "(${item!.ratingCount})",
                              //         style: robotoBold.copyWith(
                              //             color: Theme.of(context)
                              //                 .cardColor,
                              //             fontSize: Dimensions
                              //                 .fontSizeDefault),
                              //       ),
                              //     ]),

                            ],
                          )
                              : Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                  height: Dimensions
                                      .paddingSizeExtraSmall),
                              Text(
                                item!.storeName!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: robotoBold.copyWith(
                                    color:
                                    Theme.of(context).cardColor,
                                    fontSize: Dimensions
                                        .fontSizeOverLarge),
                              ),
                              Container(
                                height: 2, // Height of the divider
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                item!.name!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(
                                    color:
                                    Theme.of(context).cardColor,
                                    fontSize:
                                    Dimensions.fontSizeDefault),
                              ),
                              Row(
                                  mainAxisAlignment: isFeatured
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.star,
                                        size: 20,
                                        color: Theme.of(context)
                                            .primaryColor),
                                    const SizedBox(
                                        width: Dimensions
                                            .paddingSizeExtraSmall),
                                    Text(
                                      item!.avgRating!
                                          .toStringAsFixed(1),
                                      style: robotoBold.copyWith(
                                          color: Theme.of(context)
                                              .cardColor,
                                          fontSize: Dimensions
                                              .fontSizeDefault),
                                    ),
                                    const SizedBox(
                                        width: Dimensions
                                            .paddingSizeExtraSmall),
                                    Text(
                                      "(${item!.ratingCount})",
                                      style: robotoBold.copyWith(
                                          color: Theme.of(context)
                                              .cardColor,
                                          fontSize: Dimensions
                                              .fontSizeDefault),
                                    ),
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    item!.discount! > 0
                                        ? CustomLineThroughText(
                                      text: PriceConverter
                                          .convertPrice(
                                        Get.find<
                                            ItemController>()
                                            .getStartingPrice(
                                            item!),
                                      ),
                                      style: robotoRegular
                                          .copyWith(
                                        fontSize: Dimensions
                                            .fontSizeExtraSmall,
                                        color: Theme.of(
                                            context)
                                            .disabledColor,
                                      ),
                                    )
                                        : const SizedBox(),
                                    SizedBox(
                                        width: item!.discount! > 0
                                            ? Dimensions
                                            .paddingSizeExtraSmall
                                            : 0),
                                    Text(
                                      PriceConverter.convertPrice(
                                        Get.find<ItemController>()
                                            .getStartingPrice(
                                            item!),
                                        discount: item!.discount,
                                        discountType:
                                        item!.discountType,
                                      ),
                                      style: robotoBold.copyWith(
                                        color: Theme.of(context)
                                            .cardColor,
                                        fontSize: Dimensions
                                            .fontSizeDefault,
                                      ),
                                      textDirection:
                                      TextDirection.ltr,
                                    ),
                                  ]),
                            ],
                          )/*
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text(item!.name!,
                                              style: robotoBold,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.star,
                                                  size: 20,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text(
                                                  item!.avgRating!
                                                      .toStringAsFixed(1),
                                                  style: robotoRegular),
                                              const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall),
                                              Text("(${item!.ratingCount})",
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                          .disabledColor)),
                                            ],
                                          ),
                                          (Get.find<SplashController>()
                                                      .configModel!
                                                      .moduleConfig!
                                                      .module!
                                                      .unit! &&
                                                  item!.unitType != null)
                                              ? Text(
                                                  '(${item!.unitType ?? ''})',
                                                  style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Theme.of(context)
                                                          .disabledColor),
                                                )
                                              : const SizedBox(),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                item!.discount! > 0
                                                    ? Text(
                                                        PriceConverter
                                                            .convertPrice(
                                                          Get.find<
                                                                  ItemController>()
                                                              .getStartingPrice(
                                                                  item!),
                                                        ),
                                                        style: robotoRegular
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeExtraSmall,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                // SizedBox(height: item!.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                                                Text(
                                                  PriceConverter.convertPrice(
                                                    Get.find<ItemController>()
                                                        .getStartingPrice(
                                                            item!),
                                                    discount: item!.discount,
                                                    discountType:
                                                        item!.discountType,
                                                  ),
                                                  style: robotoMedium,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                ),
                                              ]),
                                        ],
                                      )*/,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ]),
      ),
    );
  }
}
class StarRatingIndicator extends StatelessWidget {
  final double rating; // example: 3.7
  final int ratingCount; // example: 120

  const StarRatingIndicator({
    super.key,
    required this.rating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor(); // full filled stars
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int totalStars = 5;

    return Row(
      children: [
        // --- Star Fill Section ---
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalStars, (index) {
            return AnimatedOpacity(
              opacity: index < fullStars ? 1 : 0.4,
              duration: Duration(milliseconds: 200 * (index + 1)),
              child: Icon(
                index < fullStars
                    ? Icons.star
                    : (index == fullStars && hasHalfStar)
                    ? Icons.star_half
                    : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            );
          }),),
        const SizedBox(width: 6),

        // --- Rating Text ---
        Text(
          rating.toStringAsFixed(1),
          style: robotoBold.copyWith(
              color:
              Theme.of(context).cardColor,
              fontSize: Dimensions
                  .fontSizeDefault),
        ),
        const SizedBox(width: 4),

        // --- Rating Count ---
        Text(
          "($ratingCount)",
          overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: robotoBold.copyWith(
                color:
                Theme.of(context).cardColor,
                fontSize: Dimensions
                    .fontSizeDefault),
        ),
      ],
    );
  }
}