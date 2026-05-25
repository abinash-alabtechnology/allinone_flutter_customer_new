import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/util/images.dart';

class CategorySectionModel {
  final String title;
  final String subtitle;
  final List<HandymanServiceModel> services;

  CategorySectionModel({
    required this.title,
    required this.subtitle,
    required this.services,
  });
}

class HandymanHomeController extends GetxController {
  // ─── Observable State ───────────────────────────────────────────────────────
  final RxList<HandymanServiceModel> mostBookedServices =
      <HandymanServiceModel>[].obs;
  final RxList<CategorySectionModel> categorySections =
      <CategorySectionModel>[].obs;

  final RxBool isLoading = false.obs;

  // ─── Derived ─────────────────────────────────────────────────────────────────
  int get totalCartItems {
    int total = 0;
    for (final s in mostBookedServices) {
      total += s.cartQuantity;
    }
    for (final section in categorySections) {
      for (final s in section.services) {
        total += s.cartQuantity;
      }
    }
    return total;
  }

  List<HandymanServiceModel> get wishlistedServices {
    final list = mostBookedServices.where((s) => s.isWishlisted).toList();
    for (final section in categorySections) {
      list.addAll(section.services.where((s) => s.isWishlisted));
    }
    // In a real app, you'd deduplicate based on ID if the same service exists in both
    return list;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  // ─── Data ────────────────────────────────────────────────────────────────────
  void _loadData() {
    isLoading.value = true;
    _loadMostBookedServices();
    _loadCategoryServices();
    isLoading.value = false;
  }

  void _loadMostBookedServices() {
    // Mock data matching real handyman service categories
    mostBookedServices.assignAll([
      HandymanServiceModel(
        id: 'ac_repair',
        name: 'AC Repair & Service',
        category: 'AC & Appliance',
        rating: 4.8,
        reviewCount: '2.6M',
        startingPrice: 699,
        optionsCount: 8,
        imageAsset: Images.handymanAcRepair,
      ),
      HandymanServiceModel(
        id: 'women_salon',
        name: "Women's Salon Classic",
        category: "Women's Salon & Spa",
        rating: 4.76,
        reviewCount: '1.8M',
        startingPrice: 449,
        optionsCount: 12,
        imageAsset: Images.handymanWomenSalon,
      ),
      HandymanServiceModel(
        id: 'cleaning',
        name: 'Home Deep Cleaning',
        category: 'Cleaning & Pest',
        rating: 4.72,
        reviewCount: '1.2M',
        startingPrice: 349,
        optionsCount: 5,
        imageAsset: Images.handymanCleaning,
      ),
      HandymanServiceModel(
        id: 'tools_plumb',
        name: 'Plumbing Service',
        category: 'Electrician & Plumber',
        rating: 4.65,
        reviewCount: '890K',
        startingPrice: 199,
        optionsCount: 6,
        imageAsset: Images.handymanTools,
      ),
      HandymanServiceModel(
        id: 'men_salon',
        name: "Men's Haircut & Massage",
        category: "Men's Salon",
        rating: 4.71,
        reviewCount: '760K',
        startingPrice: 299,
        optionsCount: 9,
        imageAsset: Images.handymanMenSalon,
      ),
      HandymanServiceModel(
        id: 'painting',
        name: 'Home Painting',
        category: 'Painting & Waterproofing',
        rating: 4.58,
        reviewCount: '540K',
        startingPrice: 599,
        optionsCount: 4,
        imageAsset: Images.handymanPainting,
      ),
      HandymanServiceModel(
        id: 'cctv',
        name: 'CCTV Installation',
        category: 'CCTV & Smart Home',
        rating: 4.81,
        reviewCount: '320K',
        startingPrice: 899,
        optionsCount: 3,
        imageAsset: Images.handymanCctv,
      ),
    ]);
  }

  void _loadCategoryServices() {
    categorySections.assignAll([
      CategorySectionModel(
        title: 'Salon for Women',
        subtitle: 'Pamper yourself at home',
        services: [
          HandymanServiceModel(
            id: 'threading',
            name: 'Threading',
            category: "Women's Salon & Spa",
            rating: 4.85,
            reviewCount: '2.8M',
            startingPrice: 29,
            optionsCount: 8,
            imageAsset: Images.handymanThreading,
          ),
          HandymanServiceModel(
            id: 'head_massage',
            name: 'Head massage',
            category: "Women's Salon & Spa",
            rating: 4.87,
            reviewCount: '194K',
            startingPrice: 199,
            optionsCount: 2,
            imageAsset: Images.handymanHeadMassage,
          ),
          HandymanServiceModel(
            id: 'facial',
            name: 'Facial',
            category: "Women's Salon & Spa",
            rating: 4.75,
            reviewCount: '1.2M',
            startingPrice: 399,
            optionsCount: 5,
            imageAsset: Images.handymanFacial,
          ),
          HandymanServiceModel(
            id: 'full_arms_waxing',
            name: 'Full Arms Waxing',
            category: "Women's Salon & Spa",
            rating: 4.82,
            reviewCount: '980K',
            startingPrice: 149,
            optionsCount: 6,
            imageAsset: Images.handymanFacial,
          ),
        ],
      ),
      CategorySectionModel(
        title: 'AC & Appliance Repair',
        subtitle: 'Expert technicians at your doorstep',
        services: [
          HandymanServiceModel(
            id: 'ac_service',
            name: 'AC Service',
            category: "AC Repair",
            rating: 4.80,
            reviewCount: '2.6M',
            startingPrice: 499,
            optionsCount: 0,
            imageAsset: Images.handymanAc,
          ),
          HandymanServiceModel(
            id: 'ac_deep_clean',
            name: 'AC Deep Clean',
            category: "AC Repair",
            rating: 4.72,
            reviewCount: '890K',
            startingPrice: 899,
            optionsCount: 0,
            imageAsset: Images.handymanAc,
          ),
          HandymanServiceModel(
            id: 'ac_install',
            name: 'AC Installation',
            category: "AC Repair",
            rating: 4.68,
            reviewCount: '340K',
            startingPrice: 1500,
            optionsCount: 0,
            imageAsset: Images.handymanAc,
          ),
          HandymanServiceModel(
            id: 'geyser_repair',
            name: 'Geyser Repair',
            category: "Appliance Repair",
            rating: 4.65,
            reviewCount: '210K',
            startingPrice: 399,
            optionsCount: 0,
            imageAsset: Images.handymanAc,
          ),
        ],
      ),
    ]);
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────
  void toggleWishlist(String serviceId) {
    _updateListWithNested(serviceId, (s) => s.isWishlisted = !s.isWishlisted);
  }

  void addToCart(String serviceId) {
    _updateListWithNested(serviceId, (s) => s.cartQuantity++);
  }

  void removeFromCart(String serviceId) {
    _updateListWithNested(serviceId, (s) {
      if (s.cartQuantity > 0) s.cartQuantity--;
    });
  }

  void clearCart() {
    for (final s in mostBookedServices) {
      s.cartQuantity = 0;
    }
    for (final section in categorySections) {
      for (final s in section.services) {
        s.cartQuantity = 0;
      }
    }
    mostBookedServices.refresh();
    categorySections.refresh();
  }

  void _updateListWithNested(String id, void Function(HandymanServiceModel) update) {
    // Check mostBooked
    final idx = mostBookedServices.indexWhere((s) => s.id == id);
    if (idx != -1) {
      update(mostBookedServices[idx]);
      mostBookedServices.refresh();
    }
    
    // Check category sections
    for (final section in categorySections) {
      final sIdx = section.services.indexWhere((s) => s.id == id);
      if (sIdx != -1) {
        update(section.services[sIdx]);
        categorySections.refresh();
      }
    }
  }
}
