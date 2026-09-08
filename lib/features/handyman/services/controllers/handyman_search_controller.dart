import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/util/app_constants.dart';

class HandymanSearchCategory {
  final String title;
  final String imageAsset;
  HandymanSearchCategory({required this.title, required this.imageAsset});
}

class HandymanSearchController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = ''.obs; // '', 'top_rated', 'popular', 'discounted', 'high', 'low'
  final RxString selectedCategoryId = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxList<HandymanServiceModel> searchResults = <HandymanServiceModel>[].obs;
  final RxList<HandymanSearchCategory> searchCategoryResults = <HandymanSearchCategory>[].obs;
  final RxList<String> recentSearches = <String>[].obs;

  Timer? _debounceTimer;

  // Fallback trending search terms if no recent search exists yet
  final List<String> trendingSearches = [
    'Professional bathroom cleaning',
    'Salon',
    'Professional kitchen cleaning',
    'Washing machine repair',
    'Refrigerator repair',
    'Professional cleaning',
    'Full home cleaning',
    'Ro repair',
    'Electricians',
    'Tv repair',
  ];

  // Filter options mapping: label -> filter key
  final Map<String, String> filterOptions = {
    'All': '',
    'Top Rated': 'top_rated',
    'Popular': 'popular',
    'Discounted': 'discounted',
    'Price: High to Low': 'high',
    'Price: Low to High': 'low',
  };

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  void loadRecentSearches() {
    if (Get.isRegistered<SharedPreferences>()) {
      final sp = Get.find<SharedPreferences>();
      final list = sp.getStringList(AppConstants.searchHistory);
      if (list != null && list.isNotEmpty) {
        recentSearches.assignAll(list);
      }
    }
  }

  void saveRecentSearch(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    recentSearches.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }

    if (Get.isRegistered<SharedPreferences>()) {
      Get.find<SharedPreferences>().setStringList(AppConstants.searchHistory, recentSearches);
    }
  }

  void clearRecentSearches() {
    recentSearches.clear();
    if (Get.isRegistered<SharedPreferences>()) {
      Get.find<SharedPreferences>().setStringList(AppConstants.searchHistory, []);
    }
  }

  void removeRecentSearch(String item) {
    recentSearches.remove(item);
    if (Get.isRegistered<SharedPreferences>()) {
      Get.find<SharedPreferences>().setStringList(AppConstants.searchHistory, recentSearches);
    }
  }

  void setFilter(String filterKey) {
    if (selectedFilter.value == filterKey) {
      selectedFilter.value = '';
    } else {
      selectedFilter.value = filterKey;
    }
    if (searchQuery.value.trim().isNotEmpty) {
      fetchSearchResults();
    }
  }

  void setCategoryFilter(String catId) {
    if (selectedCategoryId.value == catId) {
      selectedCategoryId.value = '';
    } else {
      selectedCategoryId.value = catId;
    }
    if (searchQuery.value.trim().isNotEmpty) {
      fetchSearchResults();
    }
  }

  void updateQuery(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      suggestions.clear();
      searchResults.clear();
      searchCategoryResults.clear();
      isLoading.value = false;
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchSearchResults();
    });
  }

  Future<void> fetchSearchResults() async {
    final query = searchQuery.value.trim();
    if (query.isEmpty) return;

    saveRecentSearch(query);

    isLoading.value = true;
    try {
      final apiClient = Get.find<ApiClient>();

      int activeModuleId = 10;
      if (Get.isRegistered<SplashController>()) {
        activeModuleId = Get.find<SplashController>().getHandymanModuleId();
      }

      Map<String, String> reqHeaders = Map.from(apiClient.getHeader());
      reqHeaders['Content-Type'] = 'application/json; charset=UTF-8';
      reqHeaders[AppConstants.moduleId] = activeModuleId.toString();

      String? serviceType = Get.isRegistered<HandymanHomeController>()
          ? Get.find<HandymanHomeController>().selectedServiceType
          : null;

      String uri = '${AppConstants.searchUri}items/search?name=${Uri.encodeComponent(query)}&offset=1&limit=50';
      if (serviceType != null && serviceType.isNotEmpty) {
        uri += '&service_type=$serviceType';
      }
      if (selectedCategoryId.value.isNotEmpty) {
        uri += '&category_ids=${selectedCategoryId.value}';
      }
      if (selectedFilter.value.isNotEmpty) {
        uri += '&filter=${selectedFilter.value}';
      }

      Response response = await apiClient.getData(uri, headers: reqHeaders);

      List<HandymanServiceModel> matchedResults = [];

      if (response.statusCode == 200 && response.body != null) {
        ItemModel itemModel = ItemModel.fromJson(response.body);
        if (itemModel.items != null && itemModel.items!.isNotEmpty) {
          final Map<int, HandymanServiceModel> uniqueMap = {};
          for (var item in itemModel.items!) {
            if (item.id != null && !uniqueMap.containsKey(item.id)) {
              uniqueMap[item.id!] = HandymanServiceModel.fromItem(item);
            }
          }
          matchedResults.addAll(uniqueMap.values);
        }
      }

      // If live API returns empty results or offline, fallback to local match
      if (matchedResults.isEmpty) {
        final homeController = Get.isRegistered<HandymanHomeController>() ? Get.find<HandymanHomeController>() : null;
        if (homeController != null) {
          final lowercaseQuery = query.toLowerCase();
          for (var service in homeController.mostBookedServices) {
            if (_matches(service, lowercaseQuery)) {
              if (!matchedResults.any((item) => item.id == service.id)) {
                matchedResults.add(service);
              }
            }
          }
          for (var section in homeController.categorySections) {
            for (var service in section.services) {
              if (_matches(service, lowercaseQuery)) {
                if (!matchedResults.any((item) => item.id == service.id)) {
                  matchedResults.add(service);
                }
              }
            }
          }
        }
      }

      searchResults.assignAll(matchedResults);
    } catch (e) {
      if (kDebugMode) {
        print('Error during search API call: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool _matches(HandymanServiceModel service, String query) {
    if (service.name.toLowerCase().contains(query)) return true;
    if (service.category.toLowerCase().contains(query)) return true;
    for (var option in service.options) {
      if (option.title.toLowerCase().contains(query)) return true;
    }
    return false;
  }

  void clearSearch() {
    searchQuery.value = '';
    selectedFilter.value = '';
    selectedCategoryId.value = '';
    suggestions.clear();
    searchResults.clear();
    searchCategoryResults.clear();
    isLoading.value = false;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
