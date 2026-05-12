import 'package:carousel_slider/carousel_slider.dart'
    show CarouselSlider, CarouselOptions;
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../helper/price_converter.dart';
import '../../../util/app_constants.dart';
import '../../coupon/controllers/coupon_controller.dart';

// class StoreDescriptionViewWidget extends StatefulWidget {
//   final Store? store;
//
//   const StoreDescriptionViewWidget({super.key, required this.store});
//
//   @override
//   State<StoreDescriptionViewWidget> createState() =>
//       _StoreDescriptionViewWidgetState();
// }
//
// class _StoreDescriptionViewWidgetState
//     extends State<StoreDescriptionViewWidget> {
//   final CouponController couponController = Get.find<CouponController>();
//   final ScrollController scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     initDataCall();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//     scrollController.dispose();
//   }
//
//   Future<void> initDataCall() async {
//     Get.find<CouponController>().getCouponRestList(widget.store!.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isAvailable = Get.find<StoreController>()
//         .isStoreOpenNow(widget.store!.active!, widget.store!.schedules);
//     Color? textColor =
//     ResponsiveHelper.isDesktop(context) ? Colors.white : null;
//     return Column(children: [
//       ResponsiveHelper.isDesktop(context)
//           ? Row(children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//           child: Stack(children: [
//             CustomImage(
//               image: '${widget.store!.logoFullUrl}',
//               height: ResponsiveHelper.isDesktop(context) ? 140 : 60,
//               width: ResponsiveHelper.isDesktop(context) ? 140 : 70,
//               fit: BoxFit.cover,
//             ),
//           ]),
//         ),
//         const SizedBox(width: Dimensions.paddingSizeDefault),
//         Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Expanded(
//                         child: Text(
//                           widget.store!.name!,
//                           style: robotoMedium.copyWith(
//                               fontSize: Dimensions.fontSizeLarge,
//                               color: textColor),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         )),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),
//                     GetBuilder<FavouriteController>(
//                         builder: (favouriteController) {
//                           bool isWished = favouriteController.wishStoreIdList
//                               .contains(widget.store!.id);
//                           return InkWell(
//                             onTap: () {
//                               if (AuthHelper.isLoggedIn()) {
//                                 isWished
//                                     ? favouriteController.removeFromFavouriteList(
//                                     widget.store!.id, true)
//                                     : favouriteController.addToFavouriteList(
//                                     null, widget.store?.id, true);
//                               } else {
//                                 showCustomSnackBar('you_are_not_logged_in'.tr);
//                               }
//                             },
//                             child: ResponsiveHelper.isDesktop(context)
//                                 ? Container(
//                               padding: const EdgeInsets.all(
//                                   Dimensions.paddingSizeExtraSmall),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(
//                                       Dimensions.radiusSmall),
//                                   border: Border.all(color: Colors.white)),
//                               child: Center(
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                         isWished
//                                             ? Icons.favorite
//                                             : Icons.favorite_border,
//                                         color: Colors.white,
//                                         size: 14),
//                                     const SizedBox(
//                                         width: Dimensions
//                                             .paddingSizeExtraSmall),
//                                     Text('wish_list'.tr,
//                                         style: robotoRegular.copyWith(
//                                             fontWeight: FontWeight.w200,
//                                             color: Colors.white,
//                                             fontSize:
//                                             Dimensions.fontSizeSmall)),
//                                   ],
//                                 ),
//                               ),
//                             )
//                                 : Icon(
//                               isWished
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: isWished
//                                   ? Theme.of(context).primaryColor
//                                   : Theme.of(context).disabledColor,
//                             ),
//                           );
//                         }),
//                   ]),
//                   const SizedBox(height: Dimensions.paddingSizeDefault),
//                   SizedBox(
//                       height: ResponsiveHelper.isDesktop(context)
//                           ? Dimensions.paddingSizeSmall
//                           : 0),
//                 ])),
//       ])
//           : const SizedBox(),
//       SizedBox(height: ResponsiveHelper.isDesktop(context) ? 30 : 0),
//       ResponsiveHelper.isDesktop(context)
//           ? IntrinsicHeight(
//         child: Row(children: [
//           const Expanded(child: SizedBox()),
//           InkWell(
//             onTap: () => Get.toNamed(RouteHelper.getStoreReviewRoute(
//                 widget.store!.id, widget.store!.name, widget.store!)),
//             child: Column(children: [
//               Row(children: [
//                 Icon(Icons.star,
//                     color: Theme.of(context).primaryColor, size: 20),
//                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                 Text(
//                   widget.store!.avgRating!.toStringAsFixed(1),
//                   style: robotoMedium.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: textColor),
//                 ),
//               ]),
//               const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//               Text(
//                 '${widget.store!.ratingCount} + ${'ratings'.tr}',
//                 style: robotoRegular.copyWith(
//                     fontSize: Dimensions.fontSizeSmall, color: textColor),
//               ),
//             ]),
//           ),
//           const Expanded(child: SizedBox()),
//           const VerticalDivider(color: Colors.white, thickness: 1),
//           const Expanded(child: SizedBox()),
//           InkWell(
//             onTap: () => Get.toNamed(RouteHelper.getMapRoute(
//                 AddressModel(
//                   id: widget.store!.id,
//                   address: widget.store!.address,
//                   latitude: widget.store!.latitude,
//                   longitude: widget.store!.longitude,
//                   contactPersonNumber: '',
//                   contactPersonName: '',
//                   addressType: '',
//                 ),
//                 'store',
//                 Get.find<SplashController>()
//                     .getModuleConfig(
//                     Get.find<SplashController>().module!.moduleType!)
//                     .newVariation!)),
//             child: Column(children: [
//               // Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
//               Image.asset(Images.storeLocationIcon,
//                   height: 20, width: 20),
//               const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//               Text('location'.tr,
//                   style: robotoRegular.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: textColor)),
//             ]),
//           ),
//           const Expanded(child: SizedBox()),
//           const VerticalDivider(color: Colors.white, thickness: 1),
//           const Expanded(child: SizedBox()),
//           Column(children: [
//             Image.asset(Images.storeDeliveryTimeIcon,
//                 height: 20, width: 20),
//             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//             Text(widget.store!.deliveryTime!,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.fontSizeSmall,
//                     color: textColor)),
//           ]),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? const Expanded(child: SizedBox())
//               : const SizedBox(),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? const VerticalDivider(color: Colors.white, thickness: 1)
//               : const SizedBox(),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? const Expanded(child: SizedBox())
//               : const SizedBox(),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? Column(children: [
//             Icon(Icons.money_off,
//                 color: Theme.of(context).primaryColor, size: 20),
//             const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             Text('free_delivery'.tr,
//                 style: robotoRegular.copyWith(
//                     fontSize: Dimensions.fontSizeSmall,
//                     color: textColor)),
//           ])
//               : const SizedBox(),
//           const Expanded(child: SizedBox()),
//         ]),
//       )
//           : Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: InkWell(
//               onTap: () => Get.toNamed(RouteHelper.getStoreReviewRoute(
//                   widget.store!.id, widget.store!.name, widget.store!)),
//               child: Column(children: [
//                 Container(
//                   height: 27,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                         bottomLeft: Radius.circular(20),
//                         bottomRight: Radius.circular(20)),
//                     color: Colors.green.shade500,
//                   ),
//                   child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         FittedBox(
//                           child: Text(
//                             widget.store!.avgRating!.toStringAsFixed(1),
//                             style: robotoMedium.copyWith(
//                                 fontSize: Dimensions.fontSizeLarge,
//                                 color: Theme.of(context).cardColor),
//                           ),
//                         ),
//                         const SizedBox(
//                             width: Dimensions.paddingSizeExtraSmall),
//                         Icon(Icons.star,
//                             color: Theme.of(context).cardColor, size: 15),
//                       ]),
//                 ),
//                 Container(
//                   height: 30,
//                   width: 60,
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(8),
//                         bottomRight: Radius.circular(8)),
//                     color: Colors.white,
//                   ),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           FittedBox(
//                             child: Text(
//                               '${widget.store!.ratingCount} ',
//                               style: robotoRegular.copyWith(
//                                   fontSize: Dimensions.fontSizeSmall,
//                                   color: Colors.black),
//                             ),
//                           ),
//                           Text(
//                             'ratings'.tr,
//                             style: robotoRegular.copyWith(
//                                 fontSize: Dimensions.fontSizeSmall,
//                                 color: Colors.black),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ]),
//             ),
//           ),
//           const SizedBox(
//             width: 3,
//           ),
///
//           couponController.couponRestList != null &&
//               couponController.couponRestList!.isNotEmpty
//               ? Expanded(
//             child: Container(
//               height: couponController.couponRestList != null &&
//                   couponController.couponRestList!.isNotEmpty
//                   ? 50.0
//                   : 10.0,
//               width: MediaQuery.of(context).size.width * 0.8,
//               decoration: BoxDecoration(
//                   border:
//                   Border.all(width: 1, color: Colors.black12),
//                   borderRadius:
//                   const BorderRadius.all(Radius.circular(8))),
//               child: GetBuilder<CouponController>(
//                 builder: (couponController) {
//                   if (couponController.couponRestList != null) {
//                     if (couponController
//                         .couponRestList!.isNotEmpty) {
//                       return RefreshIndicator(
//                         color: Theme.of(context).primaryColor,
//                         onRefresh: () async {
//                           await couponController
//                               .getCouponRestList(widget.store!.id);
//                         },
//                         child: Scrollbar(
//                           child: CarouselSlider.builder(
//                             itemCount: couponController
//                                 .couponRestList?.length ??
//                                 0,
//                             itemBuilder:
//                                 (context, index, realIndex) {
//                               return InkWell(
//                                 onTap: () {
//                                   Clipboard.setData(ClipboardData(
//                                     text: couponController
//                                         .couponRestList![index]
//                                         .code!,
//                                   ));
//                                   showCustomSnackBar(
//                                       'coupon_code_copied'.tr,
//                                       isError: false);
//                                 },
//                                 child: Container(
//                                   // height: 80,
//                                   margin: const EdgeInsets.only(
//                                       right: 5),
//                                   width: MediaQuery.of(context)
//                                       .size
//                                       .width *
//                                       0.8,
//                                   decoration: BoxDecoration(
//                                     borderRadius:
//                                     BorderRadius.circular(10),
//                                     color: Colors.transparent,
//                                   ),
//                                   child: FittedBox(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.center,
//                                       children: [
//                                         SvgPicture.asset(
//                                           Images.subtract,
//                                           width: 40,
//                                           height: 40,
//                                           color: Theme.of(context)
//                                               .primaryColor,
//                                         ),
//                                         SizedBox(width: 5),
//                                         FittedBox(
//                                           child: Row(
//                                             mainAxisAlignment:
//                                             MainAxisAlignment
//                                                 .spaceBetween,
//                                             children: [
//                                               Column(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .center,
//                                                 crossAxisAlignment:
//                                                 CrossAxisAlignment
//                                                     .start,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .center,
//                                                     children: [
//                                                       Text(
//                                                         '${couponController.couponRestList![index].discountType == 'percent' ? '%' : couponController.couponRestList![index].couponType == 'free_delivery' ? 'free_delivery'.tr : Get.find<SplashController>().configModel!.currencySymbol}'
//                                                             '${couponController.couponRestList![index].couponType == 'free_delivery' ? '' : (couponController.couponRestList![index].discount)?.toStringAsFixed(0)} '
//                                                             '${couponController.couponRestList![index].couponType == 'free_delivery' ? '' : 'off'.tr}',
//                                                         style: robotoBold.copyWith(
//                                                             fontSize:
//                                                             Dimensions.fontSizeLarge),
//                                                       ),
//                                                       Text(
//                                                         couponController.couponRestList![index].maxDiscount !=
//                                                             null
//                                                             ? ' | UPTO ₹${(couponController.couponRestList![index].maxDiscount)?.toStringAsFixed(0)}'
//                                                             : "",
//                                                         style: robotoBold.copyWith(
//                                                             fontSize:
//                                                             Dimensions.fontSizeLarge),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   SizedBox(
//                                                     width: 180,
//                                                     child:
//                                                     FittedBox(
//                                                       child: Text(
//                                                         "Use : ${couponController.couponRestList![index].code} | Valid Till : ${couponController.couponRestList![index].expireDate != null ? DateFormat('dd-MMMM-yyyy').format(DateTime.parse(couponController.couponRestList![index].expireDate!)) : 'N/A'}",
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Text(
//                                                 "${index + 1}/${couponController.couponRestList?.length}",
//                                                 style: TextStyle(
//                                                     color: Theme.of(
//                                                         context)
//                                                         .primaryColor)
//                                                     .copyWith(
//                                                     fontSize:
//                                                     10),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                             options: CarouselOptions(
//                               height: 200,
//                               enlargeCenterPage: true,
//                               autoPlay: true,
//                               scrollDirection: Axis.horizontal,
//                               autoPlayCurve: Curves.fastOutSlowIn,
//                               enableInfiniteScroll: true,
//                               autoPlayAnimationDuration:
//                               Duration(milliseconds: 700),
//                               viewportFraction: 1,
//                             ),
//                           ),
//                         ),
//                       );
//                     } else {
//                       return SizedBox(height: 0);
//                     }
//                   } else {
//                     return Center(
//                         child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<
//                                 Color>(
//                                 Theme.of(context).primaryColor)));
//                   }
//                 },
//               ),
//             ),
//           )
//               : const SizedBox(),
//         ],
//       ),
//     ]);
//   }
// }
// class StoreDescriptionViewWidgetFood extends StatefulWidget {
//   final Store? store;
//
//   const StoreDescriptionViewWidgetFood({super.key, required this.store});
//
//   @override
//   State<StoreDescriptionViewWidgetFood> createState() =>
//       _StoreDescriptionViewWidgetFoodState();
// }
//
// class _StoreDescriptionViewWidgetFoodState
//     extends State<StoreDescriptionViewWidgetFood> {
//   final CouponController couponController = Get.find<CouponController>();
//   final ScrollController scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     initDataCall();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//     scrollController.dispose();
//   }
//
//   Future<void> initDataCall() async {
//     Get.find<CouponController>().getCouponRestList(widget.store!.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isAvailable = Get.find<StoreController>()
//         .isStoreOpenNow(widget.store!.active!, widget.store!.schedules);
//     Color? textColor =
//     ResponsiveHelper.isDesktop(context) ? Colors.white : null;
//     return Column(children: [
//       ResponsiveHelper.isDesktop(context)
//           ? Row(children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//           child: Stack(children: [
//             CustomImage(
//               image: '${widget.store!.logoFullUrl}',
//               height: ResponsiveHelper.isDesktop(context) ? 140 : 60,
//               width: ResponsiveHelper.isDesktop(context) ? 140 : 70,
//               fit: BoxFit.cover,
//             ),
//           ]),
//         ),
//         const SizedBox(width: Dimensions.paddingSizeDefault),
//         Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [
//                     Expanded(
//                         child: Text(
//                           widget.store!.name!,
//                           style: robotoMedium.copyWith(
//                               fontSize: Dimensions.fontSizeLarge,
//                               color: textColor),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         )),
//                     const SizedBox(width: Dimensions.paddingSizeSmall),
//                     GetBuilder<FavouriteController>(
//                         builder: (favouriteController) {
//                           bool isWished = favouriteController.wishStoreIdList
//                               .contains(widget.store!.id);
//                           return InkWell(
//                             onTap: () {
//                               if (AuthHelper.isLoggedIn()) {
//                                 isWished
//                                     ? favouriteController.removeFromFavouriteList(
//                                     widget.store!.id, true)
//                                     : favouriteController.addToFavouriteList(
//                                     null, widget.store?.id, true);
//                               } else {
//                                 showCustomSnackBar('you_are_not_logged_in'.tr);
//                               }
//                             },
//                             child: ResponsiveHelper.isDesktop(context)
//                                 ? Container(
//                               padding: const EdgeInsets.all(
//                                   Dimensions.paddingSizeExtraSmall),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(
//                                       Dimensions.radiusSmall),
//                                   border: Border.all(color: Colors.white)),
//                               child: Center(
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                         isWished
//                                             ? Icons.favorite
//                                             : Icons.favorite_border,
//                                         color: Colors.white,
//                                         size: 14),
//                                     const SizedBox(
//                                         width: Dimensions
//                                             .paddingSizeExtraSmall),
//                                     Text('wish_list'.tr,
//                                         style: robotoRegular.copyWith(
//                                             fontWeight: FontWeight.w200,
//                                             color: Colors.white,
//                                             fontSize:
//                                             Dimensions.fontSizeSmall)),
//                                   ],
//                                 ),
//                               ),
//                             )
//                                 : Icon(
//                               isWished
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: isWished
//                                   ? Theme.of(context).primaryColor
//                                   : Theme.of(context).disabledColor,
//                             ),
//                           );
//                         }),
//                   ]),
//                   const SizedBox(height: Dimensions.paddingSizeDefault),
//                   SizedBox(
//                       height: ResponsiveHelper.isDesktop(context)
//                           ? Dimensions.paddingSizeSmall
//                           : 0),
//                 ])),
//       ])
//           : const SizedBox(),
//       SizedBox(height: ResponsiveHelper.isDesktop(context) ? 30 : 0),
//       ResponsiveHelper.isDesktop(context)
//           ? IntrinsicHeight(
//         child: Row(children: [
//           const Expanded(child: SizedBox()),
//           InkWell(
//             onTap: () => Get.toNamed(RouteHelper.getStoreReviewRoute(
//                 widget.store!.id, widget.store!.name, widget.store!)),
//             child: Column(children: [
//               Row(children: [
//                 Icon(Icons.star,
//                     color: Theme.of(context).primaryColor, size: 20),
//                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//                 Text(
//                   widget.store!.avgRating!.toStringAsFixed(1),
//                   style: robotoMedium.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: textColor),
//                 ),
//               ]),
//               const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//               Text(
//                 '${widget.store!.ratingCount} + ${'ratings'.tr}',
//                 style: robotoRegular.copyWith(
//                     fontSize: Dimensions.fontSizeSmall, color: textColor),
//               ),
//             ]),
//           ),
//           const Expanded(child: SizedBox()),
//           const VerticalDivider(color: Colors.white, thickness: 1),
//           const Expanded(child: SizedBox()),
//           InkWell(
//             onTap: () => Get.toNamed(RouteHelper.getMapRoute(
//                 AddressModel(
//                   id: widget.store!.id,
//                   address: widget.store!.address,
//                   latitude: widget.store!.latitude,
//                   longitude: widget.store!.longitude,
//                   contactPersonNumber: '',
//                   contactPersonName: '',
//                   addressType: '',
//                 ),
//                 'store',
//                 Get.find<SplashController>()
//                     .getModuleConfig(
//                     Get.find<SplashController>().module!.moduleType!)
//                     .newVariation!)),
//             child: Column(children: [
//               // Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
//               Image.asset(Images.storeLocationIcon,
//                   height: 20, width: 20),
//               const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//               Text('location'.tr,
//                   style: robotoRegular.copyWith(
//                       fontSize: Dimensions.fontSizeSmall,
//                       color: textColor)),
//             ]),
//           ),
//           const Expanded(child: SizedBox()),
//           const VerticalDivider(color: Colors.white, thickness: 1),
//           const Expanded(child: SizedBox()),
//           Column(children: [
//             Image.asset(Images.storeDeliveryTimeIcon,
//                 height: 20, width: 20),
//             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//             Text(widget.store!.deliveryTime!,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.fontSizeSmall,
//                     color: textColor)),
//           ]),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? const Expanded(child: SizedBox())
//               : const SizedBox(),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? const VerticalDivider(color: Colors.white, thickness: 1)
//               : const SizedBox(),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? const Expanded(child: SizedBox())
//               : const SizedBox(),
//           (widget.store!.delivery! && widget.store!.freeDelivery!)
//               ? Column(children: [
//             Icon(Icons.money_off,
//                 color: Theme.of(context).primaryColor, size: 20),
//             const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             Text('free_delivery'.tr,
//                 style: robotoRegular.copyWith(
//                     fontSize: Dimensions.fontSizeSmall,
//                     color: textColor)),
//           ])
//               : const SizedBox(),
//           const Expanded(child: SizedBox()),
//         ]),
//       )
//           : couponController.couponRestList != null &&
//           couponController.couponRestList!.isNotEmpty
//           ? Container(
//         height: couponController.couponRestList != null && couponController.couponRestList!.isNotEmpty ? 70.0 : 10.0,
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//             border:
//             Border.all(width: 1, color: Colors.black12),
//             borderRadius:
//             const BorderRadius.all(Radius.circular(18))),
//         child: GetBuilder<CouponController>(
//           builder: (couponController) {
//             if (couponController.couponRestList != null) {
//               if (couponController
//                   .couponRestList!.isNotEmpty) {
//                 return RefreshIndicator(
//                   color: Theme.of(context).primaryColor,
//                   onRefresh: () async {
//                     await couponController
//                         .getCouponRestList(widget.store!.id);
//                   },
//                   child: Scrollbar(
//                     child: CarouselSlider.builder(
//                       itemCount: couponController
//                           .couponRestList?.length ??
//                           0,
//                       itemBuilder:
//                           (context, index, realIndex) {
//                         return InkWell(
//                           onTap: () {
//                             Clipboard.setData(ClipboardData(
//                               text: couponController
//                                   .couponRestList![index]
//                                   .code!,
//                             ));
//                             showCustomSnackBar(
//                                 'coupon_code_copied'.tr,
//                                 isError: false);
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(right: 5),
//                             width: MediaQuery.of(context).size.width * 0.8,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Colors.transparent,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     SvgPicture.asset(
//                                       Images.subtract,
//                                       width: 30,
//                                       height: 30,
//                                       color: Theme.of(context).primaryColor,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     ConstrainedBox(
//                                       constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(vertical: 2.0),
//                                         child: Column(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               '${couponController.couponRestList?[index].discountType == 'percent' ? '%' : couponController.couponRestList?[index].couponType == 'free_delivery' ? 'free_delivery'.tr : Get.find<SplashController>().configModel?.currencySymbol}'
//                                                   '${couponController.couponRestList?[index].couponType == 'free_delivery' ? '' : (couponController.couponRestList?[index].discount)?.toStringAsFixed(0)} '
//                                                   '${couponController.couponRestList?[index].couponType == 'free_delivery' ? '' : 'off'.tr}'
//                                                   '${couponController.couponRestList?[index].maxDiscount != null ? ' | UPTO ₹${(couponController.couponRestList?[index].maxDiscount)?.toStringAsFixed(0)}' : ''}',
//                                               style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                             const SizedBox(height: 2),
//                                             // Code and expiry
//                                             Text(
//                                               "Use: ${couponController.couponRestList?[index].code ?? 'N/A'} | Valid Till: ${couponController.couponRestList?[index].expireDate != null ? DateFormat('dd-MMMM-yyyy').format(DateTime.parse(couponController.couponRestList![index].expireDate!)) : 'N/A'}",
//                                               style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 // Index indicator
//                                 Text(
//                                   "${index + 1}/${couponController.couponRestList?.length ?? 0}",
//                                   style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                       options: CarouselOptions(
//                         height: 200,
//                         enlargeCenterPage: true,
//                         autoPlay: true,
//                         scrollDirection: Axis.horizontal,
//                         autoPlayCurve: Curves.fastOutSlowIn,
//                         enableInfiniteScroll: true,
//                         autoPlayAnimationDuration:
//                         const Duration(milliseconds: 700),
//                         viewportFraction: 1,
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return const SizedBox(height: 0);
//               }
//             } else {
//               return Center(
//                   child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<
//                           Color>(
//                           Theme.of(context).primaryColor)));
//             }
//           },
//         ),
//       )
//           : const SizedBox(),
//     ]);
//   }
// }
///

class StoreDescriptionViewWidget extends StatefulWidget {
  final Store? store;

  const StoreDescriptionViewWidget({super.key, required this.store});

  @override
  State<StoreDescriptionViewWidget> createState() =>
      _StoreDescriptionViewWidgetState();
}

class _StoreDescriptionViewWidgetState
    extends State<StoreDescriptionViewWidget> {
  final CouponController couponController = Get.find<CouponController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initDataCall();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future<void> initDataCall() async {
    Get.find<CouponController>().getCouponRestList(widget.store!.id);
  }

  @override
  Widget build(BuildContext context) {
    bool isAvailable = Get.find<StoreController>().isStoreOpenNow(
      widget.store!.active!,
      widget.store!.schedules,
    );
    Color? textColor = ResponsiveHelper.isDesktop(context)
        ? Colors.white
        : null;

    return Column(
      children: [
        if (ResponsiveHelper.isDesktop(context))
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Stack(
                  children: [
                    CustomImage(
                      image: '${widget.store!.logoFullUrl}',
                      height: ResponsiveHelper.isDesktop(context) ? 140 : 60,
                      width: ResponsiveHelper.isDesktop(context) ? 140 : 70,
                      fit: BoxFit.cover,
                    ),
                    isAvailable
                        ? const SizedBox()
                        : Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                ),
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              child: Text(
                                'closed_now'.tr,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.store!.name!,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // ResponsiveHelper.isDesktop(context) ? InkWell(
                        //   onTap: () => Get.toNamed(RouteHelper.getSearchStoreItemRoute(store!.id)),
                        //   child: ResponsiveHelper.isDesktop(context) ? Container(
                        //     padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).primaryColor),
                        //     child: const Center(child: Icon(Icons.search, color: Colors.white)),
                        //   ) : Icon(Icons.search, color: Theme.of(context).primaryColor),
                        // ) : const SizedBox(),
                        // const SizedBox(width: Dimensions.paddingSizeSmall),
                        GetBuilder<FavouriteController>(
                          builder: (favouriteController) {
                            bool isWished = favouriteController.wishStoreIdList
                                .contains(widget.store!.id);
                            return InkWell(
                              onTap: () {
                                if (AuthHelper.isLoggedIn()) {
                                  isWished
                                      ? favouriteController
                                            .removeFromFavouriteList(
                                              widget.store!.id,
                                              true,
                                            )
                                      : favouriteController.addToFavouriteList(
                                          null,
                                          widget.store?.id,
                                          true,
                                        );
                                } else {
                                  showCustomSnackBar(
                                    'you_are_not_logged_in'.tr,
                                  );
                                }
                              },
                              child: ResponsiveHelper.isDesktop(context)
                                  ? Container(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Icon(
                                              isWished
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              'wish_list'.tr,
                                              style: robotoRegular.copyWith(
                                                fontWeight: FontWeight.w200,
                                                color: Colors.white,
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      isWished
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isWished
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).disabledColor,
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.store!.address ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),

                        AppConstants.webHostedUrl.isNotEmpty
                            ? InkWell(
                                onTap: () {
                                  Get.find<StoreController>().shareStore();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: const Icon(
                                    Icons.share,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeSmall
                          : 0,
                    ),

                    Row(
                      children: [
                        Text(
                          'minimum_order_amount'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                          child: Text(
                            PriceConverter.convertPrice(
                              widget.store!.minimumOrder,
                            ),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (ResponsiveHelper.isDesktop(context)) SizedBox(height: 30),
        ResponsiveHelper.isDesktop(context)
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getStoreReviewRoute(
                          widget.store!.id,
                          widget.store!.name,
                          widget.store!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                widget.store!.avgRating!.toStringAsFixed(1),
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            '${widget.store!.ratingCount} + ${'ratings'.tr}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(child: SizedBox()),

                    InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getMapRoute(
                          AddressModel(
                            id: widget.store!.id,
                            address: widget.store!.address,
                            latitude: widget.store!.latitude,
                            longitude: widget.store!.longitude,
                            contactPersonNumber: '',
                            contactPersonName: '',
                            addressType: '',
                          ),
                          'store',
                          Get.find<SplashController>()
                              .getModuleConfig(
                                Get.find<SplashController>()
                                    .module!
                                    .moduleType!,
                              )
                              .newVariation!,
                          storeName: widget.store!.name,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
                          Image.asset(
                            Images.storeLocationIcon,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            'location'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Expanded(child: SizedBox()),

                    Column(
                      children: [
                        Image.asset(
                          Images.storeDeliveryTimeIcon,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),

                        Text(
                          widget.store!.deliveryTime!,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),

                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? const Expanded(child: SizedBox())
                        : const SizedBox(),
                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? const VerticalDivider(
                            color: Colors.white,
                            thickness: 1,
                          )
                        : const SizedBox(),
                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? const Expanded(child: SizedBox())
                        : const SizedBox(),

                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? Column(
                            children: [
                              Icon(
                                Icons.money_off,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                'free_delivery'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: textColor,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.star, color: Colors.orange, size: 12),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (widget.store!.avgRating ?? 0.0).toStringAsFixed(1),
                                style: robotoBold.copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.access_time_outlined, color: Colors.pink, size: 12),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.store!.deliveryTime!,
                                  style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (couponController.couponRestList != null && couponController.couponRestList!.isNotEmpty)
                      Expanded(
                        flex: 7,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CarouselSlider.builder(
                              itemCount: couponController.couponRestList?.length ?? 0,
                              itemBuilder: (context, index, realIndex) {
                                return InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: couponController.couponRestList![index].code!));
                                    showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                          child: Icon(Icons.local_offer_outlined, color: Theme.of(context).primaryColor, size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${couponController.couponRestList![index].discount?.toStringAsFixed(0)}'
                                                '${couponController.couponRestList![index].discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol} OFF',
                                                style: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).primaryColor),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Code: ",
                                                    style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                                                  ),
                                                  Text(
                                                    "${couponController.couponRestList![index].code}",
                                                    style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).textTheme.bodyLarge!.color),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                autoPlay: true,
                                viewportFraction: 1,
                                aspectRatio: 5,
                                autoPlayInterval: const Duration(seconds: 4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    Color bgColor,
    Color accentColor,
    String iconPath,
    Widget content,
  ) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: CustomAssetImageWidget(iconPath, width: 24, height: 24),
          ),
          const SizedBox(width: 12),
          content,
        ],
      ),
    );
  }
}

class StoreDescriptionViewWidgetFood extends StatefulWidget {
  final Store? store;

  const StoreDescriptionViewWidgetFood({super.key, required this.store});

  @override
  State<StoreDescriptionViewWidgetFood> createState() =>
      _StoreDescriptionViewWidgetFoodState();
}

class _StoreDescriptionViewWidgetFoodState
    extends State<StoreDescriptionViewWidgetFood> {
  final CouponController couponController = Get.find<CouponController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initDataCall();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  Future<void> initDataCall() async {
    Get.find<CouponController>().getCouponRestList(widget.store!.id);
  }

  @override
  Widget build(BuildContext context) {
    bool isAvailable = Get.find<StoreController>().isStoreOpenNow(
      widget.store!.active!,
      widget.store!.schedules,
    );
    Color? textColor = ResponsiveHelper.isDesktop(context)
        ? Colors.white
        : null;
    return Column(
      children: [
        ResponsiveHelper.isDesktop(context)
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    child: Stack(
                      children: [
                        CustomImage(
                          image: '${widget.store!.logoFullUrl}',
                          height: ResponsiveHelper.isDesktop(context)
                              ? 140
                              : 60,
                          width: ResponsiveHelper.isDesktop(context) ? 140 : 70,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.store!.name!,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            GetBuilder<FavouriteController>(
                              builder: (favouriteController) {
                                bool isWished = favouriteController
                                    .wishStoreIdList
                                    .contains(widget.store!.id);
                                return InkWell(
                                  onTap: () {
                                    if (AuthHelper.isLoggedIn()) {
                                      isWished
                                          ? favouriteController
                                                .removeFromFavouriteList(
                                                  widget.store!.id,
                                                  true,
                                                )
                                          : favouriteController
                                                .addToFavouriteList(
                                                  null,
                                                  widget.store?.id,
                                                  true,
                                                );
                                    } else {
                                      showCustomSnackBar(
                                        'you_are_not_logged_in'.tr,
                                      );
                                    }
                                  },
                                  child: ResponsiveHelper.isDesktop(context)
                                      ? Container(
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeExtraSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isWished
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),
                                                Text(
                                                  'wish_list'.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontWeight: FontWeight.w200,
                                                    color: Colors.white,
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          isWished
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isWished
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).disabledColor,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeSmall
                              : 0,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 30 : 0),
        ResponsiveHelper.isDesktop(context)
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getStoreReviewRoute(
                          widget.store!.id,
                          widget.store!.name,
                          widget.store!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                widget.store!.avgRating!.toStringAsFixed(1),
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            '${widget.store!.ratingCount} + ${'ratings'.tr}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const VerticalDivider(color: Colors.white, thickness: 1),
                    const Expanded(child: SizedBox()),
                    InkWell(
                      onTap: () => Get.toNamed(
                        RouteHelper.getMapRoute(
                          AddressModel(
                            id: widget.store!.id,
                            address: widget.store!.address,
                            latitude: widget.store!.latitude,
                            longitude: widget.store!.longitude,
                            contactPersonNumber: '',
                            contactPersonName: '',
                            addressType: '',
                          ),
                          'store',
                          Get.find<SplashController>()
                              .getModuleConfig(
                                Get.find<SplashController>()
                                    .module!
                                    .moduleType!,
                              )
                              .newVariation!,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
                          Image.asset(
                            Images.storeLocationIcon,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            'location'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const VerticalDivider(color: Colors.white, thickness: 1),
                    const Expanded(child: SizedBox()),
                    Column(
                      children: [
                        Image.asset(
                          Images.storeDeliveryTimeIcon,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        Text(
                          widget.store!.deliveryTime!,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? const Expanded(child: SizedBox())
                        : const SizedBox(),
                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? const VerticalDivider(
                            color: Colors.white,
                            thickness: 1,
                          )
                        : const SizedBox(),
                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? const Expanded(child: SizedBox())
                        : const SizedBox(),
                    (widget.store!.delivery! && widget.store!.freeDelivery!)
                        ? Column(
                            children: [
                              Icon(
                                Icons.money_off,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              Text(
                                'free_delivery'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: textColor,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.star, color: Colors.orange, size: 12),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (widget.store!.avgRating ?? 0.0).toStringAsFixed(1),
                                style: robotoBold.copyWith(fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.access_time_outlined, color: Colors.pink, size: 12),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.store!.deliveryTime!,
                                  style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (couponController.couponRestList != null && couponController.couponRestList!.isNotEmpty)
                      Expanded(
                        flex: 7,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CarouselSlider.builder(
                              itemCount: couponController.couponRestList?.length ?? 0,
                              itemBuilder: (context, index, realIndex) {
                                return InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: couponController.couponRestList![index].code!));
                                    showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                          child: Icon(Icons.local_offer_outlined, color: Theme.of(context).primaryColor, size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${couponController.couponRestList![index].discount?.toStringAsFixed(0)}'
                                                '${couponController.couponRestList![index].discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol} OFF',
                                                style: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).primaryColor),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Code: ",
                                                    style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                                                  ),
                                                  Text(
                                                    "${couponController.couponRestList![index].code}",
                                                    style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).textTheme.bodyLarge!.color),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                autoPlay: true,
                                viewportFraction: 1,
                                aspectRatio: 5,
                                autoPlayInterval: const Duration(seconds: 4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    Color bgColor,
    Color accentColor,
    String iconPath,
    Widget content,
  ) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: CustomAssetImageWidget(iconPath, width: 24, height: 24),
          ),
          const SizedBox(width: 12),
          content,
        ],
      ),
    );
  }
}
