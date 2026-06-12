import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../common/models/module_model.dart';
import '../../../../common/widgets/custom_image.dart';
import '../../../../common/widgets/custom_ink_well.dart';
import '../../../../common/widgets/custom_snackbar.dart';
import '../../../../helper/auth_helper.dart';
import '../../../../util/images.dart';
import '../../../favourite/controllers/favourite_controller.dart';
import '../../../location/controllers/location_controller.dart';
import '../../../splash/controllers/splash_controller.dart';
import '../../../store/screens/store_screen.dart';
import '../module_view.dart';

class NewOnMartView extends StatelessWidget {
  final bool isPharmacy;
  final bool isShop;
  final bool isNewStore;
  const NewOnMartView({super.key, required this.isPharmacy, required this.isShop, this.isNewStore = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = storeController.latestStoreList;
      bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

      return  Skeletonizer(
        enabled: storeList == null,
        child: storeList != null && storeList.isNotEmpty ?Column(children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${'new_on'.tr} ${AppConstants.appName}+",style: robotoMedium.copyWith(fontSize: 18.sp),),
                      Gap(5.h),
                      Container(
                        width: 100.w,
                        height: 0.8.h,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      )
        
                      // TitleWidget(
                      //   title: '${'new_on'.tr} ${AppConstants.appName}+',
                      //   islottie: true,
                      //   image: Images.newtag,
                      //   onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('latest')),
                      // ),
                    ],
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.toNamed(RouteHelper.getAllStoreRoute('latest'));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                          color: Colors.grey.shade200
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 6.0),
                        child: Row(
                          children: [
                            Text("View All",style: robotoMedium.copyWith(fontSize: 12.sp,),),
                            Gap(5),
                            Icon(Icons.arrow_forward_outlined,size: 18.h,)
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // const SizedBox(height: Dimensions.paddingSizeSmall),
        
          SizedBox(
            height: 215.h,
            child: ListView.builder(
                primary: false,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: storeList.length,
                itemBuilder: (context, index){
                  final store = storeList[index];
                  double distance = Get.find<LocationController>().getRestaurantDistance(
                    LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                    child:
                    Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 5 : 0,
                        right: Dimensions.paddingSizeDefault,
                        bottom: 5,
                      ),
                      child: Container(
                        width: 290,
                        margin: const EdgeInsets.only(
                            top: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomInkWell(
                          onTap:storeController.isOpenNow(store)? () {
                            if (Get.find<SplashController>()
                                .moduleList !=
                                null) {
                              for (ModuleModel module
                              in Get.find<SplashController>()
                                  .moduleList!) {
                                if (module.id == store.moduleId) {
                                  Get.find<SplashController>()
                                      .setModule(module);
                                  break;
                                }
                              }
                            }
        
                            Get.toNamed(
                              RouteHelper.getStoreRoute(
                                id: store.id,
                                page: 'module',
                              ),
                              arguments: StoreScreen(
                                store: store,
                                fromModule: true,
                              ),
                            );
                          }:(){
                            showCustomSnackBar("store_is_closed".tr,isError: true);
                          },
                          radius: Dimensions.radiusSmall,
                          child: Stack(
                            children: [
                              /// Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ColorFiltered(
                                  colorFilter: storeController.isOpenNow(store)
                                      ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                                      : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                  child: CustomImage(
                                    image: store.coverPhotoFullUrl ?? "",
                                    height: 278,
                                    width: 290,
                                    fit: BoxFit.cover,
                                  ),
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
                                        stops: [0.0, 0.3, 1.0],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (!storeController.isOpenNow(store))
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(16),
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
                                          .contains(store.id);
        
                                      return InkWell(
                                        onTap: () {
                                          if (AuthHelper.isLoggedIn()) {
                                            isWished
                                                ? fc.removeFromFavouriteList(
                                                store.id, true)
                                                : fc.addToFavouriteList(
                                                null, store.id, true);
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
                                        store.name ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),

                                      /// Rating + Delivery
                                      Row(
                                        children: [
                                          // Icon(
                                          //   FontAwesome.star_solid,
                                          //   color: Theme.of(context)
                                          //       .cardColor,
                                          //   size: 12,
                                          // ),
                                          // const SizedBox(width: 5),
                                          //
                                          // store.avgRating != null
                                          //     ? Text(
                                          //   store.avgRating
                                          //       ?.toStringAsFixed(
                                          //       1) ??
                                          //       "0.0",
                                          //   style:
                                          //   GoogleFonts.inter(
                                          //       color: Colors
                                          //           .white,
                                          //       fontSize: 12,
                                          //       fontWeight:
                                          //       FontWeight
                                          //           .bold),
                                          // )
                                          //     : const SizedBox.shrink(),
                                          // const SizedBox(width: 5),
                                          //
                                          // store.ratingCount != null
                                          //     ? Text(
                                          //   "(${store.ratingCount?.toStringAsFixed(0) ?? 0})",
                                          //   style:
                                          //   GoogleFonts.inter(
                                          //       color: Colors
                                          //           .white,
                                          //       fontSize: 12),
                                          // )
                                          //     : const SizedBox.shrink(),
        
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
                                              color: Colors.transparent,
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
                                                  // const Icon(
                                                  //   Icons.bolt,
                                                  //   color: AppConstants
                                                  //       .backgroundColor,
                                                  //   size: 12,
                                                  // ),
                                                  // const SizedBox(
                                                  //     width: 5),
                                                  Text(
                                                    store.deliveryTime ??
                                                        "",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      color: Theme.of(context).cardColor,
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
                                          ),
                                          const SizedBox(width: 10),

                                          Icon(
                                            Icons.circle,
                                            color: Theme.of(context)
                                                .cardColor,
                                            size: 5,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                              '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                          style: GoogleFonts
                                                .inter(
                                              fontSize: 12,
                                              color: Theme.of(context).cardColor,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),


                                        ],
                                      ),
                                      Text(
                                        store.address ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                      SizedBox(height: 5.h),

                                      storeController.isOpenNow(store)
                                          ?  Container(
                                        decoration:BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(10.r)
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 5),
                                            child: Text("Open Now",style: robotoRegular.copyWith(color: Theme.of(context).cardColor,fontSize: 12.sp),),
                                          ),):SizedBox()
                                    ],
                                  ),
                                ),
                              ),
        
                              /// Closed Banner
                              storeController.isOpenNow(store)
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
                          ),
                        ),
                      ),
                    )
        
                    // StoreCardWithDistance(store: storeList[index], isNewStore: isNewStore),
                  );
                }),
          )
        ]):SizedBox(),
      );
    });
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({super.key, required this.storeController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        itemCount: 10,
        itemBuilder: (context, index){
          return Container(
            height: 150, width: 200,
            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)],
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  height: 90, width: 200,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                      color: Colors.grey[300],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                      Container(height: 10, width: 100, color: Colors.grey[300]),
                      const SizedBox(height: 5),

                      Container(height: 10, width: 130, color: Colors.grey[300]),
                      const SizedBox(height: 5),

                      const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

