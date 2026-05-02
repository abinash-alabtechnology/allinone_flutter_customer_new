import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:handy_allinone/common/widgets/add_favourite_view.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/common/widgets/hover/text_hover.dart';
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
import 'package:handy_allinone/common/widgets/not_available_widget.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';

import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/coupon/controllers/coupon_controller.dart';
import '../../../features/favourite/controllers/favourite_controller.dart';
import '../../../features/location/controllers/location_controller.dart';
import '../../../helper/price_converter.dart';
import '../../../helper/responsive_helper.dart';
import '../custom_snackbar.dart';
class StoreCardWithDistance extends StatelessWidget {
  final Store store;
  final bool fromAllStore;
  final bool? isNewStore;
  final bool? fromTopOffers;
  final bool recommendedStore;
  const StoreCardWithDistance({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = (store.distance!/1000);
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left:8.0),
          child: SizedBox(
            width: fromAllStore ? double.infinity : 130,
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
                      children: [
                        // Store Image Section
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(Dimensions.radiusDefault),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CustomImage(
                                isHovered: hovered,
                                image: '${store.coverPhotoFullUrl}',
                                fit: BoxFit.cover,
                                height: recommendedStore ? 160 : 150,
                                width: double.infinity,
                              ),

                              // Linear gradient overlay
                              Container(
                                height: recommendedStore ? 160 : 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent, // 1st part (top)
                                      Colors.transparent, // 2nd part
                                      Colors.black.withOpacity(0.6), // 3rd part (fade-in)
                                      Colors.black, // 4th part (bottom solid)
                                    ],
                                    stops: const [0.0, 0.6, 0.85, 1.0], // adjust ratio of each part
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimensions.radiusDefault),
                                  ),
                                ),
                              ),

                              // if (!fromTopOffers!)
                              DiscountTag1(
                                discount: Get.find<StoreController>().getDiscount(store),
                                discountType: Get.find<StoreController>().getDiscountType(store),
                                freeDelivery: store.freeDelivery,
                                fontSize: Dimensions.fontSizeExtraLarge,
                                fromTop: 0, minimum: store.discount?.minPurchase,
                              ),

                              if (!Get.find<StoreController>().isOpenNow(store))
                                const NotAvailableWidget(isStore: true),

                              AddFavouriteView1(
                                top: 10,
                                left: Get.find<LocalizationController>().isLtr ? null : 10,
                                right: Get.find<LocalizationController>().isLtr ? 10 : null,
                                item: null,
                                storeId: store.id,
                              ),

                              if (isNewStore!) const NewTag(),
                            ],
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeExtraSmall *0.5),

                        // Store Info Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // Image.asset(Images.distanceLine, height: 15, width: 15),
                                  // const SizedBox(width: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          // const Icon(
                                          //   Icons.stars,
                                          //   color: Color.fromRGBO(0, 100, 0, 1),
                                          //   size: 19,
                                          // ),                                          // const SizedBox(width: 4),
                                          // const SizedBox(
                                          //   width: 2,
                                          // ),
                                          // Text(
                                          //   '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                          //   style: robotoBold.copyWith(
                                          //     color: Theme.of(context).primaryColor,
                                          //     fontSize: Dimensions.fontSizeExtraSmall,
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 4),
                                          // Text(
                                          //   'from_you'.tr,
                                          //   style: robotoRegular.copyWith(
                                          //     color: Theme.of(context).primaryColor,
                                          //     fontSize: Dimensions.fontSizeExtraSmall,
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 6),
                                          // Text(
                                          //   '${store.avgRating}',
                                          //   style: robotoRegular.copyWith(
                                          //     // color: Colors.black54,
                                          //     fontSize: Dimensions.fontSizeDefault,
                                          //   ),
                                          // ),
                                          // const SizedBox(width:2),
                                          // Text(
                                          //   '•', // the dot separator
                                          //   style: robotoBold.copyWith(
                                          //     fontSize: Dimensions.fontSizeDefault,
                                          //     color: Colors.grey, // optional, looks subtle
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 2),
                                          // // Add travel time calculation
                                          AnimatedTextKit(
                                              repeatForever: true,
                                              pause: const Duration(seconds: 2),
                                              animatedTexts: [
                                                ColorizeAnimatedText(
                                                  '${store.deliveryTime} \n of fast delivery!',
                                                  textStyle: robotoBold.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                  ),
                                                  colors: [
                                                    Colors.blue.shade700,       // deep blue
                                                    Colors.purpleAccent.shade200, // bright purple
                                                    Colors.orange.shade600,     // vivid orange
                                                    Colors.pinkAccent.shade200, // bright pink
                                                    Colors.greenAccent.shade400, // lively green
                                                  ],
                                                  // colors: [
                                                  //   Colors.green.shade700,
                                                  //   Colors.orangeAccent,
                                                  //   Colors.redAccent,
                                                  //   Colors.yellow.shade700,
                                                  // ],
                                                  speed: const Duration(milliseconds: 250),
                                                ),])
                                          // Text(
                                          //   '${store.deliveryTime}',
                                          //   style: robotoRegular.copyWith(
                                          //     // color: Colors.black54,
                                          //     fontSize: Dimensions.fontSizeDefault,
                                          //   ),
                                          // ),
                                          // Builder(
                                          //   builder: (_) {
                                          //     double avgSpeed = 40; // km/h
                                          //     double timeInMinutes = (distance / avgSpeed) * 60;
                                          //
                                          //     // Create a range: ±20% variation
                                          //     double minTime = (timeInMinutes * 0.8).clamp(1, double.infinity);
                                          //     double maxTime = (timeInMinutes * 1.2).clamp(minTime + 1, double.infinity);
                                          //
                                          //     return Text(
                                          //       '${minTime.toStringAsFixed(0)}–${maxTime.toStringAsFixed(0)} mins',
                                          //       style: robotoBold.copyWith(
                                          //         color: Colors.black54,
                                          //         fontSize: Dimensions.fontSizeSmall,
                                          //       ),
                                          //     );
                                          //   },
                                          // ),
                                        ],
                                      ),
                                    ],
                                  )

                                  // Text(
                                  //   '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                  //   style: robotoBold.copyWith(
                                  //       color: Theme.of(context).primaryColor,
                                  //       fontSize: Dimensions.fontSizeExtraSmall),
                                  // ),
                                  // const SizedBox(width: 4),
                                  // Text(
                                  //   'from_you'.tr,
                                  //   style: robotoRegular.copyWith(
                                  //       color: Theme.of(context).primaryColor,
                                  //       fontSize: Dimensions.fontSizeExtraSmall),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                            Text(
                              store.name!.capitalizeFirst ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),


                            // if (!fromTopOffers!)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: isPharmacy
                                      ? Colors.blue
                                      : Theme.of(context).primaryColor,
                                  size: 15,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Expanded(
                                  child: Text(
                                    store.address ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoMedium.copyWith(

                                      color: Colors.black,
                                      // color: Theme.of(context).disabledColor,
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),


                          ],
                        ),
                      ],
                    );

                  }
              ),
            ),
          ),
        ),
        if (fromTopOffers! && (store.freeDelivery! || store.freetag != null || discount != null))
          Positioned(
            left: 0,
            top: 10,
            child: Builder(
              builder: (context) {
                // Prepare all parts
                List<String> tagParts = [];

                if (discount > 0) {
                  String discountText =
                      '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}';
                  tagParts.add(discountText);
                }

                if (store.freeDelivery!) {
                  tagParts.add('free_delivery'.tr);
                }

                if (!(discount > 0 || store.freeDelivery!) && store.freetag != null  ) {
                  tagParts.add(store.freetag!);
                }

                // If nothing to show, return empty container
                if (tagParts.isEmpty) return const SizedBox();

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall*0.8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(Dimensions.radiusDefault),
                      bottomRight: Radius.circular(Dimensions.radiusDefault),
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      bottomLeft: Radius.circular(Dimensions.radiusDefault),
                    ),
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.pink],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: tagParts.map((text) {
                      int index = tagParts.indexOf(text);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          index == 0 ? text : '+ $text', // add + from second line
                          style: robotoMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeSmall*0.9,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          )

        // fromTopOffers! ?Positioned(
        //   top: fromTopOffers! ? 40 : 60, left: 15,
        //   child: Stack(
        //     clipBehavior: Clip.none,
        //     children: [
        //       // Container(
        //       //   height: 65, width: 65,
        //       //   padding: const EdgeInsets.all(2),
        //       //   decoration: BoxDecoration(
        //       //     color: Theme.of(context).cardColor,
        //       //     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        //       //   ),
        //       //   child: ClipRRect(
        //       //     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        //       //     child: CustomImage(
        //       //       image: '${store.logoFullUrl}',
        //       //       fit: BoxFit.cover, height: double.infinity, width: double.infinity,
        //       //     ),
        //       //   ),
        //       // ),
        //
        //       store.avgRating! > 0 ? Positioned(
        //         bottom: -5, right: 5, left: 5,
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: Theme.of(context).cardColor,
        //             borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        //             boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        //           ),
        //           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //             Text(store.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        //             const SizedBox(width: 3),
        //
        //             Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
        //           ]),
        //         ),
        //       ) : const SizedBox(),
        //     ],
        //   ),
        // ):SizedBox.shrink(),
      ],

    );
  }
}
//   final bool fromAllStore;
//   final bool? isNewStore;
//   final bool? fromTopOffers;
//   final bool recommendedStore;
//   const StoreCardWithDistance({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});
//
//   @override
//   Widget build(BuildContext context) {
//     bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
//     double distance = (store.distance!/1000);
//     double discount = store.discount?.discount ?? 0;
//     String discountType = store.discount?.discountType ?? '';
//     bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
//     String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;
//
//     return Stack(
//       children: [
//         CustomCard(
//           width: fromAllStore ? double.infinity : 260,
//           child: CustomInkWell(
//             onTap: () {
//               if(Get.find<SplashController>().moduleList != null) {
//                 for(ModuleModel module in Get.find<SplashController>().moduleList!) {
//                   if(module.id == store.moduleId) {
//                     Get.find<SplashController>().setModule(module);
//                     break;
//                   }
//                 }
//               }
//               Get.toNamed(
//                 RouteHelper.getStoreRoute(id: store.id, page: 'store'),
//                 arguments: StoreScreen(store: store, fromModule: false),
//               );
//             },
//             radius: Dimensions.radiusDefault,
//             child: TextHover(
//               builder: (hovered) {
//                 return Column(children: [
//                   Expanded(
//                     flex: recommendedStore ? 3 : 1,
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
//                       child: Stack(clipBehavior: Clip.none, children: [
//                         CustomImage(
//                           isHovered: hovered,
//                           image: '${store.coverPhotoFullUrl}',
//                           fit: BoxFit.cover, height: double.infinity, width: double.infinity,
//                         ),
//
//                        !fromTopOffers! ? DiscountTag(
//                           discount: Get.find<StoreController>().getDiscount(store),
//                           discountType: Get.find<StoreController>().getDiscountType(store),
//                           freeDelivery: store.freeDelivery,
//                         ) : const SizedBox(),
//
//                         Get.find<StoreController>().isOpenNow(store) ? const SizedBox() : const NotAvailableWidget(isStore: true),
//
//                         fromTopOffers! ? Positioned(
//                           right: 0, bottom: 0,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
//                             decoration: BoxDecoration(
//                               borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault)),
//                               color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
//                             ),
//                             child: Text(
//                               discount > 0 ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
//                                   : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
//                               style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ) : const SizedBox(),
//
//                         AddFavouriteView(
//                           top: 10,
//                           left: Get.find<LocalizationController>().isLtr ? null : 10,
//                           right: Get.find<LocalizationController>().isLtr ? 10 : null,
//                           item: null, storeId: store.id,
//                         ),
//
//                         isNewStore! ? const NewTag() : const SizedBox(),
//                       ]),
//                     ),
//                   ),
//
//                   recommendedStore ? Expanded(
//                     flex: 2,
//                     child: Column(children: [
//                       Expanded(
//                         flex: 3,
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 95),
//                           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                             Flexible(child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium)),
//                             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                             //if(store.ratingCount! > 0)
//                             Padding(
//                               padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
//                               child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//
//                                 Icon(Icons.star, color: Theme.of(context).primaryColor, size: 14),
//                                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                 Text('${store.avgRating}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
//                                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                 Text('(${store.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
//                               ]),
//                             ),
//                           ]),
//                         ),
//                       ),
//
//                     ]),
//                   ) : Expanded(
//                     flex: 1,
//                     child: Column(children: [
//                       Expanded(
//                         flex: 3,
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 95),
//                           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                             Flexible(child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium)),
//                             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//
//                            !fromTopOffers! ? Row(children: [
//                               Icon(Icons.location_on_outlined, color: isPharmacy ? Colors.blue : Theme.of(context).primaryColor, size: 15),
//                               const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                               Expanded(child: Text(
//                                 store.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
//                                 style: robotoRegular.copyWith(
//                                   color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall,
//                                 ),
//                               )),
//                             ]) : const SizedBox(),
//                           ]),
//                         ),
//                       ),
//
//                      fromTopOffers! ? Expanded(
//                        flex: 4,
//                        child: Padding(
//                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
//                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                            Flexible(
//                              child: Text(
//                                store.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
//                                style: robotoRegular.copyWith(
//                                  color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall,
//                                ),
//                              ),
//                            ),
//
//                            Row(children: [
//                              if(store.ratingCount! > 0)
//                              Padding(
//                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
//                                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//
//                                  Icon(Icons.star, color: Theme.of(context).primaryColor, size: 14),
//                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                  Text('${store.avgRating}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
//                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                  Text('(${store.ratingCount})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
//                                ]),
//                              ),
//
//                              Text('${store.itemCount} ${'items'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
//
//                            ]),
//
//                          ]),
//                        ),
//                      ) : Expanded(
//                         flex: 3,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
//                           child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(vertical: 3, horizontal: Dimensions.paddingSizeSmall),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
//                                 borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
//                               ),
//                               child: Row(children: [
//
//                                 Image.asset(Images.distanceLine, height: 15, width: 15),
//                                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                 Text(
//                                   '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
//                                   style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
//                                 ),
//                                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                 Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)),
//                               ]),
//                             ),
//
//                             CustomButton(
//                               height: 30, width: fromAllStore? 70 : 65,
//                               radius: Dimensions.radiusSmall,
//                               onPressed: () {
//                                 if(Get.find<SplashController>().moduleList != null) {
//                                   for(ModuleModel module in Get.find<SplashController>().moduleList!) {
//                                     if(module.id == store.moduleId) {
//                                       Get.find<SplashController>().setModule(module);
//                                       break;
//                                     }
//                                   }
//                                 }
//                                 Get.toNamed(
//                                   RouteHelper.getStoreRoute(id: store.id, page: 'store'),
//                                   arguments: StoreScreen(store: store, fromModule: false),
//                                 );
//                               },
//                               buttonText: 'visit'.tr,
//                               color: Theme.of(context).primaryColor,
//                               textColor: Theme.of(context).cardColor,
//                               fontSize: Dimensions.fontSizeSmall,
//                             ),
//                           ]),
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ]);
//               }
//             ),
//           ),
//         ),
//
//         Positioned(
//           top: fromTopOffers! ? 40 : 60, left: 15,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Container(
//                 height: 65, width: 65,
//                 padding: const EdgeInsets.all(2),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                   child: CustomImage(
//                     image: '${store.logoFullUrl}',
//                     fit: BoxFit.cover, height: double.infinity, width: double.infinity,
//                   ),
//                 ),
//               ),
//
//               store.avgRating! > 0 ? Positioned(
//                 bottom: -5, right: 5, left: 5,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                     boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//                   ),
//                   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Text(store.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                     const SizedBox(width: 3),
//
//                     Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
//                   ]),
//                 ),
//               ) : const SizedBox(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


class StoreCardWithDistance1 extends StatelessWidget {
  final Store store;
  final bool fromAllStore;
  final bool? isNewStore;
  final bool? fromTopOffers;
  final bool recommendedStore;
  const StoreCardWithDistance1({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = (store.distance!/1000);
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? '';
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return Stack(children: [
      Container(
        width: 280,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
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
               // radius: Dimensions.radiusLarge,
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 5,
              child: Stack(children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: Dimensions.paddingSizeExtraSmall
                         ,
                      left: Dimensions.paddingSizeExtraSmall,
                      right: Dimensions.paddingSizeExtraSmall
                          ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        // borderRadius: const BorderRadius.only(
                        //   topLeft: Radius.circular(Dimensions.radiusLarge),
                        //   topRight: Radius.circular(Dimensions.radiusLarge),
                        //   bottomLeft: Radius.circular(Dimensions.radiusLarge),
                        //   bottomRight:
                        //       Radius.circular(Dimensions.radiusLarge),
                        // ),
                        child: CustomImage(
                          placeholder: Images.placeholder,
                          image: '${store.logoFullUrl}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.only(
                            //   bottomLeft:
                            //       Radius.circular(Dimensions.radiusLarge),
                            //   bottomRight:
                            //       Radius.circular(Dimensions.radiusLarge),
                            // ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 5,
                        right: 5, // Ensuring spacing on both sides
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Pushes columns to opposite sides
                          children: [
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment
                            //       .start, // Aligns text to the left
                            //   children: [
                            //     Text(
                            //       discount! > 0
                            //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 18
                            //                 : 18),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //     Text(
                            //       discount > 0
                            //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount
                            //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 15
                            //                 : 15),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //   ],
                            // ),
                            Column(
                              children: [
                               Column(children: [
                                 Text(
                                   store.name?.capitalizeFirst ?? '',
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                   style:  robotoBold.copyWith(
                                     color:
                                     Theme.of(context).cardColor,
                                     fontSize:
                                     (ResponsiveHelper.isMobile(
                                         context)
                                         ? 15
                                         : 15),
                                   ),),
                                  // Text(
                                  //   PriceConverter.convertPrice(
                                  //     item!
                                  //         .foodVariations!
                                  //         .first
                                  //         .variationValues!
                                  //         .first
                                  //         .optionPrice,
                                  //     discount: discount,
                                  //     discountType: discountType,
                                  //   ),
                                  //   style: robotoBold.copyWith(
                                  //     color:
                                  //     Theme.of(context).cardColor,
                                  //     fontSize:
                                  //     (ResponsiveHelper.isMobile(
                                  //         context)
                                  //         ? 15
                                  //         : 15),
                                  //   ),
                                  //   textAlign: TextAlign.start,
                                  // ),
                                  SizedBox(
                                      width: discount > 0
                                          ? Dimensions
                                          .paddingSizeExtraSmall
                                          : 0),
                                 Text(
                                   store.address?.capitalizeFirst  ?? '',
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                   style:  robotoRegular.copyWith(
                                     color:
                                     Theme.of(context).cardColor,
                                     fontSize:
                                     (ResponsiveHelper.isMobile(
                                         context)
                                         ? 10
                                         : 15),
                                   ),),
                                ])

                              ],
                            ),

                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment
                            //       .start, // Aligns text to the left
                            //   children: [
                            //     Text(
                            //       discount! > 0
                            //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 18
                            //                 : 18),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //     Text(
                            //       discount > 0
                            //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount
                            //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 15
                            //                 : 15),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //   ],
                            // ),
                            Column(
                                crossAxisAlignment
                                    : CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10) ,
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Theme.of(context).primaryColor.withOpacity(1.0), // darkest
                                          Theme.of(context).primaryColor.withOpacity(0.6), // lighter
                                          Theme.of(context).primaryColor.withOpacity(0.0), // transparent
                                        ],
                                      ),

                                    ),
                                    child: Row(

                                        children: [
                                          Icon(Icons.star,
                                              size: 14,
                                              color:Theme.of(context).cardColor),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text(
                                              store.avgRating!
                                                  .toStringAsFixed(1),
                                              style: robotoMedium.copyWith(
                                                  color: Theme.of(context).cardColor,
                                                  fontSize: Dimensions
                                                      .fontSizeSmall)),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text("(${store.ratingCount})",
                                              style: robotoMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeSmall,
                                                  color: Theme.of(context).cardColor)),
                                        ]),
                                  ),
                                  Text(store.deliveryTime ?? "",
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context)
                                              .cardColor)) // (isFood || isShop) ? Flexible(
                                  //   child: Text(
                                  //     item.name ?? '',
                                  //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                                  //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  // ]),
                                  //
                                  // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                                  //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  //
                                  // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
                                  //   '(${ item.unitType ?? ''})',
                                  //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                  // ) : const SizedBox(),

                                  // discount != null && discount > 0  ? Text(
                                  //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                                  //   style: robotoMedium.copyWith(
                                  //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                  //     decoration: TextDecoration.lineThrough,
                                  //   ), textDirection: TextDirection.ltr,
                                  // ) : const SizedBox(),
                                  // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                                  //   Text(
                                  //     PriceConverter.convertPrice(
                                  //       Get.find<ItemController>().getStartingPrice(item), discount: discount,
                                  //       discountType: discountType,
                                  //     ),
                                  //     textDirection: TextDirection.ltr, style: robotoMedium,
                                  //   ),
                                  //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AddFavouriteView(
                  storeId: store.id, item: null,
                ),
              
          
                // isShop ? const SizedBox() : Positioned(
                //   bottom: 10, right: 20,
                //   child: CartCountView(
                //     item: item,
                //   ),
                // ),
                // Get.find<ItemController>().isAvailable(item)
                //     ? const SizedBox()
                //     : NotAvailableWidget(
                //         radius: Dimensions.radiusLarge,
                //         isAllSideRound: isPopularItem),
              ]),
            ),
            // Expanded(
            //   flex: 2,
            //   child: Padding(
            //     padding: EdgeInsets.only(
            //         left: Dimensions.paddingSizeSmall,
            //         right: isShop ? 0 : Dimensions.paddingSizeSmall,
            //         top: Dimensions.paddingSizeSmall,
            //         bottom: isShop ? 0 : Dimensions.paddingSizeSmall),
            //     child: Stack(clipBehavior: Clip.none, children: [
            //       Column(
            //           crossAxisAlignment: isPopularItem
            //               ? CrossAxisAlignment.center
            //               : CrossAxisAlignment.start,
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text(
            //               item.storeName ?? '',
            //               style: robotoBold,
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //             Text(item.dtime ?? "",
            //                 style: robotoRegular.copyWith(
            //                     color: Theme.of(context)
            //                         .disabledColor)) // (isFood || isShop) ? Flexible(
            //             //   child: Text(
            //             //     item.name ?? '',
            //             //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
            //             //   ),
            //             // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
            //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //             //
            //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //             //
            //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            //             // ]),
            //             //
            //             // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
            //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //
            //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //             //
            //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            //             //
            //             // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
            //             //   '(${ item.unitType ?? ''})',
            //             //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
            //             // ) : const SizedBox(),
            //
            //             // discount != null && discount > 0  ? Text(
            //             //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
            //             //   style: robotoMedium.copyWith(
            //             //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
            //             //     decoration: TextDecoration.lineThrough,
            //             //   ), textDirection: TextDirection.ltr,
            //             // ) : const SizedBox(),
            //             // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
            //
            //             //   Text(
            //             //     PriceConverter.convertPrice(
            //             //       Get.find<ItemController>().getStartingPrice(item), discount: discount,
            //             //       discountType: discountType,
            //             //     ),
            //             //     textDirection: TextDirection.ltr, style: robotoMedium,
            //             //   ),
            //             //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            //           ]),
            //       // isShop ? Positioned(
            //       //   bottom: 0, right: 0,
            //       //   child: CartCountView(
            //       //     item: item,
            //       //     child: Container(
            //       //       height: 35, width: 38,
            //       //       decoration: BoxDecoration(
            //       //         color: Theme.of(context).primaryColor,
            //       //         borderRadius: const BorderRadius.only(
            //       //           topLeft: Radius.circular(Dimensions.radiusLarge),
            //       //           bottomRight: Radius.circular(Dimensions.radiusLarge),
            //       //         ),
            //       //       ),
            //       //       child: Icon(isPopularItemCart ? Icons.add_shopping_cart : Icons.add, color: Theme.of(context).cardColor, size: 20),
            //       //     ),
            //       //   ),
            //       // ) : const SizedBox(),
            //     ]),
            //   ),
            // ),
          ]),
        ),
      ),
      // isAvailable
      //     ? const SizedBox()
      //     : Positioned(
      //     right: ltr ? 0 : null,
      //     left: ltr ? null : 0,
      //     child: CornerBanner(
      //       bannerPosition: ltr
      //           ? CornerBannerPosition.topRight
      //           : CornerBannerPosition.topLeft,
      //       bannerColor: Theme.of(context).colorScheme.error,
      //       elevation: 5,
      //       shadowColor: Colors.transparent,
      //       child: _buildBannerContent(),
      //     )),
    ]);
  }
}
class StoreCardWithDistance2 extends StatefulWidget {

  final Store store;

  final bool fromAllStore;

  final bool? isNewStore;

  final bool? fromTopOffers;

  final bool recommendedStore;

  const StoreCardWithDistance2(

      {super.key,

        required this.store,

        this.fromAllStore = false,

        this.isNewStore = false,

        this.fromTopOffers = false,

        this.recommendedStore = false});



  @override

  State<StoreCardWithDistance2> createState() => _StoreCardWithDistance2State();

}



class _StoreCardWithDistance2State extends State<StoreCardWithDistance2> {

  @override

  void initState() {

    super.initState();

    // initDataCall();

  }



  // Future<void> initDataCall() async {

  //   Get.find<CouponController>().getCouponRestList(widget.store.id);

  // }



  @override

  Widget build(BuildContext context) {

    // final CouponController couponController = Get.find<CouponController>();

    // Get.find<CouponController>().getCouponRestList(widget.store!.id);

    bool isPharmacy = Get.find<SplashController>().module != null &&

        Get.find<SplashController>().module!.moduleType.toString() ==

            AppConstants.pharmacy;

    double distance = (widget.store.distance! / 1000);

    double discount = widget.store.discount?.discount ?? 0;

    String discountType = widget.store.discount?.discountType ?? '';

    bool isRightSide =

        Get.find<SplashController>().configModel!.currencySymbolDirection ==

            'right';

    String currencySymbol =

    Get.find<SplashController>().configModel!.currencySymbol!;



    final List<Color> vibrantColors = [

      const Color(0xFFEF5350), // Vibrant Red

      const Color(0xFF42A5F5), // Bright Blue

      const Color(0xFFFFC107), // Vibrant Amber

    ];



    // 🌀 Pick a random color

    final Color bgColor = vibrantColors[Random().nextInt(vibrantColors.length)];



    final Brightness brightness = ThemeData.estimateBrightnessForColor(bgColor);

    final Color textColor =

    brightness == Brightness.dark ? Colors.white : Colors.black;



    return Stack(children: [

      Container(

        width: 280,

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),

          // color: Colors.red,

        ),

        child: CustomInkWell(

          onTap: () {

            if (Get.find<SplashController>().moduleList != null) {

              for (ModuleModel module

              in Get.find<SplashController>().moduleList!) {

                if (module.id == widget.store.moduleId) {

                  Get.find<SplashController>().setModule(module);

                  break;

                }

              }

            }

            Get.toNamed(

              RouteHelper.getStoreRoute(id: widget.store.id, page: 'store'),

              arguments: StoreScreen(store: widget.store, fromModule: false),

            );

          },

          // radius: Dimensions.radiusLarge,

          child:

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Expanded(

              flex: 5,

              child: Stack(children: [

                Padding(

                  padding: const EdgeInsets.only(

                      top: Dimensions.paddingSizeExtraSmall,

                      left: Dimensions.paddingSizeExtraSmall,

                      right: Dimensions.paddingSizeExtraSmall),

                  child: Stack(

                    children: [

                      ClipRRect(

                        borderRadius: const BorderRadius.only(

                          topLeft: Radius.circular(Dimensions.radiusLarge),

                          topRight: Radius.circular(Dimensions.radiusLarge),

                          // bottomLeft: Radius.circular(Dimensions.radiusLarge),

                          // bottomRight:

                          //     Radius.circular(Dimensions.radiusLarge),

                        ),

                        child: CustomImage(

                          placeholder: Images.placeholder,

                          image: '${widget.store.logoFullUrl}',

                          fit: BoxFit.cover,

                          width: double.infinity,

                          height: double.infinity,

                        ),

                      ),

                      widget.store.freetag != null

                          ? Positioned(

                        bottom: 5,

                        left: 5,

                        child: Row(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          mainAxisAlignment: MainAxisAlignment.start,

                          children: [

                            Container(

                              decoration: BoxDecoration(

                                color: bgColor,

                                borderRadius: BorderRadius.circular(5),

                              ),

                              child: Padding(

                                padding: const EdgeInsets.all(4.0),

                                child: Text(

                                  widget.store.freetag!.toUpperCase(),

                                  style: robotoBlack.copyWith(

                                    color: textColor,

                                    fontSize: Dimensions.fontSizeSmall,

                                  ),

                                ),

                              ),

                            ),

                          ],

                        ),

                      )

                          : const SizedBox(),

                      Positioned(

                        bottom: 5,

                        left: 5,

                        right: 5, // Ensuring spacing on both sides

                        child: Row(

                          crossAxisAlignment: CrossAxisAlignment.end,

                          mainAxisAlignment: MainAxisAlignment

                              .end, // Pushes columns to opposite sides

                          children: [

                            // Column(

                            //   crossAxisAlignment: CrossAxisAlignment

                            //       .start, // Aligns text to the left

                            //   children: [

                            //     Text(

                            //       discount! > 0

                            //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'

                            //           : 'free_delivery'.tr,

                            //       style: robotoBold.copyWith(

                            //         color: Theme.of(context).cardColor,

                            //         fontSize:

                            //             (ResponsiveHelper.isMobile(context)

                            //                 ? 18

                            //                 : 18),

                            //       ),

                            //       textAlign: TextAlign.start,

                            //     ),

                            //     Text(

                            //       discount > 0

                            //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount

                            //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide

                            //           : 'free_delivery'.tr,

                            //       style: robotoBold.copyWith(

                            //         color: Theme.of(context).cardColor,

                            //         fontSize:

                            //             (ResponsiveHelper.isMobile(context)

                            //                 ? 15

                            //                 : 15),

                            //       ),

                            //       textAlign: TextAlign.start,

                            //     ),

                            //   ],

                            // ),

                            // Column(

                            //   crossAxisAlignment: CrossAxisAlignment

                            //       .start, // Aligns text to the left

                            //   children: [

                            //     Text(

                            //       discount! > 0

                            //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'

                            //           : 'free_delivery'.tr,

                            //       style: robotoBold.copyWith(

                            //         color: Theme.of(context).cardColor,

                            //         fontSize:

                            //             (ResponsiveHelper.isMobile(context)

                            //                 ? 18

                            //                 : 18),

                            //       ),

                            //       textAlign: TextAlign.start,

                            //     ),

                            //     Text(

                            //       discount > 0

                            //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount

                            //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide

                            //           : 'free_delivery'.tr,

                            //       style: robotoBold.copyWith(

                            //         color: Theme.of(context).cardColor,

                            //         fontSize:

                            //             (ResponsiveHelper.isMobile(context)

                            //                 ? 15

                            //                 : 15),

                            //       ),

                            //       textAlign: TextAlign.start,

                            //     ),

                            //   ],

                            // ),



                            Column(

                                crossAxisAlignment: CrossAxisAlignment.end,

                                mainAxisAlignment:

                                MainAxisAlignment.spaceBetween,

                                children: [

                                  Container(

                                    decoration: BoxDecoration(

                                        borderRadius: BorderRadius.circular(5),

                                        color: Colors.green.shade900

                                      // gradient: LinearGradient(

                                      //   begin: Alignment.centerLeft,

                                      //   end: Alignment.centerRight,

                                      //   colors: [

                                      //     Theme.of(context).primaryColor.withOpacity(1.0), // darkest

                                      //     Theme.of(context).primaryColor.withOpacity(0.6), // lighter

                                      //     Theme.of(context).primaryColor.withOpacity(0.0), // transparent

                                      //   ],

                                      // ),



                                    ),

                                    child: Padding(

                                      padding: const EdgeInsets.all(4.0),

                                      child: Row(children: [

                                        Icon(Icons.star,

                                            size: 14,

                                            color: Theme.of(context).cardColor),

                                        const SizedBox(

                                            width: Dimensions

                                                .paddingSizeExtraSmall),

                                        Text(

                                            widget.store.avgRating!

                                                .toStringAsFixed(1),

                                            style: robotoMedium.copyWith(

                                                color:

                                                Theme.of(context).cardColor,

                                                fontSize:

                                                Dimensions.fontSizeSmall)),

                                        // const SizedBox(

                                        //     width: Dimensions

                                        //         .paddingSizeExtraSmall),

                                        // Text("(${store.ratingCount})",

                                        //     style: robotoMedium.copyWith(

                                        //         fontSize: Dimensions

                                        //             .fontSizeSmall,

                                        //         color: Theme.of(context).cardColor)),

                                      ]),

                                    ),

                                  ),

                                  // (isFood || isShop) ? Flexible(

                                  //   child: Text(

                                  //     item.name ?? '',

                                  //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,

                                  //   ),

                                  // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [

                                  //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),

                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  //

                                  //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  //

                                  //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

                                  // ]),

                                  //

                                  // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [

                                  //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),

                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),



                                  //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  //

                                  //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

                                  //

                                  // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(

                                  //   '(${ item.unitType ?? ''})',

                                  //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),

                                  // ) : const SizedBox(),



                                  // discount != null && discount > 0  ? Text(

                                  //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),

                                  //   style: robotoMedium.copyWith(

                                  //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,

                                  //     decoration: TextDecoration.lineThrough,

                                  //   ), textDirection: TextDirection.ltr,

                                  // ) : const SizedBox(),

                                  // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),



                                  //   Text(

                                  //     PriceConverter.convertPrice(

                                  //       Get.find<ItemController>().getStartingPrice(item), discount: discount,

                                  //       discountType: discountType,

                                  //     ),

                                  //     textDirection: TextDirection.ltr, style: robotoMedium,

                                  //   ),

                                  //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                ]),

                          ],

                        ),

                      ),

                    ],

                  ),

                ),



                if (widget.store.deliveryTime != null &&

                    widget.store.deliveryTime!.isNotEmpty)

                  Positioned(

                    top: 10,

                    left: 10,

                    child: Container(

                      padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 1),

                      decoration: const BoxDecoration(

                        borderRadius: BorderRadius.only(

                          topLeft: Radius.circular(Dimensions.radiusDefault),

                          topRight: Radius.circular(Dimensions.radiusSmall),

                          bottomLeft: Radius.circular(Dimensions.radiusSmall),

                          bottomRight: Radius.circular(Dimensions.radiusSmall),

                        ),

                        gradient: LinearGradient(

                          colors: [

                            Color(0xFFFB9F96),

                            Color.fromARGB(255, 242, 42, 28),

                          ],

                          begin: Alignment.topLeft,

                          end: Alignment.bottomRight,

                          stops: [ 0.2, 0.8],

                        ),

                      ),

                      child: Row(

                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [

                          // Icon(

                          //   CupertinoIcons.clock,

                          //   color: Colors.black,

                          //   size: Dimensions.fontSizeExtraLarge,

                          // ),

                          SizedBox(

                            height: Dimensions.paddingSizeLarge,

                            width: Dimensions.paddingSizeLarge,

                            child: Lottie.asset(Images.deliveryManPerson2,

                                fit: BoxFit.fill),

                          ),

                          Text(

                            widget.store.deliveryTime!,

                            style: robotoBold.copyWith(color: Colors.white),

                          ),

                        ],

                      ),

                    ),

                  ),



                AddFavouriteView1(

                  storeId: widget.store.id,

                  item: null,

                ),



                // isShop ? const SizedBox() : Positioned(

                //   bottom: 10, right: 20,

                //   child: CartCountView(

                //     item: item,

                //   ),

                // ),

                // Get.find<ItemController>().isAvailable(item)

                //     ? const SizedBox()

                //     : NotAvailableWidget(

                //         radius: Dimensions.radiusLarge,

                //         isAllSideRound: isPopularItem),

              ]),

            ),

            Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.start,

              children: [

                Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [

                      Text(

                        widget.store.name?.capitalizeFirst ?? '',

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: robotoBold.copyWith(

                          // color:

                          //Theme.of(context).cardColor,

                          fontSize:

                          (ResponsiveHelper.isMobile(context) ? 15 : 15),

                        ),

                      ),

                      // Text(

                      //   PriceConverter.convertPrice(

                      //     item!

                      //         .foodVariations!

                      //         .first

                      //         .variationValues!

                      //         .first

                      //         .optionPrice,

                      //     discount: discount,

                      //     discountType: discountType,

                      //   ),

                      //   style: robotoBold.copyWith(

                      //     color:

                      //     Theme.of(context).cardColor,

                      //     fontSize:

                      //     (ResponsiveHelper.isMobile(

                      //         context)

                      //         ? 15

                      //         : 15),

                      //   ),

                      //   textAlign: TextAlign.start,

                      // ),

                      SizedBox(

                          width: discount > 0

                              ? Dimensions.paddingSizeExtraSmall

                              : 0),

                      // Text(

                      //   store.address?.capitalizeFirst  ?? '',

                      //   maxLines: 1,

                      //   overflow: TextOverflow.ellipsis,

                      //   style:  robotoRegular.copyWith(

                      //     // color:

                      //     // Theme.of(context).cardColor,

                      //     fontSize:

                      //     (ResponsiveHelper.isMobile(

                      //         context)

                      //         ? 10

                      //         : 15),

                      //   ),),



                      ///

                      /// I COMMAND THE BELOW CODE TO MOVE UPER LIKE LABLE

                      ///



                      // Row(

                      //   children: [

                      //     Icon(

                      //       CupertinoIcons.clock,

                      //       color: Colors.black,

                      //       size: Dimensions.fontSizeExtraSmall,

                      //     ),

                      //     Text(widget.store.deliveryTime ?? "",

                      //         style: robotoRegular.copyWith(

                      //           fontSize: Dimensions.fontSizeSmall,

                      //         )),

                      //   ],

                      // ),



                      ///

                      /// STILL HERE

                      ///



                      widget.store.discount != null

                          ? Row(

                        children: [

                          ClipRRect(

                            borderRadius: const BorderRadius.all(

                                Radius.circular(5)),

                            child: Container(

                              decoration: const BoxDecoration(

                                color: Colors.red,

                              ),

                              // margin: const EdgeInsets.only(right: 6),

                              child: Padding(

                                padding: const EdgeInsets.symmetric(

                                    horizontal: 4.0),

                                child: Text(

                                  "Offers",

                                  style: robotoMedium.copyWith(

                                    fontSize: Dimensions.fontSizeSmall,

                                    color: Theme.of(context).cardColor,

                                  ),

                                ),

                              ),

                            ),

                          ),

                          const SizedBox(

                            width: 5,

                          ),

                          Expanded(

                            child: AutoScrollText(

                              '${widget.store.discount!.discountType == 'percent' ? '${widget.store.discount!.discount}%' : 'Save ${PriceConverter.convertPrice(widget.store.discount!.discount)}'}  on orders above ${PriceConverter.convertPrice(widget.store.discount!.minPurchase)} (Max: ${PriceConverter.convertPrice(widget.store.discount!.maxDiscount)})',

                              style: robotoMedium.copyWith(

                                fontSize: Dimensions.fontSizeSmall,

                                color: Colors.black,

                              ),

                              textAlign: TextAlign.center,

                            ),

                          ),

                        ],

                      )

                          : const SizedBox.shrink(),



                      // const CouponOfferClass() I HAVE COMMAND THIS LINE BEACUSE WE DEICED NO MORE OFFER WIDGET

                      /**

                       *

                       * COMMENT BY: SARAVANAN

                       * PURPOSE: THE OFFER IS NOT VISISBLE AND IT VISIBLE ONLY IF THE USER START SCORLLING SOME LOGIC ISSUE HAS BEEN HAPPEND

                       *

                       */

                      // (couponController.couponRestList != null &&

                      //         couponController.couponRestList!.isNotEmpty)

                      //     ? Row(

                      //         children: [

                      //           Padding(

                      //             padding: const EdgeInsets.all(6.0),

                      //             child: ClipRRect(

                      //               borderRadius: const BorderRadius.all(

                      //                   Radius.circular(5)),

                      //               child: Container(

                      //                 decoration: const BoxDecoration(

                      //                   color: Colors.green,

                      //                 ),

                      //                 // margin: const EdgeInsets.only(right: 6),

                      //                 child: Padding(

                      //                   padding: const EdgeInsets.symmetric(

                      //                       horizontal: 4.0),

                      //                   child: Text(

                      //                     "Offers",

                      //                     style: robotoMedium.copyWith(

                      //                       fontSize:

                      //                           Dimensions.fontSizeSmall,

                      //                       color:

                      //                           Theme.of(context).cardColor,

                      //                     ),

                      //                   ),

                      //                 ),

                      //               ),

                      //             ),

                      //           ),

                      //           const SizedBox(

                      //             width: 5,

                      //           ),

                      //           Expanded(

                      //             child: AutoScrollText(

                      //               // 👇 Build text dynamically from the first coupon (you can customize)

                      //               '${couponController.couponRestList![0].couponType == 'free_delivery' ? 'Free Delivery Available!' : couponController.couponRestList![0].discountType == 'percent' ? '${couponController.couponRestList![0].discount?.toStringAsFixed(0)}% off up to ₹${couponController.couponRestList![0].maxDiscount?.toStringAsFixed(0)}' : 'Flat ₹${couponController.couponRestList![0].discount?.toStringAsFixed(0)} off up to ₹${couponController.couponRestList![0].maxDiscount?.toStringAsFixed(0)}'} ',

                      //               // '| Use Code: ${couponController.couponRestList![0].code ?? 'N/A'} '

                      //               // '| Valid Till: ${couponController.couponRestList![0].expireDate != null

                      //               // ? DateFormat('dd-MMM-yyyy').format(DateTime.parse(couponController.couponRestList![0].expireDate!))

                      //               // : 'N/A'}',

                      //               style: robotoMedium.copyWith(

                      //                 fontSize: Dimensions.fontSizeSmall,

                      //                 color: Colors.black,

                      //               ),

                      //               textAlign: TextAlign.center,

                      //             ),

                      //           ),

                      //         ],

                      //       )

                      //     : const SizedBox.shrink(),

                      /**

                       *

                       *  STILL HERE I HAVE MADE COMMENT

                       *

                       */

// 👈 returns nothing if discount is null

                    ])

              ],

            ),



            // Expanded(

            //   flex: 2,

            //   child: Padding(

            //     padding: EdgeInsets.only(

            //         left: Dimensions.paddingSizeSmall,

            //         right: isShop ? 0 : Dimensions.paddingSizeSmall,

            //         top: Dimensions.paddingSizeSmall,

            //         bottom: isShop ? 0 : Dimensions.paddingSizeSmall),

            //     child: Stack(clipBehavior: Clip.none, children: [

            //       Column(

            //           crossAxisAlignment: isPopularItem

            //               ? CrossAxisAlignment.center

            //               : CrossAxisAlignment.start,

            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,

            //           children: [

            //             Text(

            //               item.storeName ?? '',

            //               style: robotoBold,

            //               maxLines: 1,

            //               overflow: TextOverflow.ellipsis,

            //             ),

            //             Text(item.dtime ?? "",

            //                 style: robotoRegular.copyWith(

            //                     color: Theme.of(context)

            //                         .disabledColor)) // (isFood || isShop) ? Flexible(

            //             //   child: Text(

            //             //     item.name ?? '',

            //             //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,

            //             //   ),

            //             // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [

            //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),

            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            //             //

            //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            //             //

            //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

            //             // ]),

            //             //

            //             // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [

            //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),

            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            //

            //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            //             //

            //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

            //             //

            //             // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(

            //             //   '(${ item.unitType ?? ''})',

            //             //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),

            //             // ) : const SizedBox(),

            //

            //             // discount != null && discount > 0  ? Text(

            //             //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),

            //             //   style: robotoMedium.copyWith(

            //             //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,

            //             //     decoration: TextDecoration.lineThrough,

            //             //   ), textDirection: TextDirection.ltr,

            //             // ) : const SizedBox(),

            //             // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

            //

            //             //   Text(

            //             //     PriceConverter.convertPrice(

            //             //       Get.find<ItemController>().getStartingPrice(item), discount: discount,

            //             //       discountType: discountType,

            //             //     ),

            //             //     textDirection: TextDirection.ltr, style: robotoMedium,

            //             //   ),

            //             //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            //           ]),

            //       // isShop ? Positioned(

            //       //   bottom: 0, right: 0,

            //       //   child: CartCountView(

            //       //     item: item,

            //       //     child: Container(

            //       //       height: 35, width: 38,

            //       //       decoration: BoxDecoration(

            //       //         color: Theme.of(context).primaryColor,

            //       //         borderRadius: const BorderRadius.only(

            //       //           topLeft: Radius.circular(Dimensions.radiusLarge),

            //       //           bottomRight: Radius.circular(Dimensions.radiusLarge),

            //       //         ),

            //       //       ),

            //       //       child: Icon(isPopularItemCart ? Icons.add_shopping_cart : Icons.add, color: Theme.of(context).cardColor, size: 20),

            //       //     ),

            //       //   ),

            //       // ) : const SizedBox(),

            //     ]),

            //   ),

            // ),

          ]),

        ),

      ),

      // isAvailable

      //     ? const SizedBox()

      //     : Positioned(

      //     right: ltr ? 0 : null,

      //     left: ltr ? null : 0,

      //     child: CornerBanner(

      //       bannerPosition: ltr

      //           ? CornerBannerPosition.topRight

      //           : CornerBannerPosition.topLeft,

      //       bannerColor: Theme.of(context).colorScheme.error,

      //       elevation: 5,

      //       shadowColor: Colors.transparent,

      //       child: _buildBannerContent(),

      //     )),

    ]);

  }

}



// class StoreCardWithDistance2 extends StatefulWidget {
//   final Store store;
//   final bool fromAllStore;
//   final bool? isNewStore;
//   final bool? fromTopOffers;
//   final bool recommendedStore;
//   const StoreCardWithDistance2({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});
//
//   @override
//   State<StoreCardWithDistance2> createState() => _StoreCardWithDistance2State();
// }
//
// class _StoreCardWithDistance2State extends State<StoreCardWithDistance2> {
//
//   @override
//   void initState() {
//     super.initState();
//     initDataCall();
//   }
//
//   Future<void> initDataCall() async {
//     Get.find<CouponController>().getCouponRestList(widget.store!.id);
//   }
//     @override
//   Widget build(BuildContext context) {
//     final CouponController couponController = Get.find<CouponController>();
//     // Get.find<CouponController>().getCouponRestList(widget.store!.id);
//     bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
//     double distance = (widget.store.distance!/1000);
//     double discount = widget.store.discount?.discount ?? 0;
//     String discountType = widget.store.discount?.discountType ?? '';
//     bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
//     String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;
//
//     return Stack(children: [
//       Container(
//         width: 280,
//         decoration: BoxDecoration(
//           // borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
//         ),
//         child: CustomInkWell(
//           onTap: () {
//             if(Get.find<SplashController>().moduleList != null) {
//               for(ModuleModel module in Get.find<SplashController>().moduleList!) {
//                 if(module.id == widget.store.moduleId) {
//                   Get.find<SplashController>().setModule(module);
//                   break;
//                 }
//               }
//             }
//             Get.toNamed(
//               RouteHelper.getStoreRoute(id: widget.store.id, page: 'store'),
//               arguments: StoreScreen(store: widget.store, fromModule: false),
//             );
//           },
//           // radius: Dimensions.radiusLarge,
//           child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Expanded(
//               flex: 5,
//               child: Stack(children: [
//                 Padding(
//                   padding: EdgeInsets.only(
//                       top: Dimensions.paddingSizeExtraSmall
//                       ,
//                       left: Dimensions.paddingSizeExtraSmall,
//                       right: Dimensions.paddingSizeExtraSmall
//                   ),
//                   child: Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(Dimensions.radiusLarge),
//                           topRight: Radius.circular(Dimensions.radiusLarge),
//                           // bottomLeft: Radius.circular(Dimensions.radiusLarge),
//                           // bottomRight:
//                           //     Radius.circular(Dimensions.radiusLarge),
//                         ),
//                         child: CustomImage(
//                           placeholder: Images.placeholder,
//                           image: '${widget.store.logoFullUrl}',
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: double.infinity,
//                         ),
//                       ),
//
//                       widget.store.freetag != null
//                           ? Positioned(
//                         top: 5,
//                         left: 5,
//                         right: 5,
//                         child: Builder(
//                           builder: (context) {
//                             // 🎨 Vibrant color list
//                             final List<Color> vibrantColors = [
//                               const Color(0xFFEF5350), // Vibrant Red
//                               const Color(0xFF42A5F5), // Bright Blue
//                               const Color(0xFFFFC107), // Vibrant Amber
//                             ];
//
//                             // 🌀 Pick a random color
//                             final Color bgColor =
//                             vibrantColors[Random().nextInt(vibrantColors.length)];
//
//                             final Brightness brightness =
//                             ThemeData.estimateBrightnessForColor(bgColor);
//                             final Color textColor =
//                             brightness == Brightness.dark ? Colors.white : Colors.black;
//
//                             return Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: bgColor,
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: Text(
//                                       widget.store.freetag!.toUpperCase(),
//                                       style: robotoBlack.copyWith(
//                                         color: textColor,
//                                         fontSize: Dimensions.fontSizeSmall,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       )
//                           : const SizedBox(),
//                       Positioned(
//                         bottom: 5,
//                         left: 5,
//                         right: 5, // Ensuring spacing on both sides
//                         child: Row(
//                           crossAxisAlignment
//                               : CrossAxisAlignment.end,
//                           mainAxisAlignment: MainAxisAlignment
//                               .end, // Pushes columns to opposite sides
//                           children: [
//                             // Column(
//                             //   crossAxisAlignment: CrossAxisAlignment
//                             //       .start, // Aligns text to the left
//                             //   children: [
//                             //     Text(
//                             //       discount! > 0
//                             //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
//                             //           : 'free_delivery'.tr,
//                             //       style: robotoBold.copyWith(
//                             //         color: Theme.of(context).cardColor,
//                             //         fontSize:
//                             //             (ResponsiveHelper.isMobile(context)
//                             //                 ? 18
//                             //                 : 18),
//                             //       ),
//                             //       textAlign: TextAlign.start,
//                             //     ),
//                             //     Text(
//                             //       discount > 0
//                             //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount
//                             //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide
//                             //           : 'free_delivery'.tr,
//                             //       style: robotoBold.copyWith(
//                             //         color: Theme.of(context).cardColor,
//                             //         fontSize:
//                             //             (ResponsiveHelper.isMobile(context)
//                             //                 ? 15
//                             //                 : 15),
//                             //       ),
//                             //       textAlign: TextAlign.start,
//                             //     ),
//                             //   ],
//                             // ),
//                             // Column(
//                             //   crossAxisAlignment: CrossAxisAlignment
//                             //       .start, // Aligns text to the left
//                             //   children: [
//                             //     Text(
//                             //       discount! > 0
//                             //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
//                             //           : 'free_delivery'.tr,
//                             //       style: robotoBold.copyWith(
//                             //         color: Theme.of(context).cardColor,
//                             //         fontSize:
//                             //             (ResponsiveHelper.isMobile(context)
//                             //                 ? 18
//                             //                 : 18),
//                             //       ),
//                             //       textAlign: TextAlign.start,
//                             //     ),
//                             //     Text(
//                             //       discount > 0
//                             //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount
//                             //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide
//                             //           : 'free_delivery'.tr,
//                             //       style: robotoBold.copyWith(
//                             //         color: Theme.of(context).cardColor,
//                             //         fontSize:
//                             //             (ResponsiveHelper.isMobile(context)
//                             //                 ? 15
//                             //                 : 15),
//                             //       ),
//                             //       textAlign: TextAlign.start,
//                             //     ),
//                             //   ],
//                             // ),
//
//                             Column(
//                                 crossAxisAlignment
//                                     : CrossAxisAlignment.end,
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [  Container(
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(5) ,
//                                       color: Colors.green.shade900
//                                     // gradient: LinearGradient(
//                                     //   begin: Alignment.centerLeft,
//                                     //   end: Alignment.centerRight,
//                                     //   colors: [
//                                     //     Theme.of(context).primaryColor.withOpacity(1.0), // darkest
//                                     //     Theme.of(context).primaryColor.withOpacity(0.6), // lighter
//                                     //     Theme.of(context).primaryColor.withOpacity(0.0), // transparent
//                                     //   ],
//                                     // ),
//
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: Row(
//
//                                         children: [
//                                           Icon(Icons.star,
//                                               size: 14,
//                                               color:Theme.of(context).cardColor),
//                                           const SizedBox(
//                                               width: Dimensions
//                                                   .paddingSizeExtraSmall),
//                                           Text(
//                                               widget.store.avgRating!
//                                                   .toStringAsFixed(1),
//                                               style: robotoMedium.copyWith(
//                                                   color: Theme.of(context).cardColor,
//                                                   fontSize: Dimensions
//                                                       .fontSizeSmall)),
//                                           // const SizedBox(
//                                           //     width: Dimensions
//                                           //         .paddingSizeExtraSmall),
//                                           // Text("(${store.ratingCount})",
//                                           //     style: robotoMedium.copyWith(
//                                           //         fontSize: Dimensions
//                                           //             .fontSizeSmall,
//                                           //         color: Theme.of(context).cardColor)),
//                                         ]),
//                                   ),
//                                 ),
//                                   // (isFood || isShop) ? Flexible(
//                                   //   child: Text(
//                                   //     item.name ?? '',
//                                   //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
//                                   //   ),
//                                   // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//                                   //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
//                                   //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                                   //
//                                   //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                                   //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                                   //
//                                   //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
//                                   // ]),
//                                   //
//                                   // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//                                   //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
//                                   //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                   //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                                   //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                                   //
//                                   //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
//                                   //
//                                   // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
//                                   //   '(${ item.unitType ?? ''})',
//                                   //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
//                                   // ) : const SizedBox(),
//
//                                   // discount != null && discount > 0  ? Text(
//                                   //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
//                                   //   style: robotoMedium.copyWith(
//                                   //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
//                                   //     decoration: TextDecoration.lineThrough,
//                                   //   ), textDirection: TextDirection.ltr,
//                                   // ) : const SizedBox(),
//                                   // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
//
//                                   //   Text(
//                                   //     PriceConverter.convertPrice(
//                                   //       Get.find<ItemController>().getStartingPrice(item), discount: discount,
//                                   //       discountType: discountType,
//                                   //     ),
//                                   //     textDirection: TextDirection.ltr, style: robotoMedium,
//                                   //   ),
//                                   //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                                 ]),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 AddFavouriteView3(
//                   storeId: widget.store.id, item: null,
//                 ),
//
//
//                 // isShop ? const SizedBox() : Positioned(
//                 //   bottom: 10, right: 20,
//                 //   child: CartCountView(
//                 //     item: item,
//                 //   ),
//                 // ),
//                 // Get.find<ItemController>().isAvailable(item)
//                 //     ? const SizedBox()
//                 //     : NotAvailableWidget(
//                 //         radius: Dimensions.radiusLarge,
//                 //         isAllSideRound: isPopularItem),
//               ]),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                   Text(
//                     widget.store.name?.capitalizeFirst ?? '',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style:  robotoBold.copyWith(
//                       // color:
//                       //Theme.of(context).cardColor,
//                       fontSize:
//                       (ResponsiveHelper.isMobile(
//                           context)
//                           ? 15
//                           : 15),
//                     ),),
//                   // Text(
//                   //   PriceConverter.convertPrice(
//                   //     item!
//                   //         .foodVariations!
//                   //         .first
//                   //         .variationValues!
//                   //         .first
//                   //         .optionPrice,
//                   //     discount: discount,
//                   //     discountType: discountType,
//                   //   ),
//                   //   style: robotoBold.copyWith(
//                   //     color:
//                   //     Theme.of(context).cardColor,
//                   //     fontSize:
//                   //     (ResponsiveHelper.isMobile(
//                   //         context)
//                   //         ? 15
//                   //         : 15),
//                   //   ),
//                   //   textAlign: TextAlign.start,
//                   // ),
//                   SizedBox(
//                       width: discount! > 0
//                           ? Dimensions
//                           .paddingSizeExtraSmall
//                           : 0),
//                   // Text(
//                   //   store.address?.capitalizeFirst  ?? '',
//                   //   maxLines: 1,
//                   //   overflow: TextOverflow.ellipsis,
//                   //   style:  robotoRegular.copyWith(
//                   //     // color:
//                   //     // Theme.of(context).cardColor,
//                   //     fontSize:
//                   //     (ResponsiveHelper.isMobile(
//                   //         context)
//                   //         ? 10
//                   //         : 15),
//                   //   ),),
//
//                   Row(
//                     children: [
//                       Icon(CupertinoIcons.clock,color:Colors.black,size: Dimensions.fontSizeExtraSmall,),
//                       Text(widget.store.deliveryTime ?? "",
//                           style: robotoRegular.copyWith(
//                             fontSize: Dimensions.fontSizeSmall,
//                           )),
//                     ],
//                   ),
//                       widget.store?.discount != null
//                           ? Row(
//                         children: [
//                           ClipRRect(
//                             borderRadius:BorderRadius.all(Radius.circular(5)),
//                             child: Container(
//
//                               decoration:BoxDecoration(
//                                 color : Colors.red,
//                               ),
//                               // margin: const EdgeInsets.only(right: 6),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                                 child: Text(
//                                   "Offers",
//                                   style: robotoMedium.copyWith(
//                                     fontSize: Dimensions.fontSizeSmall,
//                                     color: Theme.of(context).cardColor,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 5,),
//                           Expanded(
//                             child: AutoScrollText(
//                               '${widget.store?.discount!.discountType == 'percent'
//                                   ? '${widget.store?.discount!.discount}%'
//                                   :  'Save ${PriceConverter.convertPrice(widget.store?.discount!.discount)}'}  on orders above ${PriceConverter.convertPrice(widget.store?.discount!.minPurchase)} (Max: ${PriceConverter.convertPrice(widget.store?.discount!.maxDiscount)})',    style: robotoMedium.copyWith(
//                                 fontSize: Dimensions.fontSizeSmall,
//                                 color: Colors.black,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       )
//                           : (couponController.couponRestList != null &&
//                           couponController.couponRestList!.isNotEmpty)
//                           ? Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(6.0),
//                             child: ClipRRect(
//                             borderRadius:BorderRadius.all(Radius.circular(5)),
//                               child: Container(
//
//                                 decoration:BoxDecoration(
//                               color : Colors.green,
//                                                     ),
//                                 // margin: const EdgeInsets.only(right: 6),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                                   child: Text(
//                                     "Offers",
//                                     style: robotoMedium.copyWith(
//                                       fontSize: Dimensions.fontSizeSmall,
//                                       color: Theme.of(context).cardColor,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 5,),
//                           Expanded(
//                             child: AutoScrollText(
//                               // 👇 Build text dynamically from the first coupon (you can customize)
//                               '${couponController.couponRestList![0].couponType == 'free_delivery'
//                                   ? 'Free Delivery Available!'
//                                   : couponController.couponRestList![0].discountType == 'percent'
//                                   ? '${couponController.couponRestList![0].discount?.toStringAsFixed(0)}% off up to ₹${couponController.couponRestList![0].maxDiscount?.toStringAsFixed(0)}'
//                                   : 'Flat ₹${couponController.couponRestList![0].discount?.toStringAsFixed(0)} off up to ₹${couponController.couponRestList![0].maxDiscount?.toStringAsFixed(0)}'} ',
//                                   // '| Use Code: ${couponController.couponRestList![0].code ?? 'N/A'} '
//                                   // '| Valid Till: ${couponController.couponRestList![0].expireDate != null
//                                   // ? DateFormat('dd-MMM-yyyy').format(DateTime.parse(couponController.couponRestList![0].expireDate!))
//                                   // : 'N/A'}',
//                               style: robotoMedium.copyWith(
//                                 fontSize: Dimensions.fontSizeSmall,
//                                 color: Colors.black,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ],
//                       )
//                           : const SizedBox.shrink(),
// // 👈 returns nothing if discount is null
//
//                     ])
//
//               ],
//             ),
//
//             // Expanded(
//             //   flex: 2,
//             //   child: Padding(
//             //     padding: EdgeInsets.only(
//             //         left: Dimensions.paddingSizeSmall,
//             //         right: isShop ? 0 : Dimensions.paddingSizeSmall,
//             //         top: Dimensions.paddingSizeSmall,
//             //         bottom: isShop ? 0 : Dimensions.paddingSizeSmall),
//             //     child: Stack(clipBehavior: Clip.none, children: [
//             //       Column(
//             //           crossAxisAlignment: isPopularItem
//             //               ? CrossAxisAlignment.center
//             //               : CrossAxisAlignment.start,
//             //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //           children: [
//             //             Text(
//             //               item.storeName ?? '',
//             //               style: robotoBold,
//             //               maxLines: 1,
//             //               overflow: TextOverflow.ellipsis,
//             //             ),
//             //             Text(item.dtime ?? "",
//             //                 style: robotoRegular.copyWith(
//             //                     color: Theme.of(context)
//             //                         .disabledColor)) // (isFood || isShop) ? Flexible(
//             //             //   child: Text(
//             //             //     item.name ?? '',
//             //             //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
//             //             //   ),
//             //             // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//             //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
//             //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             //             //
//             //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
//             //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             //             //
//             //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
//             //             // ]),
//             //             //
//             //             // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//             //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
//             //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             //
//             //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
//             //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             //             //
//             //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
//             //             //
//             //             // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
//             //             //   '(${ item.unitType ?? ''})',
//             //             //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
//             //             // ) : const SizedBox(),
//             //
//             //             // discount != null && discount > 0  ? Text(
//             //             //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
//             //             //   style: robotoMedium.copyWith(
//             //             //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
//             //             //     decoration: TextDecoration.lineThrough,
//             //             //   ), textDirection: TextDirection.ltr,
//             //             // ) : const SizedBox(),
//             //             // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
//             //
//             //             //   Text(
//             //             //     PriceConverter.convertPrice(
//             //             //       Get.find<ItemController>().getStartingPrice(item), discount: discount,
//             //             //       discountType: discountType,
//             //             //     ),
//             //             //     textDirection: TextDirection.ltr, style: robotoMedium,
//             //             //   ),
//             //             //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//             //           ]),
//             //       // isShop ? Positioned(
//             //       //   bottom: 0, right: 0,
//             //       //   child: CartCountView(
//             //       //     item: item,
//             //       //     child: Container(
//             //       //       height: 35, width: 38,
//             //       //       decoration: BoxDecoration(
//             //       //         color: Theme.of(context).primaryColor,
//             //       //         borderRadius: const BorderRadius.only(
//             //       //           topLeft: Radius.circular(Dimensions.radiusLarge),
//             //       //           bottomRight: Radius.circular(Dimensions.radiusLarge),
//             //       //         ),
//             //       //       ),
//             //       //       child: Icon(isPopularItemCart ? Icons.add_shopping_cart : Icons.add, color: Theme.of(context).cardColor, size: 20),
//             //       //     ),
//             //       //   ),
//             //       // ) : const SizedBox(),
//             //     ]),
//             //   ),
//             // ),
//           ]),
//         ),
//       ),
//       // isAvailable
//       //     ? const SizedBox()
//       //     : Positioned(
//       //     right: ltr ? 0 : null,
//       //     left: ltr ? null : 0,
//       //     child: CornerBanner(
//       //       bannerPosition: ltr
//       //           ? CornerBannerPosition.topRight
//       //           : CornerBannerPosition.topLeft,
//       //       bannerColor: Theme.of(context).colorScheme.error,
//       //       elevation: 5,
//       //       shadowColor: Colors.transparent,
//       //       child: _buildBannerContent(),
//       //     )),
//     ]);
//   }
// }

class StoreCardWithDistance3 extends StatefulWidget {
  final Store store;
  final bool fromAllStore;
  final bool? isNewStore;
  final bool? fromTopOffers;
  final bool recommendedStore;
  const StoreCardWithDistance3({super.key, required this.store, this.fromAllStore = false, this.isNewStore = false, this.fromTopOffers = false, this.recommendedStore = false});

  @override
  State<StoreCardWithDistance3> createState() => _StoreCardWithDistance3State();
}

class _StoreCardWithDistance3State extends State<StoreCardWithDistance3> {
  late  CouponController couponController = Get.find<CouponController>();

  @override
  void initState() {
    super.initState();

    couponController = Get.put(CouponController(couponServiceInterface: Get.find())); // ensures it's initialized
    couponController.getCouponRestList(widget.store.id);
  }

  @override
  Widget build(BuildContext context) {
    // final CouponController couponController = Get.find<CouponController>();
    // Get.find<CouponController>().getCouponRestList(store!.id);
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = (widget.store.distance!/1000);
    double discount = widget.store.discount?.discount ?? 0;
    String discountType = widget.store.discount?.discountType ?? '';
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return Stack(children: [
      Container(
        width: 280,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
        child: CustomInkWell(
          onTap: () {
            if(Get.find<SplashController>().moduleList != null) {
              for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                if(module.id == widget.store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: widget.store.id, page: 'store'),
              arguments: StoreScreen(store: widget.store, fromModule: false),
            );
          },
          // radius: Dimensions.radiusLarge,
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 5,
              child: Stack(children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: Dimensions.paddingSizeExtraSmall
                      ,
                      left: Dimensions.paddingSizeExtraSmall,
                      right: Dimensions.paddingSizeExtraSmall
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusLarge),
                          topRight: Radius.circular(Dimensions.radiusLarge),
                          // bottomLeft: Radius.circular(Dimensions.radiusLarge),
                          // bottomRight:
                          //     Radius.circular(Dimensions.radiusLarge),
                        ),
                        child: CustomImage(
                          placeholder: Images.placeholder,
                          image: '${widget.store.logoFullUrl}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 5,
                        right: 5, // Ensuring spacing on both sides
                        child: Row(
                          crossAxisAlignment
                              : CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Pushes columns to opposite sides
                          children: [
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment
                            //       .start, // Aligns text to the left
                            //   children: [
                            //     Text(
                            //       discount! > 0
                            //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 18
                            //                 : 18),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //     Text(
                            //       discount > 0
                            //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount
                            //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 15
                            //                 : 15),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //   ],
                            // ),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment
                            //       .start, // Aligns text to the left
                            //   children: [
                            //     Text(
                            //       discount! > 0
                            //           ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 18
                            //                 : 18),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //     Text(
                            //       discount > 0
                            //           ? 'UPTO ${(discountType == 'percent') ? currencySymbol : ""}${discountType == 'percent' ? ((item.price! * discount) / 100).toStringAsFixed(0) // Calculates percentage discount amount
                            //               : '$discount${isRightSide ? currencySymbol : ''}'}' // Adds the currency symbol based on isRightSide
                            //           : 'free_delivery'.tr,
                            //       style: robotoBold.copyWith(
                            //         color: Theme.of(context).cardColor,
                            //         fontSize:
                            //             (ResponsiveHelper.isMobile(context)
                            //                 ? 15
                            //                 : 15),
                            //       ),
                            //       textAlign: TextAlign.start,
                            //     ),
                            //   ],
                            // ),

                            Column(
                                crossAxisAlignment
                                    : CrossAxisAlignment.end,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [  Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5) ,
                                      color: Colors.green.shade900
                                    // gradient: LinearGradient(
                                    //   begin: Alignment.centerLeft,
                                    //   end: Alignment.centerRight,
                                    //   colors: [
                                    //     Theme.of(context).primaryColor.withOpacity(1.0), // darkest
                                    //     Theme.of(context).primaryColor.withOpacity(0.6), // lighter
                                    //     Theme.of(context).primaryColor.withOpacity(0.0), // transparent
                                    //   ],
                                    // ),

                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(

                                        children: [
                                          Icon(Icons.star,
                                              size: 14,
                                              color:Theme.of(context).cardColor),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),
                                          Text(
                                              widget.store.avgRating!
                                                  .toStringAsFixed(1),
                                              style: robotoMedium.copyWith(
                                                  color: Theme.of(context).cardColor,
                                                  fontSize: Dimensions
                                                      .fontSizeSmall)),
                                          // const SizedBox(
                                          //     width: Dimensions
                                          //         .paddingSizeExtraSmall),
                                          // Text("(${store.ratingCount})",
                                          //     style: robotoMedium.copyWith(
                                          //         fontSize: Dimensions
                                          //             .fontSizeSmall,
                                          //         color: Theme.of(context).cardColor)),
                                        ]),
                                  ),
                                ),
                                  // (isFood || isShop) ? Flexible(
                                  //   child: Text(
                                  //     item.name ?? '',
                                  //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  //   ),
                                  // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                                  //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  // ]),
                                  //
                                  // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                                  //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                  //
                                  // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
                                  //   '(${ item.unitType ?? ''})',
                                  //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                  // ) : const SizedBox(),

                                  // discount != null && discount > 0  ? Text(
                                  //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                                  //   style: robotoMedium.copyWith(
                                  //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                  //     decoration: TextDecoration.lineThrough,
                                  //   ), textDirection: TextDirection.ltr,
                                  // ) : const SizedBox(),
                                  // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                                  //   Text(
                                  //     PriceConverter.convertPrice(
                                  //       Get.find<ItemController>().getStartingPrice(item), discount: discount,
                                  //       discountType: discountType,
                                  //     ),
                                  //     textDirection: TextDirection.ltr, style: robotoMedium,
                                  //   ),
                                  //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                ]),
                          ],
                        ),
                      ),

          widget.store.freetag != null
              ? Positioned(
            top: 5,
            left: 5,
            right: 5,
            child: Builder(
              builder: (context) {
                // 🎨 Vibrant color list
                final List<Color> vibrantColors = [
                  const Color(0xFFEF5350), // Vibrant Red
                  const Color(0xFF42A5F5), // Bright Blue
                  const Color(0xFFFFC107), // Vibrant Amber
                ];

                // 🌀 Pick a random color
                final Color bgColor =
                vibrantColors[Random().nextInt(vibrantColors.length)];

                // 🧠 Auto text color (white for dark bg, black for light bg)
                final Brightness brightness =
                ThemeData.estimateBrightnessForColor(bgColor);
                final Color textColor =
                brightness == Brightness.dark ? Colors.white : Colors.black;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          widget.store.freetag!.toUpperCase(),
                          style: robotoBlack.copyWith(
                            color: textColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ) :SizedBox(),
                    ],
                  ),
                ),
                AddFavouriteView3(
                  storeId: widget.store.id, item: null,
                ),


                // isShop ? const SizedBox() : Positioned(
                //   bottom: 10, right: 20,
                //   child: CartCountView(
                //     item: item,
                //   ),
                // ),
                // Get.find<ItemController>().isAvailable(item)
                //     ? const SizedBox()
                //     : NotAvailableWidget(
                //         radius: Dimensions.radiusLarge,
                //         isAllSideRound: isPopularItem),
              ]),
            ),
            SizedBox(height: 6,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.store.name?.capitalizeFirst ?? '',
                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                        style:  robotoBold.copyWith(
                          color:
                          Theme.of(context).cardColor,
                          fontSize:
                          (ResponsiveHelper.isMobile(
                              context)
                              ? 15
                              : 15),
                        ),),
                      // Text(
                      //   PriceConverter.convertPrice(
                      //     item!
                      //         .foodVariations!
                      //         .first
                      //         .variationValues!
                      //         .first
                      //         .optionPrice,
                      //     discount: discount,
                      //     discountType: discountType,
                      //   ),
                      //   style: robotoBold.copyWith(
                      //     color:
                      //     Theme.of(context).cardColor,
                      //     fontSize:
                      //     (ResponsiveHelper.isMobile(
                      //         context)
                      //         ? 15
                      //         : 15),
                      //   ),
                      //   textAlign: TextAlign.start,
                      // ),
                      SizedBox(
                          width: discount > 0
                              ? Dimensions
                              .paddingSizeExtraSmall
                              : 0),
                      // Text(
                      //   widget.store.address?.capitalizeFirst  ?? '',
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style:  robotoRegular.copyWith(
                      //     color:
                      //     Theme.of(context).cardColor,
                      //     fontSize:
                      //     (ResponsiveHelper.isMobile(
                      //         context)
                      //         ? 10
                      //         : 15),
                      //   ),),

                      Row(
                        children: [
                          Icon(CupertinoIcons.clock ,  color:
                      Theme.of(context).cardColor,size: Dimensions.fontSizeExtraSmall,),
                          Text(widget.store.deliveryTime ?? "",
                              style: robotoRegular.copyWith(
                                color:
                                Theme.of(context).cardColor,
                                fontSize: Dimensions.fontSizeSmall,
                              )),
                        ],
                      ),
                      SizedBox(height: 3,),
                      Row(
                        children: List.generate(5, (index) {
                          double rating = widget.store.avgRating ?? 0.0; // Fallback if null
                          bool isFilled = index < rating.floor(); // Fill full stars
                          bool isHalf = rating - index > 0 && rating - index < 1; // For half stars (optional)

                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? Theme.of(context).primaryColor
                                  : Colors.black, // Primary color for filled, black for empty
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isHalf
                                    ? CupertinoIcons.star_lefthalf_fill // optional half-star support
                                    : CupertinoIcons.star_fill,
                                color: Theme.of(context).cardColor,
                                size: 15,
                              ),
                            ),
                          );
                        }),
                      ),

SizedBox(height: 10,),
                      widget.store.discount != null
                          ? Row(
                        children: [
                          ClipRRect(
                            borderRadius:BorderRadius.all(Radius.circular(5)),
                            child: Container(

                              decoration:BoxDecoration(
                                color : Colors.red,
                              ),
                              // margin: const EdgeInsets.only(right: 6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  "Offers",
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(
                            child: AutoScrollText(
                              '${widget.store.discount!.discountType == 'percent'
                                  ? '${widget.store.discount!.discount}%'
                                  :  'Save ${PriceConverter.convertPrice(widget.store.discount!.discount)}'}  on orders above ${PriceConverter.convertPrice(widget.store.discount!.minPurchase)} (Max: ${PriceConverter.convertPrice(widget.store.discount!.maxDiscount)})',    style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color:
                              Theme.of(context).cardColor,
                            ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                          : (couponController.couponRestList != null &&
                          couponController.couponRestList!.isNotEmpty)
                          ? Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipRRect(
                              borderRadius:BorderRadius.all(Radius.circular(5)),
                              child: Container(

                                decoration:BoxDecoration(
                                  color : Colors.green,
                                ),
                                // margin: const EdgeInsets.only(right: 6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    "Offers",
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(
                            child: AutoScrollText(
                              // 👇 Build text dynamically from the first coupon (you can customize)
                              '${couponController.couponRestList![0].couponType == 'free_delivery'
                                  ? 'Free Delivery Available!'
                                  : couponController.couponRestList![0].discountType == 'percent'
                                  ? '${couponController.couponRestList![0].discount?.toStringAsFixed(0)}% off up to ₹${couponController.couponRestList![0].maxDiscount?.toStringAsFixed(0)}'
                                  : 'Flat ₹${couponController.couponRestList![0].discount?.toStringAsFixed(0)} off up to ₹${couponController.couponRestList![0].maxDiscount?.toStringAsFixed(0)}'} ',
                              // '| Use Code: ${couponController.couponRestList![0].code ?? 'N/A'} '
                              // '| Valid Till: ${couponController.couponRestList![0].expireDate != null
                              // ? DateFormat('dd-MMM-yyyy').format(DateTime.parse(couponController.couponRestList![0].expireDate!))
                              // : 'N/A'}',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color:
                                Theme.of(context).cardColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                          : const SizedBox.shrink(),
// 👈 returns nothing if discount is null

                    ])

              ],
            ),

            // Expanded(
            //   flex: 2,
            //   child: Padding(
            //     padding: EdgeInsets.only(
            //         left: Dimensions.paddingSizeSmall,
            //         right: isShop ? 0 : Dimensions.paddingSizeSmall,
            //         top: Dimensions.paddingSizeSmall,
            //         bottom: isShop ? 0 : Dimensions.paddingSizeSmall),
            //     child: Stack(clipBehavior: Clip.none, children: [
            //       Column(
            //           crossAxisAlignment: isPopularItem
            //               ? CrossAxisAlignment.center
            //               : CrossAxisAlignment.start,
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text(
            //               item.storeName ?? '',
            //               style: robotoBold,
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //             Text(item.dtime ?? "",
            //                 style: robotoRegular.copyWith(
            //                     color: Theme.of(context)
            //                         .disabledColor)) // (isFood || isShop) ? Flexible(
            //             //   child: Text(
            //             //     item.name ?? '',
            //             //     style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis,
            //             //   ),
            //             // ) : Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
            //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //             //
            //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //             //
            //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            //             // ]),
            //             //
            //             // (isFood || isShop) ? Row(mainAxisAlignment: isPopularItem ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
            //             //   Icon(Icons.star, size: 14, color: Theme.of(context).primaryColor),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //
            //             //   Text(item.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
            //             //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //             //
            //             //   Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            //             //
            //             // ]) : (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
            //             //   '(${ item.unitType ?? ''})',
            //             //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
            //             // ) : const SizedBox(),
            //
            //             // discount != null && discount > 0  ? Text(
            //             //   PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
            //             //   style: robotoMedium.copyWith(
            //             //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
            //             //     decoration: TextDecoration.lineThrough,
            //             //   ), textDirection: TextDirection.ltr,
            //             // ) : const SizedBox(),
            //             // // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
            //
            //             //   Text(
            //             //     PriceConverter.convertPrice(
            //             //       Get.find<ItemController>().getStartingPrice(item), discount: discount,
            //             //       discountType: discountType,
            //             //     ),
            //             //     textDirection: TextDirection.ltr, style: robotoMedium,
            //             //   ),
            //             //   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            //           ]),
            //       // isShop ? Positioned(
            //       //   bottom: 0, right: 0,
            //       //   child: CartCountView(
            //       //     item: item,
            //       //     child: Container(
            //       //       height: 35, width: 38,
            //       //       decoration: BoxDecoration(
            //       //         color: Theme.of(context).primaryColor,
            //       //         borderRadius: const BorderRadius.only(
            //       //           topLeft: Radius.circular(Dimensions.radiusLarge),
            //       //           bottomRight: Radius.circular(Dimensions.radiusLarge),
            //       //         ),
            //       //       ),
            //       //       child: Icon(isPopularItemCart ? Icons.add_shopping_cart : Icons.add, color: Theme.of(context).cardColor, size: 20),
            //       //     ),
            //       //   ),
            //       // ) : const SizedBox(),
            //     ]),
            //   ),
            // ),
          ]),
        ),
      ),
      // isAvailable
      //     ? const SizedBox()
      //     : Positioned(
      //     right: ltr ? 0 : null,
      //     left: ltr ? null : 0,
      //     child: CornerBanner(
      //       bannerPosition: ltr
      //           ? CornerBannerPosition.topRight
      //           : CornerBannerPosition.topLeft,
      //       bannerColor: Theme.of(context).colorScheme.error,
      //       elevation: 5,
      //       shadowColor: Colors.transparent,
      //       child: _buildBannerContent(),
      //     )),
    ]);
  }
}

class StoreCardWithDistanceFood extends StatelessWidget {
  final List<Schedules>? schedules;
  final Store store;
  final bool fromAllStore;
  final bool? isNewStore;
  final bool? fastdelivery;

  const StoreCardWithDistanceFood(
      {super.key,
        required this.store,
        this.fromAllStore = false,
        this.isNewStore = false,
        this.fastdelivery = false,
        this.schedules});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;

    var size = MediaQuery.of(context).size;
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
    Get.find<SplashController>().configModel!.currencySymbol!;
    String? discounttype = Get.find<StoreController>().getDiscountType(store);
    bool isPharmacy = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.pharmacy;
    double distance = Get.find<LocationController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      width:!fastdelivery!? null : 400,
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap:  Get.find<StoreController>().isOpenNow(store) ?() {
          if (Get.find<SplashController>().moduleList != null) {
            for (ModuleModel module in Get.find<SplashController>().moduleList!) {
              if (module.id == store.moduleId) {
                Get.find<SplashController>().setModule(module);
                break;
              }
            }
          }
          Get.toNamed(
            RouteHelper.getStoreRoute(id: store.id, page: 'store'),
            arguments: StoreScreen(store: store, fromModule: false),
          );
        } :null,
        child: Row(children: [
          Stack(
            children: [
              Container(
                width: 138,
                height: 175,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Stack(clipBehavior: Clip.none, children: [

                    ColorFiltered(
                      colorFilter: Get.find<StoreController>().isOpenNow(store)
                          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                          : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      child: CustomImage(
                        image: '${store.logoFullUrl}',
                        fit: BoxFit.cover,
                        height: 175,
                        width: 138,
                      ),
                    ),

                    // DiscountTag(
                    //   discount: Get.find<StoreController>().getDiscount(store),
                    //   discountType:
                    //   Get.find<StoreController>().getDiscountType(store),
                    //   // freeDelivery: store.freeDelivery,
                    // ),
                    Get.find<StoreController>().isOpenNow(store)
                        ? const SizedBox()
                        : NotAvailableWidget(isStore: true, store: store, radius: Dimensions.radiusDefault),
                    Positioned(
                      top: 15,
                      left: Get.find<LocalizationController>().isLtr ? null : 15,
                      right: Get.find<LocalizationController>().isLtr ? 15 : null,
                      child: GetBuilder<FavouriteController>(
                          builder: (wishController) {
                            bool isWished =
                            wishController.wishStoreIdList.contains(store.id);
                            return InkWell(
                              onTap: () {
                                if (Get.find<AuthController>().isLoggedIn()) {
                                  isWished
                                      ? wishController.removeFromFavouriteList(
                                      store.id, true)
                                      : wishController.addToFavouriteList(
                                      null, store.id, true);
                                } else {
                                  showCustomSnackBar('you_are_not_logged_in'.tr);
                                }
                              },
                              child: Icon(
                                isWished ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                grade: 500,
                                color: Theme.of(context).cardColor,
                              ),
                            );
                          }),
                    ),
                    isNewStore! ? const NewTag() : const SizedBox(),
                  ]),
                ),
              ),
              // Get.find<StoreController>().isOpenNow(store)?
              // Positioned(
              //   left: 0,
              //   top: 15,
              //   child: Builder(
              //     builder: (context) {
              //       double discount = store.discount?.discount ?? 0;
              //       String discountType = store.discount?.discountType ?? '';
              //       // Prepare all parts
              //       List<String> tagParts = [];
              //
              //       if (discount > 0) {
              //         String discountText =
              //             '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}';
              //         tagParts.add(discountText);
              //       }
              //
              //       if (store.freeDelivery!) {
              //         tagParts.add('free_delivery'.tr);
              //       }
              //
              //       if (!(discount > 0 || store.freeDelivery!) && store.freetag != null  ) {
              //         tagParts.add(store.freetag!);
              //       }
              //
              //       // If nothing to show, return empty container
              //       if (tagParts.isEmpty) return const SizedBox();
              //
              //       return Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: Dimensions.paddingSizeSmall*0.8, vertical: 4),
              //         decoration: BoxDecoration(
              //           borderRadius: const BorderRadius.only(
              //             topRight: Radius.circular(Dimensions.radiusDefault),
              //             bottomRight: Radius.circular(Dimensions.radiusDefault),
              //             topLeft: Radius.circular(Dimensions.radiusDefault),
              //             bottomLeft: Radius.circular(Dimensions.radiusDefault),
              //           ),
              //           gradient: const LinearGradient(
              //             colors: [Colors.orange, Colors.pink],
              //             begin: Alignment.centerLeft,
              //             end: Alignment.centerRight,
              //           ),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.2),
              //               offset: const Offset(2, 2),
              //               blurRadius: 4,
              //             ),
              //           ],
              //         ),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisSize: MainAxisSize.min,
              //           children: tagParts.map((text) {
              //             int index = tagParts.indexOf(text);
              //             return Padding(
              //               padding: const EdgeInsets.only(bottom: 2),
              //               child: Text(
              //                 index == 0 ? text : '+ $text', // add + from second line
              //                 style: robotoMedium.copyWith(
              //                   color: Colors.white,
              //                   fontSize: Dimensions.fontSizeSmall*0.9,
              //                 ),
              //               ),
              //             );
              //           }).toList(),
              //         ),
              //       );
              //     },
              //   ),
              // ):SizedBox.shrink()
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(store.name!.capitalizeFirst ?? '',
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge * 1.2,
                            color: Get.find<StoreController>().isOpenNow(store)?null:Colors.grey.shade800,
                            fontWeight: FontWeight.w800)),
                    Row(
                      children: [
                         Icon(
                          Icons.stars,
                          color: Get.find<StoreController>().isOpenNow(store)?Color.fromRGBO(0, 100, 0, 1):Colors.grey.shade800,
                          size: 25,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${(store.avgRating ?? 0.0).toStringAsFixed(1)}(${store.ratingCount})",
                          style: robotoBold.copyWith(
                              color: Get.find<StoreController>().isOpenNow(store)?null:Colors.grey.shade800,
                              fontSize: Dimensions.fontSizeDefault),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        !fastdelivery!?Icon(
                          Icons.circle_rounded,
                          size: 10,
                        ):SizedBox.shrink(),
                         SizedBox(
                          width:    !fastdelivery! ?5 :0,
                        ),
                         !fastdelivery!?Text(store.deliveryTime ?? "",
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                )): SizedBox.shrink()
                      ],
                    ),
                    Row(
                      children: [
                         Icon(
                          Icons.restaurant_menu,
                          color: Get.find<StoreController>().isOpenNow(store)?Color.fromRGBO(0, 100, 0, 1):Colors.grey.shade800,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: AutoScrollText(
                            store.address ?? '',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Get.find<StoreController>().isOpenNow(store)?null:Colors.grey.shade800,
                            ),
                            velocity:
                            const Velocity(pixelsPerSecond: Offset(20, 0)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(Images.distanceLine,
                            color: Get.find<StoreController>().isOpenNow(store)?Color.fromRGBO(0, 100, 0, 1):Colors.grey.shade800,
                            height: 25, width: 25),
                        Text(
                          "Distance",
                          style: robotoRegular.copyWith(
                              color: Get.find<StoreController>().isOpenNow(store)?null:Colors.grey.shade800,
                              fontSize: Dimensions.fontSizeDefault),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                         Icon(
                          color: Get.find<StoreController>().isOpenNow(store)?null:Colors.grey.shade800,
                          Icons.circle_rounded,
                          size: 5,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'kms'.tr}',
                          style: robotoRegular.copyWith(
                              color: Get.find<StoreController>().isOpenNow(store)?null:Colors.grey.shade800,
                              fontSize: Dimensions.fontSizeDefault),
                        ),
                      ],
                    ),
                    (store.freeDelivery! || store.freetag != null)
                        ? Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                         Get.find<StoreController>().isOpenNow(store)?
                         fastdelivery!
                         ?Theme.of(context).primaryColor.withAlpha(140):Theme.of(context).primaryColor.withAlpha(140)
                             :Colors.grey.shade800,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                width: 45,
                                child:
                                // fastdelivery!
                                //     ?
                                HexagonalContainer(
                                  size: 45,
                                  color: Get.find<StoreController>().isOpenNow(store)
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade800,
                                )
                                    // : Padding(
                                    //   padding: const EdgeInsets.all(4.0),
                                    //   child: Image.asset(
                                    //                                     Images.discountOfferIcon,
                                    //                                     width: 35,
                                    //     // color: Get.find<StoreController>().isOpenNow(store)?Colors.green:Colors.grey.shade800,
                                    //     height: 35,
                                    //                                     fit: BoxFit.contain,
                                    //                                   ),
                                    // ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          if (fastdelivery!)
                            Text(
                              store.deliveryTime??"",
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                color: Get.find<StoreController>().isOpenNow(store)?Theme.of(context).primaryColor.withOpacity(0.5):Colors.grey.shade800,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.w800,
                              ),
                          ) else
                            Text(
                              store.freeDelivery!
                                  ? 'FREE DELIVERY'
                                  : store.freetag!.toUpperCase(),
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                color: Get.find<StoreController>().isOpenNow(store)?Theme.of(context).primaryColor:Colors.grey.shade800,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.w800,
                              ),
                          ),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),

                    // Container(
                    //     height: 40,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       borderRadius: const BorderRadius.only(
                    //           topLeft: Radius.circular(40),
                    //           bottomLeft: Radius.circular(40)),
                    //       gradient: LinearGradient(
                    //         begin: Alignment.centerLeft,
                    //         end: Alignment.centerRight,
                    //         colors: [
                    //           Theme.of(context).primaryColor.withOpacity(0.5),
                    //           Colors.white
                    //         ],
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Stack(
                    //           children: [
                    //             Container(
                    //               width: 45,
                    //               child: HexagonalContainer(
                    //                 size: 45,
                    //                 color: Theme.of(context).primaryColor,
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //         const SizedBox(
                    //           width: 5,
                    //         ),
                    //         Text('FREE DELIVERY',
                    //             maxLines: 1,
                    //             textAlign: TextAlign.start,
                    //             overflow: TextOverflow.ellipsis,
                    //             style: robotoRegular.copyWith(
                    //                 color: Theme.of(context).primaryColor,
                    //                 fontSize: Dimensions.fontSizeDefault,
                    //                 fontWeight: FontWeight.w800)),
                    //       ],
                    //     )),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}
class HexagonalContainer extends StatelessWidget {
  final double size;
  final Color color;

  const HexagonalContainer({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: HexagonalPainter(color: color),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(size / 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            // Adjust border radius as needed
            child: Image.asset(
              Images.scooter,
              fit: BoxFit.fill,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class HexagonalPainter extends CustomPainter {
  final Color color;

  HexagonalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    final double halfWidth = size.width / 2;
    final double halfHeight = size.height / 2;
    final double radius = halfWidth;

    final Path path = Path();
    final double angle = pi / 3; // 60 degrees in radians
    final double x0 = halfWidth + radius * cos(0);
    final double y0 = halfHeight + radius * sin(0);
    path.moveTo(x0, y0);

    for (int i = 1; i <= 6; i++) {
      final double x = halfWidth + radius * cos(angle * i);
      final double y = halfHeight + radius * sin(angle * i);
      path.lineTo(x, y);
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexagonalPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}


class DiscountTag1 extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? minimum;
  final double? fontSize;
  final bool inLeft;
  final bool? freeDelivery;
  final bool? isFloating;
  final bool? fromTaxi;
  const DiscountTag1({super.key,
    required this.discount, required this.discountType, this.fromTop = 5, this.fontSize, this.freeDelivery = false,
    this.inLeft = true, this.isFloating = true, this.fromTaxi = false,  this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return (discount! > 0 || freeDelivery!) ? Positioned(
      bottom: fromTop, left: inLeft ? isFloating! ? Dimensions.paddingSizeSmall : 0 : null, right: inLeft ? null : 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              discount! > 0 ?
              '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}'
                  '${discount! % 1 == 0 ? discount!.toInt() : discount}'
                  '${discountType == 'percent' ? '%' : (isRightSide ? currencySymbol : '')} '
                  '${'off'.tr}'
                  : 'free_delivery'.tr,
              style: robotoBlack.copyWith(
                color:
                Theme.of(context).cardColor,
                height: 1.0,
                fontSize: fontSize ??(ResponsiveHelper.isMobile(context) ? 8 : 12),),
              textAlign: TextAlign.center,
            ),
            minimum != null?Text("ABOVE ₹${minimum!.toInt()}",style: robotoBlack.copyWith(
              color:
              Theme.of(context).cardColor,
              fontSize: fontSize!*0.5 ??(ResponsiveHelper.isMobile(context) ? 8 : 12),),):SizedBox.shrink(),
          ],
        ),
      ),
    ) : const SizedBox();
  }
}