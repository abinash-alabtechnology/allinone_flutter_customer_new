import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:handy_allinone/features/order/screens/prescription_upload_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/common/widgets/address_widget.dart';
import 'package:handy_allinone/features/address/controllers/address_controller.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/coupon/controllers/coupon_controller.dart';
import 'package:handy_allinone/features/home/controllers/home_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/cart/domain/models/cart_model.dart';
import 'package:handy_allinone/common/models/config_model.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_dropdown.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/not_logged_in_screen.dart';
import 'package:handy_allinone/features/checkout/widgets/checkout_screen_shimmer_view.dart';
import 'package:handy_allinone/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/checkout/widgets/bottom_section.dart';
import 'package:handy_allinone/features/checkout/widgets/top_section.dart';
import 'package:handy_allinone/features/checkout/widgets/prescription_image_picker_widget.dart';
import 'package:handy_allinone/features/checkout/widgets/note_prescription_section.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/custom_asset_image_widget.dart';
import '../../../common/widgets/item_widget.dart';
import '../../../common/widgets/no_data_screen.dart';
import '../../../common/widgets/web_constrained_box.dart';
import '../../cart/widgets/cart_item_widget.dart';
import '../../cart/widgets/extra_packaging_widget.dart';
import '../../cart/widgets/not_available_bottom_sheet_widget.dart';
import '../../cart/widgets/web_cart_items_widget.dart';
import '../../cart/widgets/web_suggested_item_view_widget.dart';
import '../../store/controllers/store_controller.dart';
import '../../store/screens/store_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;

  const CheckoutScreen(
      {super.key, required this.fromCart, required this.cartList, required this.storeId});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {

  final ScrollController _scrollController = ScrollController();
  final JustTheController tooltipController1 = JustTheController();
  final JustTheController tooltipController2 = JustTheController();
  final JustTheController tooltipController3 = JustTheController();

  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  bool _isWalletActive = false;
  String _deliveryChargeForView = '';

  List<AddressModel> address = [];
  bool canCheckSmall = false;
  double? _payableAmount = 0;
  double badWeatherChargeForToolTip = 0;
  double extraChargeForToolTip = 0;
  bool isPassedVariationPrice = false;

  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestPasswordController = TextEditingController();
  final TextEditingController guestConfirmPasswordController = TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode guestPasswordNode = FocusNode();
  final FocusNode guestConfirmPasswordNode = FocusNode();

  bool _firstTimeCheckPayment = false;
  bool _calledOrderTax = false;
  List<CartModel?>? _cartList;

  @override
  void initState() {
    super.initState();
    String? razorpayKey = Get
        .find<SplashController>()
        .configModel
        ?.nativerazor
        ?.apiKey
        .trim() ?? '';
    String? razorpaySecret = Get
        .find<SplashController>()
        .configModel
        ?.nativerazor
        ?.apiSecret
        .trim() ?? '';
    _performInit();
  }

  Future<void> _performInit() async {
    await cartinitCall();
    await initCall();
  }

  ///cart Init Call

  Future<void> cartinitCall() async {
    if (Get
        .find<CartController>()
        .cartList
        .isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if (Get
        .find<CartController>()
        .cartList
        .isNotEmpty) {
      if (kDebugMode) {
        print('----cart item : ${Get
            .find<CartController>()
            .cartList[0].toJson()}');
      }

      if (Get
          .find<CartController>()
          .addCutlery) {
        Get.find<CartController>().updateCutlery(willUpdate: false);
      }
      if (Get
          .find<CartController>()
          .needExtraPackage) {
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(Get
          .find<CartController>()
          .cartList[0].item!.storeId);
      await Get.find<StoreController>().getStoreDetails(Store(id: Get
          .find<CartController>()
          .cartList[0].item!.storeId, name: null), false, fromCart: true);
      Get.find<CartController>().calculationCart();
      showReferAndEarnSnackBar();
    }
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if (Get
        .find<ProfileController>()
        .userInfoModel != null && Get
        .find<ProfileController>()
        .userInfoModel!
        .isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }

  ///

  Future<void> initCall() async {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<CheckoutController>().resetOrderTax();
    Get.find<CheckoutController>().initAdditionData();

    List<AddressModel>? neaddress = Get.find<AddressController>().addressList;
    if (neaddress != null && neaddress.isNotEmpty) {
      final CheckoutController checkoutController = Get.find<CheckoutController>();
      checkoutController.setAddressIndex(0);

      checkoutController.streetNumberController.text = neaddress[0].streetNumber ?? '';
      checkoutController.houseController.text = neaddress[0].house ?? '';
      checkoutController.floorController.text = neaddress[0].floor ?? '';
      checkoutController.cityController.text = neaddress[0].city ?? '';
      checkoutController.stateController.text = neaddress[0].state ?? '';
      checkoutController.countryController.text = neaddress[0].country ?? '';
      checkoutController.pincodeController.text = neaddress[0].pincode ?? '';

      final store = Get.find<StoreController>().store;
      if (store != null && neaddress[0].latitude != null && neaddress[0].longitude != null) {
        checkoutController.getDistanceInKM(
          LatLng(double.parse(neaddress[0].latitude!), double.parse(neaddress[0].longitude!)),
          LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        );
      }
    }


    final prefs = await SharedPreferences.getInstance();

    Get
        .find<CheckoutController>()
        .streetNumberController
        .text =
        AddressHelper.getUserAddressFromSharedPref()!.streetNumber?? '';

    Get
        .find<CheckoutController>()
        .cityController
        .text =
        AddressHelper.getUserAddressFromSharedPref()!.city?? '';
    Get
        .find<CheckoutController>()
        .stateController
        .text =
        AddressHelper.getUserAddressFromSharedPref()!.state?? '';
    Get
        .find<CheckoutController>()
        .countryController
        .text =
        AddressHelper.getUserAddressFromSharedPref()!.country?? '';
    Get
        .find<CheckoutController>()
        .pincodeController
        .text =
        AddressHelper.getUserAddressFromSharedPref()!.pincode?? '';


    Get
        .find<CheckoutController>()
        .houseController
        .text = AddressHelper.getUserAddressFromSharedPref()!.house ?? '';
    Get
        .find<CheckoutController>()
        .floorController
        .text = AddressHelper.getUserAddressFromSharedPref()!.floor ?? '';
    Get
        .find<CheckoutController>()
        .couponController
        .text = '';

    Get.find<CheckoutController>().clearPrevData();
    Get.find<CheckoutController>().getDmTipMostTapped();
    Get.find<CheckoutController>().setPreferenceTimeForView(
        '', isUpdate: false);

    Get.find<CheckoutController>().getOfflineMethodList();

    if (Get
        .find<CheckoutController>()
        .isCreateAccount) {
      Get.find<CheckoutController>().toggleCreateAccount(willUpdate: false);
    }

    if (Get
        .find<CheckoutController>()
        .isPartialPay) {
      Get.find<CheckoutController>().changePartialPayment(isUpdate: false);
    }

    if (isLoggedIn) {
      if (Get
          .find<ProfileController>()
          .userInfoModel == null) {
        Get.find<ProfileController>().getUserInfo();
      }

      Get.find<CouponController>().getCouponList();

      if (Get
          .find<AddressController>()
          .addressList == null) {
        Get.find<AddressController>().getAddressList();
      }
    }

    if (widget.storeId == null) {
      _cartList = [];
      if (GetPlatform.isWeb) {
        await Get.find<CartController>().getCartDataOnline();
      }
      widget.fromCart ? _cartList!.addAll(Get
          .find<CartController>()
          .cartList) : _cartList!.addAll(widget.cartList!);
      if (_cartList != null && _cartList!.isNotEmpty) {
        Get.find<CheckoutController>().initCheckoutData(
            _cartList![0]!.item!.storeId);
      }
    }
    if (widget.storeId != null) {
      Get.find<CheckoutController>().initCheckoutData(widget.storeId);
      Get.find<CouponController>().removeCouponData(false);
    }
    Get.find<CheckoutController>().pickPrescriptionImage(
        isRemove: true, isCamera: false);
    _isWalletActive = Get
        .find<SplashController>()
        .configModel!
        .customerWalletStatus == 1;
    Get.find<CheckoutController>().updateTips(
      Get
          .find<CheckoutController>()
          .getSharedPrefDmTipIndex()
          .isNotEmpty ? int.parse(
          Get.find<CheckoutController>().getSharedPrefDmTipIndex()) : 0,
      notify: false,
    );
    Get
        .find<CheckoutController>()
        .tipController
        .text = Get
        .find<CheckoutController>()
        .selectedTips != -1 ? AppConstants.tips[Get
        .find<CheckoutController>()
        .selectedTips] : '';
  }

  void _setSinglePaymentActive() {
    if ((!_firstTimeCheckPayment && !_isCashOnDeliveryActive! &&
        _isDigitalPaymentActive! && Get
        .find<SplashController>()
        .configModel!
        .activePaymentMethodList!
        .length == 1) && ((!_isWalletActive && AuthHelper.isLoggedIn()) ||
        !AuthHelper.isLoggedIn())) {
      Future.delayed(const Duration(milliseconds: 600), () {
        Get.find<CheckoutController>().setPaymentMethod(2, isUpdate: false);
        Get.find<CheckoutController>().changeDigitalPaymentName(Get
            .find<SplashController>()
            .configModel!
            .activePaymentMethodList![0].getWay!, willUpdate: false);
        _firstTimeCheckPayment = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    guestContactPersonNameController.dispose();
    guestContactPersonNumberController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Module? module = Get.find<SplashController>().configModel!.moduleConfig!.module;
    bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() && Get.find<SplashController>().configModel!.guestCheckoutStatus!;
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isGuestLogIn = AuthHelper.isGuestLoggedIn();
    bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Your Cart',
        bgcolor: Colors.white,
        textcolor: Colors.black,
        iconcolor: Colors.black,
      ),
      endDrawer: const MenuDrawer(), 
      endDrawerEnableOpenDragGesture: false,
      body: guestCheckoutPermission || AuthHelper.isLoggedIn() ?
      GetBuilder<
          CheckoutController>(builder: (checkoutController) {
        return GetBuilder<
            CartController>(builder: (cartController) {
          List<DropdownItem<int>> addressList = _getDropdownAddressList(
              context: context, addressList: Get
              .find<AddressController>()
              .addressList, store: checkoutController.store);
          address = _getAddressList(addressList: Get
              .find<AddressController>()
              .addressList, store: checkoutController.store);

          bool todayClosed = false;
          bool tomorrowClosed = false;
          Pivot? moduleData = _getModuleData(store: checkoutController.store);
          _isCashOnDeliveryActive =
              _checkCODActive(store: checkoutController.store);
          _isDigitalPaymentActive =
              _checkDigitalPaymentActive(store: checkoutController.store);
          _isOfflinePaymentActive = Get
              .find<SplashController>()
              .configModel!
              .offlinePaymentStatus! && _checkZoneOfflinePaymentOnOff(
              addressModel: AddressHelper.getUserAddressFromSharedPref(),
              checkoutController: checkoutController);
          if (checkoutController.store != null) {
            todayClosed = checkoutController.isStoreClosed(
                true, checkoutController.store!.active!,
                checkoutController.store!.schedules);
            tomorrowClosed = checkoutController.isStoreClosed(
                false, checkoutController.store!.active!,
                checkoutController.store!.schedules);
            _taxPercent = checkoutController.store!.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            double? maxCodOrderAmount;

            if (moduleData != null) {
              maxCodOrderAmount = moduleData.maximumCodOrderAmount;
            }
            bool hasSubscription = checkoutController.startDate != null && checkoutController.endDate != null;
            int days = 1;
            if(hasSubscription) {
              DateTime start = DateFormat('yyyy-MM-dd').parse(checkoutController.startDate!);
              DateTime end = DateFormat('yyyy-MM-dd').parse(checkoutController.endDate!);
              days = end.difference(start).inDays + 1;
            }

            double price = _calculatePrice(
                store: checkoutController.store,
                cartList: _cartList,
                days: days,
                hasSubscription: hasSubscription);
            double addOns = _calculateAddonsPrice(
                store: checkoutController.store,
                cartList: _cartList,
                days: days,
                hasSubscription: hasSubscription);
            double variations = _calculateVariationPrice(
                store: checkoutController.store,
                cartList: _cartList,
                days: days,
                hasSubscription: hasSubscription,
                calculateWithoutDiscount: true);
            double? itemDiscountPrice = _calculateDiscountPrice(
                store: checkoutController.store,
                cartList: _cartList,
                price: price,
                addOns: addOns,
                days: days,
                hasSubscription: hasSubscription,
                calStoreDiscount: false);
            double? storeDiscountPrice = _calculateDiscountPrice(
                store: checkoutController.store,
                cartList: _cartList,
                price: price,
                addOns: addOns,
                days: days,
                hasSubscription: hasSubscription,
                calStoreDiscount: true);

            double extraDiscount = _getExtraDiscountPrice(
                storeDiscountPrice, itemDiscountPrice);
            double? discount = _getDiscountPrice(
                storeDiscountPrice, itemDiscountPrice);
            double couponDiscount = PriceConverter.toFixed(
                couponController.discount!);

            double subTotal = _calculateSubTotal(price: price,
                addOns: addOns,
                variations: variations,
                cartList: _cartList);

            double referralDiscount = _calculateReferralDiscount(
                subTotal, discount, couponDiscount);

            double orderAmount = _calculateOrderAmount(
              price: price,
              variations: variations,
              discount: discount,
              addOns: addOns,
              couponDiscount: couponDiscount,
              cartList: _cartList,
              referralDiscount: referralDiscount,
            );

            Future.delayed(const Duration(milliseconds: 50), () {
              if (checkoutController.isFirstTime ||
                  (couponController.discount! > 0 &&
                      !checkoutController.isFirstTime && !_calledOrderTax)) {
                if (couponController.discount! > 0) {
                  _calledOrderTax = true;
                }
                List<OnlineCart> carts = [];

                if (widget.storeId == null) {
                  for (int index = 0; index <
                      _cartList!.length; index++) {
                    CartModel cart = _cartList![index]!;
                    List<int?> addOnIdList = [];
                    List<int?> addOnQtyList = [];
                    for (var addOn in cart.addOnIds!) {
                      addOnIdList.add(addOn.id);
                      addOnQtyList.add(addOn.quantity);
                    }

                    List<OrderVariation> variations = [];
                    if (Get
                        .find<SplashController>()
                        .getModuleConfig(cart.item!.moduleType)
                        .newVariation!) {
                      for (int i = 0; i <
                          cart.item!.foodVariations!.length; i++) {
                        if (cart.foodVariations![i].contains(true)) {
                          variations.add(OrderVariation(
                              name: cart.item!.foodVariations![i].name,
                              values: OrderVariationValue(label: [])));
                          for (int j = 0; j <
                              cart.item!.foodVariations![i].variationValues!
                                  .length; j++) {
                            if (cart.foodVariations![i][j]!) {
                              variations[variations.length - 1].values!.label!
                                  .add(cart.item!.foodVariations![i]
                                  .variationValues![j].level);
                            }
                          }
                        }
                      }
                    }
                    carts.add(OnlineCart(
                      cart.id,
                      cart.item!.id,
                      cart.isCampaign! ? cart.item!.id : null,
                      cart.discountedPrice.toString(),
                      '',
                      Get
                          .find<SplashController>()
                          .getModuleConfig(cart.item!.moduleType)
                          .newVariation! ? null : cart.variation,
                      Get
                          .find<SplashController>()
                          .getModuleConfig(cart.item!.moduleType)
                          .newVariation! ? variations : null,
                      cart.quantity,
                      addOnIdList,
                      cart.addOns,
                      addOnQtyList,
                      'Item',
                       cart.isSubscribed ?? false,
                       itemType: "App\\Models\\Item",
                     ));
                   }
                 }
 
                 PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                   cart: carts,
                   couponDiscountAmount: Get
                       .find<CouponController>()
                       .discount,
                   distance: checkoutController.distance,
                   orderAmount: widget.storeId == null ? subTotal : 0,
                   orderNote: checkoutController.noteController.text,
                   orderType: checkoutController.orderType,
                   paymentMethod: checkoutController.paymentMethodIndex == 0
                       ? 'cash_on_delivery'
                       : checkoutController.paymentMethodIndex == 1 ? 'wallet'
                       : checkoutController.paymentMethodIndex == 2
                       ? 'digital_payment'
                       : 'offline_payment',
                   couponCode: (Get
                       .find<CouponController>()
                       .discount! > 0 || (Get
                       .find<CouponController>()
                       .coupon != null
                       && Get
                           .find<CouponController>()
                           .freeDelivery)) ? Get
                       .find<CouponController>()
                       .coupon!
                       .code : null,
                   storeId: (widget.storeId == null)
                       ? _cartList![0]!.item!.storeId
                       : widget.storeId,
                   discountAmount: discount,
                   receiverDetails: null,
                   parcelCategoryId: null,
                   chargePayer: null,
                   dmTips: (checkoutController.orderType == 'take_away' ||
                       checkoutController.tipController.text == 'not_now')
                       ? ''
                       : checkoutController.tipController.text.trim(),
                   cutlery: Get
                       .find<CartController>()
                       .addCutlery ? 1 : 0,
                   unavailableItemNote: Get
                       .find<CartController>()
                       .notAvailableIndex != -1 ? Get
                       .find<CartController>()
                       .notAvailableList[Get
                       .find<CartController>()
                       .notAvailableIndex] : '',
                   deliveryInstruction: checkoutController.selectedInstruction !=
                       -1 ? AppConstants
                       .deliveryInstructionList[checkoutController
                       .selectedInstruction] : '',
                   partialPayment: checkoutController.isPartialPay ? 1 : 0,
                   guestId: isGuestLogIn
                       ? int.parse(AuthHelper.getGuestId())
                       : 0,
                   isBuyNow: widget.fromCart ? 0 : 1,
                   extraPackagingAmount: Get
                       .find<CartController>()
                       .needExtraPackage ? checkoutController.store!
                       .extraPackagingAmount : 0,
                   createNewUser: checkoutController.isCreateAccount ? 1 : 0,
                   password: guestPasswordController.text,
                   isPrescriptionOrder: widget.storeId == null ? false : true,
                   isSubscribed: carts.any((e) => e.isSubscribed ?? false),
                   startDate: checkoutController.startDate,
                   endDate: checkoutController.endDate,
                   dropTime: checkoutController.dropTime,
                 );

                checkoutController.getOrderTax(placeOrderBody);
              }
            });

            double additionalCharge = Get
                .find<SplashController>()
                .configModel!
                .additionalChargeStatus!
                ? Get
                .find<SplashController>()
                .configModel!
                .additionCharge! : 0;
            double originalCharge = _calculateOriginalDeliveryCharge(
              store: checkoutController.store,
              address: AddressHelper.getUserAddressFromSharedPref()!,
              distance: checkoutController.distance,
              extraCharge: checkoutController.extraCharge,
              surgePrice: checkoutController.surgePrice?.price,
              surgePriceType: checkoutController.surgePrice?.priceType,
            );


            double deliveryCharge = _calculateDeliveryCharge(
              store: checkoutController.store,
              address: AddressHelper.getUserAddressFromSharedPref()!,
              distance: checkoutController.distance,
              extraCharge: checkoutController.extraCharge,
              orderType: checkoutController.orderType!,
              orderAmount: orderAmount,
              surgePrice: checkoutController.surgePrice?.price,
              surgePriceType: checkoutController.surgePrice?.priceType,
            );

            if (checkoutController.orderType != 'take_away' &&
                checkoutController.store != null) {
              _deliveryChargeForView =
              (checkoutController.orderType == 'delivery' ? checkoutController
                  .store!.freeDelivery! : true) ? 'free'.tr
                  : deliveryCharge != -1 ? PriceConverter.convertPrice(
                  deliveryCharge) : 'calculating'.tr;
            }

            double extraPackagingCharge = widget.storeId != null
                ? 0
                : _calculateExtraPackagingCharge(checkoutController);

            double otherCharge = widget.storeId != null
                ? 0
                : _calculateotherCharge(checkoutController);

            double total = _calculateTotal(
              subTotal: subTotal,
              deliveryCharge: deliveryCharge,
              discount: discount,
              couponDiscount: couponDiscount,
              taxIncluded: (checkoutController.taxIncluded == 1),
              tax: checkoutController.orderTax!,
              orderType: checkoutController.orderType!,
              tips: checkoutController.tips,
              additionalCharge: additionalCharge,
              extraPackagingCharge: extraPackagingCharge,
              otherCharge: otherCharge
            );

            bool isPrescriptionRequired = _checkPrescriptionRequired();

            total = total - referralDiscount;

            if (widget.storeId != null) {
              checkoutController.setPaymentMethod(0, isUpdate: false);
            }
            checkoutController.setTotalAmount(
                total - (checkoutController.isPartialPay ? Get
                    .find<ProfileController>()
                    .userInfoModel!
                    .walletBalance! : 0));

            if (_payableAmount != checkoutController.viewTotalPrice &&
                checkoutController.distance != null && isLoggedIn) {
              _payableAmount = checkoutController.viewTotalPrice;
              showCashBackSnackBar();
            }

            _setSinglePaymentActive();

            return (checkoutController.distance != null &&
                checkoutController.store != null) ? (_cartList != null && _cartList!.isNotEmpty) ? Column(
              children: [
                ResponsiveHelper.isDesktop(context) ? Container(
                  height: 64,
                  color: Theme
                      .of(context)
                      .primaryColor
                      .withOpacity(0.10),
                  child: Center(
                      child: Text('checkout'.tr, style: robotoMedium)),
                ) : const SizedBox(),

                Expanded(child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Delivering to Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text('Delivering to', style: robotoBold.copyWith(fontSize: 14)),
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                                const Spacer(),
                                const Icon(Icons.shopping_cart_outlined, size: 22),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Text(
                                AddressHelper.getUserAddressFromSharedPref()?.address ?? 'Select Address',
                                style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

                      GetBuilder<StoreController>(builder: (storeController) {
                        return GetBuilder<CartController>(
                            builder: (cartController) {
                              return (!isPharmacy && _cartList != null && _cartList!.isNotEmpty) ?
                              Column(children: [
                                Row(crossAxisAlignment: CrossAxisAlignment
                                    .start, children: [
                                  ResponsiveHelper.isDesktop(context)
                                      ? WebCardItemsWidget(
                                      cartList: _cartList!.cast<CartModel>())
                                      : Expanded(
                                    flex: 7,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, children: [

                                      WebConstrainedBox(
                                        dataLength: _cartList?.length ?? 0,
                                        minLength: 5,
                                        minHeight: 0.6,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start, children: [
                                          Container(
                                            margin:EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      8.0),
                                                  child: Container(
                                                    child: ListView.builder(
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: cartController
                                                          .cartList.length,
                                                      itemBuilder: (context,
                                                          index) {
                                                        return CartItemWidget(
                                                          fromCheckout: true,
                                                            cart: cartController
                                                                .cartList[index],
                                                            cartIndex: index,
                                                            addOns: cartController
                                                                .addOnsList[index],
                                                            isAvailable: cartController
                                                                .availableList[index],
                                                            showDivider: index !=
                                                                cartController
                                                                    .cartList
                                                                    .length - 1);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: Dimensions
                                                    .paddingSizeDefault),
                                                /*Padding(
                                                   padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                   child: InkWell(
                                                     onTap: (){
                                                       if(ResponsiveHelper.isDesktop(context)) {
                                                         Get.dialog(const Dialog(child: NotAvailableBottomSheetWidget()));
                                                       } else {
                                                         showModalBottomSheet(
                                                           context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                                           builder: (con) => const NotAvailableBottomSheetWidget(),
                                                         );
                                                       }
                                                     },
                                                     child: Row(children: [
                                                       Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoBold.copyWith(fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                                       const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                                                     ]),
                                                   ),
                                                 ),*/
                                                DottedBorder(
                                                  options:
                                                  CustomPathDottedBorderOptions(
                                                    padding: const EdgeInsets.all(10),
                                                    color: Colors.grey.shade400,
                                                    strokeWidth: 1,
                                                    dashPattern: [5, 5],
                                                    customPath: (size) => Path()
                                                      ..moveTo(0, size.height)
                                                      ..relativeLineTo(size.width, 0),
                                                  ),
                                                  child: const SizedBox(
                                                    width: double.infinity,
                                                    height: 0,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: double.infinity,
                                                  height: 0.5,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Missing something?",
                                                        style: robotoBold.copyWith(fontSize: 16),
                                                      ),
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          cartController.forcefullySetModule(_cartList![0]!.item!.moduleId!);
                                                          Get.toNamed(
                                                            RouteHelper.getStoreRoute(id: cartController.cartList[0].item!.storeId, page: 'item'),
                                                            arguments: StoreScreen(store: Store(id: cartController.cartList[0].item!.storeId), fromModule: false),
                                                          );
                                                        },
                                                        icon: const Icon(Icons.add, color: Color(0xFF16A34A), size: 18),
                                                        label: Text('Add', style: robotoBold.copyWith(color: const Color(0xFF16A34A))),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),


                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: InkWell(
                                              onTap: () {
                                                // Instructions logic
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.shade100),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.note_add_outlined, color: Color(0xFF16A34A), size: 20),
                                                    const SizedBox(width: 8),
                                                    Text('Add cooking instructions', style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                                                    const Spacer(),
                                                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          ExtraPackagingWidget(cartController: cartController),
                                          !ResponsiveHelper.isDesktop(context)
                                              ? suggestedItemView(
                                              _cartList!.cast<CartModel>())
                                              : const SizedBox(),
                                        ]),
                                      ),



                                    ]),
                                  ),
                                  ResponsiveHelper.isDesktop(context)
                                      ? const SizedBox(
                                      width: Dimensions.paddingSizeSmall)
                                      : const SizedBox(),

                                ]),
                                ResponsiveHelper.isDesktop(context)
                                    ? WebSuggestedItemViewWidget(
                                    cartList: _cartList!.cast<CartModel>())
                                    : const SizedBox(),
                                if (!isPharmacy) Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 12,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          offset: const Offset(0, 2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 44.w,
                                          height: 44.h,
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(right: 12),
                                          child: CustomAssetImageWidget(
                                            "assets/image/brain.png",
                                            width: 44.w,
                                            height: 44.h,
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 44,
                                          color: Colors.black12,
                                          margin: const EdgeInsets.only(right: 12),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: robotoRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: 11.sp,
                                                height: 1.25,
                                              ),
                                              children:  [
                                                TextSpan(
                                                  text:
                                                  "We're currently in our AYT testing phase\n",
                                                  style: robotoRegular.copyWith(
                                                    fontWeight: FontWeight.w100,
                                                    fontSize: 12,color:Colors.grey.shade600
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "to ",
                                                  style: robotoRegular.copyWith(
                                                    fontWeight: FontWeight.w100,
                                                      fontSize: 12,color:Colors.grey.shade600
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "fine-tune your experience",
                                                  style: robotoBold.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ])
                                  : SizedBox();
                            });
                      }),
                      FooterView(child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeLarge),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Expanded(flex: 6, child: TopSection(
                                  checkoutController: checkoutController,
                                  charge: originalCharge,
                                  deliveryCharge: deliveryCharge,
                                  addressList: addressList,
                                  tomorrowClosed: tomorrowClosed,
                                  todayClosed: todayClosed,
                                  module: module,
                                  price: price,
                                  discount: discount,
                                  addOns: addOns,
                                  address: address,
                                  isPrescriptionRequired: isPrescriptionRequired,
                                  cartList: _cartList,
                                  isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                                  isDigitalPaymentActive: _isDigitalPaymentActive!,
                                  isWalletActive: _isWalletActive,
                                  storeId: widget.storeId,
                                  total: total,
                                  isOfflinePaymentActive: _isOfflinePaymentActive,
                                  guestNameTextEditingController: guestContactPersonNameController,
                                  guestNumberTextEditingController: guestContactPersonNumberController,
                                  guestNumberNode: guestNumberNode,
                                  guestEmailController: guestEmailController,
                                  guestEmailNode: guestEmailNode,
                                  tooltipController1: tooltipController1,
                                  tooltipController2: tooltipController2,
                                  dmTipsTooltipController: tooltipController3,
                                  guestPasswordController: guestPasswordController,
                                  guestConfirmPasswordController: guestConfirmPasswordController,
                                  guestPasswordNode: guestPasswordNode,
                                  guestConfirmPasswordNode: guestConfirmPasswordNode,
                                  variationPrice: isPassedVariationPrice
                                      ? variations
                                      : 0,
                                  deliveryChargeForView: _deliveryChargeForView,
                                  badWeatherCharge: badWeatherChargeForToolTip,
                                  extraChargeForToolTip: extraChargeForToolTip,
                                )),
                                const SizedBox(
                                    width: Dimensions.paddingSizeLarge),

                                Expanded(flex: 4, child: BottomSection(
                                  checkoutController: checkoutController,
                                  total: total,
                                  module: module!,
                                  subTotal: subTotal,
                                  discount: discount,
                                  couponController: couponController,
                                  taxIncluded: (checkoutController
                                      .taxIncluded ==
                                      1),
                                  tax: checkoutController.orderTax!,
                                  deliveryCharge: deliveryCharge,
                                  todayClosed: todayClosed,
                                  tomorrowClosed: tomorrowClosed,
                                  orderAmount: orderAmount,
                                  maxCodOrderAmount: maxCodOrderAmount,
                                  storeId: widget.storeId,
                                  taxPercent: _taxPercent,
                                  price: price,
                                  addOns: addOns,
                                  isPrescriptionRequired: isPrescriptionRequired,
                                  checkoutButton: _orderPlaceButton(
                                    checkoutController,
                                    todayClosed,
                                    tomorrowClosed,
                                    orderAmount,
                                    deliveryCharge,
                                    checkoutController.orderTax!,
                                    discount,
                                    total,
                                    maxCodOrderAmount,
                                    isPrescriptionRequired,
                                  ),
                                  referralDiscount: referralDiscount,
                                  variationPrice: isPassedVariationPrice
                                      ? variations
                                      : 0,
                                  extraDiscount: extraDiscount,
                                )),
                              ]))
                                    : isPharmacy ? _pharmacyCheckoutBody(checkoutController, total, _isCashOnDeliveryActive!, _isDigitalPaymentActive!, _isWalletActive, _isOfflinePaymentActive, isPrescriptionRequired) : Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              TopSection(
                                checkoutController: checkoutController,
                                charge: originalCharge,
                                deliveryCharge: deliveryCharge,
                                addressList: addressList,
                                tomorrowClosed: tomorrowClosed,
                                todayClosed: todayClosed,
                                module: module,
                                price: price,
                                discount: discount,
                                addOns: addOns,
                                address: address,
                                cartList: _cartList,
                                isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                                isDigitalPaymentActive: _isDigitalPaymentActive!,
                                isWalletActive: _isWalletActive,
                                storeId: widget.storeId,
                                total: total,
                                 isPrescriptionRequired: isPrescriptionRequired,
                                isOfflinePaymentActive: _isOfflinePaymentActive,
                                guestNameTextEditingController: guestContactPersonNameController,
                                guestNumberTextEditingController: guestContactPersonNumberController,
                                guestNumberNode: guestNumberNode,
                                guestEmailController: guestEmailController,
                                guestEmailNode: guestEmailNode,
                                tooltipController1: tooltipController1,
                                tooltipController2: tooltipController2,
                                dmTipsTooltipController: tooltipController3,
                                guestPasswordController: guestPasswordController,
                                guestConfirmPasswordController: guestConfirmPasswordController,
                                guestPasswordNode: guestPasswordNode,
                                guestConfirmPasswordNode: guestConfirmPasswordNode,
                                variationPrice: isPassedVariationPrice
                                    ? variations
                                    : 0,
                                deliveryChargeForView: _deliveryChargeForView,
                                badWeatherCharge: badWeatherChargeForToolTip,
                                extraChargeForToolTip: extraChargeForToolTip,
                              ),

                              BottomSection(
                                checkoutController: checkoutController,
                                total: total,
                                module: module!,
                                subTotal: subTotal,
                                discount: discount,
                                couponController: couponController,
                                taxIncluded: (checkoutController.taxIncluded ==
                                    1),
                                tax: checkoutController.orderTax!,
                                deliveryCharge: deliveryCharge,
                                todayClosed: todayClosed,
                                tomorrowClosed: tomorrowClosed,
                                orderAmount: orderAmount,
                                maxCodOrderAmount: maxCodOrderAmount,
                                storeId: widget.storeId,
                                taxPercent: _taxPercent,
                                price: price,
                                addOns: addOns,
                                isPrescriptionRequired: isPrescriptionRequired,
                                checkoutButton: _orderPlaceButton(
                                  checkoutController,
                                  todayClosed,
                                  tomorrowClosed,
                                  orderAmount,
                                  deliveryCharge,
                                  checkoutController.orderTax!,
                                  discount,
                                  total,
                                  maxCodOrderAmount,
                                  isPrescriptionRequired,
                                ),
                                referralDiscount: referralDiscount,
                                variationPrice: isPassedVariationPrice
                                    ? variations
                                    : 0,
                                extraDiscount: extraDiscount,
                              )
                            ]),
                      )),
                    ],
                  ),
                )),

                ResponsiveHelper.isDesktop(context)
                    ? const SizedBox()
                    : isPharmacy ? _pharmacyOrderPlaceButton(
                      checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, checkoutController.orderTax!,
                      discount, total, maxCodOrderAmount, isPrescriptionRequired,
                    ) : SafeArea(
                      child: Container(
                                        decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Theme
                          .of(context)
                          .primaryColor
                          .withOpacity(0.1), blurRadius: 10)
                      ],
                                        ),
                                        child: Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeExtraSmall),
                            child: Row(children: [
                              Text(
                                checkoutController.isPartialPay
                                    ? 'due_payment'.tr
                                    : 'total_amount'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge, color: Theme
                                    .of(context)
                                    .cardColor),
                              ),
                      
                              (checkoutController.taxIncluded == 1) ? Text(
                                  ' ${'vat_tax_inc'.tr}',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Theme
                                        .of(context)
                                        .cardColor,
                                  )) : const SizedBox(),
                      
                              const Expanded(child: SizedBox()),
                      
                              PriceConverter.convertAnimationPrice(
                                checkoutController.viewTotalPrice,
                                textStyle: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme
                                    .of(context)
                                    .cardColor),
                              ),
                            ]),
                          ),
                      
                          _orderPlaceButton(
                            checkoutController,
                            todayClosed,
                            tomorrowClosed,
                            orderAmount,
                            deliveryCharge,
                            checkoutController.orderTax!,
                            discount,
                            total,
                            maxCodOrderAmount,
                            isPrescriptionRequired,
                          ),
                        ],
                      ),
                                        ),
                                      ),
                    ),

              ],
            ) :
            SizedBox(
                height: Get.height,
                child: const NoDataScreen(
                    isCart: true, text: '', showFooter: true))
                : FactCardView();
            // const CheckoutScreenShimmerView();
          });
        });
      }) : NotLoggedInScreen(callBack: (value) {
        initCall();
        setState(() {});
      }),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if (storeController.cartSuggestItemModel != null) {
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if (!cartIds.contains(item.id)) {
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null &&
              suggestedItems!.isNotEmpty ? Container(
                          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeExtraSmall),
                  child: Text(
                      'you_may_also_like'.tr, style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
                ),

                SizedBox(
                  height: ResponsiveHelper.isDesktop(context) ? 900 : 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestedItems.length,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                        left: ResponsiveHelper.isDesktop(context) ? Dimensions
                            .paddingSizeExtraSmall : Dimensions
                            .paddingSizeDefault),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: ResponsiveHelper.isDesktop(context)
                            ? const EdgeInsets.symmetric(vertical: 20)
                            : const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          width: ResponsiveHelper.isDesktop(context)
                              ? 900
                              : 180,
                          padding: const EdgeInsets.only(
                              right: Dimensions.paddingSizeSmall,
                              left: Dimensions.paddingSizeExtraSmall),
                          margin: const EdgeInsets.only(
                              right: Dimensions.paddingSizeSmall),
                          child: ItemWidgetStore(
                            isStore: false,
                            item: suggestedItems![index],
                            fromCartSuggestion: false,
                            store: null,
                            index: index,
                            length: null,
                            isCampaign: false,
                            inStore: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
                          ),
                        ) : const SizedBox();
        }),
      ]),
    );
  }

  Widget _pharmacyCheckoutBody(CheckoutController checkoutController, double total, bool isCashOnDeliveryActive, bool isDigitalPaymentActive, bool isWalletActive, bool isOfflinePaymentActive, bool isPrescriptionRequired) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pharmacyDeliverToCard(checkoutController),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text('Payment Options', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        _pharmacyPaymentMethodsList(checkoutController, total, isCashOnDeliveryActive, isDigitalPaymentActive, isWalletActive, isOfflinePaymentActive),

        const SizedBox(height: Dimensions.paddingSizeLarge),
        PrescriptionImagePickerWidget(checkoutController: checkoutController, storeId: widget.storeId, isPrescriptionRequired: isPrescriptionRequired),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        NoteAndPrescriptionSection(checkoutController: checkoutController, storeId: widget.storeId),
      ]),
    );
  }

  Widget _pharmacyDeliverToCard(CheckoutController checkoutController) {
    AddressModel? selectedAddress = address.isNotEmpty ? address[checkoutController.addressIndex!] : null;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Deliver To', style: robotoRegular.copyWith(color: Colors.grey, fontSize: Dimensions.fontSizeExtraSmall)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(selectedAddress?.addressType?.tr ?? 'Home', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          InkWell(
            onTap: () async {
              var result = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, checkoutController.store!.zoneId));
              if (result != null && result is AddressModel) {
                 // The address controller will update, and we might need to refresh
              }
            },
            child: Text('Change', style: robotoBold.copyWith(color: const Color(0xFF16A34A), fontSize: Dimensions.fontSizeSmall)),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF16A34A)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(child: Text(selectedAddress?.address ?? '', style: robotoRegular.copyWith(color: Colors.grey, fontSize: Dimensions.fontSizeSmall), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text('${selectedAddress?.contactPersonName ?? ''} - ${selectedAddress?.contactPersonNumber ?? ''}',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey)),
      ]),
    );
  }

  Widget _pharmacyPaymentMethodsList(CheckoutController checkoutController, double total, bool isCashOnDeliveryActive, bool isDigitalPaymentActive, bool isWalletActive, bool isOfflinePaymentActive) {
    return Column(children: [
      if (isDigitalPaymentActive)
        _pharmacyPaymentCard(
          title: 'Online Payment',
          subtitle: 'UPI, Credit/Debit Card, Net Banking',
          icon: Icons.payments_outlined,
          isSelected: checkoutController.paymentMethodIndex == 2 && checkoutController.digitalPaymentName == 'razor_pay',
          onTap: () {
            checkoutController.setPaymentMethod(2);
            checkoutController.changeDigitalPaymentName('razor_pay');
          },
          customIcon: Image.asset(Images.digitalPay, height: 18),
        ),

      if (isCashOnDeliveryActive)
        _pharmacyPaymentCard(
          title: 'Cash On Delivery',
          subtitle: 'Pay when you receive',
          icon: Icons.account_balance_wallet_outlined,
          isSelected: checkoutController.paymentMethodIndex == 0,
          onTap: () => checkoutController.setPaymentMethod(0),
        ),
    ]);
  }

  Widget _pharmacyPaymentCard({required String title, required String subtitle, required IconData icon, required bool isSelected, required Function onTap, Widget? customIcon}) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(color: isSelected ? const Color(0xFF16A34A).withOpacity(0.1) : Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
        ),
        child: Row(children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF16A34A) : Colors.grey, size: 22),
          const SizedBox(width: Dimensions.paddingSizeDefault),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey)),
          ])),

          customIcon ?? Icon(icon, size: 22, color: Colors.grey.withOpacity(0.5)),
        ]),
      ),
    );
  }

  Widget _pharmacyOrderPlaceButton(CheckoutController checkoutController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount, bool isPrescriptionRequired) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: checkoutController.isLoading ? null : () => _onPlaceOrderPressed(
            checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount, isPrescriptionRequired,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Place Order', style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: 2),
              Text('Total Amount: ${PriceConverter.convertPrice(total)}', style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _orderPlaceButton(CheckoutController checkoutController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount, bool isPrescriptionRequired) {


    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButton(
            isLoading: checkoutController.isLoading,
            buttonText: 'place_order'.tr,
            onPressed: checkoutController.acceptTerms ? () => _onPlaceOrderPressed(
              checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount, isPrescriptionRequired,
            ) : null),
      ),
    );
  }

  void _onPlaceOrderPressed(CheckoutController checkoutController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount, bool isPrescriptionRequired) {

    final city = checkoutController.cityController?.text.trim();
    final state = checkoutController.stateController?.text.trim();
    final country = checkoutController.countryController?.text.trim();
    final pincode = checkoutController.pincodeController?.text.trim();
    bool isAvailable = true;
    DateTime scheduleStartDate = DateTime.now();
    DateTime scheduleEndDate = DateTime.now();
    bool isGuestLogIn = AuthHelper.isGuestLoggedIn();
    bool hasSubscription = _cartList?.any((e) => e!.isSubscribed ?? false) ?? false;

    if(!hasSubscription && (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty)) {
      isAvailable = false;
    }else if (checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
      DateTime startTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot].startTime!;
      DateTime endTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot].endTime!;
      scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
      scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
      if(_cartList != null){
        for (CartModel? cart in _cartList!) {
          if (!DateConverter.isAvailable(
            cart!.item!.availableTimeStarts, cart.item!.availableTimeEnds,
            time: checkoutController.store!.scheduleOrder! ? scheduleStartDate : null,
          ) && !DateConverter.isAvailable(
            cart.item!.availableTimeStarts, cart.item!.availableTimeEnds,
            time: checkoutController.store!.scheduleOrder! ? scheduleEndDate : null,
          )) {
            isAvailable = false;
            break;
          }
        }
      }
    }

    if(hasSubscription && isAvailable && checkoutController.dropTime != null) {
      for (CartModel? cart in _cartList!) {
        if (cart!.isSubscribed ?? false) {
          DateTime dt = DateFormat('HH:mm:ss').parse(checkoutController.dropTime!);
          if (!DateConverter.isAvailable(cart.item!.availableTimeStarts, cart.item!.availableTimeEnds, time: dt)) {
            isAvailable = false;
            break;
          }
        }
      }
    }

    if(isGuestLogIn && checkoutController.guestAddress == null && checkoutController.orderType != 'take_away') {
      showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
    } else if(isGuestLogIn && checkoutController.orderType == 'take_away' && guestContactPersonNameController.text.isEmpty) {
      showCustomSnackBar('please_enter_contact_person_name'.tr);
    } else if(isGuestLogIn && checkoutController.orderType == 'take_away' && guestContactPersonNumberController.text.isEmpty) {
      showCustomSnackBar('please_enter_contact_person_number'.tr);
    }else if(isGuestLogIn && checkoutController.orderType == 'take_away' && guestEmailController.text.isEmpty) {
      showCustomSnackBar('please_enter_contact_person_email'.tr);
    }else if(isGuestLogIn && checkoutController.isCreateAccount && guestPasswordController.text.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if(isGuestLogIn && checkoutController.isCreateAccount && guestConfirmPasswordController.text.isEmpty) {
      showCustomSnackBar('enter_confirm_password'.tr);
    }else if(isGuestLogIn && checkoutController.isCreateAccount && (guestPasswordController.text != guestConfirmPasswordController.text)) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    }
    ///newly added by ak
    ///
    else if (address.isEmpty &&
        checkoutController.orderType != 'take_away') {
      showCustomSnackBar('Please add address');
    }
    else if (address[checkoutController.addressIndex!].id==null &&
        checkoutController.orderType != 'take_away') {
      showCustomSnackBar('Please enter valid address');
    }
    else if(isPrescriptionRequired && checkoutController.pickedPrescriptions.isEmpty) {
      showCustomSnackBar('you_must_upload_prescription_for_this_order'.tr);
    } else if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive) {
      showCustomSnackBar('no_payment_method_is_enabled'.tr);
    }else if(checkoutController.paymentMethodIndex == -1) {
      if(ResponsiveHelper.isDesktop(context)){
        Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
          isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
          isWalletActive: _isWalletActive, storeId: widget.storeId, totalPrice: total, isOfflinePaymentActive: _isOfflinePaymentActive,
        )));
      }else{
        showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => PaymentMethodBottomSheet(
            isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
            isWalletActive: _isWalletActive, storeId: widget.storeId, totalPrice: total, isOfflinePaymentActive: _isOfflinePaymentActive,
          ),
        );
      }
    } else if(orderAmount < checkoutController.store!.minimumOrder! && widget.storeId == null) {
      showCustomSnackBar('${'minimum_order_amount_is'.tr} ${checkoutController.store!.minimumOrder}');
    }else if(checkoutController.tipController.text.isNotEmpty && checkoutController.tipController.text != 'not_now' && double.parse(checkoutController.tipController.text.trim()) < 0) {
      showCustomSnackBar('tips_can_not_be_negative'.tr);
    }else if((checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed)) {
      bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';
      bool showRestaurantText = Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false;
      showCustomSnackBar(isPharmacy ? 'pharmacy_is_closed'.tr : showRestaurantText ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
    }else if(checkoutController.paymentMethodIndex == 0 && _isCashOnDeliveryActive! && maxCodOrderAmount != null && maxCodOrderAmount != 0 && (total > maxCodOrderAmount) && widget.storeId == null){
      showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
    }else if(checkoutController.paymentMethodIndex != 0 && widget.storeId != null){
      showCustomSnackBar('payment_method_is_not_available'.tr);
    }else if (!hasSubscription && (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty)) {
      if(checkoutController.store!.scheduleOrder!) {
        showCustomSnackBar('select_a_time'.tr);
      }else {
        bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';
        bool showRestaurantText = Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false;
        showCustomSnackBar(isPharmacy ? 'pharmacy_is_closed'.tr : showRestaurantText ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
      }
    }else if (!isAvailable) {
      showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
    }else if (hasSubscription && (checkoutController.startDate == null || checkoutController.endDate == null)) {
      showCustomSnackBar('please_select_subscription_date_range'.tr);
    } else if (hasSubscription && checkoutController.dropTime == null) {
      showCustomSnackBar('please_select_subscription_time'.tr);
    }else if (checkoutController.orderType != 'take_away' && checkoutController.distance == -1 && deliveryCharge == -1) {
      showCustomSnackBar('delivery_fee_not_set_yet'.tr);
    }else if (widget.storeId != null && checkoutController.pickedPrescriptions.isEmpty) {
      showCustomSnackBar('please_upload_your_prescription_images'.tr);
    }else if (!checkoutController.acceptTerms) {
      showCustomSnackBar('please_accept_privacy_policy_trams_conditions_refund_policy_first'.tr);
    }
    else {

      AddressModel? finalAddress = isGuestLogIn ? checkoutController.guestAddress : address[checkoutController.addressIndex!];

      if(isGuestLogIn && checkoutController.orderType == 'take_away') {
        String number = checkoutController.countryDialCode! + guestContactPersonNumberController.text;
        finalAddress = AddressModel(contactPersonName: guestContactPersonNameController.text, contactPersonNumber: number,
          address: AddressHelper.getUserAddressFromSharedPref()!.address!, latitude: AddressHelper.getUserAddressFromSharedPref()!.latitude,
          longitude: AddressHelper.getUserAddressFromSharedPref()!.longitude, zoneId: AddressHelper.getUserAddressFromSharedPref()!.zoneId,
          email: guestEmailController.text,
        );
      }

      if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
        finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone;
      }

      if(widget.storeId == null){

        List<OnlineCart> carts = [];
        for (int index = 0; index < _cartList!.length; index++) {
          CartModel cart = _cartList![index]!;
          List<int?> addOnIdList = [];
          List<int?> addOnQtyList = [];
          for (var addOn in cart.addOnIds!) {
            addOnIdList.add(addOn.id);
            addOnQtyList.add(addOn.quantity);
          }

          List<OrderVariation> variations = [];
          if(Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
            for(int i=0; i<cart.item!.foodVariations!.length; i++) {
              if(cart.foodVariations![i].contains(true)) {
                variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                for(int j=0; j<cart.item!.foodVariations![i].variationValues!.length; j++) {
                  if(cart.foodVariations![i][j]!) {
                    variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                  }
                }
              }
            }
          }
          carts.add(OnlineCart(
            cart.id, cart.item!.id, cart.isCampaign! ? cart.item!.id : null,
            cart.discountedPrice.toString(), '',
            Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? null : cart.variation,
            Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? variations : null,
            cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Item', cart.isSubscribed ?? false, itemType: "App\\Models\\Item",
          ));
        }

        if(hasSubscription && (checkoutController.startDate == null || checkoutController.endDate == null || checkoutController.dropTime == null)) {
          showCustomSnackBar('please_select_subscription_date_and_time'.tr);
          return;
        }

        String? city = finalAddress!.city;
        String? state = finalAddress.state;
        String? country = finalAddress.country;
        String? pincode = finalAddress.pincode;

        PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
          cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: checkoutController.distance,
          scheduleAt: !checkoutController.store!.scheduleOrder! ? null : (checkoutController.selectedDateSlot == 0
              && checkoutController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
          orderAmount: total, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
          paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
              : checkoutController.paymentMethodIndex == 1 ? 'wallet'
              : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
          couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
              && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
          storeId: _cartList![0]!.item!.storeId,
          address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude,
          senderZoneId: null, addressType: finalAddress.addressType,
          contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName} '
              '${Get.find<ProfileController>().userInfoModel!.lName}',
          contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone,
          streetNumber: isGuestLogIn ? finalAddress.streetNumber??'' : checkoutController.streetNumberController.text.trim(),
          house: isGuestLogIn ? finalAddress.house??'' : checkoutController.houseController.text.trim(),
          floor: isGuestLogIn ? finalAddress.floor??'' : checkoutController.floorController.text.trim(),
          discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
          chargePayer: null, dmTips: (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now') ? '' : checkoutController.tipController.text.trim(),
          cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
          unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
          deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
          partialPayment: checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(AuthHelper.getGuestId()) : 0,
          isBuyNow: widget.fromCart ? 0 : 1, guestEmail: isGuestLogIn ? finalAddress.email : null,
          extraPackagingAmount: Get.find<CartController>().needExtraPackage ? checkoutController.store!.extraPackagingAmount : 0,
          createNewUser: checkoutController.isCreateAccount ? 1 : 0, password: guestPasswordController.text,
          otherchargesamount:checkoutController.store?.otherchargeenabled==true? checkoutController.store?.otherchargeamount??0.0:0.0,
          otherchargeslabel: checkoutController.store?.otherchargeenabled==true? checkoutController.store?.otherchargelabel??"":"",
          city:city,
          state: state,
          country: country,
          pincode: pincode,
          isSubscribed: hasSubscription,
          startDate: checkoutController.startDate,
          endDate: checkoutController.endDate,
          dropTime: checkoutController.dropTime,
        );
        if(checkoutController.paymentMethodIndex == 3){
          Get.toNamed(RouteHelper.getOfflinePaymentScreen(
            placeOrderBody: placeOrderBody, zoneId: checkoutController.store!.zoneId!, total: checkoutController.viewTotalPrice!,
            maxCodOrderAmount: maxCodOrderAmount, fromCart: widget.fromCart, isCodActive: _isCashOnDeliveryActive, forParcel: false,
          ));
        } else {
          checkoutController.placeOrder(placeOrderBody, checkoutController.store!.zoneId, total, maxCodOrderAmount, widget.fromCart, _isCashOnDeliveryActive!, checkoutController.pickedPrescriptions);
        }
      }else{
        checkoutController.placePrescriptionOrder(
          widget.storeId, checkoutController.store!.zoneId, checkoutController.distance,
          finalAddress!.address!, finalAddress.longitude!, finalAddress.latitude!, checkoutController.noteController.text,
          checkoutController.pickedPrescriptions, (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now')
            ? '' : checkoutController.tipController.text.trim(), checkoutController.selectedInstruction != -1
            ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '', 0, 0, widget.fromCart, _isCashOnDeliveryActive!,
        );
      }
    }
  }


  List<DropdownItem<int>> _getDropdownAddressList(
      {required BuildContext context, required List<
          AddressModel>? addressList, required Store? store}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    // dropDownAddressList.add(DropdownItem<int>(value: 0, child: SizedBox(
    //   width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth -
    //       50 : context.width - 50,
    //   child: AddressWidget(
    //     address: AddressHelper.getUserAddressFromSharedPref(),
    //     fromAddress: false, fromCheckout: true,
    //   ),
    // )));

    if (addressList != null && store != null) {
      for (int index = 0; index < addressList.length; index++) {
        if (addressList[index].zoneIds!.contains(store.zoneId)) {
          dropDownAddressList.add(
              DropdownItem<int>(value: index + 1, child: SizedBox(
                width: context.width > Dimensions.webMaxWidth ? Dimensions
                    .webMaxWidth - 50 : context.width - 50,
                child: AddressWidget(
                  address: addressList[index],
                  fromAddress: false, fromCheckout: true,
                ),
              )));
        }
      }
    }
    return dropDownAddressList;
  }

  List<AddressModel> _getAddressList(
      {required List<AddressModel>? addressList, required Store? store}) {
    List<AddressModel> address = [];

    // address.add(AddressHelper.getUserAddressFromSharedPref()!);

    if (addressList != null && store != null) {
      for (int index = 0; index < addressList.length; index++) {
        if (addressList[index].zoneIds!.contains(store.zoneId)) {
          address.add(addressList[index]);
        }
      }
    }
    return address;
  }

  Pivot? _getModuleData({required Store? store}) {
    Pivot? moduleData;
    if (store != null) {
      for (ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!
          .zoneData!) {
        for (Modules m in zData.modules!) {
          if (m.id == Get
              .find<SplashController>()
              .module!
              .id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }
      }
    }
    return moduleData;
  }

  bool _checkCODActive({required Store? store}) {
    bool isCashOnDeliveryActive = false;
    if (store != null) {
      for (ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!
          .zoneData!) {
        if (zData.id == store.zoneId) {
          isCashOnDeliveryActive = zData.cashOnDelivery! && Get
              .find<SplashController>()
              .configModel!
              .cashOnDelivery!;
        }
      }
    }
    return isCashOnDeliveryActive;
  }

  bool _checkDigitalPaymentActive({required Store? store}) {
    bool isDigitalPaymentActive = false;
    if (store != null) {
      for (ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!
          .zoneData!) {
        if (zData.id == store.zoneId) {
          isDigitalPaymentActive = zData.digitalPayment! && Get
              .find<SplashController>()
              .configModel!
              .digitalPayment!;
        }
      }
    }
    return isDigitalPaymentActive;
  }

  double _calculatePrice(
      {required Store? store, required List<CartModel?>? cartList, int days = 1, bool hasSubscription = false}) {
    double price = 0;

    if (cartList != null) {
      for (var cartModel in cartList) {
        bool isFoodVariation = Get.find<SplashController>().getModuleConfig(cartModel!.item!.moduleType).newVariation!;
        bool haveVariation = false;
        if (!isFoodVariation && cartModel.variation != null && cartModel.variation!.isNotEmpty && cartModel.item!.variations != null && cartModel.item!.variations!.isNotEmpty) {
            haveVariation = true;
        }

        if (isFoodVariation || !haveVariation) {
            double itemPrice = (cartModel.item!.price! * cartModel.quantity!);
            if (hasSubscription || (cartModel.isSubscribed ?? false)) {
              itemPrice = itemPrice * days;
            }
            price = price + itemPrice;
        }
      }
    }
    return PriceConverter.toFixed(price);
  }

  double _calculateAddonsPrice(
      {required Store? store, required List<CartModel?>? cartList, int days = 1, bool hasSubscription = false}) {
    double addOns = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        List<AddOns> addOnList = [];
        for (var addOnId in cartModel!.addOnIds!) {
          for (AddOns addOns in cartModel.item!.addOns!) {
            if (addOns.id == addOnId.id) {
              addOnList.add(addOns);
              break;
            }
          }
        }
        for (int index = 0; index < addOnList.length; index++) {
          double addOnPrice = (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
          if(hasSubscription || (cartModel.isSubscribed ?? false)) {
            addOnPrice = addOnPrice * days;
          }
          addOns = addOns + addOnPrice;
        }
      }
    }
    return PriceConverter.toFixed(addOns);
  }

  double _calculateVariationPrice({required Store? store, required List<
      CartModel?>? cartList, int days = 1, bool hasSubscription = false, bool calculateDiscount = false, bool calculateWithoutDiscount = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? discount = cartModel!.item!.discount;
        String? discountType = cartModel.item!.discountType;

        if (Get
            .find<SplashController>()
            .getModuleConfig(cartModel.item!.moduleType)
            .newVariation!) {
          isPassedVariationPrice = true;
          for (int index = 0; index <
              cartModel.item!.foodVariations!.length; index++) {
            for (int i = 0; i <
                cartModel.item!.foodVariations![index].variationValues!
                    .length; i++) {
              if (cartModel.foodVariations![index][i]!) {
                double vPrice = (PriceConverter.convertWithDiscount(
                    cartModel.item!.foodVariations![index].variationValues![i]
                        .optionPrice!, discount, discountType,
                    isFoodVariation: true)! * cartModel.quantity!);
                double vDiscount = (cartModel.item!.foodVariations![index].variationValues![i]
                    .optionPrice! * cartModel.quantity!);

                if(hasSubscription || (cartModel.isSubscribed ?? false)) {
                  vPrice = vPrice * days;
                  vDiscount = vDiscount * days;
                }
                variationPrice += vPrice;
                variationDiscount += vDiscount;
              }
            }
          }
        } else {
          String variationType = '';
          for (int i = 0; i < cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }

          if (cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                double vPrice = (variation.price! * cartModel.quantity!);
                if(hasSubscription || (cartModel.isSubscribed ?? false)) {
                  vPrice = vPrice * days;
                }
                variationPrice += vPrice;
                break;
              }
            }
          } else {
            double vDiscount = (PriceConverter.convertWithDiscount(
                cartModel.item!.price!, discount, discountType)! *
                cartModel.quantity!);
            double vPrice = (cartModel.item!.price! * cartModel.quantity!);
            if(hasSubscription || (cartModel.isSubscribed ?? false)) {
              vDiscount = vDiscount * days;
              vPrice = vPrice * days;
            }
            variationDiscount += vDiscount;
            variationPrice += vPrice;
          }
        }
      }
    }
    if (calculateDiscount) {
      return (variationDiscount - variationPrice);
    } else if (calculateWithoutDiscount) {
      return variationDiscount;
    } else {
      return variationPrice;
    }
  }

  double _calculateDiscountPrice({required Store? store, required List<
      CartModel?>? cartList, required double price, required double addOns, int days = 1, bool hasSubscription = false, required bool calStoreDiscount}) {
    double discount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? dis = (store.discount != null
            && DateConverter.isAvailable(
                store.discount!.startTime, store.discount!.endTime))
            && calStoreDiscount ? store.discount!.discount : cartModel!.item!
            .discount;

        String? disType = (store.discount != null
            && DateConverter.isAvailable(
                store.discount!.startTime, store.discount!.endTime))
            && calStoreDiscount ? 'percent' : cartModel?.item!.discountType;

        if (Get
            .find<SplashController>()
            .getModuleConfig(cartModel!.item!.moduleType)
            .newVariation!) {
          double d = ((cartModel.item!.price! -
              PriceConverter.convertWithDiscount(
                  cartModel.item!.price!, dis, disType)!) *
              cartModel.quantity!);
          if(hasSubscription || (cartModel.isSubscribed ?? false)) {
            d = d * days;
          }
          discount = discount + d;
          if (disType == 'percent' && discount != 0) {
            discount = discount +
                _calculateFoodVariationDiscount(cartModel: cartModel, days: days, hasSubscription: hasSubscription);
          }
        } else {
          String variationType = '';
          double variationPrice = 0;
          double variationWithoutDiscountPrice = 0;
          for (int i = 0; i < cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }
          if (cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                double vPrice = (PriceConverter.convertWithDiscount(
                    variation.price!, dis, disType)! * cartModel.quantity!);
                double vWithoutDiscountPrice = (variation.price! * cartModel.quantity!);
                if(hasSubscription || (cartModel.isSubscribed ?? false)) {
                  vPrice = vPrice * days;
                  vWithoutDiscountPrice = vWithoutDiscountPrice * days;
                }
                variationPrice += vPrice;
                variationWithoutDiscountPrice += vWithoutDiscountPrice;
                break;
              }
            }
            discount =
                discount + (variationWithoutDiscountPrice - variationPrice);
          } else {
            double d = ((cartModel.item!.price! -
                PriceConverter.convertWithDiscount(
                    cartModel.item!.price!, dis, disType)!) *
                cartModel.quantity!);
            if(hasSubscription || (cartModel.isSubscribed ?? false)) {
              d = d * days;
            }
            discount = discount + d;
          }
        }
      }
    }

    if (calStoreDiscount) {
      if (store != null && store.discount != null) {
        if (store.discount!.maxDiscount != 0 &&
            store.discount!.maxDiscount! < discount) {
          discount = store.discount!.maxDiscount!;
        }
        if (store.discount!.minPurchase != 0 &&
            store.discount!.minPurchase! > (price + addOns)) {
          discount = 0;
        }
      }
    }
    return PriceConverter.toFixed(discount);
  }

  double _getDiscountPrice(double storeDiscountPrice,
      double itemDiscountPrice) {
    double discountPrice = 0;
    if (storeDiscountPrice > itemDiscountPrice) {
      discountPrice = storeDiscountPrice;
    } else if (itemDiscountPrice > storeDiscountPrice) {
      discountPrice = itemDiscountPrice;
    } else {
      discountPrice = itemDiscountPrice;
    }
    return discountPrice;
  }

  double _getExtraDiscountPrice(double storeDiscountPrice,
      double itemDiscountPrice) {
    double extraDiscount = 0;
    if (storeDiscountPrice > itemDiscountPrice) {
      extraDiscount = storeDiscountPrice - itemDiscountPrice;
    } else if (itemDiscountPrice > storeDiscountPrice) {
      extraDiscount = 0;
    } else {
      extraDiscount = 0;
    }
    return extraDiscount;
  }

  double _calculateFoodVariationDiscount({required CartModel? cartModel, int days = 1, bool hasSubscription = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if (cartModel != null) {
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;
      for (int index = 0; index <
          cartModel.item!.foodVariations!.length; index++) {
        for (int i = 0; i <
            cartModel.item!.foodVariations![index].variationValues!
                .length; i++) {
          if (cartModel.foodVariations![index][i]!) {
            double vPrice = (PriceConverter.convertWithDiscount(
                cartModel.item!.foodVariations![index].variationValues![i]
                    .optionPrice!, discount, discountType,
                isFoodVariation: true)! * cartModel.quantity!);
            double vDiscount = (cartModel.item!.foodVariations![index].variationValues![i]
                .optionPrice! * cartModel.quantity!);
            
            if(hasSubscription || (cartModel.isSubscribed ?? false)) {
              vPrice = vPrice * days;
              vDiscount = vDiscount * days;
            }
            variationPrice += vPrice;
            variationDiscount += vDiscount;
          }
        }
      }
    }
    return (variationDiscount - variationPrice);
  }

  double _calculateOrderAmount(
      {required double price, required double variations, required double discount, required double addOns, required double couponDiscount, required List<
          CartModel?>? cartList, required double referralDiscount}) {
    double orderAmount = 0;
    double variationPrice = variations;
    orderAmount =
        (price + variationPrice - discount) + addOns - couponDiscount -
            referralDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  double _calculateSubTotal(
      {required double price, required double addOns, required double variations, required List<
          CartModel?>? cartList}) {
    double subTotal = 0;
    bool isFoodVariation = false;

    if (cartList != null && cartList.isNotEmpty) {
      isFoodVariation = Get
          .find<SplashController>()
          .getModuleConfig(cartList[0]!.item!.moduleType)
          .newVariation!;
    }
    subTotal = price + addOns + variations;

    return subTotal;
  }

  double _calculateOriginalDeliveryCharge(
      {required Store? store, required AddressModel address, required double? distance, required double? extraCharge, double? surgePrice, String? surgePriceType}) {
    double deliveryCharge = -1;

    Pivot? moduleData;
    if (store != null) {
      for (ZoneData zData in address.zoneData!) {
        for (Modules m in zData.modules!) {
          if (m.id == Get
              .find<SplashController>()
              .module!
              .id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }
      }
    }
    double perKmCharge = 0;
    double minimumCharge = 0;
    double? maximumCharge = 0;
    if (store != null && distance != null && distance != -1 &&
        store.selfDeliverySystem == 1) {
      perKmCharge = store.perKmShippingCharge!;
      minimumCharge = store.minimumShippingCharge!;
      maximumCharge = store.maximumShippingCharge;
    } else if (store != null && distance != null && distance != -1 &&
        moduleData != null && moduleData.deliveryChargeType == 'distance') {
      perKmCharge = moduleData.perKmShippingCharge!;
      minimumCharge = moduleData.minimumShippingCharge!;
      maximumCharge = moduleData.maximumShippingCharge;
    } else if (store != null && moduleData != null &&
        moduleData.deliveryChargeType == 'fixed') {
      perKmCharge = moduleData.fixedShippingCharge ?? 0;
      minimumCharge = moduleData.fixedShippingCharge ?? 0;
      maximumCharge = moduleData.fixedShippingCharge ?? 0;
    }
    if (store != null && distance != null) {
      deliveryCharge = distance * perKmCharge;

      if (deliveryCharge < minimumCharge) {
        deliveryCharge = minimumCharge;
      } else if (maximumCharge != null && deliveryCharge > maximumCharge) {
        deliveryCharge = maximumCharge;
      }
    }

    if (store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
      extraChargeForToolTip = extraCharge;
      deliveryCharge = deliveryCharge + extraCharge;
    }

    if (store != null && store.selfDeliverySystem == 0 && surgePrice != null &&
        surgePrice > 0) {
      if (surgePriceType == 'percent') {
        badWeatherChargeForToolTip = (deliveryCharge * (surgePrice / 100));
        deliveryCharge = deliveryCharge + (deliveryCharge * (surgePrice / 100));
      } else {
        badWeatherChargeForToolTip = surgePrice;
        deliveryCharge = deliveryCharge + surgePrice;
      }
    }

    return deliveryCharge;
  }

  double _calculateDeliveryCharge(
      {required Store? store, required AddressModel address, required double? distance, required double? extraCharge, required double orderAmount,
        required String orderType, double? surgePrice, String? surgePriceType}) {
    double deliveryCharge = _calculateOriginalDeliveryCharge(store: store,
        address: address,
        distance: distance,
        extraCharge: extraCharge,
        surgePrice: surgePrice,
        surgePriceType: surgePriceType);

    ConfigModel? configModel = Get
        .find<SplashController>()
        .configModel;


    if (orderType == 'take_away' || (store != null && store.freeDelivery!)
        || (configModel?.adminFreeDelivery?.status == true &&
            (configModel?.adminFreeDelivery?.type != null &&
                configModel?.adminFreeDelivery?.type ==
                    'free_delivery_to_all_store'))
        || ((configModel?.adminFreeDelivery?.status == true &&
            (configModel?.adminFreeDelivery?.type != null &&
                configModel?.adminFreeDelivery?.type ==
                    'free_delivery_by_order_amount') &&
            (configModel!.adminFreeDelivery?.freeDeliveryOver != null &&
                orderAmount >=
                    configModel.adminFreeDelivery!.freeDeliveryOver!))
        && (configModel?.adminFreeDelivery?.status == true &&
            configModel?.adminFreeDelivery?.freeDeliveryKm != null &&
            distance != null &&
            distance <= configModel!.adminFreeDelivery!.freeDeliveryKm!))
        || Get
            .find<CouponController>()
            .freeDelivery || (AuthHelper.isGuestLoggedIn() && (Get
        .find<CheckoutController>()
        .guestAddress == null && Get
        .find<CheckoutController>()
        .orderType != 'take_away'))) {
      deliveryCharge = 0;
    }

    return PriceConverter.toFixed(deliveryCharge);
  }

  double _calculateTotal({
    required double subTotal, required double deliveryCharge, required double discount,
    required double couponDiscount, required bool taxIncluded, required double tax,
    required String orderType, required double tips, required double additionalCharge, required double extraPackagingCharge, required double otherCharge
  }) {
    return PriceConverter.toFixed(
        subTotal + deliveryCharge - discount - couponDiscount +
            (taxIncluded ? 0 : tax)
            + ((orderType != 'take_away' && Get
            .find<SplashController>()
            .configModel!
            .dmTipsStatus == 1) ? tips : 0)
            + additionalCharge + extraPackagingCharge + otherCharge
    );
  }

  bool _checkZoneOfflinePaymentOnOff(
      {required AddressModel? addressModel, required CheckoutController checkoutController}) {
    bool? status = false;
    ZoneData? zoneData;
    for (var data in addressModel!.zoneData!) {
      if (data.id == checkoutController.store?.zoneId) {
        zoneData = data;
        break;
      }
    }
    status = zoneData?.offlinePayment ?? false;
    return status;
  }

  bool _checkPrescriptionRequired() {
    if (widget.storeId == null && Get
        .find<SplashController>()
        .configModel!
        .moduleConfig!
        .module!
        .orderAttachment!) {
      for (var cart in Get
          .find<CheckoutController>()
          .cartList!) {
        if (cart!.item!.isPrescriptionRequired!) {
          return true;
        }
      }
    }
    return false;
  }

  double _calculateExtraPackagingCharge(CheckoutController checkoutController) {
    if ((checkoutController.store?.extraPackagingStatus ?? true) && (Get
        .find<CartController>()
        .needExtraPackage)) {
      return checkoutController.store?.extraPackagingAmount ?? 0;
    }
    return 0;
  }


  double _calculateotherCharge(CheckoutController checkoutController) {
    if ((checkoutController.store?.otherchargeenabled ?? true)) {
      return checkoutController.store?.otherchargeamount ?? 0;
    }
    return 0;
  }

  double _calculateReferralDiscount(double subTotal, double discount,
      double couponDiscount) {
    double referralDiscount = 0;
    if (Get
        .find<ProfileController>()
        .userInfoModel != null && Get
        .find<ProfileController>()
        .userInfoModel!
        .isValidForDiscount!) {
      if (Get
          .find<ProfileController>()
          .userInfoModel!
          .discountAmountType! == "percentage") {
        referralDiscount = (Get
            .find<ProfileController>()
            .userInfoModel!
            .discountAmount! / 100) * (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = Get
            .find<ProfileController>()
            .userInfoModel!
            .discountAmount!;
      }
    }
    return PriceConverter.toFixed(referralDiscount);
  }

  Widget _buildPharmacyCheckoutUI(
    CheckoutController checkoutController, CartController cartController, CouponController couponController,
    double total, double subTotal, double? discount, double referralDiscount, double orderAmount,
    double? maxCodOrderAmount, double originalCharge, double deliveryCharge, List<DropdownItem<int>> addressList,
    bool tomorrowClosed, bool todayClosed, bool isPrescriptionRequired, Module? module, double variations,
    double? itemDiscountPrice,
  ) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  children: [
                    // Pharmacy Items List
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cartController.cartList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, spreadRadius: 1)],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: CartItemWidget(
                            fromCheckout: true,
                            cart: cartController.cartList[index],
                            cartIndex: index,
                            addOns: cartController.addOnsList[index],
                            isAvailable: cartController.availableList[index],
                            showDivider: index != cartController.cartList.length - 1,
                          ),
                        );
                      },
                    ),



                    // Delivery Address Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Deliver to', style: robotoBold.copyWith(fontSize: 16)),
                              InkWell(
                                onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('checkout')),
                                child: Text('Change', style: robotoBold.copyWith(color: const Color(0xFF16A34A), fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AddressHelper.getUserAddressFromSharedPref()?.address ?? 'Select Address',
                                  style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Prescription Section (if required)
                    if (isPrescriptionRequired)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFEF08A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description_outlined, color: Color(0xFF854D0E), size: 20),
                                const SizedBox(width: 8),
                                Text('Prescription Required', style: robotoBold.copyWith(fontSize: 14, color: const Color(0xFF854D0E))),
                              ],
                            ),
                            const SizedBox(height: 8),
                             Text('This order contains items that require a valid medical prescription.', 
                              style: robotoRegular.copyWith(fontSize: 12, color: const Color(0xFF854D0E))),
                            const SizedBox(height: 12),

                            if(checkoutController.pickedPrescriptions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  height: 60,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: checkoutController.pickedPrescriptions.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFFEF08A)),
                                          image: DecorationImage(
                                            image: FileImage(File(checkoutController.pickedPrescriptions[index].path)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            CustomButton(
                              buttonText: 'Upload Prescription',
                              onPressed: () => Get.to(() => const PrescriptionUploadScreen()),
                              radius: 8,
                              height: 35,
                              color: const Color(0xFF854D0E),
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),

                    // Bill Details Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bill Details', style: robotoBold.copyWith(fontSize: 16)),
                          const SizedBox(height: 20),
                          _buildBillRow('Item Total', PriceConverter.convertPrice(subTotal)),
                          const SizedBox(height: 12),
                          _buildBillRow('Delivery Fee', deliveryCharge == 0 ? 'FREE' : PriceConverter.convertPrice(deliveryCharge), isGreen: deliveryCharge == 0),
                          if (discount! > 0) ...[
                            const SizedBox(height: 12),
                            _buildBillRow('Discount', '- ${PriceConverter.convertPrice(discount)}', isGreen: true),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Amount', style: robotoBold.copyWith(fontSize: 18)),
                              PriceConverter.convertAnimationPrice(
                                total,
                                textStyle: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment Method Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Payment Method', style: robotoBold.copyWith(fontSize: 16)),
                              if (checkoutController.paymentMethodIndex != -1)
                                TextButton(
                                  onPressed: () => _onPlaceOrderPressed(checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, checkoutController.orderTax!, discount, total, maxCodOrderAmount, isPrescriptionRequired),
                                  child: Text('Change', style: robotoMedium.copyWith(color: const Color(0xFF16A34A))),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (checkoutController.paymentMethodIndex == -1)
                            InkWell(
                              onTap: () => _onPlaceOrderPressed(checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, checkoutController.orderTax!, discount, total, maxCodOrderAmount, isPrescriptionRequired),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF64748B)),
                                    const SizedBox(width: 12),
                                    Text('Select Payment Method', style: robotoMedium.copyWith(color: const Color(0xFF64748B))),
                                    const Spacer(),
                                    const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDCFCE7)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    checkoutController.paymentMethodIndex == 0 ? Icons.money : 
                                    checkoutController.paymentMethodIndex == 1 ? Icons.account_balance_wallet : 
                                    checkoutController.paymentMethodIndex == 2 ? Icons.payment : Icons.offline_pin,
                                    color: const Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    checkoutController.paymentMethodIndex == 0 ? 'Cash on Delivery' : 
                                    checkoutController.paymentMethodIndex == 1 ? 'Wallet' : 
                                    checkoutController.paymentMethodIndex == 2 ? checkoutController.digitalPaymentName ?? 'Digital Payment' : 'Offline Payment',
                                    style: robotoMedium.copyWith(color: const Color(0xFF16A34A)),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.check_circle, color: const Color(0xFF16A34A), size: 20),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for sticky button
                  ],
                ),
              ),
            ),
          ),
        ),

        // Sticky Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey)),
                    PriceConverter.convertAnimationPrice(total, textStyle: robotoBold.copyWith(fontSize: 20, color: const Color(0xFF16A34A))),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CustomButton(
                    buttonText: widget.fromCart ? 'Proceed to Payment' : 'Place Order',
                    onPressed: checkoutController.acceptTerms ? () => _onPlaceOrderPressed(
                      checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge,
                      checkoutController.orderTax!, discount, total, maxCodOrderAmount, isPrescriptionRequired,
                    ) : null,
                    radius: 12,
                    height: 50,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600)),
        Text(
          value,
          style: robotoBold.copyWith(
            fontSize: 14,
            color: isGreen ? const Color(0xFF16A34A) : Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> showCashBackSnackBar() async {
    await Get.find<HomeController>().getCashBackData(_payableAmount!);
    double? cashBackAmount = Get
        .find<HomeController>()
        .cashBackData
        ?.cashbackAmount ?? 0;
    String? cashBackType = Get
        .find<HomeController>()
        .cashBackData
        ?.cashbackType ?? '';
    String text = '${'you_will_get'.tr} ${cashBackType == 'amount'
        ? PriceConverter.convertPrice(cashBackAmount)
        : '${cashBackAmount.toStringAsFixed(
        0)}%'} ${'cash_back_after_completing_order'.tr}';
    if (cashBackAmount > 0) {
      showCustomSnackBar(text, isError: false);
    }
  }

}


class CheckoutTabBar extends StatelessWidget {
  final List<String> tabs = const [
    'Delivery Type',
    'Tip',
    'Instructions',
  ];

  const CheckoutTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (controller) {
        return Container(
          height: 35.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xffF3F4F7),
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final indicatorWidth =
                  (constraints.maxWidth - 8.r) / tabs.length;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    left: controller.selectedtabIndex * indicatorWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: indicatorWidth,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(
                      tabs.length,
                          (index) => Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(index),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text(
                              tabs[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                                color:
                                controller.selectedtabIndex == index
                                    ? Colors.white
                                    : const Color(0xff1C1C1E),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}


class FactCardView extends StatefulWidget {
  const FactCardView({super.key});

  @override
  State<FactCardView> createState() => _FactCardViewState();
}

class _FactCardViewState extends State<FactCardView>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF9E9E9E),
      end: const Color(0xFF000000),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 48,
                color: Color(0xFFBDBDBD),
              ),

              const SizedBox(height: 24),

              // Animated Quote (Blink Grey ↔ Black)
              AnimatedBuilder(
                animation: _colorAnimation,
                builder: (_, __) {
                  return Text(
                    '"${AppConstants.appName} processes upto 200 orders every 10 minutes during peak hours!"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: _colorAnimation.value,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              const Text(
                '- ${AppConstants.appName} Scale',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFB0B0B0),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Tap for next fact',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFD6D6D6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

