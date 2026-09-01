import 'dart:async';
import 'dart:io';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/Taxi/Taxi_home.dart';
import 'package:handy_allinone/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:handy_allinone/features/home/controllers/home_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/order/controllers/order_controller.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/address/screens/address_screen.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/features/rental_module/rental_favourite/screens/vehicle_favourite_screen.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/taxi_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/custom_dialog.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:handy_allinone/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:handy_allinone/features/favourite/screens/favourite_screen.dart';
import 'package:handy_allinone/features/home/screens/home_screen.dart';
import 'package:handy_allinone/features/menu/screens/menu_screen.dart';
import 'package:handy_allinone/features/order/screens/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Taxi/booking_history.dart';
import '../../../Taxi/ridesummary.dart';
import '../../../Taxi/sharedservice.dart';
import '../../../helper/address_helper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/screens/cart_screen.dart';
import '../../category/screens/category_screen.dart';
import '../../../common/widgets/booking_status_banner.dart';

import '../../store/widgets/bottom_cart_widget.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;

  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  bool _hasDropoff = false;
  bool _showRideBanner = false;
  String _rideStatus = '';
  int _bookingId = 0;
  int _driverId = 0;
  int _userId = 0;
  String _otp = '';
  bool _showFloatingIcon = false;
  Offset _floatingIconOffset = const Offset(0, 0);
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  final InAppReview inAppReview = InAppReview.instance;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  late bool _isLogin;
  bool active = false;
  bool isBookingTab = false;

  StreamSubscription<DatabaseEvent>? _rideStatusSubscription;
  void _listenToStoredRideStatus() async {
    final isLoggedIn = await AuthHelper.isLoggedIn();
    if (!isLoggedIn) return;

    final fullData = await SharedService.getOngoingBooking();
    if (fullData != null &&
        fullData.containsKey('bookingId') &&
        fullData.containsKey('driverId') &&
        fullData.containsKey('userId') &&
        fullData.containsKey('otp')) {
      _bookingId = fullData['bookingId'];
      _driverId = fullData['driverId'];
      _userId = fullData['userId'];
      _otp = fullData['otp'];
    } else {
      final idData = await SharedService.getBookingIdFromPrefs();
      if (idData != null &&
          idData.containsKey('bookingId') &&
          idData.containsKey('userId') &&
          idData.containsKey('otp')) {
        _bookingId = idData['bookingId'];
        _userId = idData['userId'];
        _otp = idData['otp'];
      } else {
        print("ℹ️ No stored booking data found. this is dashboard");
        return;
      }
    }

    // if (_bookingId == null) {
    //   print("❌ Booking ID is null.");
    //   return;
    // }

    _rideStatusSubscription?.cancel();

    final ref = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: AppConstants.firebaseDBURL,
    ).ref('bookings/$_bookingId');

    _rideStatusSubscription = ref.onValue.listen((event) async {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        print("ℹ️ Firebase booking node does not exist. Clearing ongoing booking.");
        await SharedService.clearOngoingBooking();
        if (!mounted) return;
        setState(() {
          _showRideBanner = false;
          _showFloatingIcon = false;
        });
        return;
      }
      final snapshot = event.snapshot.value as Map<dynamic, dynamic>?;

      if (snapshot != null && snapshot['ride_status'] != null) {
        final status = snapshot['ride_status'].toString();
        if (status == 'completed' || status == 'cancelled') {
          await SharedService.clearOngoingBooking();
          if (!mounted) return;
          setState(() {
            _showRideBanner = false;
            _showFloatingIcon = false;
          });
        }
        else if (['pending', 'accepted', 'arrived', 'in_progress', 'dropped']
            .contains(status)) {
          final driverIdsMap = snapshot['driver_ids'];
          if (driverIdsMap is Map && driverIdsMap.isNotEmpty) {
            final rawDriverKey = driverIdsMap.keys.first;
            final parsedDriverId = int.tryParse(
              rawDriverKey.replaceAll(RegExp(r'[^0-9]'), ''),
            );
            if (parsedDriverId != null) {
              _driverId = parsedDriverId;
              await SharedService.saveOngoingBooking(
                _bookingId,
                _driverId,
                _userId,
                _otp,
              );
            }
          }
          if (!mounted) return;
          setState(() {
            _rideStatus = status;
            _showRideBanner = true;
          });
          print("✅ Showing Ride Banner: $_showRideBanner this is dashboard");
        }
      }
    });
  }

  void _handleBannerTap() {
    if (['accepted', 'arrived', 'in_progress', 'dropped'].contains(_rideStatus)) {
      Get.to(() => RideConfirmedScreen(
        Bookingid: _bookingId,
        driverid: _driverId,
        userId: _userId,
        otp: _otp,
      ));
    } else if (_rideStatus == 'pending') {
      Get.to(() => Taxihome(
        showBottomSheet: true,
        bookingId: _bookingId,
        userId: _userId,
        otp: _otp,
      ));
    } else {
      print("❌ Ride status $_rideStatus not actionable.");
    }
  }

  Widget _buildFloatingIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.directions_car, color: Colors.white),
    );
  }

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();
    _loadDropoffFlag();
    _showRegistrationSuccessBottomSheet();

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
          Get.find<AuthController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
            const Duration(seconds: 1),
                () => showAnimatedDialog(
                Get.context!, const CongratulationDialogue()));
      }
      _autoSelectStoredAddress().then((value) => suggestAddressBottomSheet());
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }

    _pageIndex = widget.pageIndex;
    if(_pageIndex == 2) {
      isBookingTab = true;
    }

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const FavouriteScreen(),
      Taxihome(),
      const CartScreen(fromNav: false),
      const OrderScreen(),
      const MenuScreen(fromNav: true),HistoryScreen()
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    });
    _listenToStoredRideStatus();
  }

  Future<void> _loadDropoffFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasDropoff = prefs.getBool('hasDropoff') ?? false;
    });
  }
  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet =
    Get.find<HomeController>().getRegistrationSuccessfulSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context)
            ? Get.dialog(
            const Dialog(child: StoreRegistrationSuccessBottomSheet()))
            .then((value) {
          Get.find<HomeController>()
              .saveRegistrationSuccessfulSharedPref(false);
          Get.find<HomeController>()
              .saveIsStoreRegistrationSharedPref(false);
          setState(() {});
        })
            : showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const StoreRegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<HomeController>()
              .saveRegistrationSuccessfulSharedPref(false);
          Get.find<HomeController>()
              .saveIsStoreRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  Future<void> _autoSelectStoredAddress() async {
    if (AddressHelper.getUserAddressFromSharedPref() == null) {
      if (Get.find<AddressController>().addressList == null) {
        await Get.find<AddressController>().getAddressList();
      }
      if (Get.find<AddressController>().addressList != null && Get.find<AddressController>().addressList!.isNotEmpty) {
        AddressModel address = Get.find<AddressController>().addressList![0];
        Get.find<LocationController>().saveAddressAndNavigate(
          address, false, null, false, ResponsiveHelper.isDesktop(Get.context),
        );
      }
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    final bool isLocation = await loc.Location().serviceEnabled();
    /**
     * AUTHORE: SARAVANAN
     * PURPOSE: the location want topop up when the user hase trun off
     *
     * widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        !active
     *
     * i have removed the reversor operator ! asper rubini sayed
     */

    bool moduel = AddressHelper.isLocationSelected();

    if (!moduel && (widget.fromSplash &&
        Get.find<LocationController>().showLocationSuggestion &&
        active ||
        (!isLocation && !moduel))) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().showSuggestedLocation(false);
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return GetBuilder<SplashController>(builder: (splashController) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (_pageIndex != 0) {
            _setPage(0);
          } else {
            if (!ResponsiveHelper.isDesktop(context) &&
                Get.find<SplashController>().module != null &&
                Get.find<SplashController>().configModel!.module == null) {
              Get.find<SplashController>().removeModule();
              Get.find<StoreController>().resetStoreData();
            } else {
              if (_canExit) {
                if (GetPlatform.isAndroid) {
                  SystemNavigator.pop();
                } else if (GetPlatform.isIOS) {
                  exit(0);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('back_press_again_to_exit'.tr,
                      style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));
                _canExit = true;
                Timer(const Duration(seconds: 2), () {
                  _canExit = false;
                });
              }
            }
          }
        },
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            List<OrderModel> runningOrder =
            orderController.runningOrderModel != null
                ? orderController.runningOrderModel!.orders!
                : [];

            List<OrderModel> reversOrder = List.from(runningOrder.reversed);

            return SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: Scaffold(
                key: _scaffoldKey,
                body: ExpandableBottomSheet(
                  background: Stack(children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _screens.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _screens[index];
                      },
                    ),
                    ResponsiveHelper.isDesktop(context) || keyboardVisible
                        ? const SizedBox()
                        : Align(
                      alignment: Alignment.bottomCenter,
                      child: GetBuilder<SplashController>(
                          builder: (splashController) {
                            bool isParcel = splashController.module != null &&
                                splashController.configModel!.moduleConfig!
                                    .module!.isParcel!;
                            bool isTaxiWithCache = ((splashController
                                .module !=
                                null &&
                                splashController.module!.moduleType
                                    .toString() ==
                                    AppConstants.taxi) ||
                                (splashController.cacheModule != null &&
                                    splashController
                                        .cacheModule!.moduleType
                                        .toString() ==
                                        AppConstants.taxi)) &&
                                TaxiHelper.haveTaxiModule();
                            bool isTaxi = (splashController.module != null &&
                                splashController.module!.moduleType
                                    .toString() ==
                                    AppConstants.taxi);
                            bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
                            isParcel = isParcel && !isTaxiWithCache;

                            _screens = [
                              const HomeScreen(),
                              isParcel
                                  ? const AddressScreen(fromDashboard: true)
                                  : isTaxi
                                  ? const VehicleFavouriteScreen()
                                  : isPharmacy ? const CategoryScreen() : const FavouriteScreen(),
                              Taxihome(),
                              isPharmacy ? const FavouriteScreen() : (Get.find<CartController>()
                                  .availableList
                                  .isNotEmpty
                                  ? const SizedBox()
                                  : const CartScreen(fromNav: false)),
                              OrderScreen(index: isTaxi ? 1 : 0),
                              const MenuScreen(fromNav: true),
                              HistoryScreen(),
                            ];

                            return  Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if(splashController.module!=null && splashController.module?.id!=null)   Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                  padding: isPharmacy ? EdgeInsets.only(left: 18.w, right: 18.w, bottom: 4.w) : EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: isPharmacy ? Colors.transparent : const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(isPharmacy ? 15 : Dimensions.radiusLarge),
                                        boxShadow: isPharmacy ? [
                                          BoxShadow(
                                            color: Colors.lightGreenAccent.withValues(alpha: 0.3),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : [
                                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                                        ],
                                      ),
                                      child: isPharmacy ? const BottomCartWidget() : const BottomCartWidgetStore()),
                                ),
                                ),
                                splashController.showBottomNav
                                    ?    AnimatedSlide(
                                  duration:
                                  const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  offset: Offset.zero,
                                  child: AnimatedOpacity(
                                    duration:
                                    const Duration(milliseconds: 300),
                                    opacity: 1.0,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        isPharmacy ? Container(
                                          width: size.width,
                                          height: GetPlatform.isIOS ? 90 : 75,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, -5),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _pharmacyNavItem(context, 'Home', Images.homeSelect, Images.homeUnselect, _pageIndex == 0, () => _setPage(0)),
                                              _pharmacyNavItem(context, 'Categories', Images.moduleIcon, Images.moduleIcon, _pageIndex == 1, () => _setPage(1)),
                                              _pharmacyNavItem(context, 'Orders', Images.orderSelect, Images.orderUnselect, _pageIndex == 4, () => _setPage(4)),
                                              _pharmacyNavItem(context, 'Health Corner', Images.heartsvg, Images.heartsvg, _pageIndex == 3, () => _setPage(3)),
                                              _pharmacyNavItem(context, 'Account', Images.user, Images.user, _pageIndex == 5, () => _setPage(5)),
                                            ],
                                          ),
                                        ) : Padding(
                                          padding: EdgeInsets.only(
                                              left: 18.w, right: 18.w,bottom: 18.w),
                                          child: Card(
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(15)),
                                            child: Container(
                                              width: size.width,
                                              height:
                                              GetPlatform.isIOS ? 90 : 75,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      15)),
                                              child: Center(
                                                child: SizedBox(
                                                  width: size.width,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        if((splashController.module != null && splashController.configModel!.module == null))
                                                          const SizedBox.shrink(),
                                                        GetBuilder<SplashController>(
                                                          builder: (splashController) {
                                                            if ((splashController.module != null && splashController.configModel!.module == null)) {
                                                              return BottomNavItemWidget(
                                                                title: "Main",
                                                                selectedIcon: Images.arrow,
                                                                unSelectedIcon: Images.arrow,
                                                                activeColor: Theme.of(context).primaryColor,
                                                                onTap: () {
                                                                  splashController.removeModule();
                                                                  Get.find<StoreController>().resetStoreData();
                                                                  _setPage(0);
                                                                },
                                                              );
                                                            } else {
                                                              return const SizedBox.shrink();
                                                            }
                                                          },
                                                        ),
                                                        BottomNavItemWidget(
                                                            title: 'home'.tr,
                                                            selectedIcon:
                                                            Images.logotransparent,
                                                            unSelectedIcon:
                                                            Images.logotransparent,
                                                            isSelected:
                                                            _pageIndex == 0,
                                                            activeColor: Theme.of(context).primaryColor,
                                                            onTap: () {     setState(() {
                                                              isBookingTab = false;
                                                            });
                                                            _setPage(0);}
                                                        ),
                                                        BottomNavItemWidget(
                                                          title: 'Ride'.tr,
                                                          selectedIcon: Images.TaxiIcon,
                                                          unSelectedIcon: Images.TaxiIcon,
                                                          isSelected: _pageIndex == 2,
                                                          activeColor: Theme.of(context).primaryColor,
                                                          onTap: _showRideBanner
                                                              ? () {
                                                            debugPrint("🚕 Tapped. Status: $_rideStatus");
                                                            setState(() {
                                                              isBookingTab = true;
                                                            });
                                                            if (['accepted', 'arrived', 'in_progress', 'dropped']
                                                                .contains(_rideStatus)) {
                                                              Get.to(() => RideConfirmedScreen(
                                                                Bookingid: _bookingId,
                                                                driverid: _driverId,
                                                                userId: _userId,
                                                                otp: _otp,
                                                              ));
                                                            } else if (_rideStatus == 'pending') {
                                                              Get.to(() => Taxihome(
                                                                showBottomSheet: true,
                                                                bookingId: _bookingId,
                                                                userId: _userId,
                                                                otp: _otp,
                                                              ));
                                                            } else {
                                                              debugPrint("❌ Ride status $_rideStatus not actionable.");
                                                            }
                                                          }
                                                              : () {
                                                            setState(() {
                                                              isBookingTab = true;
                                                              _setPage(2);
                                                            });
                                                            debugPrint("is this true $isBookingTab");
                                                          },
                                                        ),
                                                      if(_pageIndex != 2 && _pageIndex != 4 && _pageIndex != 6) BottomNavItemWidget(
                                                           title: isParcel
                                                               ? 'address'.tr
                                                               : isTaxi
                                                               ? 'wishlist'
                                                               .tr
                                                               : 'favourite'
                                                               .tr,
                                                           selectedIcon: isParcel
                                                               ? Images
                                                               .addressSelect
                                                               : Images.heartsvg,
                                                           unSelectedIcon: isParcel
                                                               ? Images
                                                               .addressUnselect
                                                               : Images
                                                               .favouriteUnselect,
                                                           isSelected:
                                                           _pageIndex == 1,
                                                           activeColor: Theme.of(context).primaryColor,
                                                           onTap: () =>
                                                               _setPage(1),
                                                         ),
                                                        BottomNavItemWidget(
                                                          title: (isBookingTab || _pageIndex == 6 )
                                                              ? 'Bookings'.tr
                                                              : (isTaxi ? 'trips'.tr : 'orders'.tr),
                                                          selectedIcon: Images.ordersvg,
                                                          unSelectedIcon: Images.ordersvg,
                                                          isSelected:  _pageIndex == ((isBookingTab || _pageIndex == 6 ) ? 6 : 4),
                                                          activeColor: Theme.of(context).primaryColor,
                                                          onTap: () {
                                                            _setPage(isBookingTab ? 6 : 4);
                                                            if (AuthHelper.isLoggedIn()) {
                                                              Get.find<OrderController>().getRunningOrders(1);
                                                              Get.find<OrderController>().getHistoryOrders(1);
                                                            }
                                                          },
                                                        ),
                                                         if (!(splashController.module != null && splashController.configModel!.module == null)) BottomNavItemWidget(
                                                            title: 'profile'.tr,
                                                            selectedIcon: '',
                                                            unSelectedIcon: '',
                                                            icon: Icons.person_outline_rounded,
                                                            isSelected: _pageIndex == 5,
                                                            activeColor: Theme.of(context).primaryColor,
                                                            onTap: () => _setPage(5),
                                                         ),
                                                        const SizedBox.shrink()
                                                      ],
                                                    ),
                                                  ),
                                                ),  
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ):const SizedBox(),
                              ],
                            );
                          }),
                        ),
                      if (_showRideBanner)
                        Positioned(
                          bottom: 90,
                          left: 5,
                          right: 5,
                          child: Dismissible(
                            key: const Key("banner"),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (_) {
                              setState(() {
                                _showRideBanner = false;
                                _showFloatingIcon = true;
                              });
                            },
                            child: GestureDetector(
                              onTap: _handleBannerTap,
                              child: BookingStatusBanner(
                                rideStatus: _rideStatus,
                                bookingId: _bookingId,
                              ),
                            ),
                          ),
                        ),
                      if (_showFloatingIcon)
                        Positioned(
                          left: _floatingIconOffset == Offset(0, 0) ? null : _floatingIconOffset.dx,
                          top: _floatingIconOffset == Offset(0, 0) ? null : _floatingIconOffset.dy,
                          right: _floatingIconOffset == Offset(0, 0) ? 10 : null,
                          bottom: _floatingIconOffset == Offset(0, 0) ? 90 : null,
                          child: Draggable(
                            feedback: _buildFloatingIcon(),
                            childWhenDragging: Container(),
                            onDragEnd: (details) {
                              setState(() {
                                _floatingIconOffset = Offset(
                                  details.offset.dx,
                                  details.offset.dy - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
                                );
                              });
                            },
                            child: GestureDetector(
                              onTap: _handleBannerTap,
                              child: _buildFloatingIcon(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  persistentContentHeight: (widget.fromSplash &&
                      Get.find<LocationController>()
                          .showLocationSuggestion &&
                      active)
                      ? 0
                      : GetPlatform.isIOS
                      ? 110
                      : 100,
                  onIsContractedCallback: () {
                    if (!orderController.showOneOrder) {
                      orderController.showOrders();
                    }
                  },
                  onIsExtendedCallback: () {
                    if (orderController.showOneOrder) {
                      orderController.showOrders();
                    }
                  },
                  enableToggle: true,
                  expandableContent: const SizedBox(),
                  /**
                   *
                   * AUTHORE: SARAVANAN
                   * PURPOSE: I HAVE COMMENT THE BELOW CODE BECAUSE IT HIDING THE NAVIGATION BAR
                   *
                   * CODE: SHOW RUNNING ORDER
                   *
                   *
                   */
                  // expandableContent: (widget.fromSplash &&
                  //         Get.find<LocationController>()
                  //             .showLocationSuggestion &&
                  //         active &&
                  //         !ResponsiveHelper.isDesktop(context))
                  //     ? const SizedBox()
                  //     : (ResponsiveHelper.isDesktop(context) ||
                  //             !_isLogin ||
                  //             orderController.runningOrderModel == null ||
                  //             orderController
                  //                 .runningOrderModel!.orders!.isEmpty ||
                  //             !orderController.showBottomSheet)
                  //         ? const SizedBox()
                  //         : Dismissible(
                  //             key: UniqueKey(),
                  //             onDismissed: (direction) {
                  //               if (orderController.showBottomSheet) {
                  //                 orderController.showRunningOrders();
                  //               }
                  //             },
                  //             child: RunningOrderViewWidget(
                  //                 reversOrder: reversOrder,
                  //                 onOrderTap: () {
                  //                   _setPage(3);
                  //                   if (orderController.showBottomSheet) {
                  //                     orderController.showRunningOrders();
                  //                   }
                  //                 }),
                  //           ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _setPage(int pageIndex) {
    Get.find<SplashController>().showBottomNavBar();
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
        height: 3,
        decoration: BoxDecoration(
            color: status
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }

  Widget _pharmacyNavItem(BuildContext context, String title, String selectedIcon, String unSelectedIcon, bool isSelected, VoidCallback onTap) {
    final Color activeColor = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAssetImageWidget(
            isSelected ? selectedIcon : unSelectedIcon,
            height: 25,
            width: 25,
            color: isSelected ? activeColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

