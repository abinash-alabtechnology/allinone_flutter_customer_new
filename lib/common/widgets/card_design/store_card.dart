import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/common/widgets/add_favourite_view.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
import 'package:handy_allinone/common/widgets/not_available_widget.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/common/models/module_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/new_tag.dart';
import 'package:handy_allinone/common/widgets/rating_bar.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';

import '../../../helper/responsive_helper.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final bool? isTopOffers;
  const StoreCard({super.key, required this.store, this.isTopOffers = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = Get.find<StoreController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;
    bool isAvailable = store.open == 1 && store.active!;

    return Stack(children: [

      Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: ResponsiveHelper.isMobile(context) ? [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 5, spreadRadius: 1)] : null,
        ),
        child: CustomInkWell(
          onTap: () {
            if(Get.find<SplashController>().moduleList != null) {
              for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                if(module.id == store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          },
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          radius: Dimensions.radiusDefault,
          child: TextHover(
            builder: (hovered) {
              return Stack(children: [

                Column(children: [

                  Expanded(
                    flex: 5,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              isHovered: hovered,
                              image: '${store.logoFullUrl}',
                              height: 50, width: 50, fit: BoxFit.cover,
                            ),
                          ),

                          isAvailable ? const SizedBox() : NotAvailableWidget(isStore: true, store: store, fontSize: Dimensions.fontSizeExtraSmall, isAllSideRound: true),
                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          SizedBox(
                            width: 190,
                            child: Text(store.name!.capitalizeFirst ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          !isPharmacy ? store.ratingCount! > 0 ? RatingBar(
                            rating: store.avgRating,
                            ratingCount: store.ratingCount,
                            size: 12,
                          ) : const SizedBox() : Row(children: [

                            Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Expanded(
                              child: Text(store.address ?? '',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          !isPharmacy ? Row(children: [

                            Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Flexible(
                              child: Text(store.address ?? '',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ]) : Text('${store.itemCount}' ' ' 'items'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                        ]),
                      ),
                    ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: isTopOffers! ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Image.asset(Images.distanceLine, height: 15, width: 15, color: Theme.of(context).disabledColor,),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                        ]),

                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                          child: Text(
                            discount > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
                                : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ]),

                    ) : Row(children: [

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        child: Row(children: [

                          Image.asset(Images.distanceLine, height: 15, width: 15),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),
                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        ),
                        child: Row(children: [

                          Image.asset(Images.clockIcon, height: 15, width: 15, color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text(Get.find<StoreController>().isOpenNow(store) ? 'open_now'.tr : 'closed_now'.tr, style: robotoBold.copyWith(color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),
                    ]),
                  ),
                ]),

                AddFavouriteView(
                  top: 0,
                  left: Get.find<LocalizationController>().isLtr ? null : 0,
                  right: Get.find<LocalizationController>().isLtr ? 0 : null,
                  item: null, storeId: store.id,
                ),

              ]);
            }
          ),
        ),
      ),

      !isTopOffers! ? const NewTag() : const SizedBox(),
    ]);
  }
}
class StoreCard1 extends StatelessWidget {
  final Store store;
  final bool? isTopOffers;
  const StoreCard1({super.key, required this.store, this.isTopOffers = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = Get.find<StoreController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;
    bool isAvailable = store.open == 1 && store.active!;

    return Stack(children: [

      Container(
        width: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFDFFFE2), // Pale mint white-green
              Colors.white
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: ResponsiveHelper.isMobile(context) ? [BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), blurRadius: 5, spreadRadius: 1)] : null,
        ),
        child: CustomInkWell(
          onTap: () {
            if(Get.find<SplashController>().moduleList != null) {
              for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                if(module.id == store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          },
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          radius: Dimensions.radiusDefault,
          child: TextHover(
              builder: (hovered) {
                return Stack(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              isHovered: hovered,
                              image: '${store.logoFullUrl}',
                              height: 150, width: 150, fit: BoxFit.cover,
                            ),
                          ),
                          isAvailable? AddFavouriteView1(
                            top: 5,
                            right: 5,
                            item: null, storeId: store.id,
                          ):const SizedBox(),
                          isAvailable ? const SizedBox() : NotAvailableWidget(isStore: true, store: store, fontSize: Dimensions.fontSizeExtraSmall, isAllSideRound: true),
                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      SizedBox(
                        width: 190,
                        child: Text(store.name!.capitalizeFirst ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isPharmacy ? store.ratingCount! > 0 ? RatingBar(
                        rating: store.avgRating,
                        ratingCount: store.ratingCount,
                        size: 12,
                      ) : const SizedBox() : Row(children: [

                        Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: Text(store.address ?? '',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          ),
                          child: Row(children: [

                            Image.asset(Images.clockIcon, height: 15, width: 15, color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Text(Get.find<StoreController>().isOpenNow(store) ? 'open_now'.tr : 'closed_now'.tr, style: robotoBold.copyWith(color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                          ]),
                        ),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isPharmacy ? Row(children: [

                        Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Flexible(
                          child: Text(store.address ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ]) : Text('${store.itemCount}' ' ' 'items'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall,),
                    isTopOffers! ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Image.asset(Images.distanceLine, height: 15, width: 15, color: Theme.of(context).disabledColor,),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                        ]),

                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                          child: Text(
                            discount > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
                                : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ]),

                    ) :
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                        decoration: BoxDecoration(
                          // color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          gradient: const LinearGradient(
                            colors: [
                           Colors.purple,
                              Colors.blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(children: [

                          Image.asset(Images.distanceLine, height: 15, width: 15,color: Theme.of(context).cardColor,),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),

                    ]),
                  ]),



                ]);
              }
          ),
        ),
      ),

      !isTopOffers! ? const NewTag() : const SizedBox(),
    ]);
  }
}
class StoreCardNewOn extends StatelessWidget {
  final Store store;
  final bool? isTopOffers;
  const StoreCardNewOn({super.key, required this.store, this.isTopOffers = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = Get.find<StoreController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;
    bool isAvailable = store.open == 1 && store.active!;

    return Card(
      elevation: 3,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: CustomInkWell(
          onTap: () {
            if(Get.find<SplashController>().moduleList != null) {
              for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                if(module.id == store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          },
          radius: Dimensions.radiusDefault,
          child: TextHover(
              builder: (hovered) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              isHovered: hovered,
                              image: '${store.logoFullUrl}',
                              height: 150,width: (180),
                              fit: BoxFit.cover,
                            ),
                          ),
                          isAvailable? AddFavouriteView1(
                            top: 5,
                            right: 5,
                            item: null, storeId: store.id,
                          ):const SizedBox(),
                          isAvailable ? const SizedBox() : NotAvailableWidget(isStore: true, store: store, fontSize: Dimensions.fontSizeExtraSmall, isAllSideRound: true),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          SizedBox(
                            width: 160,
                            child: Text(store.name!.capitalizeFirst ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          !isPharmacy ? store.ratingCount! > 0 ? RatingBar(
                            rating: store.avgRating,
                            ratingCount: store.ratingCount,
                            size: 16,
                          ) : const SizedBox() : Row(children: [

                            Icon(Icons.storefront, size: 20, color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Expanded(
                              child: Text(store.address ?? '',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                              ),
                              child: Row(children: [

                                Image.asset(Images.clockIcon, height: 15, width: 15, color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Text(Get.find<StoreController>().isOpenNow(store) ? 'open_now'.tr : 'closed_now'.tr, style: robotoBold.copyWith(color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                              ]),
                            ),

                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          !isPharmacy ? Row(children: [

                            Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Flexible(
                              child: Text(store.address ?? '',
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          ]) : Text('${store.itemCount}' ' ' 'items'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                          const SizedBox(height: Dimensions.paddingSizeSmall,),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(colors: [
                                Theme.of(context).primaryColor,
                                Colors.yellow.shade900
                              ])
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                              child: Text(store.deliveryTime ?? "",
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context)
                                          .cardColor)),
                            ),
                          ),

                          // isTopOffers! ? Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 3),
                          //   decoration: BoxDecoration(
                          //     color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          //     borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          //   ),
                          //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          //     Row(children: [
                          //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          //
                          //       Image.asset(Images.distanceLine, height: 15, width: 15, color: Theme.of(context).disabledColor,),
                          //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          //
                          //       Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                          //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          //
                          //       Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                          //     ]),
                          //
                          //     Container(
                          //       decoration: BoxDecoration(
                          //         color: Theme.of(context).primaryColor,
                          //         borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                          //       child: Text(
                          //         discount > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
                          //             : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
                          //         style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                          //         textAlign: TextAlign.center,
                          //       ),
                          //     )
                          //   ]),
                          //
                          // ) :
                          // Row(children: [
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                          //     decoration: BoxDecoration(
                          //       // color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          //       borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          //       gradient: const LinearGradient(
                          //         colors: [
                          //           Colors.purple,
                          //           Colors.blue
                          //         ],
                          //         begin: Alignment.topLeft,
                          //         end: Alignment.bottomRight,
                          //       ),
                          //     ),
                          //     child: Row(children: [
                          //
                          //       Image.asset(Images.distanceLine, height: 15, width: 15,color: Theme.of(context).cardColor,),
                          //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          //
                          //       Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                          //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          //
                          //       Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                          //     ]),
                          //   ),
                          //
                          // ]),
                          const SizedBox(height: Dimensions.paddingSizeSmall,),
                        ]),
                      ),

                    ]);
              }
          ),
        ),
      ),
    );
  }
}
