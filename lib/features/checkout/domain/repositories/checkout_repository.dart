import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/checkout/domain/models/surge_price_model.dart';
import 'package:handy_allinone/features/payment/domain/models/offline_method_model.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/util/app_constants.dart';

class CheckoutRepository implements CheckoutRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CheckoutRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<int> getDmTipMostTapped() async {
    int mostDmTipAmount = 0;
    Response response = await apiClient.getData(AppConstants.mostTipsUri);
    if (response.statusCode == 200) {
      mostDmTipAmount = response.body['most_tips_amount'] ?? 0;
    }
    return mostDmTipAmount;
  }

  @override
  Future<bool> saveSharedPrefDmTipIndex(String index) async {
    return await sharedPreferences.setString(AppConstants.dmTipIndex, index);
  }

  @override
  String getSharedPrefDmTipIndex() {
    return sharedPreferences.getString(AppConstants.dmTipIndex) ?? "";
  }

  @override
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    return await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
          '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=WALK',
      handleError: false,
    );
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    double extraCharge = 0;
    Response response = await apiClient.getData('${AppConstants.vehicleChargeUri}?distance=$distance', handleError: false);
    if (response.statusCode == 200) {
      extraCharge = double.parse(response.body.toString());
    }
    return extraCharge;
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody, List<MultipartBody>? orderAttachment) async {
    debugPrint("====> Place Order Request: ${orderBody.toJson()}");

    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';

    int? activeModuleId;
    if (Get.isRegistered<CartController>()) {
      for (var c in Get.find<CartController>().cartList) {
        if (c.item?.moduleId != null && c.item!.moduleId! > 0) {
          activeModuleId = c.item!.moduleId;
          break;
        }
      }
    }
    if (activeModuleId == null && Get.isRegistered<SplashController>()) {
      final hMod = Get.find<SplashController>().moduleList?.firstWhereOrNull((m) {
        String name = m.moduleName?.toLowerCase() ?? '';
        String type = m.moduleType?.toLowerCase() ?? '';
        return name.contains('handyman') || type.contains('handyman');
      });
      if (hMod != null && hMod.id != null) {
        activeModuleId = hMod.id;
      }
    }
    activeModuleId ??= 10;
    reqHeaders[AppConstants.moduleId] = activeModuleId.toString();

    if (orderBody.paymentMethod == 'digital_payment'&&!kIsWeb) {
      print("digitalpayment api works");
      return await apiClient.postMultipartData(
        AppConstants.tempplaceOrderUri,
        orderBody.toJson(),
        orderAttachment ?? [],
        headers: reqHeaders,
        handleError: false,
      );
    } else {
      return await apiClient.postMultipartData(
        AppConstants.placeOrderUri,
        orderBody.toJson(),
        orderAttachment ?? [],
        headers: reqHeaders,
        handleError: false,
      );
    }
  }

  @override
  Future<Response> placePrescriptionOrder(int? storeId, double? distance, String address, String longitude, String latitude, String note,
      List<MultipartBody> orderAttachment, String dmTips, String deliveryInstruction) async {

    Map<String, String> body = {
      'store_id': storeId.toString(),
      'distance': distance.toString(),
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'order_note': note,
      'dm_tips': dmTips,
      'delivery_instruction': deliveryInstruction,
      'payment_method': 'cash_on_delivery',
      'order_type': 'delivery',
    };
    return await apiClient.postMultipartData(AppConstants.placePrescriptionOrderUri, body, orderAttachment, handleError: false);
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
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) async{
    return await _getOfflineMethodList();
  }

  Future<List<OfflineMethodModel>?> _getOfflineMethodList() async {
    List<OfflineMethodModel>? offlineMethodList;
    Response response = await apiClient.getData(AppConstants.offlineMethodListUri);
    if (response.statusCode == 200) {
      offlineMethodList = [];
      var data = response.body;

      offlineMethodList = [];

      if (data is List) {
        for (var method in data) {
          offlineMethodList.add(OfflineMethodModel.fromJson(method));
        }

      } else if (data is Map) {
        for (var method in data.values) {
          offlineMethodList.add(OfflineMethodModel.fromJson(method));
        }
      }
      ///comment by akilan add above code
      // response.body.forEach((method) => offlineMethodList!.add(OfflineMethodModel.fromJson(method)));
    }
    return offlineMethodList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> getOrderTax(PlaceOrderBodyModel orderBody) async {
    Response response = await apiClient.postData(AppConstants.getOrderTaxUri, orderBody.toJson());
    return response;
  }

  @override
  Future<SurgePriceModel?> getSurgePrice({required String zoneId, required String moduleId, required String dateTime, String? guestId}) async {
    SurgePriceModel? surgePrice;
    Map<String, dynamic> body = {
      'zone_id': zoneId,
      'module_id': moduleId,
      'date_time': dateTime,
      'guest_id': guestId ?? '',
    };
    Response response = await apiClient.postData(AppConstants.getSurgePriceUri, body);
    if (response.statusCode == 200) {
      surgePrice = SurgePriceModel.fromJson(response.body);
    }
    return surgePrice;
  }

  @override
  Future<Response> checkAddressDelivery(int addressId, int storeId) async {
    return await apiClient.postData(AppConstants.checkAddressDeliveryUri, {'address_id': addressId, 'store_id': storeId});
  }
  
}