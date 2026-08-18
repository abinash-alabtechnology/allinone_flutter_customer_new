import 'package:get/get.dart';
import 'package:handy_allinone/common/models/response_model.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/favourite/domain/repositories/favourite_repository_interface.dart';
import 'package:handy_allinone/util/app_constants.dart';

import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';

class FavouriteRepository implements FavouriteRepositoryInterface<ResponseModel> {
  final ApiClient apiClient;
  FavouriteRepository({required this.apiClient});

  Map<String, String> _getModuleHeaders() {
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    int? activeModuleId;
    if (Get.find<SplashController>().module != null && Get.find<SplashController>().module!.id != null) {
      activeModuleId = Get.find<SplashController>().module!.id;
    } else {
      activeModuleId = Get.find<SplashController>().getHandymanModuleId();
    }
    if (activeModuleId != null) {
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();
    }
    return reqHeaders;
  }

  @override
  Future<Response> getList({int? offset}) async {
    String? serviceType = Get.isRegistered<HandymanHomeController>()
        ? Get.find<HandymanHomeController>().selectedServiceType
        : null;
    String url = AppConstants.wishListGetUri;
    if (serviceType != null && serviceType.isNotEmpty) {
      url = '$url${url.contains('?') ? '&' : '?'}service_type=$serviceType';
    }
    return await apiClient.getData(url, headers: _getModuleHeaders());
  }

  @override
  Future<ResponseModel> add(dynamic a, {bool isStore = false, int? id}) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData('${AppConstants.addWishListUri}${isStore ? 'store_id=' : 'item_id='}$id', null, headers: _getModuleHeaders(), handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> delete(int? id, {bool isStore = false}) async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData('${AppConstants.removeWishListUri}${isStore ? 'store_id=' : 'item_id='}$id', headers: _getModuleHeaders(), handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}