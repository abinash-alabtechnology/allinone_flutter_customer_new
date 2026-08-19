import 'package:get/get_connect/connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/order/domain/models/order_cancellation_body.dart';
import 'package:handy_allinone/features/order/domain/models/order_details_model.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/features/order/domain/models/refund_model.dart';
import 'package:handy_allinone/features/order/domain/models/support_model.dart';
import 'package:handy_allinone/features/order/domain/repositories/order_repository_interface.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'dart:convert'; 

import 'package:get/get.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/module_helper.dart';

class OrderRepository implements OrderRepositoryInterface {
  final ApiClient apiClient;
  OrderRepository({required this.apiClient});

  @override
  Future<Response> submitRefundRequest(Map<String, String> body, XFile? data) async {
    return apiClient.postMultipartData(AppConstants.refundRequestUri, body,  [MultipartBody('image[]', data)]);
  }

  @override
  Future<Response> trackOrder(String? orderID, String? guestId, {String? contactNumber}) async {
    Response response = await apiClient.getData(
      '${AppConstants.trackUri}$orderID${guestId != null ? '&guest_id=$guestId' : ''}'
          '${contactNumber != null ? '&contact_number=$contactNumber' : ''}',
    );
    print("=====> Track Order Response: ${response.body}");
    return response;
  }

  @override
  Future<Response> switchToCOD(String? orderID, {String? guestId}) async {
    Map<String, String> data = {'_method': 'put', 'order_id': orderID!};
    if(AuthHelper.isGuestLoggedIn() || guestId != null) {
      data.addAll({'guest_id': guestId ?? AuthHelper.getGuestId()});
    }
    return await apiClient.postData(AppConstants.codSwitchUri, data);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> cancelOrder(String orderID, String? reason, {String? guestId}) async {
    bool success = false;
    Map<String, String> data = {'_method': 'put', 'order_id': orderID, 'reason': reason!};
    if(AuthHelper.isGuestLoggedIn() || guestId != null){
      data.addAll({'guest_id': guestId ?? AuthHelper.getGuestId()});
    }
    Response response = await apiClient.postData(AppConstants.orderCancelUri, data);
    if (response.statusCode == 200) {
      success = true;
      showCustomSnackBar(response.body['message'], isError: false);
    }
    return success;
  }

  @override
  Future get(String? id, {String? guestId}) async {
    return await _getOrderDetails(id!, guestId);
  }

  Future<List<OrderDetailsModel>?> _getOrderDetails(String orderID, String? guestId) async {
    List<OrderDetailsModel>? orderDetails;
    Response response = await apiClient.getData('${AppConstants.orderDetailsUri}$orderID${guestId != null ? '&guest_id=$guestId' : ''}');
    if (response.statusCode == 200) {
      print("=====> Order Details Response Type: ${response.body.runtimeType}");
      print("=====> Order Details Response: ${response.body}");

      if (response.body is List && response.body.isNotEmpty) {
        print("=====> First Item Delivar Booking (Raw): ${response.body[0]['delivar_booking']}");
        print("=====> First Item Public Tracking ID (Raw): ${response.body[0]['public_tracking_id']}");
      } else if (response.body is Map) {
        print("=====> Map Delivar Booking: ${response.body['delivar_booking']}");
        print("=====> Map Public Tracking ID: ${response.body['public_tracking_id']}");
      }
      
      orderDetails = [];
      if (response.body is List) {
        response.body.forEach((orderDetail) {
          OrderDetailsModel model = OrderDetailsModel.fromJson(orderDetail);
          print("=====> Parsed Item Model | ID: ${model.id} | Delivar: ${model.delivarBooking} | Tracking: ${model.publicTrackingId}");
          orderDetails!.add(model);
        });
      } else if (response.body is Map && response.body['details'] != null) {
        response.body['details'].forEach((orderDetail) {
          OrderDetailsModel model = OrderDetailsModel.fromJson(orderDetail);
          orderDetails!.add(model);
        });
      }
    }
    return orderDetails;
  }

  @override
  Future getList({int? offset, bool isRunningOrder = false, bool isHistoryOrder = false, bool isCancelReasons = false, bool isRefundReasons = false, bool fromDashboard = false, bool isSupportReasons = false}) async {
    if(isRunningOrder) {
      return await _getRunningOrderList(offset!, fromDashboard);
    } else if(isHistoryOrder) {
      return await _getHistoryOrderList(offset!);
    } else if(isCancelReasons) {
      return await _getCancelReasons();
    } else if(isRefundReasons) {
      return await _getRefundReasons();
    } else if(isSupportReasons) {
      return await _getSupportReasons();
    }
  }

  Future<PaginatedOrderModel?> _getRunningOrderList(int offset, bool fromDashboard) async {
    PaginatedOrderModel? runningOrderModel;
    int handymanModuleId = Get.isRegistered<SplashController>() ? Get.find<SplashController>().getHandymanModuleId() : 10;
    int? activeModuleId = ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;
    if (activeModuleId == null || activeModuleId == 0) {
      if (Get.isRegistered<SplashController>()) {
        activeModuleId = Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id;
      }
    }
    bool isHandyman = (activeModuleId == handymanModuleId) ||
        (Get.isRegistered<SplashController>() && Get.find<SplashController>().module?.id == handymanModuleId);

    String uri = isHandyman
        ? '${AppConstants.runningOrderListUri}?limit=${fromDashboard ? 50 : 25}&offset=$offset&filter_module_id=$handymanModuleId'
        : '${AppConstants.runningOrderListUri}?offset=$offset&limit=${fromDashboard ? 50 : 10}';

    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200) {
      runningOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return runningOrderModel;
  }

  Future<PaginatedOrderModel?> _getHistoryOrderList(int offset) async {
    PaginatedOrderModel? historyOrderModel;
    int handymanModuleId = Get.isRegistered<SplashController>() ? Get.find<SplashController>().getHandymanModuleId() : 10;
    int? activeModuleId = ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;
    if (activeModuleId == null || activeModuleId == 0) {
      if (Get.isRegistered<SplashController>()) {
        activeModuleId = Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id;
      }
    }
    bool isHandyman = (activeModuleId == handymanModuleId) ||
        (Get.isRegistered<SplashController>() && Get.find<SplashController>().module?.id == handymanModuleId);

    String uri = isHandyman
        ? '${AppConstants.historyOrderListUri}?limit=25&offset=$offset&filter_module_id=$handymanModuleId'
        : '${AppConstants.historyOrderListUri}?offset=$offset&limit=10';

    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200) {
      historyOrderModel = PaginatedOrderModel.fromJson(response.body);
    }
    return historyOrderModel;
  }

  Future<List<CancellationData>?> _getCancelReasons() async {
    List<CancellationData>? orderCancelReasons;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer');
    if (response.statusCode == 200) {
      OrderCancellationBody orderCancellationBody = OrderCancellationBody.fromJson(response.body);
      orderCancelReasons = [];
      for (var element in orderCancellationBody.reasons!) {
        orderCancelReasons.add(element);
      }
    }
    return orderCancelReasons;
  }

  Future<List<String?>?> _getRefundReasons() async {
    List<String?>? refundReasons;
    Response response = await apiClient.getData(AppConstants.refundReasonUri);
    if (response.statusCode == 200) {
      RefundModel refundModel = RefundModel.fromJson(response.body);
      refundReasons = [];
      refundReasons.insert(0, 'select_an_option');
      for (var element in refundModel.refundReasons!) {
        refundReasons.add(element.reason);
      }
    }
    return refundReasons;
  }

  Future<List<String?>?> _getSupportReasons() async {
    List<String?>? supportReasons;
    Response response = await apiClient.getData(AppConstants.supportReasonUri);
    if (response.statusCode == 200) {
      SupportModel supportModel = SupportModel.fromJson(response.body);
      supportReasons = [];
      for (var element in supportModel.data!) {
        supportReasons.add(element.message);
      }
    }
    return supportReasons;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
  
}