import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:handy_allinone/features/home/screens/delivery_quotation_list_screen.dart';
import 'package:handy_allinone/features/home/screens/quotation_image_screen.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/auth/screens/new_user_setup_screen.dart';
import 'package:handy_allinone/features/brands/screens/brands_product_screen.dart';
import 'package:handy_allinone/features/brands/screens/brands_screen.dart';
import 'package:handy_allinone/features/business/screens/subscription_payment_screen.dart';
import 'package:handy_allinone/features/business/screens/subscription_success_or_failed_screen.dart';
import 'package:handy_allinone/features/chat/domain/models/order_chat_model.dart';
import 'package:handy_allinone/features/item/screens/item_view_all_screen.dart';
import 'package:handy_allinone/features/loyalty/screens/loyalty_screen.dart';
import 'package:handy_allinone/features/profile/domain/models/update_user_model.dart';
import 'package:handy_allinone/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/notification/domain/models/notification_body_model.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/item/domain/models/basic_campaign_model.dart';
import 'package:handy_allinone/features/chat/domain/models/conversation_model.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/parcel/domain/models/parcel_category_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/features/address/screens/add_address_screen.dart';
import 'package:handy_allinone/features/address/screens/address_screen.dart';
import 'package:handy_allinone/features/auth/screens/delivery_man_registration_screen.dart';
import 'package:handy_allinone/features/auth/screens/sign_in_screen.dart';
import 'package:handy_allinone/features/auth/screens/sign_up_screen.dart';
import 'package:handy_allinone/features/auth/screens/store_registration_screen.dart';
import 'package:handy_allinone/features/category/screens/category_screen.dart';
import 'package:handy_allinone/features/location/screens/map_screen.dart';
import 'package:handy_allinone/features/store/screens/campaign_screen.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/html_type.dart';
import 'package:handy_allinone/common/widgets/image_viewer_screen.dart';
import 'package:handy_allinone/common/widgets/not_found.dart';
import 'package:handy_allinone/features/cart/screens/cart_screen.dart';
import 'package:handy_allinone/features/category/screens/category_item_screen.dart';
import 'package:handy_allinone/features/chat/screens/chat_screen.dart';
import 'package:handy_allinone/features/chat/screens/conversation_screen.dart';
import 'package:handy_allinone/features/checkout/screens/checkout_screen.dart';
import 'package:handy_allinone/features/payment/screens/offline_payment_screen.dart';
import 'package:handy_allinone/features/checkout/screens/order_successful_screen.dart';
import 'package:handy_allinone/features/payment/screens/payment_screen.dart';
import 'package:handy_allinone/features/payment/screens/payment_webview_screen.dart';
import 'package:handy_allinone/features/coupon/screens/coupon_screen.dart';
import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
import 'package:handy_allinone/features/favourite/screens/favourite_screen.dart';
import 'package:handy_allinone/features/flash_sale/screens/flash_sale_details_screen.dart';
import 'package:handy_allinone/features/item/screens/item_campaign_screen.dart';
import 'package:handy_allinone/features/item/screens/item_details_screen.dart';
import 'package:handy_allinone/features/item/screens/popular_item_screen.dart';
import 'package:handy_allinone/features/verification/screens/forget_pass_screen.dart';
import 'package:handy_allinone/features/verification/screens/new_pass_screen.dart';
import 'package:handy_allinone/features/verification/screens/verification_screen.dart';
import 'package:handy_allinone/features/html/screens/html_viewer_screen.dart';
import 'package:handy_allinone/features/interest/screens/interest_screen.dart';
import 'package:handy_allinone/features/language/screens/language_screen.dart';
import 'package:handy_allinone/features/location/screens/access_location_screen.dart';
import 'package:handy_allinone/features/location/screens/pick_map_screen.dart';
import 'package:handy_allinone/features/notification/screens/notification_screen.dart';
import 'package:handy_allinone/features/onboard/screens/onboarding_screen.dart';
import 'package:handy_allinone/features/order/screens/guest_track_order_screen.dart';
import 'package:handy_allinone/features/order/screens/order_details_screen.dart';
import 'package:handy_allinone/features/order/screens/order_screen.dart';
import 'package:handy_allinone/features/order/screens/order_tracking_screen.dart';
import 'package:handy_allinone/features/order/screens/refund_request_screen.dart';
import 'package:handy_allinone/features/order/screens/delivar_webview_screen.dart';
import 'package:handy_allinone/features/parcel/screens/parcel_category_screen.dart';
import 'package:handy_allinone/features/parcel/screens/parcel_location_screen.dart';
import 'package:handy_allinone/features/parcel/screens/parcel_request_screen.dart';
import 'package:handy_allinone/features/profile/screens/profile_screen.dart';
import 'package:handy_allinone/features/profile/screens/update_profile_screen.dart';
import 'package:handy_allinone/features/store/screens/all_store_screen.dart';
import 'package:handy_allinone/features/store/screens/store_item_search_screen.dart';
import 'package:handy_allinone/features/store/screens/store_screen.dart';
import 'package:handy_allinone/features/review/screens/review_screen.dart';
import 'package:handy_allinone/features/search/screens/search_screen.dart';
import 'package:handy_allinone/features/splash/screens/splash_screen.dart';
import 'package:handy_allinone/features/support/screens/support_screen.dart';
import 'package:handy_allinone/features/update/screens/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/wallet/screens/wallet_screen.dart';
import 'package:handy_allinone/features/order/screens/prescription_upload_screen.dart';

import '../features/razorpay-ak/razor_native_pay.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onBoarding = '/on-boarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String verification = '/verification';
  static const String accessLocation = '/access-location';
  static const String pickMap = '/pick-map';
  static const String interest = '/interest';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String search = '/search';
  static const String store = '/store';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String coupon = '/coupon';
  static const String notification = '/notification';
  static const String map = '/map';
  static const String address = '/address';
  static const String orderSuccess = '/order-successful';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String orderTracking = '/track-order';
  static const String basicCampaign = '/basic-campaign';
  static const String html = '/html-page';
  static const String categories = '/categories';
  static const String categoryItem = '/category-item';
  static const String popularItems = '/popular-items';
  static const String itemCampaign = '/item-campaign';
  static const String support = '/help-and-support';
  static const String rateReview = '/rate-and-review';
  static const String update = '/update';
  static const String cart = '/cart';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String storeReview = '/store-review';
  static const String allStores = '/stores';
  static const String itemImages = '/item-images';
  static const String parcelCategory = '/parcel-category';
  static const String parcelLocation = '/parcel-location';
  static const String parcelRequest = '/parcel-request';
  static const String searchStoreItem = '/search-store-item';
  static const String order = '/order';
  static const String itemDetails = '/item-details';
  static const String wallet = '/wallet';
  static const String loyalty = '/loyalty';
  static const String referAndEarn = '/refer-and-earn';
  static const String messages = '/messages';
  static const String conversation = '/conversation';
  static const String restaurantRegistration = '/store-registration';
  static const String deliveryManRegistration = '/delivery-man-registration';
  static const String refund = '/refund';
  static const String delivarTracking = '/delivar-tracking';
  static const String deliveryQuotationList = '/delivery-quotation-list';
  static const String quotationImage = '/quotation-image';
  static const String prescriptionUpload = '/prescription-upload';

  static const String offlinePaymentScreen = '/offline-payment-screen';
  static const String flashSaleDetailsScreen = '/flash-sale-details-screen';
  static const String guestTrackOrderScreen = '/guest-track-order-screen';
  static const String favourite = '/favourite';
  static const String brands = '/brands';
  static const String brandsItemScreen = '/brands-item-screen';

  static const String subscriptionSuccess = '/subscription-success';
  static const String subscriptionPayment = '/subscription-payment';
  static const String newUserSetupScreen = '/new-user-setup-screen';
  static const String itemViewAllScreen = '/item-view-all-screen';

///added by ak
  // static String getInitialRoute({bool fromSplash = false}) => '$initial?from-splash=$fromSplash';
  static String getInitialRoute({bool fromSplash = false}) {
    final isLoggedIn = AuthHelper.isLoggedIn();

    if (isLoggedIn) {
      return '$initial?from-splash=$fromSplash';
    } else {
      return '$signIn?page=$splash';
    }
  }


  static String getSplashRoute(NotificationBodyModel? body) {
    String data = 'null';
    if(body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encoded);
    }
    return '$splash?data=$data';
  }
  static String getPrescriptionUploadRoute() => prescriptionUpload;
  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getOnBoardingRoute() => onBoarding;
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getSignUpRoute() => signUp;
  static String getVerificationRoute(String? number, String? email, String? token, String page, String? pass, String loginType, {String? session, UpdateUserModel? updateUserModel}) {
    String? authSession;
    String? userModel;
    if(session != null) {
      authSession = base64Url.encode(utf8.encode(session));
    }
    if(updateUserModel != null) {
      List<int> encoded = utf8.encode(jsonEncode(updateUserModel.toJson()));
      userModel = base64Encode(encoded);
    }
    return '$verification?page=$page&number=$number&email=$email&token=$token&pass=$pass&login_type=$loginType&session=$authSession&user_model=$userModel';
  }

  static String getAccessLocationRoute(String page) => '$accessLocation?page=$page';
  static String getPickMapRoute(String? page, bool canRoute) => '$pickMap?page=$page&route=${canRoute.toString()}';
  static String getInterestRoute() => interest;
  static String getMainRoute(String page) => '$main?page=$page';
  static String getForgotPassRoute() => forgotPassword;
  static String getResetPasswordRoute({String? phone, String? email, required String token, required String page}) => '$resetPassword?phone=$phone&token=$token&page=$page&email=$email';
  static String getSearchRoute({String? queryText}) => '$search?query=${queryText ?? ''}';
  static String getStoreRoute({required int? id, required String page}) {
    return '$store?id=$id&page=$page';
  }
  static String getOrderDetailsRoute(int? orderID, {bool? fromNotification, bool? fromOffline, String? contactNumber}) {
    return '$orderDetails?id=$orderID&from=${fromNotification.toString()}&from_offline=$fromOffline&contact=$contactNumber';
  }
  static String getProfileRoute() => profile;
  static String getUpdateProfileRoute() => updateProfile;
  static String getCouponRoute() => coupon;
  static String getNotificationRoute({bool? fromNotification}) => '$notification?from=${fromNotification.toString()}';
  static String getMapRoute(AddressModel addressModel, String page, bool isFood, {String? storeName}) {
    List<int> encoded = utf8.encode(jsonEncode(addressModel.toJson()));
    String data = base64Encode(encoded);
    return '$map?address=$data&page=$page&module=$isFood&store-name=$storeName';
  }
  static String getAddressRoute() => address;
  static String getOrderSuccessRoute(String orderID, String? contactNumber, {bool? createAccount, String guestId = ''}) {
    return '$orderSuccess?id=$orderID&contact_number=$contactNumber&create_account=$createAccount&guest_id=$guestId';
  }
  static String getPaymentRoute(String id, int? user, String? type, double amount, bool? codDelivery, String? paymentMethod, {required String guestId, String? contactNumber, String? addFundUrl, String? subscriptionUrl, int? storeId, bool? createAccount, int? createUserId}
      ) => '$payment?id=$id&user=$user&type=$type&amount=$amount&cod-delivery=$codDelivery&add-fund-url=$addFundUrl&payment-method=$paymentMethod&guest-id=$guestId&number=$contactNumber&subscription-url=$subscriptionUrl&store_id=$storeId&create_account=$createAccount&create_user_id=$createUserId';
  static String getCheckoutRoute(String page,{int? storeId}) => '$checkout?page=$page&store-id=$storeId';
  static String getOrderTrackingRoute(int? id, String? contactNumber) => '$orderTracking?id=$id&number=$contactNumber';
  static String getDelivarTrackingRoute(String url) {
    String encodedUrl = base64Encode(utf8.encode(url));
    return '$delivarTracking?url=$encodedUrl';
  }
  static String getBasicCampaignRoute(BasicCampaignModel basicCampaignModel) {
    String data = base64Encode(utf8.encode(jsonEncode(basicCampaignModel.toJson())));
    return '$basicCampaign?data=$data';
  }
  static String getHtmlRoute(String page) => '$html?page=$page';
  static String getCategoryRoute() => categories;
  static String getCategoryItemRoute(int? id, String name) {
    List<int> encoded = utf8.encode(name);
    String data = base64Encode(encoded);
    return '$categoryItem?id=$id&name=$data';
  }
  static String getPopularItemRoute(bool isPopular, bool isSpecial) => '$popularItems?page=${isPopular ? 'popular' : 'reviewed'}&special=${isSpecial.toString()}';
  static String getItemCampaignRoute({bool isJustForYou = false}) => itemCampaign + (isJustForYou ? '?just-for-you=${isJustForYou.toString()}' : '');
  static String getSupportRoute() => support;
  static String getReviewRoute() => rateReview;
  static String getUpdateRoute(bool isUpdate) => '$update?update=${isUpdate.toString()}';
  static String getCartRoute() => cart;
  static String getAddAddressRoute(bool fromCheckout, bool fromRide, int? zoneId, {bool isNavbar = false}) => '$addAddress?page=${fromCheckout ? 'checkout' : 'address'}&ride=$fromRide&zone_id=$zoneId&navbar=$isNavbar';
  static String getEditAddressRoute(AddressModel? address, {bool fromGuest = false}) {
    String data = 'null';
    if(address != null) {
      data = base64Url.encode(utf8.encode(jsonEncode(address.toJson())));
    }
    return '$editAddress?data=$data&from-guest=$fromGuest';
  }
  static String getStoreReviewRoute(int? storeID, String? storeName, Store store) {
    String data = base64Url.encode(utf8.encode(jsonEncode(store.toJson())));
    return '$storeReview?storeID=$storeID&storeName=$storeName&store=$data';
  }
  static String getAllStoreRoute(String page, {bool isNearbyStore = false}) => '$allStores?page=$page${isNearbyStore ? '&nearby=${isNearbyStore.toString()}' : ''}';
  static String getItemImagesRoute(Item item) {
    String data = base64Url.encode(utf8.encode(jsonEncode(item.toJson())));
    return '$itemImages?item=$data';
  }
  static String getParcelCategoryRoute() => parcelCategory;
  static String getParcelLocationRoute(ParcelCategoryModel category) {
    String data = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    return '$parcelLocation?data=$data';
  }
  static String getParcelRequestRoute(ParcelCategoryModel category, AddressModel pickupAddress, AddressModel destinationAddress) {
    String category0 = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    String pickedUpAddress = base64Url.encode(utf8.encode(jsonEncode(pickupAddress.toJson())));
    String destinationAddress0 = base64Url.encode(utf8.encode(jsonEncode(destinationAddress.toJson())));
    return '$parcelRequest?category=$category0&picked=$pickedUpAddress&destination=$destinationAddress0';
  }
  static String getSearchStoreItemRoute(int? storeID) => '$searchStoreItem?id=$storeID';
  static String getOrderRoute() => order;
  static String getItemDetailsRoute(int? itemID, bool isRestaurant) => '$itemDetails?id=$itemID&page=${isRestaurant ? 'restaurant' : 'item'}';
  static String getWalletRoute({String? fundStatus, String? token,  bool fromNotification = false}) => '$wallet?payment_status=$fundStatus&token=$token&from_notification=$fromNotification';
  static String getLoyaltyRoute({bool fromNotification = false}) => '$loyalty?from_notification=$fromNotification';
  static String getReferAndEarnRoute() => referAndEarn;
  static String getChatRoute({required NotificationBodyModel? notificationBody, User? user, int? conversationID, int? index, bool? fromNotification, OrderChatModel? orderChatModel}) {
    String notificationBody0 = 'null';
    if(notificationBody != null) {
      notificationBody0 = base64Encode(utf8.encode(jsonEncode(notificationBody.toJson())));
    }
    String orderChat = 'null';
    if(orderChatModel != null) {
      orderChat = base64Encode(utf8.encode(jsonEncode(orderChatModel.toJson())));
    }
    String user0 = 'null';
    if(user != null) {
      user0 = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$messages?notification=$notificationBody0&user=$user0&conversation_id=$conversationID&index=$index&from=${fromNotification.toString()}&order-chat=$orderChat';
  }
  static String getConversationRoute() => conversation;
  static String getRestaurantRegistrationRoute() => restaurantRegistration;
  static String getDeliverymanRegistrationRoute() => deliveryManRegistration;
  static String getRefundRequestRoute(String orderID) => '$refund?id=$orderID';
  static String getDeliveryQuotationListRoute() => deliveryQuotationList;
  static String getQuotationImageRoute(List<String> images) {
    String data = base64Encode(utf8.encode(jsonEncode(images)));
    return '$quotationImage?data=$data';
  }

  static String getOfflinePaymentScreen({
    required PlaceOrderBodyModel placeOrderBody, required int? zoneId, required double total,
    required double? maxCodOrderAmount, required bool fromCart, required bool? isCodActive,
    required bool forParcel,
  }) {
    List<int> encoded = utf8.encode(jsonEncode(placeOrderBody.toJson()));
    String data = base64Encode(encoded);
    return '$offlinePaymentScreen?order_body=$data&zone_id=$zoneId&total=$total&max_cod_amount=$maxCodOrderAmount&from_cart=$fromCart&cod_active=$isCodActive&for_parcel=$forParcel';
  }
  static String getFlashSaleDetailsScreen(int id) => '$flashSaleDetailsScreen?id=$id';
  static String getGuestTrackOrderScreen(String orderId, String number) => '$guestTrackOrderScreen?order_id=$orderId&number=$number';
  static String getFavouriteScreen() => favourite;
  static String getBrandsScreen() => brands;
  static String getBrandsItemScreen(int brandId, String brandName) => '$brandsItemScreen?brandId=$brandId&brandName=$brandName';

  static String getSubscriptionSuccessRoute({String? status, required bool fromSubscription, int? storeId}) => '$subscriptionSuccess?flag=$status&from_subscription=$fromSubscription&store_id=$storeId';
  static String getSubscriptionPaymentRoute({required int? storeId, required int? packageId}) => '$subscriptionPayment?store-id=$storeId&package-id=$packageId';
  static String getNewUserSetupScreen({required String name, required String loginType, required String? phone, required String? email}) {
    return '$newUserSetupScreen?name=$name&login_type=$loginType&phone=$phone&email=$email';
  }
  static String getItemViewAllScreen(bool isPopular, bool isSpecial) => '$itemViewAllScreen?page=${isPopular ? 'popular' : 'reviewed'}&special=${isSpecial.toString()}';

  static List<GetPage> routes = [
    GetPage(name: initial,
        customTransition: ZoomInTransition(),
       page: () => getRoute(DashboardScreen(pageIndex: 0, fromSplash: Get.parameters['from-splash'] == 'true'))),
    GetPage(name: splash,
        customTransition: ZoomInTransition(),
        page: () {
      NotificationBodyModel? data;
      if(Get.parameters['data'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
        data = NotificationBodyModel.fromJson(jsonDecode(utf8.decode(decode)));
      }
      return SplashScreen(body: data);
    }),
    GetPage(name: language,
        customTransition: ZoomInTransition(),
        page: () => ChooseLanguageScreen(fromMenu: Get.parameters['page'] == 'menu')),
    GetPage(name: onBoarding,  customTransition: ZoomInTransition(),
        page: () => const OnBoardingScreen()),
    GetPage(name: signIn,  customTransition: ZoomInTransition(),
        page: () => SignInScreen(
      exitFromApp: Get.parameters['page'] == signUp || Get.parameters['page'] == splash || Get.parameters['page'] == onBoarding,
      backFromThis: Get.parameters['page'] != splash && Get.parameters['page'] != onBoarding,
      fromNotification: Get.parameters['page'] == notification, fromResetPassword: Get.parameters['page'] == resetPassword,
    )),
    GetPage(name: signUp,  customTransition: ZoomInTransition(),
        page: () => const SignUpScreen()),
    GetPage(name: verification,  customTransition: ZoomInTransition(),
        page: () {
      String? pass;
      if(Get.parameters['pass'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['pass']!.replaceAll(' ', '+'));
        pass = utf8.decode(decode);
      }
      String? session;
      if(Get.parameters['session'] != null && Get.parameters['session'] != 'null') {
        session = utf8.decode(base64Url.decode(Get.parameters['session'] ?? ''));
      }
      UpdateUserModel? userModel;
      if(Get.parameters['user_model'] != null && Get.parameters['user_model'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['user_model'] != null ? Get.parameters['user_model']!.replaceAll(' ', '+') : '');
        userModel = UpdateUserModel.fromJson(jsonDecode(utf8.decode(decode)));
      }
      return VerificationScreen(
        number: Get.parameters['number'] != '' && Get.parameters['number'] != 'null' ? Get.parameters['number'] : null,
        fromSignUp: Get.parameters['page'] == signUp, token: Get.parameters['token'], password: pass,
        email: Get.parameters['email'] != '' && Get.parameters['email'] != 'null' ? Get.parameters['email'] : null, loginType: Get.parameters['login_type']!,
        firebaseSession: session, fromForgetPassword: Get.parameters['page'] == forgotPassword, userModel: userModel,
      );
    }),

    GetPage(name: accessLocation,  customTransition: ZoomInTransition(),
        page: () => AccessLocationScreen(
      fromSignUp: Get.parameters['page'] == signUp, fromHome: Get.parameters['page'] == 'home', route: null,
    )),
    GetPage(name: pickMap,  customTransition: ZoomInTransition(),
        page: () {
      PickMapScreen? pickMapScreen = Get.arguments;
      bool fromAddress = Get.parameters['page'] == 'add-address';
      return ((Get.parameters['page'] == 'parcel' && pickMapScreen == null) || (fromAddress && pickMapScreen == null))
          ? const NotFound() : pickMapScreen ?? PickMapScreen(
        fromSignUp: Get.parameters['page'] == signUp, fromAddAddress: fromAddress, route: Get.parameters['page'],
        canRoute: Get.parameters['route'] == 'true',
      );
    }),
    GetPage(name: interest,  customTransition: ZoomInTransition(),
        page: () => const InterestScreen()),
    GetPage(name: main,  customTransition: ZoomInTransition(),
        page: () => getRoute(
        DashboardScreen(
      pageIndex: Get.parameters['page'] == 'home' ? 0 : Get.parameters['page'] == 'favourite' ? 1
          : Get.parameters['page'] == 'cart' ? 2 : Get.parameters['page'] == 'order' ? 3 : Get.parameters['page'] == 'menu' ? 4 : 0,
    )
    )),

    GetPage(name: forgotPassword,   customTransition: ZoomInTransition(),
        page: () => const ForgetPassScreen()),

    GetPage(name: resetPassword,  customTransition: ZoomInTransition(),
        page: () => NewPassScreen(
      resetToken: Get.parameters['token'], number: Get.parameters['phone'], fromPasswordChange: Get.parameters['page'] == 'password-change',
      email: Get.parameters['email'],
    )),
    GetPage(name: search,  transition: Transition.fadeIn,
       page: () => getRoute(SearchScreen(queryText: Get.parameters['query']))),
    GetPage(name: store,  customTransition: ZoomInTransition(),
      page: () {
      return getRoute(Get.arguments ?? StoreScreen(
        store: Store(id: Get.parameters['id'] != 'null' && Get.parameters['id'] != null ? int.parse(Get.parameters['id']!) : null),
        fromModule: Get.parameters['page'] != null && Get.parameters['page'] == 'module',
        slug: Get.parameters['slug'] ?? '',
      ), byPuss: Get.parameters['slug']?.isNotEmpty ?? false);
    }),
    GetPage(name: orderDetails,   customTransition: ZoomInTransition(),
        page: () {
      return getRoute(Get.arguments ?? OrderDetailsScreen(
        orderId: int.parse(Get.parameters['id'] ?? '0'), orderModel: null, fromNotification: Get.parameters['from'] == 'true',
        fromOfflinePayment: Get.parameters['from_offline'] == 'true', contactNumber: Get.parameters['contact'],
      ),);
    }),
    GetPage(name: profile,   customTransition: ZoomInTransition(),
       page: () => getRoute(const ProfileScreen())),
    GetPage(name: updateProfile,  customTransition: ZoomInTransition(),
       page: () => getRoute(const UpdateProfileScreen())),
    GetPage(name: coupon,  customTransition: ZoomInTransition(),
     page: () => getRoute(const CouponScreen())),
    GetPage(name: notification,  customTransition: ZoomInTransition(),
        page: () => getRoute(NotificationScreen(fromNotification: Get.parameters['from'] == 'true'))),
    GetPage(name: map,  customTransition: ZoomInTransition(),
        page: () {
      List<int> decode = base64Decode(Get.parameters['address']!.replaceAll(' ', '+'));
      AddressModel data = AddressModel.fromJson(jsonDecode(utf8.decode(decode)));
      return getRoute(MapScreen(fromStore: Get.parameters['page'] == 'store', address: data, isFood: Get.parameters['module'] == 'true', storeName: Get.parameters['store-name'] ?? ''));
    }),
    GetPage(name: address,   customTransition: ZoomInTransition(),
        page: () => getRoute(const AddressScreen())),
    GetPage(name: orderSuccess,  customTransition: ZoomInTransition(),
       page: () => getRoute(OrderSuccessfulScreen(
      orderID: Get.parameters['id'],
      contactPersonNumber: Get.parameters['contact_number'] != null && Get.parameters['contact_number'] != 'null'
          ? Get.parameters['contact_number']
          : AuthHelper.isGuestLoggedIn() ? Get.find<AuthController>().getGuestNumber() : null,
      createAccount: Get.parameters['create_account'] == 'true', guestId: Get.parameters['guest_id'] ?? '',
    ),
    )),
    GetPage(name: payment,  customTransition: ZoomInTransition(),
        page: () {
      OrderModel order = OrderModel(
        id: int.parse(Get.parameters['id']!), orderType: Get.parameters['type'], userId: int.parse(Get.parameters['user']!),
        orderAmount: double.parse(Get.parameters['amount']!),
      );
      bool isCodActive = Get.parameters['cod-delivery'] == 'true';
      String addFundUrl = '';
      String subscriptionUrl = '';
      String paymentMethod = Get.parameters['payment-method']!;
      if(Get.parameters['add-fund-url'] != null && Get.parameters['add-fund-url'] != 'null'){
        addFundUrl = Get.parameters['add-fund-url']!;
      }
      if(Get.parameters['subscription-url'] != null && Get.parameters['subscription-url'] != 'null'){
        subscriptionUrl = Get.parameters['subscription-url']!;
      }
      String guestId = Get.parameters['guest-id']!;
      String number = Get.parameters['number']!;
      int? storeId = (Get.parameters['store_id'] != null && Get.parameters['store_id'] != 'null') ? int.parse(Get.parameters['store_id']!) : null;
      bool createAccount = Get.parameters['create_account'] == 'true';
      int? createUserId = Get.parameters['create_user_id'] != null && Get.parameters['create_user_id'] != 'null' ? int.parse(Get.parameters['create_user_id']!) : null;
      return getRoute(AppConstants.payInWevView ? PaymentWebViewScreen(
        orderModel: order, isCashOnDelivery: isCodActive, addFundUrl: addFundUrl, paymentMethod: paymentMethod, guestId: guestId,
        contactNumber: number, subscriptionUrl: subscriptionUrl, storeId: storeId, createAccount: createAccount,
      ) :
   kIsWeb?
   PaymentScreen(
     orderModel: order, isCashOnDelivery: isCodActive, addFundUrl: addFundUrl, paymentMethod: paymentMethod, guestId: guestId,
     contactNumber: number, subscriptionUrl: subscriptionUrl, storeId: storeId, createAccount: createAccount, createUserId: createUserId,
   )
   : PaymentScreenmobile(
        orderModel: order,
        isCashOnDelivery: isCodActive,
        addFundUrl: addFundUrl,
        paymentMethod: paymentMethod,
        guestId: guestId,
        contactNumber: number,
        subscriptionUrl: subscriptionUrl,
        storeId: storeId,
        createAccount: createAccount,
        createUserId: createUserId,
      ));
    }),
    GetPage(name: checkout,   customTransition: ZoomInTransition(),
        page: () {
      CheckoutScreen? checkoutScreen = Get.arguments;
      // bool fromCart = Get.parameters['page'] == 'cart';
      return getRoute(checkoutScreen ?? (/*!fromCart ? const NotFound() :*/ CheckoutScreen(
        cartList: null, fromCart: Get.parameters['page'] == 'cart', storeId: Get.parameters['store-id'] != 'null' ? int.parse(Get.parameters['store-id']!) : null,
      )));
    }),
    GetPage(name: orderTracking,  customTransition: ZoomInTransition(),
       page: () => getRoute(OrderTrackingScreen(orderID: Get.parameters['id'], contactNumber: Get.parameters['number'],))),
    GetPage(name: basicCampaign,   customTransition: ZoomInTransition(),
        page: () {
      BasicCampaignModel data = BasicCampaignModel.fromJson(jsonDecode(utf8.decode(base64Decode(Get.parameters['data']!.replaceAll(' ', '+')))));
      return getRoute(CampaignScreen(campaign: data));
    }),
    GetPage(name: html,  customTransition: ZoomInTransition(),
       page: () => HtmlViewerScreen(
      htmlType: Get.parameters['page'] == 'terms-and-condition' ? HtmlType.termsAndCondition
          : Get.parameters['page'] == 'privacy-policy' ? HtmlType.privacyPolicy
          : Get.parameters['page'] == 'shipping-policy' ? HtmlType.shippingPolicy
          : Get.parameters['page'] == 'cancellation-policy' ? HtmlType.cancellation
          : Get.parameters['page'] == 'refund-policy' ? HtmlType.refund : HtmlType.aboutUs,
    )),
    GetPage(name: categories,  customTransition: ZoomInTransition(),
        page: () => getRoute(const CategoryScreen())),
    GetPage(name: categoryItem,  customTransition: ZoomInTransition(),
        page: () {
      List<int> decode = base64Decode(Get.parameters['name']!.replaceAll(' ', '+'));
      String data = utf8.decode(decode);
      return getRoute(CategoryItemScreen(categoryID: Get.parameters['id'], categoryName: data));
    }),
    GetPage(name: popularItems,  customTransition: ZoomInTransition(),
        page: () => getRoute(PopularItemScreen(isPopular: Get.parameters['page'] == 'popular', isSpecial: Get.parameters['special'] == 'true'))),
    GetPage(name: itemCampaign,customTransition: ZoomInTransition(), page: () => getRoute(ItemCampaignScreen(isJustForYou: Get.parameters['just-for-you'] == 'true'))),
    GetPage(name: support,customTransition: ZoomInTransition(), page: () => const SupportScreen()),
    GetPage(name: update,customTransition: ZoomInTransition(), page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(name: cart,customTransition: ZoomInTransition(), page: () {
      bool isPharmacy = Get.find<SplashController>().module?.moduleType == 'pharmacy';
      if(isPharmacy) {
        return getRoute(const CartScreen(fromNav: false));
      } else {
        return getRoute(const CheckoutScreen(cartList: null, fromCart: true, storeId: null));
      }
    }),
    GetPage(name: addAddress,customTransition: ZoomInTransition(), page: () => getRoute(AddAddressScreen(
      fromCheckout: Get.parameters['page'] == 'checkout', fromRide: Get.parameters['ride'] == 'true', zoneId: int.parse(Get.parameters['zone_id']!),
      fromNavBar: Get.parameters['navbar'] == 'true',
    ))),
    GetPage(name: editAddress,customTransition: ZoomInTransition(), page: () {
      AddressModel? data;
      if(Get.parameters['data'] != 'null') {
      data = AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['data']!.replaceAll(' ', '+')))));
      }
      return getRoute(AddAddressScreen(
        fromCheckout: false, fromRide: false,
        address: data, forGuest: Get.parameters['from-guest'] == 'true',
      ));
    }),
    GetPage(name: rateReview,customTransition: ZoomInTransition(), page: () => getRoute(Get.arguments ?? const NotFound())),
    GetPage(name: storeReview,customTransition: ZoomInTransition(), page: () => getRoute(ReviewScreen(storeID: Get.parameters['storeID'], storeName: Get.parameters['storeName'], store: Store.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['store']!.replaceAll(' ', '+')))))))),
    GetPage(name: allStores,  transition: Transition.noTransition,   // essential for Hero animation
        opaque: true,
        page: () => getRoute(AllStoreScreen(
      isPopular: Get.parameters['page'] == 'popular', isFeatured: Get.parameters['page'] == 'featured',
      isTopOfferStore: Get.parameters['page'] == 'topOffer', isNearbyStore: Get.parameters['nearby'] == 'true',
      isRecommendedStore: Get.parameters['page'] == 'recommended',
    ))),
    GetPage(name: itemImages,customTransition: ZoomInTransition(), page: () => getRoute(ImageViewerScreen(
      item: Item.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['item']!.replaceAll(' ', '+'))))),
    ))),
    GetPage(name: parcelCategory,customTransition: ZoomInTransition(), page: () => getRoute(const ParcelCategoryScreen())),
    GetPage(name: parcelLocation,customTransition: ZoomInTransition(), page: () => getRoute(ParcelLocationScreen(
      category: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['data']!.replaceAll(' ', '+'))))),
    ))),
    GetPage(name: parcelRequest,customTransition: ZoomInTransition(), page: () => getRoute(ParcelRequestScreen(
      parcelCategory: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['category']!.replaceAll(' ', '+'))))),
      pickedUpAddress: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['picked']!.replaceAll(' ', '+'))))),
      destinationAddress: AddressModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['destination']!.replaceAll(' ', '+'))))),
    ))),
    GetPage(name: searchStoreItem,customTransition: ZoomInTransition(), page: () => getRoute(StoreItemSearchScreen(storeID: Get.parameters['id']))),
    GetPage(name: order,customTransition: ZoomInTransition(), page: () => getRoute(const OrderScreen())),
    GetPage(name: itemDetails,customTransition: ZoomInTransition(), page: () => getRoute(Get.arguments ?? ItemDetailsScreen(itemId: int.parse(Get.parameters['id']!), inStorePage: Get.parameters['page'] == 'restaurant'))),
    GetPage(name: wallet,customTransition: ZoomInTransition(), page: () {
      return getRoute(WalletScreen(
        fundStatus: Get.parameters['flag'] ?? Get.parameters['payment_status'],
        token: Get.parameters['token'],
        fromNotification: Get.parameters['from_notification'] == 'true',
      ));
    }),
    GetPage(name: loyalty,customTransition: ZoomInTransition(), page: () => getRoute(LoyaltyScreen(fromNotification: Get.parameters['from_notification'] == 'true'))),
    GetPage(name: referAndEarn,customTransition: ZoomInTransition(), page: () => getRoute(const ReferAndEarnScreen())),
    GetPage(name: messages,customTransition: ZoomInTransition(), page: () {
      NotificationBodyModel? notificationBody;
      if(Get.parameters['notification'] != 'null') {
        notificationBody = NotificationBodyModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['notification']!.replaceAll(' ', '+')))));
      }
      OrderChatModel? orderChat;
      if(Get.parameters['order-chat'] != 'null') {
        orderChat = OrderChatModel.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['order-chat']!.replaceAll(' ', '+')))));
      }
      User? user;
      if(Get.parameters['user'] != 'null') {
        user = User.fromJson(jsonDecode(utf8.decode(base64Url.decode(Get.parameters['user']!.replaceAll(' ', '+')))));
      }
      return getRoute(ChatScreen(
        notificationBody: notificationBody, user: user, index: Get.parameters['index'] != 'null' ? int.parse(Get.parameters['index']!) : null, fromNotification: Get.parameters['from'] == 'true',
        conversationID: (Get.parameters['conversation_id'] != null && Get.parameters['conversation_id'] != 'null') ? int.parse(Get.parameters['conversation_id']!) : null,
        orderChatModel: orderChat,
      ));
    }),
    GetPage(name: conversation,customTransition: ZoomInTransition(), page: () => const ConversationScreen()),
    GetPage(name: restaurantRegistration,customTransition: ZoomInTransition(), page: () => const StoreRegistrationScreen()),
    GetPage(name: deliveryManRegistration,customTransition: ZoomInTransition(), page: () => const DeliveryManRegistrationScreen()),
    GetPage(name: refund,customTransition: ZoomInTransition(), page: () => RefundRequestScreen(orderId: Get.parameters['id'])),
    GetPage(name: delivarTracking, customTransition: ZoomInTransition(), page: () {
      String? encodedUrl = Get.parameters['url'];
      if(encodedUrl != null && encodedUrl != 'null') {
        String url = utf8.decode(base64Decode(encodedUrl.replaceAll(' ', '+')));
        return DelivarWebViewScreen(url: url);
      } else {
        return const NotFound();
      }
    }),
    GetPage(name: offlinePaymentScreen,customTransition: ZoomInTransition(), page: () {
      List<int> decode = base64Decode(Get.parameters['order_body']!.replaceAll(' ', '+'));
      PlaceOrderBodyModel orderBody = PlaceOrderBodyModel.fromJson(jsonDecode(utf8.decode(decode)));

      return OfflinePaymentScreen(
        placeOrderBody: orderBody, zoneId: int.parse(Get.parameters['zone_id']!),
        total: double.parse(Get.parameters['total']!),
        maxCodOrderAmount: (Get.parameters['max_cod_amount'] != null && Get.parameters['max_cod_amount'] != 'null') ? double.parse(Get.parameters['max_cod_amount']!) : null,
        fromCart: Get.parameters['from_cart'] == 'true', isCashOnDeliveryActive: Get.parameters['cod_active'] == 'true', forParcel : Get.parameters['for_parcel'] == 'true',
      );
    },
    ),
    GetPage(name: flashSaleDetailsScreen,customTransition: ZoomInTransition(), page: () => FlashSaleDetailsScreen(id: int.parse(Get.parameters['id']!))),
    GetPage(name: guestTrackOrderScreen,customTransition: ZoomInTransition(), page: () => GuestTrackOrderScreen(
      orderId: Get.parameters['order_id']!, number: Get.parameters['number']!,
    )),
    GetPage(name: favourite,customTransition: ZoomInTransition(), page: () => const FavouriteScreen()),
    GetPage(name: brands,customTransition: ZoomInTransition(), page: () => const BrandsScreen()),
    GetPage(name: brandsItemScreen,customTransition: ZoomInTransition(), page: () => BrandsItemScreen(
      brandId: int.parse(Get.parameters['brandId']!), brandName: Get.parameters['brandName']!,
    )),

    GetPage(name: subscriptionSuccess,customTransition: ZoomInTransition(), page: () => SubscriptionSuccessOrFailedScreen(success: Get.parameters['flag'] == 'success', fromSubscription: Get.parameters['from_subscription'] == 'true', storeId: (Get.parameters['store_id'] != null && Get.parameters['store_id'] != 'null') ? int.parse(Get.parameters['store_id']!) : null)),
    GetPage(name: subscriptionPayment,customTransition: ZoomInTransition(), page: () => SubscriptionPaymentScreen(storeId: int.parse(Get.parameters['store-id']!), packageId: int.parse(Get.parameters['package-id']!))),
    GetPage(name: newUserSetupScreen,customTransition: ZoomInTransition(), page: () => NewUserSetupScreen(
      name: Get.parameters['name']!, loginType: Get.parameters['login_type']!,
      phone: Get.parameters['phone'] != '' && Get.parameters['phone'] != 'null' ? Get.parameters['phone']!.replaceAll(' ', '+') : null,
      email: Get.parameters['email'] != '' && Get.parameters['email'] != 'null' ? Get.parameters['email']!.replaceAll(' ', '+') : null,
    )),
    GetPage(name: itemViewAllScreen,customTransition: ZoomInTransition(), page: () => getRoute(ItemViewAllScreen(isPopular: Get.parameters['page'] == 'popular', isSpecial: Get.parameters['special'] == 'true'))),
    GetPage(name: deliveryQuotationList, customTransition: ZoomInTransition(), page: () => getRoute(const DeliveryQuotationListScreen())),
    GetPage(name: quotationImage, customTransition: ZoomInTransition(), page: () {
      String? data = Get.parameters['data'];
      if(data != null && data != 'null') {
        List<int> decode = base64Decode(data.replaceAll(' ', '+'));
        List<String> images = List<String>.from(jsonDecode(utf8.decode(decode)));
        return QuotationImageScreen(images: images);
      } else {
        return const NotFound();
      }
    }),
    GetPage(name: prescriptionUpload, page: () => const PrescriptionUploadScreen()),
  ];

  static Widget getRoute(Widget navigateTo, {AccessLocationScreen? locationScreen, bool byPuss = false}) {
    double? minimumVersion = 0;
    if(GetPlatform.isAndroid) {
      minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    }else if(GetPlatform.isIOS) {
      minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return (AppConstants.appVersion < minimumVersion! && !GetPlatform.isWeb)  ? const UpdateScreen(isUpdate: true)
        : Get.find<SplashController>().configModel!.maintenanceMode! ? const UpdateScreen(isUpdate: false)
        : (AddressHelper.getUserAddressFromSharedPref() == null && !byPuss)
        ? AccessLocationScreen(fromSignUp: false, fromHome: false, route: Get.currentRoute) : navigateTo;
  }


}

class ZoomInTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {

    // Entry: zoom-in from 0.90 to 1.00
    final zoomIn = Tween<double>(begin: 0.90, end: 1.00).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutExpo,
      ),
    );

    // Exit: zoom-out from 1.00 to 0.95 + fade-out
    final zoomOut = Tween<double>(begin: 1.00, end: 0.95).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInCubic,
      ),
    );

    final fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, _) {
        return Transform.scale(
          scale: animation.value < 1.0 ? zoomIn.value : zoomOut.value,
          child: Opacity(
            opacity: fadeOut.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

