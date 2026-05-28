import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/util/images.dart';

class HandymanSearchCategory {
  final String title;
  final String imageAsset;
  HandymanSearchCategory({required this.title, required this.imageAsset});
}

class HandymanSearchController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<String> suggestions = <String>[].obs;
  final RxList<HandymanServiceModel> searchResults = <HandymanServiceModel>[].obs;
  final RxList<HandymanSearchCategory> searchCategoryResults = <HandymanSearchCategory>[].obs;

  // Trending search terms matching the first UI
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

  // Specific mock suggestions mapping for visual excellence (matching the 2nd UI for "FACIAL")
  final Map<String, List<String>> _presetSuggestions = {
    'facial': [
      "Women's facial",
      "Men's facial",
      "Women's facial consultation",
    ],
    'clean': [
      'Bathroom deep cleaning',
      'Kitchen cleaning',
      'Full home deep cleaning',
      'Sofa cleaning',
    ],
    'salon': [
      "Women's salon classic",
      "Men's haircut & massage",
      "Threading",
      "Full arms waxing",
    ],
    'ac': [
      'AC service',
      'AC deep clean',
      'AC installation',
    ],
  };

  void updateQuery(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      suggestions.clear();
      searchResults.clear();
      searchCategoryResults.clear();
      return;
    }

    final lowercaseQuery = query.toLowerCase().trim();

    // 1. Generate Autocomplete Suggestions
    List<String> matchedSuggestions = [];
    
    // Check preset mappings first
    _presetSuggestions.forEach((key, list) {
      if (lowercaseQuery.contains(key) || key.contains(lowercaseQuery)) {
        matchedSuggestions.addAll(list);
      }
    });

    // Also dynamically scan existing services/options
    final homeController = Get.find<HandymanHomeController>();
    for (var service in homeController.mostBookedServices) {
      if (service.name.toLowerCase().contains(lowercaseQuery) && !matchedSuggestions.contains(service.name)) {
        matchedSuggestions.add(service.name);
      }
    }
    for (var section in homeController.categorySections) {
      for (var service in section.services) {
        if (service.name.toLowerCase().contains(lowercaseQuery) && !matchedSuggestions.contains(service.name)) {
          matchedSuggestions.add(service.name);
        }
        for (var option in service.options) {
          if (option.title.toLowerCase().contains(lowercaseQuery) && !matchedSuggestions.contains(option.title)) {
            matchedSuggestions.add(option.title);
          }
        }
      }
    }

    suggestions.assignAll(matchedSuggestions.take(5).toList());

    // 2. Filter Search Results
    List<HandymanServiceModel> matchedResults = [];

    searchCategoryResults.clear();
    if (lowercaseQuery.contains('clean') || lowercaseQuery.contains('bathroom') || lowercaseQuery.contains('professional')) {
      searchCategoryResults.assignAll([
        HandymanSearchCategory(title: 'Bathroom\n& Kitchen\nCleaning', imageAsset: Images.bathroomSink),
        HandymanSearchCategory(title: 'Geyser\nService &\nRepair', imageAsset: Images.geyserClean),
        HandymanSearchCategory(title: 'Sofa &\nCarpet\nCleaning', imageAsset: Images.sofaClean),
        HandymanSearchCategory(title: 'Full Home/\nBy Room\nCleaning', imageAsset: Images.houseClean),
      ]);
    }

    // If query is "facial", inject the exact items shown in the 2nd UI screenshot for premium fidelity
    if (lowercaseQuery.contains('facial')) {
      matchedResults.addAll([
        HandymanServiceModel(
          id: 'skin_brightening_facial',
          name: 'Skin brightening facial',
          category: "Women's Salon & Spa",
          rating: 4.74,
          reviewCount: '17K',
          startingPrice: 1399,
          optionsCount: 0,
          imageAsset: Images.handymanFacial,
        ),
        HandymanServiceModel(
          id: 'face_care_beyond',
          name: 'Face care & beyond',
          category: "Women's Salon & Spa",
          rating: 4.05,
          reviewCount: '1M',
          startingPrice: 659,
          optionsCount: 0,
          imageAsset: Images.handymanWomenSalon,
        ),
      ]);
    } else if (lowercaseQuery.contains('clean') || lowercaseQuery.contains('bathroom') || lowercaseQuery.contains('professional')) {
      matchedResults.addAll([
        HandymanServiceModel(
          id: 'intense_bathroom_cleaning',
          name: 'Intense bathroom cleaning',
          category: 'Cleaning',
          rating: 4.80,
          reviewCount: '6.7M',
          startingPrice: 549,
          optionsCount: 0,
          imageAsset: Images.intenseBathroom,
        ),
        HandymanServiceModel(
          id: 'ant_control_kitchen_bathroom',
          name: 'Ant control – kitchen/bathroom (with utensil removal)',
          category: 'Cleaning',
          rating: 5.00,
          reviewCount: '22',
          startingPrice: 1249,
          optionsCount: 6,
          imageAsset: Images.antControl,
        ),
        HandymanServiceModel(
          id: 'furnished_apartment_deep_cleaning',
          name: 'Furnished apartment - Home deep cleaning',
          category: 'Cleaning',
          rating: 4.80,
          reviewCount: '571K',
          startingPrice: 3499,
          optionsCount: 0,
          imageAsset: Images.furnishedApartment,
        ),
      ]);
    }

    // Filter normal handyman services
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

    searchResults.assignAll(matchedResults);
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
    suggestions.clear();
    searchResults.clear();
    searchCategoryResults.clear();
  }
}
