import 'dart:convert';

import 'package:get/get.dart';
import 'package:handy_allinone/api/local_client.dart';
import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/features/category/domain/models/category_model.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/features/category/domain/reposotories/category_repository_interface.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';

class CategoryRepository implements CategoryRepositoryInterface {
  final ApiClient apiClient;
  CategoryRepository({required this.apiClient});

  @override
  Future getList({int? offset, bool categoryList = false, bool subCategoryList = false, bool categoryItemList = false, bool categoryStoreList = false,
    bool? allCategory, String? id, String? type, DataSourceEnum? source}) async {
    if (categoryList) {
      return await _getCategoryList(allCategory!, source ?? DataSourceEnum.client);
    } else if (subCategoryList) {
      return await _getSubCategoryList(id);
    } else if (categoryItemList) {
      return await _getCategoryItemList(id, offset!, type!);
    } else if (categoryStoreList) {
      return await _getCategoryStoreList(id, offset!, type!);
    }
  }

  int? _getActiveModuleId() {
    if (Get.isRegistered<SplashController>()) {
      return Get.find<SplashController>().getHandymanModuleId();
    }
    return 10;
  }

  Future<List<CategoryModel>?> _getCategoryList(bool allCategory, DataSourceEnum source) async {
    List<CategoryModel>? categoryList;
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';

    int? activeModuleId = _getActiveModuleId();

    if (activeModuleId != null) {
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();
    }

    String cacheId = '${AppConstants.categoryUri}_${activeModuleId ?? 0}';

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.categoryUri, headers: reqHeaders);
        if (response.statusCode == 200) {
          categoryList = [];
          dynamic rawData;
          if (response.body is Map && response.body.containsKey('categories')) {
            rawData = response.body['categories'];
          } else if (response.body is List) {
            rawData = response.body;
          }
          if (rawData is List) {
            for (var category in rawData) {
              CategoryModel cat = CategoryModel.fromJson(category);
              if (activeModuleId == null || cat.moduleId == null || cat.moduleId == activeModuleId) {
                categoryList.add(cat);
              }
            }
          }
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), reqHeaders);
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          categoryList = [];
          try {
            dynamic decoded = jsonDecode(cacheResponseData);
            dynamic rawData;
            if (decoded is Map && decoded.containsKey('categories')) {
              rawData = decoded['categories'];
            } else if (decoded is List) {
              rawData = decoded;
            }
            if (rawData is List) {
              for (var category in rawData) {
                CategoryModel cat = CategoryModel.fromJson(category);
                if (activeModuleId == null || cat.moduleId == null || cat.moduleId == activeModuleId) {
                  categoryList.add(cat);
                }
              }
            }
          } catch (_) {}
        }
    }

    return categoryList;
  }

  Future<List<CategoryModel>?> _getSubCategoryList(String? parentID) async {
    List<CategoryModel>? subCategoryList;
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    int? activeModuleId = _getActiveModuleId();
    if (activeModuleId != null) {
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();
    }
    Response response = await apiClient.getData('${AppConstants.subCategoryUri}$parentID', headers: reqHeaders);
    if (response.statusCode == 200) {
      subCategoryList= [];
      response.body.forEach((category) => subCategoryList!.add(CategoryModel.fromJson(category)));
    }
    return subCategoryList;
  }

  Future<ItemModel?> _getCategoryItemList(String? categoryID, int offset, String type) async {
    ItemModel? categoryItem;
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    int? activeModuleId = _getActiveModuleId();
    if (activeModuleId != null) {
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();
    }
    String? serviceType = Get.isRegistered<HandymanHomeController>()
        ? Get.find<HandymanHomeController>().selectedServiceType
        : null;
    String serviceTypeParam = (serviceType != null && serviceType.isNotEmpty)
        ? '&service_type=$serviceType'
        : '';
    Response response = await apiClient.getData('${AppConstants.categoryItemUri}$categoryID?limit=50&offset=$offset&type=$type$serviceTypeParam', headers: reqHeaders);
    if (response.statusCode == 200) {
      categoryItem = ItemModel.fromJson(response.body);
    }
    return categoryItem;
  }

  Future<StoreModel?> _getCategoryStoreList(String? categoryID, int offset, String type) async {
    StoreModel? categoryStore;
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    int? activeModuleId = _getActiveModuleId();
    if (activeModuleId != null) {
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();
    }
    Response response = await apiClient.getData('${AppConstants.categoryStoreUri}$categoryID?limit=10&offset=$offset&type=$type', headers: reqHeaders);
    if (response.statusCode == 200) {
      categoryStore = StoreModel.fromJson(response.body);
    }
    return categoryStore;
  }

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isStore, String type) async {
    Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
    reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    int? activeModuleId = _getActiveModuleId();
    if (activeModuleId != null) {
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();
    }
    return await apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
      headers: reqHeaders,
    );
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    Response response = await apiClient.postData(AppConstants.interestUri, {"interest": interests});
    return (response.statusCode == 200);
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
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}