import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/profile/domain/models/userinfo_model.dart';
import '../../helper/address_helper.dart';
import '../../helper/auth_helper.dart';
import '../../helper/route_helper.dart';
import '../../util/app_constants.dart';
import '../auth/controllers/auth_controller.dart';
import '../cart/controllers/cart_controller.dart';
import '../checkout/widgets/payment_failed_dialog.dart';
import '../coupon/controllers/coupon_controller.dart';
import '../home/controllers/home_controller.dart';
import '../home/screens/home_screen.dart';
import '../location/domain/models/zone_response_model.dart';
import '../order/controllers/order_controller.dart';
import '../order/domain/models/order_model.dart';
import '../splash/controllers/splash_controller.dart';
import 'package:http/http.dart' as http;
import '../wallet/widgets/fund_payment_dialog_widget.dart';


// class PaymentScreenmobile extends StatefulWidget {
//   final OrderModel orderModel;
//   final bool isCashOnDelivery;
//   final String? addFundUrl;
//   final String paymentMethod;
//   final String guestId;
//   final String contactNumber;
//   final String? subscriptionUrl;
//   final int? storeId;
//   final bool createAccount;
//   final int? createUserId;
//
//   const PaymentScreenmobile({
//     Key? key,
//     required this.orderModel,
//     required this.isCashOnDelivery,
//     this.addFundUrl,
//     required this.paymentMethod,
//     required this.guestId,
//     required this.contactNumber,
//     this.storeId,
//     this.subscriptionUrl,
//     this.createAccount = false,
//     this.createUserId,
//   }) : super(key: key);
//
//   @override
//   PaymentScreenmobileState createState() => PaymentScreenmobileState();
// }
//
// class PaymentScreenmobileState extends State<PaymentScreenmobile> {
//   double? _maximumCodOrderAmount;
//   late String selectstatus;
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // decide selectstatus safely
//     final bool hasAddFund = widget.addFundUrl?.isNotEmpty == true;
//     final bool hasSubscription = widget.subscriptionUrl?.isNotEmpty == true;
//
//     if (!hasAddFund && !hasSubscription) {
//       selectstatus = 'order';
//     } else if (hasSubscription) {
//       selectstatus = 'subscription';
//     } else {
//       selectstatus = 'add_fund';
//     }
//
//     if (kDebugMode) {
//       debugPrint('==========url=======> $selectstatus');
//     }
//
//     _razorpay = Razorpay();
//     // init data (safe)
//     _initData();
//     getOrderDataFromPrefs();
//   }
//
//   /// Helper getters to safely obtain Razorpay keys
//   String? get _razorpayKey =>
//       Get.find<SplashController>().configModel?.nativerazor?.apiKey.trim();
//
//   String? get _razorpaySecret =>
//       Get.find<SplashController>().configModel?.nativerazor?.apiSecret.trim();
//
//   ///Shared Preferences
//   void storeOrderDataInPrefs(String? orderid) async {
//     if (kDebugMode) {
//       debugPrint('storeOrderDataInPrefs -> userId: ${widget.orderModel.userId}');
//     }
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('user_id_razor_pay', widget.orderModel.userId ?? -1);
//       await prefs.setString('order_id_razor_pay', orderid ?? "");
//       await prefs.setString('addFundUrl_razor', widget.addFundUrl ?? "");
//       await prefs.setString(
//           'subscriptionUrl_razor', widget.subscriptionUrl ?? "");
//       await prefs.setInt('orderID_razor', widget.orderModel.id ?? -1);
//       await prefs.setInt('storeID_razor', widget.storeId ?? -1);
//       await prefs.setDouble(
//           'orderAmount_razor', widget.orderModel.orderAmount ?? 0.0);
//       await prefs.setDouble(
//           'maxCodOrderAmount_razor', _maximumCodOrderAmount ?? 0.0);
//       await prefs.setString(
//           'contactPersonNumber_razor', widget.contactNumber ?? "");
//       await prefs.setBool("isCash_order", widget.isCashOnDelivery);
//     } catch (e, s) {
//       if (kDebugMode) {
//         debugPrint('Error storing prefs: $e\n$s');
//       }
//     }
//   }
//
//   Future<void> removeOrderDataFromPrefs() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//
//       await prefs.remove('order_id_razor_pay');
//       await prefs.remove('addFundUrl_razor');
//       await prefs.remove('subscriptionUrl_razor');
//       await prefs.remove('orderID_razor');
//       await prefs.remove('storeID_razor');
//       await prefs.remove('orderAmount_razor');
//       await prefs.remove('maxCodOrderAmount_razor');
//       await prefs.remove('contactPersonNumber_razor');
//       await prefs.remove('user_id_razor_pay');
//       await prefs.remove("isCash_order");
//
//       if (kDebugMode) debugPrint("Data removed from SharedPreferences.");
//     } catch (e) {
//       if (kDebugMode) debugPrint("Error removing prefs: $e");
//     }
//   }
//
//   Future<void> getOrderDataFromPrefs() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String orderId = prefs.getString('order_id_razor_pay') ?? "";
//       String addFundUrl = prefs.getString('addFundUrl_razor') ?? "";
//       String subscriptionUrl = prefs.getString('subscriptionUrl_razor') ?? "";
//       int orderID = prefs.getInt('orderID_razor') ?? -1;
//       int storeID = prefs.getInt('storeID_razor') ?? -1;
//       double orderAmount = prefs.getDouble('orderAmount_razor') ?? 0.0;
//       double maxCodOrderAmount =
//           prefs.getDouble('maxCodOrderAmount_razor') ?? 0.0;
//       String contactPersonNumber =
//           prefs.getString('contactPersonNumber_razor') ?? "";
//       bool isCashorder = prefs.getBool("isCash_order") ?? false;
//
//       if (orderId.isEmpty) {
//         await createOrder();
//       } else {
//         await fetchPaymentDetails(orderId);
//       }
//
//       if (kDebugMode) {
//         debugPrint('Order ID: $orderId');
//         debugPrint('Add Fund URL: $addFundUrl');
//         debugPrint('Subscription URL: $subscriptionUrl');
//         debugPrint('Order ID (int): $orderID');
//         debugPrint('Store ID: $storeID');
//         debugPrint('Order Amount: $orderAmount');
//         debugPrint('Max COD Order Amount: $maxCodOrderAmount');
//         debugPrint('Contact Person Number: $contactPersonNumber');
//         debugPrint('Is Cash Order: $isCashorder');
//       }
//     } catch (e) {
//       if (kDebugMode) debugPrint('Error reading prefs: $e');
//     }
//   }
//
//   void _initData() {
//     // Only check zone data when this is a normal order (not add fund/subscription)
//     final bool hasAddFund = widget.addFundUrl?.isNotEmpty == true;
//     final bool hasSubscription = widget.subscriptionUrl?.isNotEmpty == true;
//
//     if (!hasAddFund && !hasSubscription) {
//       final userAddress = AddressHelper.getUserAddressFromSharedPref();
//       if (userAddress != null) {
//         for (ZoneData zData in userAddress.zoneData ?? <ZoneData>[]) {
//           for (Modules m in zData.modules ?? <Modules>[]) {
//             // safe compare
//             if (m.id == Get.find<SplashController>().module?.id) {
//               // pivot might be null — use safe access and break
//               _maximumCodOrderAmount =
//                   m.pivot?.maximumCodOrderAmount ?? _maximumCodOrderAmount;
//               break;
//             }
//           }
//         }
//       }
//     }
//   }
//   String? razorpayKey = Get.find<SplashController>().configModel?.nativerazor?.apiKey?.trim() ?? '';
//   String? razorpaySecret = Get.find<SplashController>().configModel?.nativerazor?.apiSecret?.trim() ?? '';
//
//   // String? razorpayKey =
//   // Get.find<SplashController>().configModel!.nativerazor!.apiKey.trim();
//   // String? razorpaySecret =
//   // Get.find<SplashController>().configModel!.nativerazor!.apiSecret.trim();
//
//   Future<void> createOrder() async {
//     final Uri uri = Uri.parse('https://api.razorpay.com/v1/orders');
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization':
//       'Basic ' + base64Encode(utf8.encode('$razorpayKey:$razorpaySecret')),
//     };
//
//     final body = jsonEncode({
//       'amount': (widget.orderModel.orderAmount! * 100).toInt(),
//       'currency': 'INR',
//       'receipt': 'Receipt no.${widget.orderModel.id}',
//       'notes': {
//         'notes_key_1': 'Sutram',
//         'notes_key_2': 'Sutram app',
//       }
//     });
//
//     try {
//       final response = await http.post(uri, headers: headers, body: body);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         String orderId = data['id'];
//         debugPrint("nfjknjne");
//         debugPrint(orderId);
//         storeOrderDataInPrefs(orderId);
//         _openPaymentGateway(orderId);
//       } else {
//         _exitApp();
//       }
//     } catch (e) {
//       _exitApp();
//     }
//   }
//
//   Future<void> fetchPaymentDetails(String orderId) async {
//     final String? key = _razorpayKey;
//     final String? secret = _razorpaySecret;
//
//     if (key == null || key.isEmpty || secret == null || secret.isEmpty) {
//       if (kDebugMode) debugPrint('Razorpay key/secret missing. Aborting fetchPaymentDetails.');
//       await _exitApp();
//       return;
//     }
//
//     final String url = 'https://api.razorpay.com/v1/orders/$orderId/payments';
//     final headers = {
//       'Authorization':
//       'Basic ${base64Encode(utf8.encode('$key:$secret'))}',
//       'Content-Type': 'application/json',
//     };
//
//     try {
//       final response = await http.get(Uri.parse(url), headers: headers);
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final List<dynamic> items = data['items'] ?? [];
//         if (items.isNotEmpty) {
//           for (var item in items) {
//             final String paymentId = (item['id'] ?? "").toString();
//             final String status = (item['status'] ?? "").toString();
//             final bool captured = (item['captured'] ?? false) as bool;
//             if (kDebugMode) {
//               debugPrint("fetchPaymentDetails -> id:$paymentId status:$status captured:$captured");
//             }
//             if (paymentId.isNotEmpty && status == "captured" && captured) {
//               // Payment captured — handle according to selectstatus
//               final String customerId = widget.orderModel.userId?.toString() ??
//                   (Get.find<ProfileController>().userInfoModel?.id?.toString() ?? widget.guestId);
//
//               if (selectstatus == "order") {
//                 await RazorApiService().handlePaymentResponse(
//                   orderId: widget.orderModel.id?.toString() ?? "",
//                   customerId: customerId,
//                   paymentMethod: "razor_pay",
//                   orderStatus: "confirmed",
//                   paymentStatus: "paid",
//                   transactionId: paymentId,
//                 );
//
//                 final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//                     (widget.subscriptionUrl?.isEmpty ?? true);
//
//                 await removeOrderDataFromPrefs();
//                 if (isNormalOrder) {
//                   _orderPaymentDoneDecision(true, false, false);
//                 } else {
//                   _decideSubscriptionOrWallet(true, false, false, widget.storeId);
//                 }
//               } else {
//                 final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//                     (widget.subscriptionUrl?.isEmpty ?? true);
//                 await removeOrderDataFromPrefs();
//                 if (isNormalOrder) {
//                   return Get.dialog(PaymentFailedDialog(
//                     isCashOnDelivery: widget.isCashOnDelivery,
//                     orderType: widget.paymentMethod,
//                     orderID: widget.orderModel.id?.toString() ?? "",
//                     orderAmount: widget.orderModel.orderAmount,
//                     maxCodOrderAmount: _maximumCodOrderAmount,
//                     guestId: widget.contactNumber,
//                   ));
//                 } else {
//                   return Get.dialog(FundPaymentDialogWidget(
//                       isSubscription: widget.subscriptionUrl?.isNotEmpty == true));
//                 }
//               }
//               // After handling, break out
//               break;
//             } else {
//               final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//                   (widget.subscriptionUrl?.isEmpty ?? true);
//               await removeOrderDataFromPrefs();
//               if (isNormalOrder) {
//                 return Get.dialog(PaymentFailedDialog(
//                   isCashOnDelivery: widget.isCashOnDelivery,
//                   orderType: widget.paymentMethod,
//                   orderID: widget.orderModel.id?.toString() ?? "",
//                   orderAmount: widget.orderModel.orderAmount,
//                   maxCodOrderAmount: _maximumCodOrderAmount,
//                   guestId: widget.contactNumber,
//                 ));
//               } else {
//                 return Get.dialog(FundPaymentDialogWidget(
//                     isSubscription: widget.subscriptionUrl?.isNotEmpty == true));
//               }
//             }
//           }
//         } else {
//           final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//               (widget.subscriptionUrl?.isEmpty ?? true);
//           if (isNormalOrder) {
//             return Get.dialog(PaymentFailedDialog(
//               isCashOnDelivery: widget.isCashOnDelivery,
//               orderType: widget.paymentMethod,
//               orderID: widget.orderModel.id?.toString() ?? "",
//               orderAmount: widget.orderModel.orderAmount,
//               maxCodOrderAmount: _maximumCodOrderAmount,
//               guestId: widget.contactNumber,
//             ));
//           } else {
//             return Get.dialog(FundPaymentDialogWidget(
//                 isSubscription: widget.subscriptionUrl?.isNotEmpty == true));
//           }
//         }
//       } else {
//         if (kDebugMode) debugPrint('fetchPaymentDetails failed: ${response.statusCode}');
//         await _exitApp();
//       }
//     } catch (e) {
//       if (kDebugMode) debugPrint('Error fetching payment details: $e');
//       await _exitApp();
//     }
//   }
//
//   void _openPaymentGateway(String orderid) {
//     // ensure we have api key
//     final String? key = _razorpayKey;
//     if (key == null || key.isEmpty) {
//       if (kDebugMode) debugPrint('Razorpay key missing. Cannot open gateway.');
//       _exitApp();
//       return;
//     }
//
//     final int amountPaise = ((widget.orderModel.orderAmount ?? 0.0) * 100).toInt();
//
//     var options = {
//       'key': key,
//       'amount': amountPaise,
//       'name': Get.find<SplashController>().configModel?.businessName ?? '',
//       'description': 'Order #${widget.orderModel.id ?? ''}',
//       'retry': {'enabled': true, 'max_count': 1},
//       'send_sms_hash': true,
//       'timeout': 300,
//       'order_id': orderid,
//       'prefill': {
//         'contact': widget.contactNumber,
//       },
//       'method': {
//         'upi': true,
//       },
//       'redirect': true,
//     };
//
//     // attach handlers
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentErrorResponse);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccessResponse);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWalletSelected);
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       if (kDebugMode) debugPrint('Error opening Razorpay: $e');
//       _exitApp();
//     }
//   }
//
//   @override
//   void dispose() {
//     try {
//       _razorpay.clear();
//     } catch (e) {
//       if (kDebugMode) debugPrint('Error clearing razorpay: $e');
//     }
//     super.dispose();
//   }
//
//   Future<void> _handlePaymentErrorResponse(PaymentFailureResponse response) {
//     final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//         (widget.subscriptionUrl?.isEmpty ?? true);
//
//     if (isNormalOrder) {
//       return Get.dialog(PaymentFailedDialog(
//         orderID: widget.orderModel.id?.toString() ?? "",
//         orderAmount: widget.orderModel.orderAmount,
//         maxCodOrderAmount: _maximumCodOrderAmount,
//         orderType: widget.orderModel.orderType,
//         isCashOnDelivery: widget.isCashOnDelivery,
//         guestId: widget.createAccount
//             ? (widget.createUserId?.toString() ?? widget.guestId)
//             : widget.guestId,
//       ));
//     } else {
//       return Get.dialog(FundPaymentDialogWidget(
//           isSubscription: widget.subscriptionUrl?.isNotEmpty == true));
//     }
//   }
//
//   Future<void> _handlePaymentSuccessResponse(
//       PaymentSuccessResponse response) async {
//     if (kDebugMode) {
//       debugPrint("Payment success: ${response.paymentId}");
//     }
//
//     if (selectstatus == "order") {
//       final String customerId = Get.find<ProfileController>().userInfoModel?.id?.toString() ?? widget.guestId;
//       await RazorApiService().handlePaymentResponse(
//         orderId: widget.orderModel.id?.toString() ?? "",
//         customerId: customerId,
//         paymentMethod: "razor_pay",
//         orderStatus: "confirmed",
//         paymentStatus: "paid",
//         transactionId: response.paymentId,
//       );
//
//       final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//           (widget.subscriptionUrl?.isEmpty ?? true);
//
//       if (isNormalOrder) {
//         Get.find<CartController>().clearCartList();
//       }
//       Get.find<CheckoutController>().setGuestAddress(null);
//       if (!Get.find<OrderController>().showBottomSheet) {
//         Get.find<OrderController>().showRunningOrders(canUpdate: false);
//       }
//       if (Get.find<CheckoutController>().isDmTipSave) {
//         Get.find<CheckoutController>().saveSharedPrefDmTipIndex(
//             Get.find<CheckoutController>().selectedTips.toString());
//       }
//       Get.find<CheckoutController>().stopLoader(canUpdate: false);
//       HomeScreen.loadData(true);
//
//       double total = ((widget.orderModel.orderAmount ?? 0.0) / 100) *
//           (Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0.0);
//       if (AuthHelper.isLoggedIn()) {
//         Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
//       }
//       Get.find<CheckoutController>().clearPrevData();
//       Get.find<CouponController>().removeCouponData(false);
//       Get.find<CheckoutController>().updateTips(
//         Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty
//             ? int.parse(Get.find<CheckoutController>().getSharedPrefDmTipIndex())
//             : 0,
//         notify: false,
//       );
//       Get.offNamed(RouteHelper.getOrderSuccessRoute(
//         widget.orderModel.id?.toString() ?? "",
//         widget.contactNumber,
//         createAccount: Get.find<CheckoutController>().isCreateAccount,
//       ));
//     } else if (selectstatus == 'add_fund') {
//       String tokenString =
//           'payment_method=${widget.paymentMethod}&&attribute_id=${widget.orderModel.id}&&transaction_reference=${response.paymentId}';
//       String encodedToken = base64Encode(utf8.encode(tokenString));
//       String redirectUrl =
//           "${AppConstants.baseUrl}/payment-success?token=$encodedToken";
//
//       Get.find<OrderController>().paymentRedirect(
//         url: redirectUrl.toString(),
//         canRedirect: true,
//         onClose: () {},
//         addFundUrl: widget.addFundUrl,
//         orderID: widget.orderModel.id!.toString(),
//         contactNumber: widget.contactNumber,
//         storeId: widget.storeId,
//         subscriptionUrl: widget.subscriptionUrl,
//         createAccount: widget.createAccount,
//         guestId: widget.guestId,
//       );
//     } else if (selectstatus == 'subscription') {
//       Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(true);
//       Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
//       Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
//           status: 'success',
//           fromSubscription: true,
//           storeId: widget.orderModel.store?.id));
//     }
//   }
//
//   void _handleExternalWalletSelected(ExternalWalletResponse response) {
//     if (kDebugMode) {
//       debugPrint('External wallet selected: ${response.walletName}');
//     }
//
//     if (selectstatus == "order") {
//       final String customerId = Get.find<ProfileController>().userInfoModel?.id?.toString() ?? widget.guestId;
//       RazorApiService().handlePaymentResponse(
//         orderId: widget.orderModel.id?.toString() ?? "",
//         customerId: customerId,
//         paymentMethod: "razor_pay",
//         orderStatus: "confirmed",
//         paymentStatus: "paid",
//         transactionId: response.walletName ?? '',
//       );
//
//       final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//           (widget.subscriptionUrl?.isEmpty ?? true);
//
//       if (isNormalOrder) {
//         Get.find<CartController>().clearCartList();
//       }
//       Get.find<CheckoutController>().setGuestAddress(null);
//       if (!Get.find<OrderController>().showBottomSheet) {
//         Get.find<OrderController>().showRunningOrders(canUpdate: false);
//       }
//       if (Get.find<CheckoutController>().isDmTipSave) {
//         Get.find<CheckoutController>().saveSharedPrefDmTipIndex(
//             Get.find<CheckoutController>().selectedTips.toString());
//       }
//       Get.find<CheckoutController>().stopLoader(canUpdate: false);
//       HomeScreen.loadData(true);
//
//       double total = ((widget.orderModel.orderAmount ?? 0.0) / 100) *
//           (Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0.0);
//       if (AuthHelper.isLoggedIn()) {
//         Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
//       }
//
//       String tokenString =
//           'payment_method=${widget.paymentMethod}&&attribute_id=${widget.orderModel.id}&&transaction_reference=ghswjijdwguiggdwhggdhdg';
//       String encodedToken = base64Encode(utf8.encode(tokenString));
//       String redirectUrl =
//           "${AppConstants.baseUrl}/payment-success?token=$encodedToken";
//
//       Get.find<OrderController>().paymentRedirect(
//         url: redirectUrl.toString(),
//         canRedirect: true,
//         onClose: () {},
//         addFundUrl: widget.addFundUrl,
//         orderID: widget.orderModel.id!.toString(),
//         contactNumber: widget.contactNumber,
//         storeId: widget.storeId,
//         subscriptionUrl: widget.subscriptionUrl,
//         createAccount: widget.createAccount,
//         guestId: widget.guestId,
//       );
//
//       Get.find<CheckoutController>().clearPrevData();
//       Get.find<CouponController>().removeCouponData(false);
//       Get.find<CheckoutController>().updateTips(
//         Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty
//             ? int.parse(Get.find<CheckoutController>().getSharedPrefDmTipIndex())
//             : 0,
//         notify: false,
//       );
//     } else if (selectstatus == 'add_fund') {
//       String tokenString =
//           'payment_method=${widget.paymentMethod}&&attribute_id=${widget.orderModel.id}&&transaction_reference=ghswjijdwguiggdwhggdhdg';
//       String encodedToken = base64Encode(utf8.encode(tokenString));
//       String redirectUrl =
//           "${AppConstants.baseUrl}/payment-success?token=$encodedToken";
//       Get.find<OrderController>().paymentRedirect(
//         url: redirectUrl.toString(),
//         canRedirect: true,
//         onClose: () {},
//         addFundUrl: widget.addFundUrl,
//         orderID: widget.orderModel.id!.toString(),
//         contactNumber: widget.contactNumber,
//         storeId: widget.storeId,
//         subscriptionUrl: widget.subscriptionUrl,
//         createAccount: widget.createAccount,
//         guestId: widget.guestId,
//       );
//       Get.back();
//     } else if (selectstatus == 'subscription') {
//       Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(true);
//       Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
//       Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
//           status: 'success',
//           fromSubscription: true,
//           storeId: widget.orderModel.store?.id));
//     }
//   }
//
//   void _orderPaymentDoneDecision(bool isSuccess, bool isFailed, bool isCancel) {
//     if (isSuccess) {
//       double total = ((widget.orderModel.orderAmount ?? 0.0) / 100) *
//           (Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 0.0);
//       Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
//       Get.offNamed(RouteHelper.getOrderSuccessRoute(
//         widget.orderModel.id?.toString() ?? "",
//         widget.contactNumber,
//         createAccount: Get.find<CheckoutController>().isCreateAccount,
//       ));
//     } else if (isFailed || isCancel) {
//       Get.offNamed(RouteHelper.getOrderSuccessRoute(
//         widget.orderModel.id?.toString() ?? "",
//         widget.contactNumber,
//         createAccount: Get.find<CheckoutController>().isCreateAccount,
//       ));
//     }
//   }
//
//   void _decideSubscriptionOrWallet(
//       bool isSuccess, bool isFailed, bool isCancel, int? restaurantId) {
//     if (isSuccess || isFailed || isCancel) {
//       if (Get.currentRoute.contains(RouteHelper.payment)) {
//         Get.back();
//       }
//       final bool hasSubscription = widget.subscriptionUrl?.isNotEmpty == true;
//       final bool hasAddFund = widget.addFundUrl?.isNotEmpty == true;
//
//       if (hasSubscription && !hasAddFund) {
//         Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
//         Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
//         Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
//             status: isSuccess
//                 ? 'success'
//                 : isFailed
//                 ? 'fail'
//                 : 'cancel',
//             fromSubscription: true,
//             storeId: restaurantId));
//       } else {
//         Get.back();
//         Get.offAllNamed(RouteHelper.getWalletRoute(
//           fundStatus: isSuccess
//               ? 'success'
//               : isFailed
//               ? 'fail'
//               : 'cancel',
//         ));
//       }
//     }
//   }
//
//   Future<void> _exitApp() {
//     final bool isNormalOrder = (widget.addFundUrl?.isEmpty ?? true) &&
//         (widget.subscriptionUrl?.isEmpty ?? true);
//
//     if (isNormalOrder) {
//       return Get.dialog(PaymentFailedDialog(
//         orderID: widget.orderModel.id?.toString() ?? "",
//         orderAmount: widget.orderModel.orderAmount,
//         maxCodOrderAmount: _maximumCodOrderAmount,
//         orderType: widget.orderModel.orderType,
//         isCashOnDelivery: widget.isCashOnDelivery,
//         guestId: widget.createAccount
//             ? (widget.createUserId?.toString() ?? widget.guestId)
//             : widget.guestId,
//       ));
//     } else {
//       return Get.dialog(FundPaymentDialogWidget(
//           isSubscription: widget.subscriptionUrl?.isNotEmpty == true));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         _exitApp();
//         return Future.value(false); // Prevent default back navigation
//       },
//       child: const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
// }
class PaymentScreenmobile extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool createAccount;
  final int? createUserId;

  const PaymentScreenmobile({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.storeId,
    this.subscriptionUrl,
    this.createAccount = false,
    this.createUserId,
  });

  @override
  PaymentScreenmobileState createState() => PaymentScreenmobileState();
}

class PaymentScreenmobileState extends State<PaymentScreenmobile> {
  double? _maximumCodOrderAmount;
  late String selectstatus;
  final Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    removeOrderDataFromPrefs();
    _debugPrintSavedRazorpayPrefs();
    debugPrint("Navigating to PaymentScreenmobile...");
    debugPrint("Navigating to PaymentScreenmobile...");
    debugPrint("Navigating to ${widget.addFundUrl}");

    _initData();


    getOrderDataFromPrefs();
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      selectstatus = 'order';
    } else if (widget.subscriptionUrl != null &&
        widget.subscriptionUrl!.isNotEmpty) {
      selectstatus = 'subscription';
    } else {
      selectstatus = 'add_fund';
    }
    if (kDebugMode) {
      debugPrint('==========url=======> $selectstatus');
    }

  }
  Future<void> _debugPrintSavedRazorpayPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    debugPrint('🧾 ----- Razorpay Stored Values -----');
    debugPrint('user_id_razor_pay: ${widget.orderModel.userId}');
    debugPrint('order_id_razor_pay: ${widget.addFundUrl}');
    debugPrint('addFundUrl_razor: ${widget.subscriptionUrl}');
    debugPrint('subscriptionUrl_razor: ${widget.subscriptionUrl}');
    debugPrint('orderID_razor: ${widget.orderModel.id}');
    debugPrint('storeID_razor: ${widget.storeId}');
    debugPrint('orderAmount_razor: ${widget.orderModel.orderAmount}');
    debugPrint('maxCodOrderAmount_razor: $_maximumCodOrderAmount');
    debugPrint('contactPersonNumber_razor: ${prefs.getString('contactPersonNumber_razor')}');
    // debugPrint('isCash_order: ${orderid}');
    debugPrint('------------------------------------');
  }
  ///Shared Preferences
  void storeOrderDataInPrefs(String? orderid) async {
    debugPrint(widget.orderModel.userId.toString());
    debugPrint("shbghgbsuhgu");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id_razor_pay', widget.orderModel.userId ?? -1);
    await prefs.setString('order_id_razor_pay', orderid ?? "");
    await prefs.setString('addFundUrl_razor', widget.addFundUrl ?? "");
    await prefs.setString(
        'subscriptionUrl_razor', widget.subscriptionUrl ?? "");
    await prefs.setInt('orderID_razor', widget.orderModel.id ?? -1);
    await prefs.setInt('storeID_razor', widget.storeId ?? -1);
    await prefs.setDouble(
        'orderAmount_razor', widget.orderModel.orderAmount ?? 0.0);
    await prefs.setDouble(
        'maxCodOrderAmount_razor', _maximumCodOrderAmount ?? 0.0);
    await prefs.setString(
        'contactPersonNumber_razor', widget.contactNumber ?? "");
    await prefs.setBool("isCash_order", widget.isCashOnDelivery ?? false);
  }

  Future<void> removeOrderDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('order_id_razor_pay');
    await prefs.remove('addFundUrl_razor');
    await prefs.remove('subscriptionUrl_razor');
    await prefs.remove('orderID_razor');
    await prefs.remove('storeID_razor');
    await prefs.remove('orderAmount_razor');
    await prefs.remove('maxCodOrderAmount_razor');
    await prefs.remove('contactPersonNumber_razor');
    await prefs.remove('user_id_razor_pay');
    await prefs.remove("isCash_order");

    debugPrint("Data removed from SharedPreferences.");
  }

  Future<void> getOrderDataFromPrefs() async {
    debugPrint("get order is initiated...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String orderId = prefs.getString('order_id_razor_pay') ?? "";
    String addFundUrl = prefs.getString('addFundUrl_razor') ?? "";
    String subscriptionUrl = prefs.getString('subscriptionUrl_razor') ?? "";
    int orderID = prefs.getInt('orderID_razor') ?? -1;
    int storeID = prefs.getInt('storeID_razor') ?? -1;
    double orderAmount = prefs.getDouble('orderAmount_razor') ?? 0.0;
    double maxCodOrderAmount =
        prefs.getDouble('maxCodOrderAmount_razor') ?? 0.0;
    String contactPersonNumber =
        prefs.getString('contactPersonNumber_razor') ?? "";
    bool isCashorder = prefs.getBool("isCash_order") ?? false;
    if (orderId.isEmpty || orderId == "") {
      debugPrint("get order is create...");
      createOrder();
    } else {
      debugPrint("get order is payment detail...");
      fetchPaymentDetails(orderId);
    }
    debugPrint('Order ID: $orderId');
    debugPrint('Add Fund URL: $addFundUrl');
    debugPrint('Subscription URL: $subscriptionUrl');
    debugPrint('Order ID: $orderID');
    debugPrint('Store ID: $storeID');
    debugPrint('Order Amount: $orderAmount');
    debugPrint('Max COD Order Amount: $maxCodOrderAmount');
    debugPrint('Contact Person Number: $contactPersonNumber');
  }

  void _initData() async {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      final userAddress = AddressHelper.getUserAddressFromSharedPref();
      if (userAddress != null) {
        for (ZoneData zData in userAddress.zoneData!) {
          for (Modules m in zData.modules!) {
            if (m.id == Get.find<SplashController>().module!.id) {
              _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
              break;
            }
          }
        }
      }
    }
  }

  String? razorpayKey = Get.find<SplashController>().configModel?.nativerazor?.apiKey.trim() ?? '';
  String? razorpaySecret = Get.find<SplashController>().configModel?.nativerazor?.apiSecret.trim() ?? '';

  Future<void> createOrder() async {
    debugPrint("edsgdsfzgv $razorpayKey");
    debugPrint("edsgdsfzgv $razorpaySecret");
    debugPrint("edsgdsfzgv ${widget.orderModel.orderAmount.runtimeType}");
    debugPrint("edsgdsfzgv ${widget.orderModel.orderAmount!}");

    final Uri uri = Uri.parse('https://api.razorpay.com/v1/orders');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
      'Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}',
    };

    final body = jsonEncode({
      'amount': (widget.orderModel.orderAmount! * 100).toInt(),
      'currency': 'INR',
      'receipt': 'Receipt no.${widget.orderModel.id??0}',
      'payment_capture': 1,
      'notes': {
        'notes_key_1': AppConstants.appName,
        'notes_key_2': '${AppConstants.appName} APP',
      }
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      debugPrint("edsgdsfzgv ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(response.body);
        String orderId = data['id'];
        debugPrint("nfjknjne");
        debugPrint(orderId);
        storeOrderDataInPrefs(orderId);
        _openPaymentGateway(orderId);
      } else {
        _exitApp();
        debugPrint("exit app 1");
        debugPrint("exit app 2${response.statusCode}");

      }
    } catch (e) {
      _exitApp();
    }
  }

  Future<void> fetchPaymentDetails(String orderId) async {
    final String url = 'https://api.razorpay.com/v1/orders/$orderId/payments';
    final headers = {
      'Authorization':
      'Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint("erter ${response.statusCode}");
      debugPrint("ertdfse260152r ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        if (items.isNotEmpty) {
          for (var item in items) {
            String paymentId = item['id'];
            String status = item['status'];
            bool captured = item['captured'];
            debugPrint("sbhbsjbs");
            debugPrint(paymentId);
            debugPrint(status);
            debugPrint(captured.toString());
            if (paymentId.isNotEmpty &&
                status == "captured" &&
                captured == true) {
              debugPrint("kjnksj");
              debugPrint(selectstatus);
              debugPrint(
                  Get.find<ProfileController>().userInfoModel?.id.toString() ??
                      "idjuhjdijdi");
              if (selectstatus == "order") {
                await RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
                  orderId: widget.orderModel.id.toString(),
                  customerId: widget.orderModel.userId.toString(),
                  paymentMethod: "razor_pay",
                  paymentStatus: "success",
                  transactionId: paymentId,
                );
                if ((widget.addFundUrl == '' &&
                    widget.addFundUrl!.isEmpty &&
                    widget.subscriptionUrl == '' &&
                    widget.subscriptionUrl!.isEmpty)) {
                  removeOrderDataFromPrefs();
                  _orderPaymentDoneDecision(true, false, false);
                } else {
                  removeOrderDataFromPrefs();
                  _decideSubscriptionOrWallet(
                      true, false, false, widget.storeId);
                }
              } else {
                if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
                    (widget.subscriptionUrl == '' &&
                        widget.subscriptionUrl!.isEmpty)) {
                  debugPrint("payment failed 1");

                  await RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
                    orderId: widget.orderModel.id.toString(),
                    customerId: widget.orderModel.userId.toString(),
                    paymentMethod: "razor_pay",
                    paymentStatus: "failed",
                    transactionId: "",
                  );  removeOrderDataFromPrefs();
                  return Get.dialog(PaymentFailedDialog(
                    isCashOnDelivery: widget.isCashOnDelivery,
                    orderType: widget.paymentMethod,
                    orderID: widget.orderModel.id.toString(),
                    orderAmount: widget.orderModel.orderAmount,
                    maxCodOrderAmount: _maximumCodOrderAmount,
                    guestId: widget.contactNumber,
                  ));
                } else {
                  removeOrderDataFromPrefs();
                  return Get.dialog(FundPaymentDialogWidget(
                      isSubscription: widget.subscriptionUrl != null &&
                          widget.subscriptionUrl!.isNotEmpty));
                }
              }
              // removeOrderDataFromPrefs();
            } else {
              if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
                  (widget.subscriptionUrl == '' &&
                      widget.subscriptionUrl!.isEmpty)) {
                debugPrint("payment failed 2");
                await RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
                  orderId: widget.orderModel.id.toString(),
                  customerId: widget.orderModel.userId.toString(),
                  paymentMethod: "razor_pay",
                  paymentStatus: "failed",
                  transactionId: "",
                );     removeOrderDataFromPrefs();
                return Get.dialog(PaymentFailedDialog(
                  isCashOnDelivery: widget.isCashOnDelivery,
                  orderType: widget.paymentMethod,
                  orderID: widget.orderModel.id.toString(),
                  orderAmount: widget.orderModel.orderAmount,
                  maxCodOrderAmount: _maximumCodOrderAmount,
                  guestId: widget.contactNumber,
                ));
              } else {
                removeOrderDataFromPrefs();
                return Get.dialog(FundPaymentDialogWidget(
                    isSubscription: widget.subscriptionUrl != null &&
                        widget.subscriptionUrl!.isNotEmpty));
              }
            }
          }
        }
        else {
          if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
              (widget.subscriptionUrl == '' &&
                  widget.subscriptionUrl!.isEmpty)) {
            debugPrint("payment failed 3");
            await RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
              orderId: widget.orderModel.id.toString(),
              customerId: widget.orderModel.userId.toString(),
              paymentMethod: "razor_pay",
              paymentStatus: "failed",
              transactionId: "",
            );
            removeOrderDataFromPrefs();
            return Get.dialog(PaymentFailedDialog(
              isCashOnDelivery: widget.isCashOnDelivery,
              orderType: widget.paymentMethod,
              orderID: widget.orderModel.id.toString(),
              orderAmount: widget.orderModel.orderAmount,
              maxCodOrderAmount: _maximumCodOrderAmount,
              guestId: widget.contactNumber,
            ));
          } else {
            return Get.dialog(FundPaymentDialogWidget(
                isSubscription: widget.subscriptionUrl != null &&
                    widget.subscriptionUrl!.isNotEmpty));
          }
        }
      } else {
        _exitApp();
        debugPrint("exit app 3");
      }
    } catch (e) {
      debugPrint("exit app 4");
      _exitApp();
      debugPrint('Error fetching payment details: $e');
    }
  }

  void _openPaymentGateway(String orderid) {
    var options = {
      'key':
      Get.find<SplashController>().configModel!.nativerazor!.apiKey.trim(),
      'amount': (widget.orderModel.orderAmount! * 100).toInt(),
      'name': Get.find<SplashController>().configModel!.businessName,
      'description': 'Order #${widget.orderModel.id}',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'timeout': 300,
      'order_id': orderid,
      'prefill': {
        'contact': widget.contactNumber,
      },
      'method': {
        'upi': true,
      },
      'redirect': true,
    };
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWalletSelected);
    _razorpay.open(options);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentErrorResponse(PaymentFailureResponse response) {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == '' && widget.subscriptionUrl!.isEmpty)) {
      debugPrint("payment failed 4");
       RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
        orderId: widget.orderModel.id.toString(),
        customerId: widget.orderModel.userId.toString(),
        paymentMethod: "razor_pay",
        paymentStatus: "failed",
        transactionId: "",
      );
      removeOrderDataFromPrefs();
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
        guestId: widget.createAccount
            ? widget.createUserId.toString()
            : widget.guestId,
      ));
    } else {
      return Get.dialog(FundPaymentDialogWidget(
          isSubscription: widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty));
    }
  }

  Future<void> _handlePaymentSuccessResponse(
      PaymentSuccessResponse response) async {
    debugPrint(
        "////////////////////////////////////////////////////////////////////////////");

    if (selectstatus == "order") {
      debugPrint("jjkshsjkhjshjh");
      RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
        orderId: widget.orderModel.id.toString(),
        customerId:
        Get.find<ProfileController>().userInfoModel?.id.toString() ?? "23",
        paymentMethod: "razor_pay",
        paymentStatus: "success",
        transactionId: response.paymentId,
      );
      if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
          (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<CheckoutController>().setGuestAddress(null);
      if (!Get.find<OrderController>().showBottomSheet) {
        Get.find<OrderController>().showRunningOrders(canUpdate: false);
      }
      if (Get.find<CheckoutController>().isDmTipSave) {
        Get.find<CheckoutController>().saveSharedPrefDmTipIndex(
            Get.find<CheckoutController>().selectedTips.toString());
      }
      Get.find<CheckoutController>().stopLoader(canUpdate: false);
      HomeScreen.loadData(true);
      double total = ((widget.orderModel.orderAmount ?? 0) / 100) *
          Get.find<SplashController>()
              .configModel!
              .loyaltyPointItemPurchasePoint!;
      if (AuthHelper.isLoggedIn()) {
        Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
      }
      Get.find<CheckoutController>().clearPrevData();
      Get.find<CouponController>().removeCouponData(false);
      Get.find<CheckoutController>().updateTips(
        Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty
            ? int.parse(
            Get.find<CheckoutController>().getSharedPrefDmTipIndex())
            : 0,
        notify: false,
      );
      Get.offNamed(RouteHelper.getOrderSuccessRoute(
        widget.orderModel.id.toString(),
        widget.contactNumber, // Ensure contactNumber is declared
        createAccount: Get.find<CheckoutController>().isCreateAccount,
      ));
    }
    else if (selectstatus == 'add_fund') {
      String tokenString =
          'payment_method=${widget.paymentMethod}&&attribute_id=${widget.orderModel.id}&&transaction_reference=${response.paymentId}';
      debugPrint("=========tokenString=============>$tokenString");
      String encodedToken = base64Encode(utf8.encode(tokenString));
      debugPrint("=========encodedtoken=============>$encodedToken");
      //
      //
      String redirectUrl =
          "${AppConstants.baseUrl}/payment-success?token=$encodedToken";
      debugPrint("=============redirecturl=========>$redirectUrl");
      debugPrint(""" url: ${redirectUrl.toString()},
          canRedirect: true,
          onClose: () {},
          addFundUrl:${widget.addFundUrl},
          orderID:${widget.orderModel.id.toString()},
          contactNumber: ${widget.contactNumber},
          storeId:${widget.storeId},
          subscriptionUrl: ${widget.subscriptionUrl},
          createAccount:${widget.createAccount},
          guestId:${widget.guestId},""");
      Get.find<OrderController>().paymentRedirect(
        url: redirectUrl.toString(),
        canRedirect: true,
        onClose: () {},
        addFundUrl: widget.addFundUrl,
        orderID: widget.orderModel.id.toString(),
        contactNumber: widget.contactNumber,
        storeId: widget.storeId,
        subscriptionUrl: widget.subscriptionUrl,
        createAccount: widget.createAccount,
        guestId: widget.guestId,
      );
      AddwalletAmount(
              userid: widget.orderModel.userId.toString(),
              amount: widget.orderModel.orderAmount!.toInt(),
              surl: AppConstants.addwalletamount)
          .callwallet();
      // Get.back();
    } else if (selectstatus == 'subscription') {
      Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(true);
      Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
      Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
          status: 'success',
          fromSubscription: true,
          storeId: widget.orderModel.store!.id));
    }
  }

  void _handleExternalWalletSelected(ExternalWalletResponse response) {
    if (selectstatus == "order") {
      RazorApiService(apiClient: Get.find<ApiClient>()).handlePaymentResponse(
        orderId: widget.orderModel.id.toString(),
        customerId:
        Get.find<ProfileController>().userInfoModel?.id.toString() ?? "23",
        paymentMethod: "razor_pay",
        paymentStatus: "success",
        transactionId: response.walletName,
      );

      if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
          (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<CheckoutController>().setGuestAddress(null);
      if (!Get.find<OrderController>().showBottomSheet) {
        Get.find<OrderController>().showRunningOrders(canUpdate: false);
      }
      if (Get.find<CheckoutController>().isDmTipSave) {
        Get.find<CheckoutController>().saveSharedPrefDmTipIndex(
            Get.find<CheckoutController>().selectedTips.toString());
      }
      Get.find<CheckoutController>().stopLoader(canUpdate: false);
      HomeScreen.loadData(true);

      double total = ((widget.orderModel.orderAmount ?? 0) / 100) *
          Get.find<SplashController>()
              .configModel!
              .loyaltyPointItemPurchasePoint!;

      if (AuthHelper.isLoggedIn()) {
        Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
      }
      String tokenString =
          'payment_method=${widget.paymentMethod}&&attribute_id=${widget.orderModel.id}&&transaction_reference=ghswjijdwguiggdwhggdhdg';
      String encodedToken = base64Encode(utf8.encode(tokenString));

      String redirectUrl =
          "${AppConstants.baseUrl}/payment-success?token=$encodedToken";
      Get.find<OrderController>().paymentRedirect(
        url: redirectUrl.toString(),
        canRedirect: true,
        onClose: () {},
        addFundUrl: widget.addFundUrl,
        orderID: widget.orderModel.id.toString(),
        contactNumber: widget.contactNumber,
        storeId: widget.storeId,
        subscriptionUrl: widget.subscriptionUrl,
        createAccount: widget.createAccount,
        guestId: widget.guestId,
      );
      // Get.offNamed(RouteHelper.getOrderSuccessRoute(
      //   widget.orderModel.id.toString(),
      //   widget.contactNumber, // Ensure contactNumber is declared
      //   createAccount: Get.find<CheckoutController>().isCreateAccount,
      // ));

      Get.find<CheckoutController>().clearPrevData();
      Get.find<CouponController>().removeCouponData(false);
      Get.find<CheckoutController>().updateTips(
        Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty
            ? int.parse(
            Get.find<CheckoutController>().getSharedPrefDmTipIndex())
            : 0,
        notify: false,
      );
    } else if (selectstatus == 'add_fund') {
      String tokenString =
          'payment_method=${widget.paymentMethod}&&attribute_id=${widget.orderModel.id}&&transaction_reference=ghswjijdwguiggdwhggdhdg';
      String encodedToken = base64Encode(utf8.encode(tokenString));

      String redirectUrl =
          "${AppConstants.baseUrl}/payment-success?token=$encodedToken";
      Get.find<OrderController>().paymentRedirect(
        url: redirectUrl.toString(),
        canRedirect: true,
        onClose: () {},
        addFundUrl: widget.addFundUrl,
        orderID: widget.orderModel.id.toString(),
        contactNumber: widget.contactNumber,
        storeId: widget.storeId,
        subscriptionUrl: widget.subscriptionUrl,
        createAccount: widget.createAccount,
        guestId: widget.guestId,
      );
      Get.back();
    } else if (selectstatus == 'subscription') {
      Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(true);
      Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
      Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
          status: 'success',
          fromSubscription: true,
          storeId: widget.orderModel.store!.id));
    }
  }

  void _orderPaymentDoneDecision(bool isSuccess, bool isFailed, bool isCancel) {
    if (isSuccess) {
      double total = ((widget.orderModel.orderAmount! / 100) *
          Get.find<SplashController>()
              .configModel!
              .loyaltyPointItemPurchasePoint!);
      Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
      Get.offNamed(RouteHelper.getOrderSuccessRoute(
        widget.orderModel.id.toString(),
        widget.contactNumber,
        createAccount: Get.find<CheckoutController>().isCreateAccount,
      ));
    } else if (isFailed || isCancel) {
      Get.offNamed(RouteHelper.getOrderSuccessRoute(
        widget.orderModel.id.toString(),
        widget.contactNumber,
        createAccount: Get.find<CheckoutController>().isCreateAccount,
      ));
    }
  }

  void _decideSubscriptionOrWallet(
      bool isSuccess, bool isFailed, bool isCancel, int? restaurantId) {
    if (isSuccess || isFailed || isCancel) {
      if (Get.currentRoute.contains(RouteHelper.payment)) {
        Get.back();
      }
      if (widget.subscriptionUrl != null &&
          widget.subscriptionUrl!.isNotEmpty &&
          widget.addFundUrl == '' &&
          widget.addFundUrl!.isEmpty) {
        Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
        Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
        Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
            status: isSuccess
                ? 'success'
                : isFailed
                ? 'fail'
                : 'cancel',
            fromSubscription: true,
            storeId: restaurantId));
      } else {
        Get.back();
        Get.offAllNamed(RouteHelper.getWalletRoute(
          fundStatus: isSuccess
              ? 'success'
              : isFailed
              ? 'fail'
              : 'cancel',
          //token: UniqueKey().toString()//
        ));
      }
    }
  }

  Future<void> _exitApp() {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == '' && widget.subscriptionUrl!.isEmpty)) {
      debugPrint("payment failed 5");
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
        guestId: widget.createAccount
            ? widget.createUserId.toString()
            : widget.guestId,
      ));
    } else {
      return Get.dialog(FundPaymentDialogWidget(
          isSubscription: widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _exitApp();
        debugPrint("exit app 6");
        return Future.value(true); // Prevent default back navigation
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class RazorApiService {
  final ApiClient apiClient;

  RazorApiService({required this.apiClient});

  final String apiUrl = "${AppConstants.baseUrl}${AppConstants.paymenthandler}";

  Future<void> handlePaymentResponse({
    required String orderId,
    required String customerId,
    required String paymentMethod,

    required String paymentStatus,
    String? transactionId, // Can be null for canceled responses
  }) async {
    try {
      debugPrint("🔹 RazorApiService: Handling payment response...");
      debugPrint("Order ID: $orderId");
      debugPrint("Customer ID: $customerId");
      debugPrint("Payment Method: $paymentMethod");
      debugPrint("Payment Status: $paymentStatus");
      debugPrint("Transaction ID: ${transactionId ?? 'N/A'}");

      Map<String, dynamic> requestBody = {
        "order_id": orderId,
        "payment_platform": paymentMethod,
        "platform_status": paymentStatus,
        "transaction_id": transactionId ?? "",
      };

      final response = await apiClient.postData(
        AppConstants.paymenthandler,
        requestBody,
        handleError: false,
      );

      debugPrint("🔹 Response Status Code: ${response.statusCode}");
      debugPrint("🔹 Response fdgdBody: ${response.body}");

      if (response.statusCode == 200) {
        dynamic jsonResponse;
        if (response.body is String) {
          jsonResponse = jsonDecode(response.body);
        } else if (response.body is Map) {
          jsonResponse = response.body;
        } else {
          debugPrint("⚠️ Unknown response type: ${response.body.runtimeType}");
          return;
        }

        // ✅ Store order ID only on success
        if (jsonResponse["status"] == "confirmed" ) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('order_id', jsonResponse["order_id"].toString());
          debugPrint("✅ Payment successful — Order ID saved: ${jsonResponse["order_id"]}");
        } else {
          debugPrint("⚠️ Unknown payment state: $jsonResponse");
        }
      } else {
        debugPrint("🚨 Failed to process payment. Status code: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      debugPrint("🔥 Error occurred while handling payment: $e");
      debugPrint(stackTrace.toString());
    }
  }
}

// class RazorApiService {
//   final ApiClient apiClient;
//
//   // ✅ Inject ApiClient through constructor
//   RazorApiService({required this.apiClient});
//   final String apiUrl =
//       "${AppConstants.baseUrl}${AppConstants.paymenthandler}";
//       // "${AppConstants.baseUrl}/native-payment-responsehandler";
//
//   Future<void> handlePaymentResponse({
//     required String orderId,
//     required String customerId,
//     required String paymentMethod,
//     required String orderStatus,
//     required String paymentStatus,
//     String? transactionId, // This can be null for a canceled response
//   })
//   async {
//     try {
//       debugPrint("shjhhsjsh");
//       debugPrint(orderId);
//       debugPrint(customerId);
//       debugPrint(paymentMethod);
//       debugPrint(orderStatus);
//       debugPrint(transactionId);
//
//       Map<String, dynamic> requestBody = {
//         "order_id": orderId,
//         // "customer_id": customerId,
//          "payment_platform": paymentMethod,
//         "order_status": orderStatus,
//         "platform_status": paymentStatus,
//         // "payment_status": paymentStatus,
//         "transaction_id": transactionId ?? "", // Empty string if null
//       };
//
//       final response = await apiClient.postData(AppConstants.paymenthandler, requestBody, handleError: false);
//
//       // await http.post(
//       //   Uri.parse(apiUrl),
//       //   headers: {
//       //     "Content-Type": "application/json",
//       //   },
//       //   body: jsonEncode(requestBody),
//       // );
// debugPrint("dsfsfvdsf ${response.statusCode}");
// debugPrint("dsfsfvdsf ${response.body}");
//       if (response.statusCode == 200) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
// String?orderid;
//         await prefs.setString('order_id_razor_pay', orderid ?? "");
//         var jsonResponse = jsonDecode(response.body);
//         if (orderStatus == "confirmed" && paymentStatus == "paid") {
//           debugPrint("Payment Successful");
//         } else if (orderStatus == "canceled" && paymentStatus == "unpaid") {
//           debugPrint("Payment Canceled");
//         }
//       } else {
//         debugPrint("Failed to process payment. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error occurred: $e");
//     }
//   }
// }

class AddwalletAmount {
  UserInfoModel userInfoModel = Get.find<ProfileController>().userInfoModel!;
  final String _url;
  String surl;
  String userid;
  int amount;
  late Map<String, dynamic> rbody;
  AddwalletAmount(
      {required this.userid, required this.amount, required this.surl})
      : _url = "${AppConstants.baseUrl}/$surl" {
    debugPrint("THE REAL CAPTION OF SHIP IS HERE : $userInfoModel");
    rbody = {"user_id": userInfoModel.id.toString(), "amount": amount};
  }
  Future<void> callwallet() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString(AppConstants.token)!;
    debugPrint("THE REAL GOAT OF ALL TIME : $token");
    try {
      debugPrint("/=_url=>$_url");
      debugPrint(rbody.toString());
      http.Response response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(rbody),
      );
      if (response.statusCode == 200) {
        Get.find<ProfileController>().getUserInfo();
        debugPrint(rbody.toString());

        debugPrint(
            '==addwalletamount=====sucess=======${response.statusCode}===>');
      } else {
        debugPrint(rbody.toString());
        debugPrint(
            "===addwalletamount======faild=====${response.statusCode}===>");
      }
    } catch (e) {
      debugPrint("===catch====$e=======>");
    }
  }
}
