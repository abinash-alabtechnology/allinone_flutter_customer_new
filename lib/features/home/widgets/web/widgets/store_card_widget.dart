import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/common/models/module_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/hover/on_hover.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';

import '../../../../../common/widgets/custom_snackbar.dart';
import '../../../../../helper/auth_helper.dart';
import '../../../../../util/app_constants.dart';
import '../../../../favourite/controllers/favourite_controller.dart';
import '../../../../location/controllers/location_controller.dart';
import '../../module_view.dart';


class StoreCardWidget extends StatelessWidget {
  final Store? store;
  const StoreCardWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    double? discount = store!.discount != null ? store!.discount!.discount : 0;
    String? discountType =
    store!.discount != null ? store!.discount!.discountType : 'percent';
    bool isAvailable = store!.open == 1 && store!.active!;
    Color disabledColor = Theme.of(context).shadowColor;
    double distance = Get.find<LocationController>().getRestaurantDistance(
      LatLng(double.parse(store!.latitude!), double.parse(store!.longitude!)),
    );

    return OnHover(
      isItem: true,
      child: Stack(
        children: [
          CustomInkWell(
            onTap:isAvailable? () async {
              debugPrint("\u001B[33m taped :\u001B[35m isTapedstore");
              if (store != null) {
                if (Get.find<SplashController>().moduleList != null) {
                  for (ModuleModel module
                  in Get.find<SplashController>().moduleList!) {
                    if (module.id == store!.moduleId) {
                      Get.find<SplashController>().setModule(module);
                      break;
                    }
                  }
                }
                Get.toNamed(
                  RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
                  arguments: StoreScreen(store: store, fromModule: false),
                );
              }

            }:(){
              showCustomSnackBar("store_is_closed".tr,isError: true,);
            },
            child:
            Stack(
              children: [
                /// Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomImage(
                    image: store!.coverPhotoFullUrl ?? "",
                    height: 278,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                /// Bottom gradient overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Favorite Button
                Positioned(
                  top: 12,
                  left: 12,
                  child: GetBuilder<FavouriteController>(
                      builder: (fc) {
                        final isWished = fc.wishStoreIdList
                            .contains(store!.id);

                        return InkWell(
                          onTap: () {
                            if (AuthHelper.isLoggedIn()) {
                              isWished
                                  ? fc.removeFromFavouriteList(
                                  store!.id, true)
                                  : fc.addToFavouriteList(
                                  null, store!.id, true);
                            } else {
                              showCustomSnackBar(
                                  'you_are_not_logged_in'.tr);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(
                                Dimensions
                                    .paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius:
                              BorderRadius.circular(25),
                            ),
                            child: Icon(
                              isWished
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color:
                              Theme.of(context).cardColor,
                            ),
                          ),
                        );
                      }),
                ),

                /// Bottom store info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          store!.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold),
                        ),
                        const SizedBox(height: 5),

                        /// Rating + Delivery
                        Row(
                          children: [
                            Icon(
                              FontAwesome.star_solid,
                              color: Theme.of(context)
                                  .cardColor,
                              size: 12,
                            ),
                            const SizedBox(width: 5),

                            store!.avgRating != null
                                ? Text(
                              store!.avgRating
                                  ?.toStringAsFixed(
                                  1) ??
                                  "0.0",
                              style:
                              GoogleFonts.inter(
                                  color: Colors
                                      .white,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight
                                      .bold),
                            )
                                : const SizedBox.shrink(),
                            const SizedBox(width: 5),

                            store!.ratingCount != null
                                ? Text(
                              "(${store!.ratingCount?.toStringAsFixed(0) ?? 0})",
                              style:
                              GoogleFonts.inter(
                                  color: Colors
                                      .white,
                                  fontSize: 12),
                            )
                                : const SizedBox.shrink(),

                            const SizedBox(width: 10),

                            Icon(
                              Icons.circle,
                              color: Theme.of(context)
                                  .cardColor,
                              size: 5,
                            ),
                            const SizedBox(width: 10),

                            /// Delivery Time tag
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .cardColor,
                                borderRadius:
                                BorderRadius.circular(
                                    5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 6.0,
                                    vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt,
                                      color: AppConstants
                                          .backgroundColor,
                                      size: 12,
                                    ),
                                    const SizedBox(
                                        width: 5),
                                    Text(
                                      store!.deliveryTime ??
                                          "",
                                      style: GoogleFonts
                                          .inter(
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 5),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 5),

                        Text(
                          store!.address ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Closed Banner
               isAvailable
                    ? const SizedBox()
                    : const Positioned(
                  top: 10,
                  right: 10,
                  child: PendulumImage(
                    asset: Images.closed,
                    angle: 20,
                    size: 80,
                  ),
                )
              ],
            )

            // Container(
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //       color: Theme.of(context).cardColor,
            //       borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            //       border: Border.all(
            //           color: Theme.of(context).disabledColor.withOpacity(0.1)),
            //       boxShadow: ResponsiveHelper.isDesktop(context)
            //           ? []
            //           : [
            //         BoxShadow(
            //             color: Colors.black.withOpacity(0.1),
            //             blurRadius: 10)
            //       ]),
            //   padding: const EdgeInsets.all(1),
            //   child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Stack(clipBehavior: Clip.none, children: [
            //           ClipRRect(
            //             borderRadius: const BorderRadius.vertical(
            //                 top: Radius.circular(Dimensions.radiusDefault)),
            //             child: CustomImage(
            //               image: '${store!.coverPhotoFullUrl}',
            //               height: 155,
            //               width: double.infinity,
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //           DiscountTag(
            //             discount: discount,
            //             discountType: discountType,
            //           ),
            //           isAvailable
            //               ? const SizedBox()
            //               : NotAvailableWidget(
            //               isStore: true,
            //               fontSize: Dimensions.fontSizeExtraSmall,
            //               isAllSideRound: false),
            //           Positioned(
            //             bottom: -15,
            //             left: Get.find<LocalizationController>().isLtr
            //                 ? null
            //                 : 10,
            //             right: Get.find<LocalizationController>().isLtr
            //                 ? 10
            //                 : null,
            //             child: Container(
            //               padding: const EdgeInsets.all(
            //                   Dimensions.paddingSizeExtraSmall),
            //               decoration: BoxDecoration(
            //                 color: Colors.green.shade500,
            //                 //Theme.of(context).cardColor,
            //                 borderRadius:
            //                 const BorderRadius.all(Radius.circular(20)),
            //                 boxShadow: const [
            //                   BoxShadow(
            //                       color: Colors.black12,
            //                       blurRadius: 5,
            //                       spreadRadius: 1)
            //                 ],
            //               ),
            //               child: Row(children: [
            //                 Icon(Icons.star,
            //                     size: 24, color: Theme.of(context).cardColor),
            //                 const SizedBox(
            //                     width: Dimensions.paddingSizeExtraSmall),
            //                 Text(
            //                   store!.avgRating!.toStringAsFixed(1),
            //                   style: robotoMedium.copyWith(
            //                       color: Theme.of(context).cardColor,
            //                       fontSize: Dimensions.fontSizeDefault * 1.3),
            //                 ),
            //                 const SizedBox(
            //                     width: Dimensions.paddingSizeExtraSmall),
            //                 Text(
            //                   '(${store!.ratingCount})',
            //                   style: robotoMedium.copyWith(
            //                       fontSize: Dimensions.fontSizeDefault * 1.1,
            //                       color: Theme.of(context).cardColor),
            //                 ),
            //               ]),
            //             ),
            //           ),
            //         ]),
            //         Expanded(
            //           child: Stack(
            //             children: [
            //               Positioned(
            //                 bottom: Dimensions.paddingSizeSmall * 1.2,
            //                 right: Dimensions.paddingSizeSmall,
            //                 child: GetBuilder<FavouriteController>(
            //                     builder: (favouriteController) {
            //                       bool isWished = favouriteController
            //                           .wishStoreIdList
            //                           .contains(store!.id);
            //                       return InkWell(
            //                         onTap: () {
            //                           if (AuthHelper.isLoggedIn()) {
            //                             isWished
            //                                 ? favouriteController
            //                                 .removeFromFavouriteList(
            //                                 store!.id, true)
            //                                 : favouriteController
            //                                 .addToFavouriteList(
            //                                 null, store?.id, true);
            //
            //                           } else {
            //                             showCustomSnackBar(
            //                                 'you_are_not_logged_in'.tr);
            //                           }
            //                         },
            //                         child: Icon(
            //                           isWished
            //                               ? Icons.favorite
            //                               : Icons.favorite_border,
            //                           size: 24,
            //                           color: isWished
            //                               ? Theme.of(context).primaryColor
            //                               : Theme.of(context).disabledColor,
            //                         ),
            //                       );
            //                     }),
            //               ),
            //               Container(
            //                 child: Padding(
            //                   padding: const EdgeInsets.symmetric(
            //                       horizontal: Dimensions.paddingSizeSmall),
            //                   child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       children: [
            //                         Container(
            //                             height: Dimensions.paddingSizeSmall),
            //                         SizedBox(
            //                           width: context.width * 0.68,
            //                           child: Text(
            //                             store!.name ?? '',
            //                             style: robotoBold.copyWith(
            //                                 fontSize:
            //                                 Dimensions.fontSizeOverLarge),
            //                             maxLines: 1,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                         ),
            //                         const SizedBox(
            //                             height:
            //                             Dimensions.paddingSizeExtraSmall),
            //                         Row(children: [
            //                           Icon(Icons.restaurant_menu,
            //                               size: 18,
            //                               color:
            //                               Theme.of(context).primaryColor),
            //                           const SizedBox(
            //                               width:
            //                               Dimensions.paddingSizeExtraSmall),
            //                           Flexible(
            //                             child: AutoScrollText(
            //                               store!.address ?? '',
            //                               style: robotoMedium.copyWith(
            //                                   fontSize:
            //                                   Dimensions.fontSizeSmall,
            //                                   color: disabledColor
            //                                       .withOpacity(0.5)),
            //                               velocity: const Velocity(
            //                                   pixelsPerSecond: Offset(20, 0)),
            //                             ),
            //                           ),
            //                         ]),
            //                         const SizedBox(
            //                             height:
            //                             Dimensions.paddingSizeExtraSmall),
            //                         Padding(
            //                           padding: EdgeInsets.only(right: 30),
            //                           child: Container(
            //                             child: FittedBox(
            //                               child: Row(children: [
            //                                 store!.freeDelivery!
            //                                     ? Row(children: [
            //                                   Image.asset(
            //                                       Images.deliveryIcon,
            //                                       height: 15,
            //                                       width: 15,
            //                                       color: disabledColor
            //                                           .withOpacity(0.5)),
            //                                   const SizedBox(
            //                                       width: Dimensions
            //                                           .paddingSizeExtraSmall),
            //                                   Text(
            //                                     'free_delivery'.tr,
            //                                     style: robotoMedium.copyWith(
            //                                         fontSize: Dimensions
            //                                             .fontSizeSmall,
            //                                         color: disabledColor
            //                                             .withOpacity(
            //                                             0.5)),
            //                                   ),
            //                                 ])
            //                                     : const SizedBox(),
            //                                 SizedBox(
            //                                     width: store!.freeDelivery!
            //                                         ? Dimensions
            //                                         .paddingSizeSmall
            //                                         : 0),
            //                                 Row(children: [
            //                                   Icon(Icons.timer,
            //                                       size: 18,
            //                                       color: Theme.of(context)
            //                                           .primaryColor),
            //                                   const SizedBox(
            //                                       width: Dimensions
            //                                           .paddingSizeExtraSmall),
            //                                   Text(
            //                                       store!.deliveryTime!
            //                                           .replaceAll(
            //                                           " min", " Mints"),
            //                                       style: robotoBold.copyWith(
            //                                           fontSize: Dimensions
            //                                               .fontSizeSmall,
            //                                           color: disabledColor
            //                                               .withOpacity(0.6))),
            //                                 ]),
            //                                 const SizedBox(
            //                                     width: Dimensions
            //                                         .paddingSizeSmall),
            //                                 Container(
            //                                     height: 10,
            //                                     width: 1,
            //                                     color: Colors.black),
            //                                 const SizedBox(
            //                                     width: Dimensions
            //                                         .paddingSizeSmall),
            //                                 Row(children: [
            //                                   Icon(Icons.delivery_dining,
            //                                       size: 18,
            //                                       color: Theme.of(context)
            //                                           .primaryColor),
            //                                   const SizedBox(
            //                                       width: Dimensions
            //                                           .paddingSizeExtraSmall),
            //                                   Text(
            //                                     '${distance.toStringAsFixed(1)} KM',
            //                                     style: robotoBold.copyWith(
            //                                         fontSize: Dimensions
            //                                             .fontSizeSmall,
            //                                         color: disabledColor
            //                                             .withOpacity(0.5)),
            //                                   ),
            //                                 ]),
            //                                 const SizedBox(
            //                                     width: Dimensions
            //                                         .paddingSizeSmall),
            //                                 Container(
            //                                     height: 10,
            //                                     width: 1,
            //                                     color: Colors.black),
            //                                 const SizedBox(
            //                                     width: Dimensions
            //                                         .paddingSizeSmall),
            //                                 Row(children: [
            //                                   Icon(Icons.money,
            //                                       size: 18,
            //                                       color: Theme.of(context)
            //                                           .primaryColor),
            //                                   const SizedBox(
            //                                       width: Dimensions
            //                                           .paddingSizeExtraSmall),
            //                                   Text(
            //                                     'Min Order : ${PriceConverter.convertPrice(store!.minimumOrder)}',
            //                                     style: robotoBold.copyWith(
            //                                         fontSize: Dimensions
            //                                             .fontSizeSmall,
            //                                         color: disabledColor
            //                                             .withOpacity(0.5)),
            //                                   ),
            //                                 ]),
            //                               ]),
            //                             ),
            //                           ),
            //                         ),
            //                         Container(
            //                             height: Dimensions.paddingSizeSmall),
            //                       ]),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ]),
            // ),
          ),
        ],
      ),
    );
  }
}





class StoreCardShimmer extends StatelessWidget {
  const StoreCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: 120, width: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
              color: Theme.of(context).shadowColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(height: 15, width: 200, color: Theme.of(context).shadowColor),
                const SizedBox(height: 5),

                Container(height: 10, width: 130, color: Theme.of(context).shadowColor),
                const SizedBox(height: 5),

                Row(
                  children: List.generate(5, (index) {
                    return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 15);
                  }),
                ),

              ]),
            ),
          ),

        ]),
      ),
    );
  }
}