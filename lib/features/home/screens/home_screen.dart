import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/common/controllers/theme_controller.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:handy_allinone/features/brands/controllers/brands_controller.dart';
import 'package:handy_allinone/features/home/controllers/advertisement_controller.dart';
import 'package:handy_allinone/features/home/controllers/home_controller.dart';
import 'package:handy_allinone/features/home/widgets/all_store_filter_widget.dart';
import 'package:handy_allinone/features/home/widgets/cashback_logo_widget.dart';
import 'package:handy_allinone/features/home/widgets/cashback_dialog_widget.dart';
import 'package:handy_allinone/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:handy_allinone/features/item/controllers/campaign_controller.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';
import 'package:handy_allinone/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/notification/controllers/notification_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/home/screens/modules/food_home_screen.dart';
import 'package:handy_allinone/features/home/screens/modules/grocery_home_screen.dart';
import 'package:handy_allinone/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:handy_allinone/features/home/screens/modules/shop_home_screen.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:handy_allinone/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:handy_allinone/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/item_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/paginated_list_view.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:handy_allinone/features/home/screens/web_new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/home/widgets/module_view.dart';
import 'package:handy_allinone/features/parcel/screens/parcel_category_screen.dart';
import '../../../Taxi/Taxi_home.dart';
import '../../../Taxi/ridesummary.dart';
import '../../../Taxi/sharedservice.dart';
import '../../../image_cache.dart';
import '../../../weatherapi.dart';
import '../../favourite/controllers/favourite_controller.dart';
import 'modules/meat_home_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static bool _isLoading = false;
  static bool _queuedLoad = false;

  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    if (_isLoading) {
      if (fromModule) {
        _queuedLoad = true;
      }
      return;
    }
    _isLoading = true;
    _queuedLoad = false;
    try {
      final splash = Get.find<SplashController>();
      final flash = Get.find<FlashSaleController>();
      final store = Get.find<StoreController>();
      final item = Get.find<ItemController>();
      final banner = Get.find<BannerController>();
      final category = Get.find<CategoryController>();
      final campaign = Get.find<CampaignController>();
      final adv = Get.find<AdvertisementController>();
      final parcel = Get.find<ParcelController>();
      final profile = Get.find<ProfileController>();
      final notification = Get.find<NotificationController>();
      final coupon = Get.find<CouponController>();
      final address = Get.find<AddressController>();
      final brands = Get.find<BrandsController>();

      final location = Get.find<LocationController>();
      location.syncZoneData();
      await Future.wait([
        splash.getModules(),
        banner.getFeaturedBanner(reload),
      ]);

      flash.setEmptyFlashSale(fromModule: fromModule);

      List<Future> authGroup = [];
      if (AuthHelper.isLoggedIn()) {
        authGroup.add(store.getVisitAgainStoreList(fromModule: fromModule));
      }
      if (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
        authGroup.add(Get.find<CartController>().getCartDataOnline());
      }

      List<Future> generalModuleGroup = [];
      final isNormalModule = splash.module != null &&
          !splash.configModel!.moduleConfig!.module!.isParcel! &&
          !splash.configModel!.moduleConfig!.module!.isTaxi!;

      if (isNormalModule) {
        generalModuleGroup.addAll([
          banner.getBannerList(reload),
          store.getRecommendedStoreList(),
          item.getDiscountedItemList(offset: '1', firstTimeCategoryLoad: true),
          item.getPopularItemList(offset: '1', firstTimeCategoryLoad: true),
          item.getReviewedItemList(offset: '1', firstTimeCategoryLoad: true),
          store.getPopularStoreList(reload, 'all', false),
          store.getLatestStoreList(reload, 'all', false),
          store.getTopOfferStoreList(reload, false),
          item.getRecommendedItemList(reload, 'all', false),
          category.getCategoryList(reload),
          store.getStoreList(1, reload),
          banner.getPromotionalBannerList(reload),
          adv.getAdvertisementList(),
          campaign.getBasicCampaignList(reload),
          campaign.getItemCampaignList(reload),
        ]);

        if (splash.module!.moduleType == AppConstants.grocery) {
          generalModuleGroup.add(flash.getFlashSale(reload, false));
          generalModuleGroup.add(item.getSubscriptionItemList(offset: 1));
          generalModuleGroup.add(item.getFreshItemList(offset: 1));
        }

        if (splash.module!.moduleType == AppConstants.ecommerce) {
          generalModuleGroup.addAll([
            item.getFeaturedCategoriesItemList(false, false),
            flash.getFlashSale(reload, false),
            brands.getBrandList(),
          ]);
        }
      }

      await Future.wait([
        ...authGroup,
        ...generalModuleGroup,
      ]);


      if (AuthHelper.isLoggedIn()) {
        await Future.wait([
          profile.getUserInfo(),
          notification.getNotificationList(reload),
          coupon.getCouponList(),
          Get.find<FavouriteController>().getFavouriteList(),
        ]);
      }


      if (splash.module == null && splash.configModel!.module == null) {
        await Future.wait([
          store.getFeaturedStoreList(),
          if (AuthHelper.isLoggedIn()) address.getAddressList(),
        ]);
      }


      if (splash.module != null &&
          splash.configModel!.moduleConfig!.module!.isParcel!) {
        await parcel.getParcelCategoryList();
      }


      if (splash.module != null &&
          splash.module!.moduleType == AppConstants.pharmacy) {
        await Future.wait([
          item.getBasicMedicine(reload, false),
          store.getFeaturedStoreList(),
        ]);

        await item.getCommonConditions(false);

        if (item.commonConditions!.isNotEmpty) {
          item.getConditionsWiseItem(
            item.commonConditions![0].id!,
            false,
          );
        }
      }

    } finally {
      _isLoading = false;
      if (_queuedLoad) {
        loadData(reload, fromModule: true);
      }
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();
      if ((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ??
          false) &&
          Get.find<SplashController>().showReferBottomSheet) {
        _showReferBottomSheet();
      }
    });
    

    if (!ResponsiveHelper.isWeb()) {
      if (AddressHelper.getUserAddressFromSharedPref() != null) {
        Get.find<LocationController>().getZone(
          AddressHelper.getUserAddressFromSharedPref()!.latitude,
          AddressHelper.getUserAddressFromSharedPref()!.longitude,
          false,
          updateInAddress: true,
        );
      }

    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollListener();
    });
  }
  final ValueNotifier<String?> weatherType = ValueNotifier(null);
  final ValueNotifier<List<HourlyTemperature>> hourlyTemp =
  ValueNotifier<List<HourlyTemperature>>([]);
  Future<void> getrainornot() async {
    final userAddress = AddressHelper.getUserAddressFromSharedPref();

    if (userAddress == null) {
      debugPrint('User address not found');
      return;
    }

    final lat = double.tryParse(userAddress.latitude ?? '') ?? 0.0;
    final lng = double.tryParse(userAddress.longitude ?? '') ?? 0.0;

    try {
      final weather = await getWeatherData(lat: lat, lng: lng);

      weatherType.value = weather.weatherType;

      hourlyTemp.value = weather.hourlyTemperature;

      debugPrint(weather.weatherType);
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
    }
  }
  void _setupScrollListener() {
    final homeController = Get.find<HomeController>();
    final splashController = Get.find<SplashController>();

    ScrollDirection? lastDirection;

    _scrollController.addListener(() {
      final currentDirection = _scrollController.position.userScrollDirection;
      if (currentDirection != lastDirection) {
        lastDirection = currentDirection;

        if (currentDirection == ScrollDirection.reverse) {
          if (homeController.showFavButton) {
            homeController.changeFavVisibility();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (!homeController.showFavButton) {
                homeController.changeFavVisibility();
              }
            });
          }
          splashController.hideBottomNav();
        } else if (currentDirection == ScrollDirection.forward) {
          if (!homeController.showFavButton) {
            homeController.changeFavVisibility();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (homeController.showFavButton) {
                homeController.changeFavVisibility();
              }
            });
          }
          splashController.showBottomNavBar();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        insetPadding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: const ReferBottomSheetWidget(),
      ),
      useSafeArea: false,
    ).then((value) =>
        Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) =>
        Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  Future<void> loadTaxiApis() async {
    await Get.find<TaxiHomeController>().getTaxiBannerList(true);
    await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
      await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      await Get.find<TaxiCartController>().getCarCartList();
    }
  }


  ///newly added
  Future<WeatherModel> getWeatherData({
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.token);


    if (token == null || token.isEmpty) {
      throw Exception('Authorization token not found');
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}/api/v1/customer/get-weather-data/$lat/$lng',
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      debugPrint("eknkrkr ${jsonBody.toString()}");
      return WeatherModel.fromJson(jsonBody);
    }

    else {
      debugPrint("eknkrkr ${response.statusCode.toString()}");

      throw Exception(
        'Weather API error | ${response.statusCode} | ${response.body}',
      );
    }
  }



  ///

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (splashController.moduleList != null &&
          splashController.moduleList!.length == 1) {
        splashController.switchModule(0, true);
      }

      bool showMobileModule = !ResponsiveHelper.isDesktop(context) &&
          splashController.module == null &&
          splashController.configModel!.module == null;
      bool isParcel = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.parcel;
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString().toLowerCase() ==
              AppConstants.pharmacy.toLowerCase();
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.food;
      bool isShop = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.ecommerce;
      bool isGrocery = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.grocery;
      bool isTaxi = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.taxi;
      bool isMeat = splashController.module != null &&
          splashController.module!.moduleName.toString().toLowerCase() ==
              "meat";
      debugPrint("Current Module Type: ${splashController.module?.moduleType}");
      debugPrint("isPharmacy: $isPharmacy");
      getrainornot();

      return isGrocery
          ? GroceryHomeScreen(
        hourlyTemp: hourlyTemp.value,
        scrollController: _scrollController,
        wheathertype: weatherType.value,
      ):isFood?
      FoodHomeScreen(scrollController:
      _scrollController,
        wheathertype: weatherType.value,
        hourlyTemp: hourlyTemp.value,
      )
          : GetBuilder<HomeController>(builder: (homeController) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: Scaffold(
            appBar: ResponsiveHelper.isDesktop(context)
                ? const WebMenuBar()
                : null,
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            backgroundColor: isPharmacy ? const Color(0xFFF5F5F5) : Theme.of(context).colorScheme.surface,
            body: isParcel
                ?  ParcelCategoryScreen()
                :Stack(
              children: [
                // SafeArea(
                //         top: false,
                //         left: false,
                //         right: false,
                //         bottom: true ,
                //         child:
                RefreshIndicator(
                  onRefresh: () async {
                    splashController.setRefreshing(true);
                    if (Get.find<SplashController>().module != null && !isTaxi) {
                      await Get.find<LocationController>().syncZoneData();
                      await Get.find<BannerController>().getBannerList(true);
                      if (isGrocery) {
                        await Get.find<FlashSaleController>().getFlashSale(true, true);
                      }
                      await Get.find<BannerController>().getPromotionalBannerList(true);
                      await Get.find<ItemController>().getDiscountedItemList(offset: '1');
                      await Get.find<CategoryController>().getCategoryList(true);
                      await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                      await Get.find<CampaignController>().getItemCampaignList(true);
                      Get.find<CampaignController>().getBasicCampaignList(true);
                      await Get.find<ItemController>().getPopularItemList(offset: '1');
                      await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                      await Get.find<StoreController>().getTopOfferStoreList(true, false);
                      await Get.find<ItemController>().getReviewedItemList(offset: '1');
                      await Get.find<StoreController>().getStoreList(1, true);
                      Get.find<AdvertisementController>().getAdvertisementList();
                      if (AuthHelper.isLoggedIn()) {
                        await Get.find<ProfileController>().getUserInfo();
                        await Get.find<NotificationController>().getNotificationList(true);
                        Get.find<CouponController>().getCouponList();
                      }
                      if (isPharmacy) {
                        Get.find<ItemController>()
                            .getBasicMedicine(true, true);
                        Get.find<ItemController>()
                            .getCommonConditions(true);
                      }

                      if (isShop) {
                        await Get.find<FlashSaleController>()
                            .getFlashSale(true, true);
                        Get.find<ItemController>()
                            .getFeaturedCategoriesItemList(
                            true, true);
                        Get.find<BrandsController>().getBrandList();
                      }
                    }
                    else if (isTaxi) {
                      await loadTaxiApis();
                    }
                    else {
                      await Get.find<BannerController>().getFeaturedBanner(true);
                      await Get.find<SplashController>().getModules();
                      if (AuthHelper.isLoggedIn()) {
                        await Get.find<AddressController>().getAddressList();
                      }
                      await Get.find<StoreController>().getFeaturedStoreList();
                    }
                    splashController.setRefreshing(false);
                  },
                  child: ResponsiveHelper.isDesktop(context)
                      ? WebNewHomeScreen(
                    scrollController: _scrollController,
                  )
                      : Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        slivers: [

                          ///this is for module

                          // if (showMobileModule)
                          //   !isGrocery
                          //       ? SliverToBoxAdapter(
                          //           child:
                          //           Container(
                          //             width: Dimensions
                          //                 .webMaxWidth,
                          //             height: Get.find<
                          //                         LocalizationController>()
                          //                     .isLtr
                          //                 ? 120
                          //                 : 150,
                          //             decoration: BoxDecoration(
                          //               gradient:
                          //                   LinearGradient(
                          //                 colors: [
                          //                   Colors.lightGreenAccent
                          //                       .shade700,
                          //                   Colors
                          //                       .lightGreenAccent
                          //                       .withValues(
                          //                           alpha: 0.7),
                          //                 ],
                          //                 begin: Alignment
                          //                     .topCenter,
                          //                 end: Alignment
                          //                     .bottomCenter,
                          //               ),
                          //             ),
                          //             child: Stack(
                          //               children: [
                          //                 const Positioned(
                          //                   right: 10,
                          //                   top: -30,
                          //                   child: CustomAssetImageWidget(
                          //                     Images.leaf,
                          //                     width: 100,
                          //                     height: 100,
                          //                     fit: BoxFit
                          //                         .fitHeight,
                          //                   ),
                          //                 ),
                          //                 Positioned(
                          //                   left: 10,
                          //                   top: -30,
                          //                   child: Transform(
                          //                     alignment:
                          //                     Alignment
                          //                         .center,
                          //                     transform: Matrix4
                          //                         .identity()
                          //                       ..scale(-1.0,
                          //                           1.0, 1.0),
                          //                     child:
                          //                     const CustomAssetImageWidget(
                          //                       Images.leaf,
                          //                       width: 120,
                          //                       height: 120,
                          //                       fit: BoxFit
                          //                           .contain,
                          //                     ),
                          //                   ),
                          //                 ),
                          //
                          //                 Column(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment
                          //                           .end,
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment
                          //                           .end,
                          //                   children: [
                          //                     Padding(
                          //                       padding: const EdgeInsets
                          //                           .symmetric(
                          //                           horizontal:
                          //                               8),
                          //                       child: Row(
                          //                         children: [
                          //                           const Gap(
                          //                               5),
                          //
                          //                           Container(
                          //                             decoration:
                          //                                 BoxDecoration(
                          //                               borderRadius:
                          //                                   BorderRadius.circular(8),
                          //                                   color: const Color(0xFF4BB045),
                          //                               border: Border.all(
                          //                                   width:
                          //                                       1.5,
                          //                                   color:
                          //                                   Color(0xFF4BB055)),
                          //                             ),
                          //                             child:
                          //                                 Padding(
                          //                               padding: const EdgeInsets
                          //                                   .symmetric(
                          //                                   horizontal:
                          //                                       8.0,
                          //                                   vertical:
                          //                                       8),
                          //                               child:
                          //                                   Column(
                          //                                 mainAxisAlignment:
                          //                                     MainAxisAlignment.center,
                          //                                 crossAxisAlignment:
                          //                                     CrossAxisAlignment.center,
                          //                                 children: [
                          //                                   Text(
                          //                                     "10-25",
                          //                                     style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: 16),
                          //                                   ),
                          //                                   Text(
                          //                                     "MINS",
                          //                                     style: robotoBold.copyWith(color: Theme.of(context).cardColor, fontSize: 14),
                          //                                   ),
                          //                                 ],
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           const Gap(
                          //                               10),
                          //
                          //                           (splashController.module !=
                          //                                       null &&
                          //                                   splashController.configModel!.module ==
                          //                                       null)
                          //                               ? InkWell(
                          //                                   onTap:
                          //                                       () {
                          //                                     splashController.removeModule();
                          //                                     Get.find<StoreController>().resetStoreData();
                          //                                   },
                          //                                   child:
                          //                                       Image.asset(
                          //                                     Images.homeIcon,
                          //                                     height: 25,
                          //                                     width: 25,
                          //                                     color: Theme.of(context).primaryColor,
                          //                                   ),
                          //                                 )
                          //                               : const SizedBox(),
                          //                           SizedBox(
                          //                             width: (splashController.module != null &&
                          //                                     splashController.configModel!.module ==
                          //                                         null)
                          //                                 ? Dimensions
                          //                                     .paddingSizeSmall
                          //                                 : 0,
                          //                           ),
                          //                           Expanded(
                          //                             child:
                          //                                 InkWell(
                          //                               onTap: () =>
                          //                                   Get.find<LocationController>().navigateToLocationScreen('home'),
                          //                               child:
                          //                                   Padding(
                          //                                 padding:
                          //                                     EdgeInsets.symmetric(
                          //                                   vertical:
                          //                                       Dimensions.paddingSizeSmall,
                          //                                   horizontal: ResponsiveHelper.isDesktop(context)
                          //                                       ? Dimensions.paddingSizeSmall
                          //                                       : 0,
                          //                                 ),
                          //                                 child:
                          //                                     GetBuilder<LocationController>(builder: (_) {
                          //                                   return Column(
                          //                                     crossAxisAlignment: CrossAxisAlignment.start,
                          //                                     children: [
                          //                                       Row(
                          //                                         children: [
                          //                                           Transform.rotate(
                          //                                               angle: 175,
                          //                                               child: const Icon(
                          //                                                 Icons.send_rounded,
                          //                                                 size: 22,
                          //                                               )),
                          //                                           const Gap(10),
                          //                                           Text(
                          //                                             AuthHelper.isLoggedIn() ? AddressHelper.getUserAddressFromSharedPref()!.addressType!.tr : 'your_location'.tr,
                          //                                             maxLines: 2,
                          //                                             overflow: TextOverflow.ellipsis,
                          //                                             style: robotoBold.copyWith(
                          //                                               fontSize: Dimensions.fontSizeLarge,
                          //                                             ),
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                       Row(
                          //                                         children: [
                          //                                           Flexible(
                          //                                             child: Text(
                          //                                               AddressHelper.getUserAddressFromSharedPref()!.address!,
                          //                                               maxLines: 2,
                          //                                               overflow: TextOverflow.ellipsis,
                          //                                               style: robotoBold.copyWith(
                          //                                                 fontSize: Dimensions.fontSizeSmall,
                          //                                                 color: Theme.of(context).cardColor,
                          //                                               ),
                          //                                             ),
                          //                                           ),
                          //                                           Icon(
                          //                                             Icons.expand_more,
                          //                                             size: 22,
                          //                                             color: Theme.of(context).cardColor,
                          //                                           ),
                          //                                         ],
                          //                                       ),
                          //                                     ],
                          //                                   );
                          //                                 }),
                          //                               ),
                          //                             ),
                          //                           ),
                          //
                          //                           // Notifications icon
                          //                           InkWell(
                          //                             onTap: () =>
                          //                                 Get.toNamed(
                          //                                     RouteHelper.getNotificationRoute()),
                          //                             child: GetBuilder<
                          //                                 NotificationController>(
                          //                               builder:
                          //                                   (notificationController) {
                          //                                 return Stack(
                          //                                   children: [
                          //                                     Icon(
                          //                                       CupertinoIcons.bell,
                          //                                       size: 25,
                          //                                       color: Theme.of(context).cardColor,
                          //                                     ),
                          //                                     notificationController.hasNotification
                          //                                         ? Positioned(
                          //                                             top: 0,
                          //                                             right: 0,
                          //                                             Container(
                          //                                               height: 10,
                          //                                               width: 10,
                          //                                               decoration: BoxDecoration(
                          //                                                 color: Theme.of(context).primaryColor,
                          //                                                 shape: BoxShape.circle,
                          //                                                 border: Border.all(
                          //                                                   width: 1,
                          //                                                   color: Theme.of(context).cardColor,
                          //                                                 ),
                          //                                               ),
                          //                                             ),
                          //                                           )
                          //                                         : const SizedBox(),
                          //                                   ],
                          //                                 );
                          //                               },
                          //                             ),
                          //                           ),
                          //
                          //                           const SizedBox(
                          //                               width:
                          //                                   8),
                          //
                          //                           // Wishlist icon
                          //                           // InkWell(
                          //                           //   onTap: () => Navigator.of(context).push(
                          //                           //     MaterialPageRoute(
                          //                           //       builder: (context) =>
                          //                           //       const FavouriteScreen(),
                          //                           //     ),
                          //                           //   ),
                          //                           //   child: Icon(
                          //                           //     CupertinoIcons.heart,
                          //                           //     size: 25,
                          //                           //     color: Theme.of(context).textTheme.bodyLarge!.color,
                          //                           //   ),
                          //                           // ),
                          //             GetBuilder<ProfileController>(
                          //               builder: (profileController) {
                          //                 final bool isLoggedIn = AuthHelper.isLoggedIn();
                          //
                          //                 final imageUrl = isLoggedIn &&
                          //                     profileController.userInfoModel != null
                          //                     ? profileController.userInfoModel!.imageFullUrl ?? ''
                          //                     : Images.guestDummyIcon;
                          //
                          //                 return Container(
                          //                   decoration: const BoxDecoration(
                          //                     shape: BoxShape.circle,
                          //                   ),
                          //                   Container(
                          //                     margin: const EdgeInsets.all(4),
                          //                     decoration: const BoxDecoration(
                          //                       shape: BoxShape.circle,
                          //                     ),
                          //                     height: 38,
                          //                     width: 38,
                          //                     child: Center(
                          //                       child: ClipOval(
                          //                         child: CustomImage(
                          //                           placeholder: Images.guestDummyIcon,
                          //                           image: imageUrl,
                          //                           height: 38,
                          //                           width: 38,
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 );
                          //               },
                          //             )
                          //
                          //             ],
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         )
                          //       : const SliverToBoxAdapter(child: SizedBox())

                          ///want to remove



                          if (isMeat || isPharmacy)
                            !isGrocery
                                ? SliverAppBar(
                              floating: true,
                              elevation: 0,
                              automaticallyImplyLeading:
                              false,
                              surfaceTintColor: isPharmacy ? Colors.transparent : Theme.of(context)
                                  .primaryColor,
                              backgroundColor:
                              ResponsiveHelper
                                  .isDesktop(
                                  context)
                                  ? Colors.transparent
                                  : isPharmacy ? Colors.white : Theme.of(context)
                                  .primaryColor,
                              title: Center(
                                child: Container(
                                  width: Dimensions
                                      .webMaxWidth,
                                  height: Get.find<
                                      LocalizationController>()
                                      .isLtr
                                      ? 60
                                      : 70,
                                  color: isPharmacy ? Colors.white : Theme.of(context)
                                      .primaryColor,
                                  child: Row(
                                    children: [
                                      if (isPharmacy) ...[
                                        InkWell(
                                          onTap: () {
                                            Get.find<SplashController>().removeModule();
                                            Get.find<StoreController>().resetStoreData();
                                          },
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      ]
                                      else if (Get.find<SplashController>()
                                          .module !=
                                          null &&
                                          Get.find<SplashController>()
                                              .configModel!
                                              .module ==
                                              null &&
                                          Get.find<SplashController>()
                                              .moduleList
                                              ?.length !=
                                              1)
                                        InkWell(
                                          onTap: () {
                                            Get.find<
                                                SplashController>()
                                                .removeModule();
                                            Get.find<
                                                StoreController>()
                                                .resetStoreData();
                                          },
                                          child:
                                          Image.asset(
                                            Images
                                                .moduleIcon,
                                            height: 30,
                                            width: 30,
                                            color: isPharmacy ? Colors.black : Theme.of(
                                                context)
                                                .cardColor,
                                          ),
                                        ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => Get
                                              .find<
                                              LocationController>()
                                              .navigateToLocationScreen(
                                              'home'),
                                          child: Padding(
                                            padding:
                                            EdgeInsets
                                                .symmetric(
                                              vertical:
                                              Dimensions
                                                  .paddingSizeSmall,
                                              horizontal: ResponsiveHelper.isDesktop(
                                                  context)
                                                  ? Dimensions
                                                  .paddingSizeSmall
                                                  : 0,
                                            ),
                                            child: GetBuilder<
                                                LocationController>(
                                                builder:
                                                    (locationController) {
                                                  final userAddress =
                                                  AddressHelper
                                                      .getUserAddressFromSharedPref();
                                                  return Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          userAddress!.address!,
                                                          style: robotoMedium.copyWith(
                                                            color: isPharmacy ? Colors.black : Theme.of(context).cardColor,
                                                            fontSize: Dimensions.fontSizeDefault,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.expand_more,
                                                        color: isPharmacy ? Colors.black : Theme.of(context).cardColor,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            Get.toNamed(
                                              RouteHelper
                                                  .getNotificationRoute(),
                                            ),
                                        child: GetBuilder<
                                            NotificationController>(
                                          builder:
                                              (notificationController) {
                                            return Stack(
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .bell,
                                                  size:
                                                  25,
                                                  color: isPharmacy ? Colors.black : Theme.of(context)
                                                       .cardColor,
                                                ),
                                                if (notificationController
                                                    .hasNotification)
                                                  Positioned(
                                                    top:
                                                    0,
                                                    right:
                                                    0,
                                                    child:
                                                 Container(
                                                      height:
                                                      10,
                                                      width:
                                                      10,
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Theme.of(context).primaryColor,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Theme.of(context).cardColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                              ),
                              actions: const [SizedBox()],
                            )
                                : const SliverAppBar(),

                          !isGrocery
                              ? SliverPersistentHeader(
                              pinned: true,
                              delegate: SliverDelegate(
                                  callback: (val) {},
                                  height: (isMeat || isPharmacy) ? 60 : 0,
                                  child: (isMeat || isPharmacy)
                                      ? Center(
                                      child: Stack(
                                          children: [
                                                 Container(
                                              height: 60,
                                              width: Dimensions
                                                  .webMaxWidth,
                                              color: Theme.of(
                                                  context)
                                                  .colorScheme
                                                  .surface,
                                              child: Column(
                                                  children: [
                                                      Expanded(
                                                          child: Container(color: isPharmacy ? Colors.white : Theme.of(context).primaryColor)),
                                                    Expanded(
                                                        child: Container(color: Colors.transparent)),
                                                  ]),
                                            ),
                                            Positioned(
                                              left: 10,
                                              right: 10,
                                              top: 5,
                                              bottom: 5,
                                              child:
                                              InkWell(
                                                onTap: () =>
                                                    Get.toNamed(
                                                         RouteHelper.getSearchRoute()),
                                                 child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal:
                                                      Dimensions.paddingSizeSmall),
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical:
                                                      3),
                                                  decoration:
                                                  BoxDecoration(
                                                    color: isPharmacy ? const Color(0xFFF5F5F5) : Theme.of(context).cardColor,
                                                    border: isPharmacy ? null : Border.all(color: Theme.of(context).disabledColor.withAlpha(100)),
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                                  ),
                                                  child:
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons.search,
                                                        size: 20,
                                                        color: Colors.black.withValues(alpha: 0.5),
                                                      ),
                                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                                      Expanded(
                                                        child: Text(
                                                          isPharmacy ? 'Search medicines, health products...' : 'Search for...',
                                                          style: robotoRegular.copyWith(
                                                            fontSize: Dimensions.fontSizeDefault,
                                                            color: Colors.black.withValues(alpha: 0.5),
                                                          ),
                                                        ),
                                                      ),
                                                      if (!isPharmacy) ...[
                                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                        const SizedBox(
                                                            width: Dimensions.paddingSizeExtraSmall,
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 6.0),
                                                              child: VerticalDivider(
                                                                color: Colors.grey,
                                                                width: 2,
                                                              ),
                                                            )),
                                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                        Icon(
                                                          CupertinoIcons.mic,
                                                          size: 25,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]))
                                      : const SizedBox()))
                              : const SliverToBoxAdapter(),

                          SliverToBoxAdapter(
                            child: Center(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: !showMobileModule
                                    ? Stack(
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          !isMeat
                                              ? !isGrocery && !isPharmacy
                                              ? ClipRRect(
                                              borderRadius: const BorderRadius
                                                  .only(
                                                bottomLeft: Radius.circular(20.0),
                                                bottomRight: Radius.circular(20.0),
                                              ),
                                              child: FutureBuilder<
                                                  Uint8List?>(
                                                future: CrossPlatformImageCache.getCachedOrUpdatedImage(
                                                  '${AppConstants.baseUrl}/image-proxy?url=${AppConstants.baseUrl}${AppConstants.searchimage}${Get.find<SplashController>().configModel!.searchimage!}',
                                                ),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return TweenAnimationBuilder(
                                                      tween: Tween<double>(begin: 0, end: 2 * math.pi),
                                                      duration: const Duration(seconds: 5),
                                                      builder: (context, value, child) {
                                                        return Container(
                                                          height: context.height / 2,
                                                          width: context.width > 700 ? 500 : context.width,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Theme.of(context).primaryColor,
                                                                Colors.yellow.shade900,
                                                              ],
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                  return Image.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.fill,
                                                    height: context.height / 2,
                                                    width: context.width > 700 ? 500 : context.width,
                                                  );
                                                },
                                              ))
                                              : const SizedBox
                                              .shrink()
                                              : const SizedBox
                                              .shrink(),
                                          isGrocery
                                              ? (isMeat
                                              ? Container(
                                              color: Colors.orange,
                                              child: Padding(
                                                padding: const EdgeInsets.all(80.0),
                                                child: const MeatHomeScreen(),
                                              ))
                                              : GroceryHomeScreen(
                                            scrollController:
                                            _scrollController,
                                            hourlyTemp:  hourlyTemp.value,
                                          ))
                                              : isPharmacy
                                              ? const PharmacyHomeScreen()
                                              : isFood
                                              ? FoodHomeScreen(scrollController:
                                          _scrollController,
                                            hourlyTemp:  hourlyTemp.value,
                                          )
                                              : isShop
                                              ? const ShopHomeScreen()
                                              : isTaxi
                                              ? const TaxiHomeScreen()
                                              : const SizedBox(),
                                        ]),
                                    !isMeat && !isPharmacy
                                        ? !isGrocery
                                        ? Positioned(
                                      top: 20,
                                      right: 5,
                                      left: 5,
                                      child:
                                      Center(
                                        child:
                                        Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8.0),
                                          child:
                                          SizedBox(
                                            width:
                                            Dimensions.webMaxWidth,
                                            height: Get.find<LocalizationController>().isLtr
                                                ? 60
                                                : 70,
                                            child:
                                            Row(
                                              children: [
                                                (splashController.module != null && splashController.configModel!.module == null)
                                                    ? InkWell(
                                                  onTap: () {
                                                    splashController.removeModule();
                                                    Get.find<StoreController>().resetStoreData();
                                                  },
                                                  child: Image.asset(
                                                    Images.homeIcon,
                                                    height: 25,
                                                    width: 25,
                                                    color: Theme.of(context).cardColor,
                                                  ),
                                                )
                                                    : const SizedBox(),
                                                SizedBox(
                                                  width: (splashController.module != null && splashController.configModel!.module == null) ? Dimensions.paddingSizeSmall : 0,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        vertical: Dimensions.paddingSizeSmall,
                                                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                                                      ),
                                                      child: GetBuilder<LocationController>(
                                                        builder: (locationController) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                AuthHelper.isLoggedIn() ? AddressHelper.getUserAddressFromSharedPref()?.addressType?.tr ?? 'your_location'.tr : 'your_location'.tr,
                                                                style: robotoMedium.copyWith(
                                                                  color: Theme.of(context).cardColor,
                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      AddressHelper.getUserAddressFromSharedPref()?.address ?? '',
                                                                      style: robotoRegular.copyWith(
                                                                        color: Theme.of(context).cardColor,
                                                                        fontSize: Dimensions.fontSizeSmall,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons.expand_more,
                                                                    color: Theme.of(context).cardColor,
                                                                    size: 18,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  child: GetBuilder<NotificationController>(
                                                    builder: (notificationController) {
                                                      return Stack(
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons.bell,
                                                            size: 25,
                                                            color: Theme.of(context).cardColor,
                                                          ),
                                                          notificationController.hasNotification
                                                              ? Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Container(
                                                              height: 10,
                                                              width: 10,
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).cardColor,
                                                                shape: BoxShape.circle,
                                                                border: Border.all(
                                                                  width: 1,
                                                                  color: Theme.of(context).cardColor,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                              : const SizedBox(),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        : const SizedBox
                                        .shrink()
                                        : const SizedBox
                                        .shrink(),
                                    !isMeat && !isPharmacy
                                        ? !isGrocery
                                        ? Positioned(
                                      top: 80,
                                      right: 5,
                                      left: 5,
                                      child:
                                                 Container(
                                        height:
                                        50,
                                        width: Dimensions
                                            .webMaxWidth,
                                        color: searchBgShow
                                            ? Get.find<ThemeController>().darkTheme
                                            ? Theme.of(context).colorScheme.surface
                                            : isPharmacy ? const Color(0xFFF5F5F5) : Theme.of(context).cardColor
                                            : null,
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                            Dimensions.paddingSizeSmall),
                                        child:
                                        InkWell(
                                          onTap: () =>
                                              Get.toNamed(RouteHelper.getSearchRoute()),
                                          child:
                                                 Container(
                                            padding:
                                            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                            margin:
                                            const EdgeInsets.symmetric(vertical: 3),
                                            decoration:
                                            BoxDecoration(
                                              color: Theme.of(context).cardColor,
                                              border: Border.all(
                                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 5,
                                                  spreadRadius: 1,
                                                )
                                              ],
                                            ),
                                            child:
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      const SizedBox(width: 10.0, height: 100.0),
                                                      Text(
                                                        'Search for',
                                                        style: robotoRegular.copyWith(
                                                          fontSize: Dimensions.fontSizeLarge,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5, height: 100.0),
                                                      GetBuilder<CategoryController>(
                                                        builder: (categoryController) {
                                                          if (categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty) {
                                                            return AnimatedTextKit(
                                                              repeatForever: true,
                                                              animatedTexts: categoryController.categoryList!
                                                                  .map((category) => RotateAnimatedText(
                                                                ("${(category.name?.capitalizeFirst)}"),
                                                                textStyle: robotoRegular.copyWith(
                                                                  fontSize: Dimensions.fontSizeLarge,
                                                                  color: isPharmacy ? Colors.black : Theme.of(context).primaryColor,
                                                                ),
                                                              ))
                                                                  .toList(),
                                                            );
                                                          } else {
                                                            return const Text('Loading categories...');
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                Icon(
                                                  CupertinoIcons.search,
                                                  size: 25,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                const SizedBox(
                                                    width: Dimensions.paddingSizeExtraSmall,
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 6.0),
                                                      child: VerticalDivider(
                                                        color: Colors.grey,
                                                        width: 2,
                                                      ),
                                                    )),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                                Icon(
                                                  CupertinoIcons.mic,
                                                  size: 25,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                        : const SizedBox
                                        .shrink()
                                        : const SizedBox
                                        .shrink(),
                                  ],
                                )

                                    : ModuleView(
                                    scrollController:
                                    _scrollController,
                                    splashController:
                                    splashController),
                              ),
                            ),
                          ),

                          !showMobileModule && !isTaxi && !isPharmacy
                              ? SliverPersistentHeader(
                            pinned: true,
                            delegate: SafeAreaSliverDelegate(
                              baseHeight: 110,
                              callback: (val) =>
                              searchBgShow = val,
                              child: const Stack(
                                children: [
                                  Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child:
                                      AllStoreFilterWidget()),
                                ],
                              ),
                            ),
                          )
                              : const SliverToBoxAdapter(),

                          SliverToBoxAdapter(
                            child: !showMobileModule && !isTaxi && !isPharmacy
                                ? Center(
                              child: Column(
                                children: [
                                  GetBuilder<
                                      StoreController>(
                                    builder:
                                        (storeController) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: ResponsiveHelper
                                                .isDesktop(
                                                context)
                                                ? 0
                                                : 0),
                                        child:
                                        PaginatedListView(
                                          scrollController:
                                          _scrollController,
                                          totalSize: storeController
                                              .storeModel
                                              ?.totalSize,
                                          offset: storeController
                                              .storeModel
                                              ?.offset,
                                          onPaginate: (int?
                                          offset) async =>
                                          await storeController
                                              .getStoreList(
                                              offset!,
                                              false),
                                          itemView: isFood ||
                                              isGrocery
                                              ? Container(
                                            child:
                                            ItemsView(
                                              isStore:
                                              true,
                                              items:
                                              null,
                                              isFoodOrGrocery:
                                              (isFood || isGrocery),
                                              stores: storeController
                                                  .storeModel
                                                  ?.stores,
                                              padding:
                                              EdgeInsets.symmetric(
                                                horizontal: ResponsiveHelper.isDesktop(context)
                                                    ? Dimensions.paddingSizeExtraSmall
                                                    : Dimensions.paddingSizeSmall,
                                                vertical: ResponsiveHelper.isDesktop(context)
                                                    ? Dimensions.paddingSizeExtraSmall
                                                    : Dimensions.paddingSizeExtraSmall,
                                                // vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                                              ),
                                            ),
                                          )
                                              : ItemsView(
                                            isStore:
                                            true,
                                            items:
                                            null,
                                            isFoodOrGrocery:
                                            (isFood ||
                                                isGrocery),
                                            stores: storeController
                                                .storeModel
                                                ?.stores,
                                            padding:
                                            EdgeInsets.symmetric(
                                              horizontal: ResponsiveHelper.isDesktop(context)
                                                  ? Dimensions.paddingSizeExtraSmall
                                                  : Dimensions.paddingSizeSmall,
                                              vertical: ResponsiveHelper.isDesktop(context)
                                                  ? Dimensions.paddingSizeExtraSmall
                                                  : Dimensions.paddingSizeDefault,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  isFood
                                      ? const FoodAnimatedBanner()
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 150,
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                      BackToTopButton(
                        scrollController: _scrollController,
                        isNavVisible:
                        splashController.showBottomNav,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: AuthHelper.isLoggedIn() &&
                homeController.cashBackOfferList != null &&
                homeController.cashBackOfferList!.isNotEmpty
                ? homeController.showFavButton
                ? Padding(
              padding: EdgeInsets.only(
                  bottom: 80.0,
                  right: ResponsiveHelper.isDesktop(context)
                      ? 50
                      : 0),
              child: InkWell(
                onTap: () =>
                    Get.dialog(const CashBackDialogWidget()),
                child: const CashBackLogoWidget(),
              ),
            )
                : null
                : null,
          ),
        );
      });
    });
  }
}

class SafeAreaSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double baseHeight;
  final Function(bool)? callback;

  SafeAreaSliverDelegate({
    required this.child,
    this.baseHeight = 200,
    this.callback,
  });

  @override
  double get minExtent => baseHeight;

  @override
  double get maxExtent => baseHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bool isPinned = shrinkOffset > 0;
    callback?.call(isPinned);
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: isPinned,
        bottom: false,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SafeAreaSliverDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.baseHeight != baseHeight;
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  SliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent /*|| shrinkOffset < maxExtent*/;
    callback!(isPinned);
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

class BackToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final bool isNavVisible;

  const BackToTopButton({
    super.key,
    required this.scrollController,
    required this.isNavVisible,
  });

  @override
  State<BackToTopButton> createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<BackToTopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // continuous bounce loop

    _bounce = Tween<double>(begin: 0, end: -10)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashController>();

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          offset: widget.isNavVisible ? const Offset(0, 1.5) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: widget.isNavVisible ? 0.0 : 1.0,
            child: AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounce.value),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    splashController.showBottomNavBar();
                    widget.scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text('Back to Top',
                            style: robotoRegular.copyWith(
                                color: Theme.of(context).cardColor)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FoodAnimatedBanner extends StatefulWidget {
  const FoodAnimatedBanner({super.key});

  @override
  State<FoodAnimatedBanner> createState() => _FoodAnimatedBannerState();
}

class _FoodAnimatedBannerState extends State<FoodAnimatedBanner> {
  final List<String> messages = [
    "Good Food\nGood Mood!",
    "What do you want?\nScroll top,\nexplore, and enjoy!",
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % messages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showLottie = _currentIndex == 1;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Center(
            child: Lottie.asset("assets/animation/Searching.json",
                height: 200, width: 200, repeat: true),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class WeatherModel {
  final bool status;
  final String weatherType;
  final int weatherCode;
  final double temperature;
  final List<HourlyTemperature> hourlyTemperature;


  WeatherModel({
    required this.status,
    required this.weatherType,
    required this.weatherCode,
    required this.temperature,
    required this.hourlyTemperature,

  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      status: json['status'] ?? false,
      weatherType: json['weather_type'] ?? '',
      weatherCode: json['weather_code'] ?? 0,
      hourlyTemperature: (json['hourly_temperature'] as List?)
          ?.map((e) => HourlyTemperature.fromJson(e))
          .toList() ??
          [],
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
    );
  }
}