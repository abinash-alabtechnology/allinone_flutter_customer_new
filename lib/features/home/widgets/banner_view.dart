import 'package:carousel_slider/carousel_slider.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/basic_campaign_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/common/models/module_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BannerView extends StatelessWidget {
  final bool isFeatured;

  const BannerView({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      final List<String?>? bannerList = isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      final List<dynamic>? bannerDataList = isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      if (bannerList == null) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.grey[300],
            ),
          ),
        );
      }

      if (bannerList.isEmpty) {
        return const SizedBox();
      }

      return Container(
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall),
        // padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  bannerController.setCurrentIndex(index, true);
                },
              ),
              itemCount: bannerList.length,
              itemBuilder: (context, index, _) {
                return InkWell(
                  onTap: () async {
                    final data = bannerDataList?[index];
                    if (data == null) return;

                    if (data is Item) {
                      Get.find<ItemController>()
                          .navigateToItemPage(data, context);
                    } else if (data is Store) {
                      final store = data;

                      if (isFeatured &&
                          (AddressHelper.getUserAddressFromSharedPref()
                                      ?.zoneData !=
                                  null &&
                              AddressHelper.getUserAddressFromSharedPref()!
                                  .zoneData!
                                  .isNotEmpty)) {
                        for (final module
                            in Get.find<SplashController>().moduleList ?? []) {
                          if (module.id == store.moduleId) {
                            Get.find<SplashController>().setModule(module);
                            break;
                          }
                        }

                        final zoneData = AddressHelper
                                .getUserAddressFromSharedPref()!
                            .zoneData!
                            .firstWhere(
                              (data) => data.id == store.zoneId,
                              orElse: () =>
                                  AddressHelper.getUserAddressFromSharedPref()!
                                      .zoneData!
                                      .first,
                            );

                        final module = zoneData.modules!.firstWhere(
                            (m) => m.id == store.moduleId,
                            orElse: () => zoneData.modules!.first);

                        Get.find<SplashController>().setModule(ModuleModel(
                          id: module.id,
                          moduleName: module.moduleName,
                          moduleType: module.moduleType,
                          themeId: module.themeId,
                          storesCount: module.storesCount,
                        ));
                      }

                      Get.toNamed(
                        RouteHelper.getStoreRoute(
                            id: store.id,
                            page: isFeatured ? 'module' : 'banner'),
                        arguments:
                            StoreScreen(store: store, fromModule: isFeatured),
                      );
                    } else if (data is BasicCampaignModel) {
                      Get.toNamed(RouteHelper.getBasicCampaignRoute(data));
                    } else if (data is String) {
                      if (await canLaunchUrlString(data)) {
                        await launchUrlString(data,
                            mode: LaunchMode.externalApplication);
                      } else {
                        showCustomSnackBar('unable_to_found_url'.tr);
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 0)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      child: GetBuilder<SplashController>(
                        builder: (splashController) {
                          return CustomImage(
                            image: bannerList[index] ?? '',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            if (bannerList.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: bannerList
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final total = bannerList.length;
                  final isActive = index == bannerController.currentIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: isActive
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            child: Text(
                              '${index + 1}/$total',
                              style: robotoRegular.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Container(
                            height: 4.18,
                            width: 5.57,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withAlpha((255 * 0.5).round()),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault),
                            ),
                          ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    });
  }
}
class BannerViewModule extends StatelessWidget {
  final bool isFeatured;

  const BannerViewModule({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      final List<String?>? bannerList = isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      final List<dynamic>? bannerDataList = isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      if (bannerList == null) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.grey[300],
            ),
          ),
        );
      }

      if (bannerList.isEmpty) {
        return const SizedBox();
      }

      return Container(
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: Dimensions.paddingSizeSmall),
        // padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 1.0,
                enlargeCenterPage: true,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  bannerController.setCurrentIndex(index, true);
                },
              ),
              itemCount: bannerList.length,
              itemBuilder: (context, index, _) {
                return InkWell(
                  onTap: () async {
                    final data = bannerDataList?[index];
                    if (data == null) return;

                    if (data is Item) {
                      Get.find<ItemController>()
                          .navigateToItemPage(data, context);
                    } else if (data is Store) {
                      final store = data;

                      if (isFeatured &&
                          (AddressHelper.getUserAddressFromSharedPref()
                              ?.zoneData !=
                              null &&
                              AddressHelper.getUserAddressFromSharedPref()!
                                  .zoneData!
                                  .isNotEmpty)) {
                        for (final module
                        in Get.find<SplashController>().moduleList ?? []) {
                          if (module.id == store.moduleId) {
                            Get.find<SplashController>().setModule(module);
                            break;
                          }
                        }

                        final zoneData = AddressHelper
                            .getUserAddressFromSharedPref()!
                            .zoneData!
                            .firstWhere(
                              (data) => data.id == store.zoneId,
                          orElse: () =>
                          AddressHelper.getUserAddressFromSharedPref()!
                              .zoneData!
                              .first,
                        );

                        final module = zoneData.modules!.firstWhere(
                                (m) => m.id == store.moduleId,
                            orElse: () => zoneData.modules!.first);

                        Get.find<SplashController>().setModule(ModuleModel(
                          id: module.id,
                          moduleName: module.moduleName,
                          moduleType: module.moduleType,
                          themeId: module.themeId,
                          storesCount: module.storesCount,
                        ));
                      }

                      Get.toNamed(
                        RouteHelper.getStoreRoute(
                            id: store.id,
                            page: isFeatured ? 'module' : 'banner'),
                        arguments:
                        StoreScreen(store: store, fromModule: isFeatured),
                      );
                    } else if (data is BasicCampaignModel) {
                      Get.toNamed(RouteHelper.getBasicCampaignRoute(data));
                    } else if (data is String) {
                      if (await canLaunchUrlString(data)) {
                        await launchUrlString(data,
                            mode: LaunchMode.externalApplication);
                      } else {
                        showCustomSnackBar('unable_to_found_url'.tr);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(18),
                        child: GetBuilder<SplashController>(
                          builder: (splashController) {
                            return CustomImage(
                              image: bannerList[index] ?? '',
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            GetBuilder<BannerController>(
              builder: (bannerController) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(bannerList.length, (index) {
                    bool isActive = bannerController.currentIndex == index;
                    int total = bannerList.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: isActive
                          ? Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                '${index + 1}/$total',
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : Container(
                              height: 5,
                              width: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withAlpha((255 * 0.5).round()),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                            ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}


class BannerViewGrocery extends StatelessWidget {
  final bool isFeatured;

  const BannerViewGrocery({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      final List<String?>? bannerList = isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      final List<dynamic>? bannerDataList = isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      if (bannerList == null) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Colors.grey[300],
            ),
          ),
        );
      }

      if (bannerList.isEmpty) {
        return const SizedBox();
      }
return Container(
  color: Colors.transparent,
  width: double.infinity,
  padding: const EdgeInsets.only(
    top: Dimensions.paddingSizeDefault,
    bottom: Dimensions.paddingSizeSmall,
  ),
  child: Column(
    children: [

      /// Banner Slider
      CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: true,
          viewportFraction: 1.0,
          enlargeCenterPage: true,
          disableCenter: true,
          autoPlayInterval: const Duration(seconds: 7),
          onPageChanged: (index, reason) {
            bannerController.setCurrentIndex(index, true);
          },
        ),
        itemCount: bannerList.length,
        itemBuilder: (context, index, _) {
          return InkWell(
            onTap: () async {
              final data = bannerDataList?[index];
              if (data == null) return;

              if (data is Item) {
                Get.find<ItemController>()
                    .navigateToItemPage(data, context);

              } else if (data is Store) {
                final store = data;

                if (isFeatured &&
                    (AddressHelper.getUserAddressFromSharedPref()?.zoneData != null &&
                        AddressHelper.getUserAddressFromSharedPref()!.zoneData!.isNotEmpty)) {

                  for (final module in Get.find<SplashController>().moduleList ?? []) {
                    if (module.id == store.moduleId) {
                      Get.find<SplashController>().setModule(module);
                      break;
                    }
                  }

                  final zoneData = AddressHelper
                      .getUserAddressFromSharedPref()!
                      .zoneData!
                      .firstWhere(
                        (data) => data.id == store.zoneId,
                    orElse: () => AddressHelper
                        .getUserAddressFromSharedPref()!
                        .zoneData!
                        .first,
                  );

                  final module = zoneData.modules!.firstWhere(
                        (m) => m.id == store.moduleId,
                    orElse: () => zoneData.modules!.first,
                  );

                  Get.find<SplashController>().setModule(
                    ModuleModel(
                      id: module.id,
                      moduleName: module.moduleName,
                      moduleType: module.moduleType,
                      themeId: module.themeId,
                      storesCount: module.storesCount,
                    ),
                  );
                }

                Get.toNamed(
                  RouteHelper.getStoreRoute(
                    id: store.id,
                    page: isFeatured ? 'module' : 'banner',
                  ),
                  arguments: StoreScreen(store: store, fromModule: isFeatured),
                );

              } else if (data is BasicCampaignModel) {

                Get.toNamed(RouteHelper.getBasicCampaignRoute(data));

              } else if (data is String) {

                if (await canLaunchUrlString(data)) {
                  await launchUrlString(
                    data,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  showCustomSnackBar('unable_to_found_url'.tr);
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GetBuilder<SplashController>(
                  builder: (splashController) {
                    return CustomImage(
                      image: bannerList[index] ?? '',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),

      /// Page Indicator
      const SizedBox(height: 10),

      GetBuilder<BannerController>(
        builder: (bannerController) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(bannerList.length, (index) {
              bool isActive = bannerController.currentIndex == index;
              int total = bannerList.length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: isActive
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          '${index + 1}/$total',
                          style: robotoRegular.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Container(
                        height: 5,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha((255 * 0.5).round()),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
              );
            }),
          );
        },
      ),
    ],
  ),
);
      // return Container(
      //   color: Colors.transparent,
      //   width: double.infinity,
      //   padding: const EdgeInsets.only(
      //       top: Dimensions.paddingSizeDefault,
      //       bottom: Dimensions.paddingSizeSmall),
      //   // padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
      //   child: CarouselSlider.builder(
      //     options: CarouselOptions(
      //       autoPlay: true,
      //       viewportFraction: 1.0,
      //       enlargeCenterPage: true,
      //       disableCenter: true,
      //       autoPlayInterval: const Duration(seconds: 7),
      //       onPageChanged: (index, reason) {
      //         bannerController.setCurrentIndex(index, true);
      //       },
      //     ),
      //     itemCount: bannerList.length,
      //     itemBuilder: (context, index, _) {
      //       return InkWell(
      //         onTap: () async {
      //           final data = bannerDataList?[index];
      //           if (data == null) return;

      //           if (data is Item) {
      //             Get.find<ItemController>()
      //                 .navigateToItemPage(data, context);
      //           } else if (data is Store) {
      //             final store = data;

      //             if (isFeatured &&
      //                 (AddressHelper.getUserAddressFromSharedPref()
      //                     ?.zoneData !=
      //                     null &&
      //                     AddressHelper.getUserAddressFromSharedPref()!
      //                         .zoneData!
      //                         .isNotEmpty)) {
      //               for (final module
      //               in Get.find<SplashController>().moduleList ?? []) {
      //                 if (module.id == store.moduleId) {
      //                   Get.find<SplashController>().setModule(module);
      //                   break;
      //                 }
      //               }

      //               final zoneData = AddressHelper
      //                   .getUserAddressFromSharedPref()!
      //                   .zoneData!
      //                   .firstWhere(
      //                     (data) => data.id == store.zoneId,
      //                 orElse: () =>
      //                 AddressHelper.getUserAddressFromSharedPref()!
      //                     .zoneData!
      //                     .first,
      //               );

      //               final module = zoneData.modules!.firstWhere(
      //                       (m) => m.id == store.moduleId,
      //                   orElse: () => zoneData.modules!.first);

      //               Get.find<SplashController>().setModule(ModuleModel(
      //                 id: module.id,
      //                 moduleName: module.moduleName,
      //                 moduleType: module.moduleType,
      //                 themeId: module.themeId,
      //                 storesCount: module.storesCount,
      //               ));
      //             }

      //             Get.toNamed(
      //               RouteHelper.getStoreRoute(
      //                   id: store.id,
      //                   page: isFeatured ? 'module' : 'banner'),
      //               arguments:
      //               StoreScreen(store: store, fromModule: isFeatured),
      //             );
      //           } else if (data is BasicCampaignModel) {
      //             Get.toNamed(RouteHelper.getBasicCampaignRoute(data));
      //           } else if (data is String) {
      //             if (await canLaunchUrlString(data)) {
      //               await launchUrlString(data,
      //                   mode: LaunchMode.externalApplication);
      //             } else {
      //               showCustomSnackBar('unable_to_found_url'.tr);
      //             }
      //           }
      //         },
      //         child: Container(
      //           decoration: BoxDecoration(
      //             color: Theme.of(context).cardColor,
      //             borderRadius:
      //             BorderRadius.circular(20),
      //             boxShadow: const [
      //               BoxShadow(
      //                   color: Colors.black12,
      //                   blurRadius: 5,
      //                   spreadRadius: 0)
      //             ],
      //           ),
      //           child: ClipRRect(
      //             borderRadius:
      //             BorderRadius.circular(20),
      //             child: GetBuilder<SplashController>(
      //               builder: (splashController) {
      //                 return CustomImage(
      //                   image: bannerList[index] ?? '',
      //                   fit: BoxFit.cover,
      //                 );
      //               },
      //             ),
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      // );
    });
  }
}

