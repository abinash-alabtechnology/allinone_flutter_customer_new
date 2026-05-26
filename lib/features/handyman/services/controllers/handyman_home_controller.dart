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
        name: 'Foam-jet AC service',
        category: 'AC & Appliance',
        rating: 4.76,
        reviewCount: '2.6M',
        startingPrice: 699,
        optionsCount: 3,
        options: [
          HandymanServiceOption(
            id: 'ac_1',
            title: '1 AC',
            originalPrice: 699,
            discountedPrice: 699,
            discountText: '',
            subtitle: '',
          ),
          HandymanServiceOption(
            id: 'ac_2',
            title: '2 ACs',
            originalPrice: 1398,
            discountedPrice: 1298,
            discountText: '7% off',
            subtitle: '(₹649/AC)',
          ),
          HandymanServiceOption(
            id: 'ac_3',
            title: '3 ACs',
            originalPrice: 2097,
            discountedPrice: 1797,
            discountText: '14% off',
            subtitle: '(₹599/AC)',
          ),
        ],
        imageAsset: Images.handymanAc,
        coverImageAsset: Images.handymanAcRepair,
        coverTitle: 'AC Repair',
        coverDescription: 'Hassle-free fixes\nfor all AC issues',
      ),
      HandymanServiceModel(
        id: 'women_salon',
        name: "Women's Salon Classic",
        category: "Women's Salon & Spa",
        rating: 4.76,
        reviewCount: '1.8M',
        startingPrice: 449,
        optionsCount: 0,
        imageAsset: Images.handymanWomenSalon,
      ),
      HandymanServiceModel(
        id: 'cleaning',
        name: 'Home Deep Cleaning',
        category: 'Cleaning & Pest',
        rating: 4.72,
        reviewCount: '1.2M',
        startingPrice: 349,
        optionsCount: 2,
        options: [
          HandymanServiceOption(
            id: 'clean_1',
            title: '1 BHK',
            originalPrice: 349,
            discountedPrice: 349,
            discountText: '',
            subtitle: '',
          ),
          HandymanServiceOption(
            id: 'clean_2',
            title: '2 BHK',
            originalPrice: 698,
            discountedPrice: 599,
            discountText: '14% off',
            subtitle: '',
          ),
        ],
        imageAsset: Images.handymanCleaning,
        coverImageAsset: Images.handymanCleaning,
      ),
      HandymanServiceModel(
        id: 'tools_plumb',
        name: 'Plumbing Service',
        category: 'Electrician & Plumber',
        rating: 4.65,
        reviewCount: '890K',
        startingPrice: 199,
        optionsCount: 0,
        imageAsset: Images.handymanTools,
      ),
      HandymanServiceModel(
        id: 'men_salon',
        name: "Men's Haircut & Massage",
        category: "Men's Salon",
        rating: 4.71,
        reviewCount: '760K',
        startingPrice: 299,
        optionsCount: 1,
        options: [
          HandymanServiceOption(
            id: 'haircut_1',
            title: 'Haircut',
            originalPrice: 299,
            discountedPrice: 299,
            discountText: '',
            subtitle: '',
          ),
        ],
        imageAsset: Images.handymanMenSalon,
      ),
      HandymanServiceModel(
        id: 'painting',
        name: 'Home Painting',
        category: 'Painting & Waterproofing',
        rating: 4.58,
        reviewCount: '540K',
        startingPrice: 599,
        optionsCount: 0,
        imageAsset: Images.handymanPainting,
      ),
      HandymanServiceModel(
        id: 'cctv',
        name: 'CCTV Installation',
        category: 'CCTV & Smart Home',
        rating: 4.81,
        reviewCount: '320K',
        startingPrice: 899,
        optionsCount: 2,
        options: [
          HandymanServiceOption(
            id: 'cctv_1',
            title: '1 Camera',
            originalPrice: 899,
            discountedPrice: 899,
            discountText: '',
            subtitle: '',
          ),
          HandymanServiceOption(
            id: 'cctv_2',
            title: '2 Cameras',
            originalPrice: 1798,
            discountedPrice: 1599,
            discountText: '11% off',
            subtitle: '',
          ),
        ],
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
            optionsCount: 3,
            coverTitle: 'Precise threading for a smooth,\nhair-free finish',
            isCoverTextDark: false,
            options: [
              HandymanServiceOption(
                id: 'thread_1',
                title: 'Eyebrow',
                originalPrice: 59,
                discountedPrice: 59,
                discountText: '',
                subtitle: '',
                rating: 4.85,
                reviewCount: '1.5M',
                imageAsset: Images.handymanThreading,
              ),
              HandymanServiceOption(
                id: 'thread_2',
                title: 'Upper lip',
                originalPrice: 59,
                discountedPrice: 59,
                discountText: '',
                subtitle: '',
                rating: 4.85,
                reviewCount: '723K',
                imageAsset: Images.handymanUpperLip,
              ),
              HandymanServiceOption(
                id: 'thread_3',
                title: 'Chin',
                originalPrice: 29,
                discountedPrice: 29,
                discountText: '',
                subtitle: '',
                rating: 4.86,
                reviewCount: '161K',
                imageAsset: Images.handymanChin,
              ),
            ],
            imageAsset: Images.handymanThreading,
            coverImageAsset: Images.handymanWomenSalon,
          ),
          HandymanServiceModel(
            id: 'head_massage',
            name: 'Head massage',
            category: "Women's Salon & Spa",
            rating: 4.87,
            reviewCount: '194K',
            startingPrice: 199,
            optionsCount: 0,
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
            coverImageAsset: Images.handymanWomenSalon,
            options: [
              HandymanServiceOption(
                id: 'facial_1',
                title: 'Fruit Facial',
                originalPrice: 399,
                discountedPrice: 399,
                discountText: '',
                subtitle: '',
                rating: 4.75,
                reviewCount: '450K',
                imageAsset: Images.facialFruit,
              ),
              HandymanServiceOption(
                id: 'facial_2',
                title: 'Gold Facial',
                originalPrice: 599,
                discountedPrice: 599,
                discountText: '',
                subtitle: '',
                rating: 4.80,
                reviewCount: '320K',
                imageAsset: Images.facialGold,
              ),
              HandymanServiceOption(
                id: 'facial_3',
                title: 'De-tan Facial',
                originalPrice: 499,
                discountedPrice: 499,
                discountText: '',
                subtitle: '',
                rating: 4.72,
                reviewCount: '190K',
                imageAsset: Images.facialDetan,
              ),
              HandymanServiceOption(
                id: 'facial_4',
                title: 'Herbal Facial',
                originalPrice: 449,
                discountedPrice: 449,
                discountText: '',
                subtitle: '',
                rating: 4.78,
                reviewCount: '120K',
                imageAsset: Images.facialHerbal,
              ),
              HandymanServiceOption(
                id: 'facial_5',
                title: 'Glow Facial',
                originalPrice: 549,
                discountedPrice: 549,
                discountText: '',
                subtitle: '',
                rating: 4.82,
                reviewCount: '210K',
                imageAsset: Images.facialGlow,
              ),
            ],
          ),
          HandymanServiceModel(
            id: 'full_arms_waxing',
            name: 'Full Arms Waxing',
            category: "Women's Salon & Spa",
            rating: 4.82,
            reviewCount: '980K',
            startingPrice: 149,
            optionsCount: 0,
            imageAsset: Images.handymanWaxing,
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
            imageAsset: Images.acDeepClean,
          ),
          HandymanServiceModel(
            id: 'ac_install',
            name: 'AC Installation',
            category: "AC Repair",
            rating: 4.68,
            reviewCount: '340K',
            startingPrice: 1500,
            optionsCount: 0,
            imageAsset: Images.acInstallation,
          ),
          HandymanServiceModel(
            id: 'geyser_repair',
            name: 'Geyser Repair',
            category: "Appliance Repair",
            rating: 4.65,
            reviewCount: '210K',
            startingPrice: 399,
            optionsCount: 0,
            imageAsset: Images.geyserRepair,
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
    _updateListWithNested(serviceId, (s) {
      s.cartQuantity++;
      // If there's only one option, automatically increment its quantity too
      if (s.options.length == 1) {
        s.options[0].quantity++;
      }
    });
  }

  void removeFromCart(String serviceId) {
    _updateListWithNested(serviceId, (s) {
      if (s.cartQuantity > 0) s.cartQuantity--;
      if (s.options.length == 1 && s.options[0].quantity > 0) {
        s.options[0].quantity--;
      }
    });
  }

  void addOptionToCart(String serviceId, String optionId) {
    _updateListWithNested(serviceId, (s) {
      s.cartQuantity++;
      final opt = s.options.firstWhereOrNull((o) => o.id == optionId);
      if (opt != null) {
        opt.quantity++;
      }
    });
  }

  void removeOptionFromCart(String serviceId, String optionId) {
    _updateListWithNested(serviceId, (s) {
      final opt = s.options.firstWhereOrNull((o) => o.id == optionId);
      if (opt != null && opt.quantity > 0) {
        opt.quantity--;
        if (s.cartQuantity > 0) s.cartQuantity--;
      }
    });
  }

  void clearCart() {
    for (final s in mostBookedServices) {
      s.cartQuantity = 0;
      for (final o in s.options) {
        o.quantity = 0;
      }
    }
    for (final section in categorySections) {
      for (final s in section.services) {
        s.cartQuantity = 0;
        for (final o in s.options) {
          o.quantity = 0;
        }
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
