import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_booking_model.dart';
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
  // ─── Master State ──────────────────────────────────────────────────────────
  final RxMap<String, HandymanServiceModel> allServices =
      <String, HandymanServiceModel>{}.obs;

  // ─── UI References ─────────────────────────────────────────────────────────
  final RxList<HandymanServiceModel> mostBookedServices =
      <HandymanServiceModel>[].obs;
  final RxList<CategorySectionModel> categorySections =
      <CategorySectionModel>[].obs;
  final RxList<HandymanBookingModel> bookings = <HandymanBookingModel>[].obs;

  final RxBool isLoading = false.obs;

  // ─── Derived ─────────────────────────────────────────────────────────────────
  int get totalCartItems {
    int total = 0;
    for (final s in allServices.values) {
      total += s.cartQuantity;
    }
    return total;
  }

  int getServiceQuantity(String serviceId) {
    return allServices[serviceId]?.cartQuantity ?? 0;
  }

  List<HandymanServiceModel> get wishlistedServices {
    return allServices.values.where((s) => s.isWishlisted).toList();
  }

  List<HandymanServiceModel> get cartServices {
    return allServices.values.where((s) => s.cartQuantity > 0).toList();
  }

  int get cartTotalPrice {
    int total = 0;
    for (final s in cartServices) {
      total += s.startingPrice * s.cartQuantity;
    }
    return total;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────────
  void toggleWishlist(String serviceId) {
    final s = allServices[serviceId];
    if (s != null) {
      s.isWishlisted = !s.isWishlisted;
      _refreshAll();
    }
  }

  void addToCart(String serviceId) {
    final s = allServices[serviceId];
    if (s != null) {
      s.cartQuantity++;
      if (s.options.length == 1) {
        s.options[0].quantity++;
      }
      _refreshAll();
    }
  }

  void removeFromCart(String serviceId) {
    final s = allServices[serviceId];
    if (s != null && s.cartQuantity > 0) {
      s.cartQuantity--;
      if (s.options.length == 1 && s.options[0].quantity > 0) {
        s.options[0].quantity--;
      }
      _refreshAll();
    }
  }

  void addServiceToCart(String serviceId) {
    addToCart(serviceId);
  }

  void removeServiceFromCart(String serviceId) {
    removeFromCart(serviceId);
  }

  void addOptionToCart(String serviceId, String optionId) {
    final s = allServices[serviceId];
    if (s != null) {
      s.cartQuantity++;
      final opt = s.options.firstWhereOrNull((o) => o.id == optionId);
      if (opt != null) {
        opt.quantity++;
      }
      _refreshAll();
    }
  }

  void removeOptionFromCart(String serviceId, String optionId) {
    final s = allServices[serviceId];
    if (s != null) {
      final opt = s.options.firstWhereOrNull((o) => o.id == optionId);
      if (opt != null && opt.quantity > 0) {
        opt.quantity--;
        if (s.cartQuantity > 0) s.cartQuantity--;
      }
      _refreshAll();
    }
  }

  void clearCart() {
    for (final s in allServices.values) {
      s.cartQuantity = 0;
      for (final o in s.options) {
        o.quantity = 0;
      }
    }
    _refreshAll();
  }

  void _refreshAll() {
    allServices.refresh();
    mostBookedServices.refresh();
    categorySections.refresh();
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
    _initializeMasterServices();
    _loadMostBookedServices();
    _loadCategoryServices();
    _loadBookings();
    isLoading.value = false;
  }

  void _initializeMasterServices() {
    final Map<String, HandymanServiceModel> master = {};

    void add(HandymanServiceModel s) {
      master[s.id] = s;
    }

    // 1. Home / popular services
    add(HandymanServiceModel(
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
    ));

    add(HandymanServiceModel(
      id: 'women_salon',
      name: "Women's Salon Classic",
      category: "Women's Salon & Spa",
      rating: 4.76,
      reviewCount: '1.8M',
      startingPrice: 449,
      optionsCount: 0,
      imageAsset: Images.handymanWomenSalon,
    ));

    add(HandymanServiceModel(
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
    ));

    add(HandymanServiceModel(
      id: 'tools_plumb',
      name: 'Plumbing Service',
      category: 'Electrician & Plumber',
      rating: 4.65,
      reviewCount: '890K',
      startingPrice: 199,
      optionsCount: 0,
      imageAsset: Images.kitchenSink,
    ));

    add(HandymanServiceModel(
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
    ));

    add(HandymanServiceModel(
      id: 'painting',
      name: 'Home Painting',
      category: 'Painting & Waterproofing',
      rating: 4.58,
      reviewCount: '540K',
      startingPrice: 599,
      optionsCount: 0,
      imageAsset: Images.handymanPainting,
    ));

    add(HandymanServiceModel(
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
    ));

    // 2. Category specific services
    add(HandymanServiceModel(
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
    ));

    add(HandymanServiceModel(
      id: 'head_massage',
      name: 'Head massage',
      category: "Women's Salon & Spa",
      rating: 4.87,
      reviewCount: '194K',
      startingPrice: 199,
      optionsCount: 0,
      imageAsset: Images.handymanHeadMassage,
    ));

    add(HandymanServiceModel(
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
    ));

    add(HandymanServiceModel(
      id: 'full_arms_waxing',
      name: 'Full Arms Waxing',
      category: "Women's Salon & Spa",
      rating: 4.82,
      reviewCount: '980K',
      startingPrice: 149,
      optionsCount: 0,
      imageAsset: Images.handymanWaxing,
    ));

    add(HandymanServiceModel(
      id: 'ac_service',
      name: 'AC Service',
      category: "AC Repair",
      rating: 4.80,
      reviewCount: '2.6M',
      startingPrice: 499,
      optionsCount: 0,
      imageAsset: Images.handymanAc,
    ));

    add(HandymanServiceModel(
      id: 'ac_deep_clean',
      name: 'AC Deep Clean',
      category: "AC Repair",
      rating: 4.72,
      reviewCount: '890K',
      startingPrice: 899,
      optionsCount: 0,
      imageAsset: Images.acDeepClean,
    ));

    add(HandymanServiceModel(
      id: 'ac_install',
      name: 'AC Installation',
      category: "AC Repair",
      rating: 4.68,
      reviewCount: '340K',
      startingPrice: 1500,
      optionsCount: 0,
      imageAsset: Images.acInstallation,
    ));

    add(HandymanServiceModel(
      id: 'geyser_repair',
      name: 'Geyser Repair',
      category: "Appliance Repair",
      rating: 4.65,
      reviewCount: '210K',
      startingPrice: 399,
      optionsCount: 0,
      imageAsset: Images.geyserRepair,
    ));

    // 3. Additional services from subcategories screen
    add(HandymanServiceModel(
      id: 'emergency_electrician',
      name: 'Emergency Electrician',
      category: 'InstaHelp',
      rating: 4.85,
      reviewCount: '1.2K',
      startingPrice: 399,
      optionsCount: 0,
      imageAsset: Images.handymanElectricianBanner,
    ));

    add(HandymanServiceModel(
      id: 'urgent_lockout',
      name: 'Urgent Lockout Service',
      category: 'InstaHelp',
      rating: 4.90,
      reviewCount: '800',
      startingPrice: 599,
      optionsCount: 0,
      imageAsset: Images.handymanLocksmith,
    ));

    add(HandymanServiceModel(
      id: 'threading_waxing_eyebrow',
      name: 'Eyebrow & Upper Lip Threading',
      category: "Women's Salon & Spa",
      rating: 4.85,
      reviewCount: '2.8M',
      startingPrice: 59,
      optionsCount: 0,
      imageAsset: Images.handymanThreading,
    ));

    add(HandymanServiceModel(
      id: 'skin_brightening_facial',
      name: 'Skin Brightening Facial',
      category: "Women's Salon & Spa",
      rating: 4.74,
      reviewCount: '17K',
      startingPrice: 1399,
      optionsCount: 0,
      imageAsset: Images.handymanFacial,
    ));

    add(HandymanServiceModel(
      id: 'men_haircut_styling',
      name: "Men's Haircut & Styling",
      category: "Men's Salon & Massage",
      rating: 4.71,
      reviewCount: '760K',
      startingPrice: 299,
      optionsCount: 0,
      imageAsset: Images.handymanMenSalon,
    ));

    add(HandymanServiceModel(
      id: 'beard_styling_trim',
      name: 'Beard Styling & Trim',
      category: "Men's Salon & Massage",
      rating: 4.65,
      reviewCount: '120K',
      startingPrice: 149,
      optionsCount: 0,
      imageAsset: Images.handymanMenSalon,
    ));

    add(HandymanServiceModel(
      id: 'stress_relief_massage',
      name: 'Stress Relief Head Massage',
      category: "Men's Salon & Massage",
      rating: 4.80,
      reviewCount: '90K',
      startingPrice: 199,
      optionsCount: 0,
      imageAsset: Images.handymanMenSalon,
    ));

    add(HandymanServiceModel(
      id: 'intense_bathroom_cleaning',
      name: 'Intense bathroom cleaning',
      category: 'Cleaning & Pest Control',
      rating: 4.80,
      reviewCount: '6.7M',
      startingPrice: 549,
      optionsCount: 0,
      imageAsset: Images.intenseBathroom,
    ));

    add(HandymanServiceModel(
      id: 'bathroom_kitchen_cleaning',
      name: 'Bathroom & kitchen cleaning',
      category: 'Cleaning & Pest Control',
      rating: 4.75,
      reviewCount: '1.2M',
      startingPrice: 899,
      optionsCount: 0,
      imageAsset: Images.bathroomSink,
    ));

    add(HandymanServiceModel(
      id: 'complete_kitchen_cleaning',
      name: 'Complete kitchen cleaning',
      category: 'Cleaning & Pest Control',
      rating: 4.85,
      reviewCount: '450K',
      startingPrice: 1299,
      optionsCount: 0,
      imageAsset: Images.kitchenCleaning,
    ));

    add(HandymanServiceModel(
      id: 'kitchen_sink_cleaning',
      name: 'Kitchen sink cleaning',
      category: 'Cleaning & Pest Control',
      rating: 4.65,
      reviewCount: '89K',
      startingPrice: 199,
      optionsCount: 0,
      imageAsset: Images.kitchenSink,
    ));

    add(HandymanServiceModel(
      id: 'sofa_deep_cleaning',
      name: 'Sofa deep cleaning',
      category: 'Cleaning & Pest Control',
      rating: 4.76,
      reviewCount: '2.6M',
      startingPrice: 699,
      optionsCount: 0,
      imageAsset: Images.sofaClean,
    ));

    add(HandymanServiceModel(
      id: 'carpet_deep_cleaning',
      name: 'Carpet deep cleaning',
      category: 'Cleaning & Pest Control',
      rating: 4.72,
      reviewCount: '890K',
      startingPrice: 499,
      optionsCount: 0,
      imageAsset: Images.sofaClean,
    ));

    add(HandymanServiceModel(
      id: 'furnished_apartment_deep_cleaning',
      name: 'Furnished apartment deep clean',
      category: 'Cleaning & Pest Control',
      rating: 4.80,
      reviewCount: '571K',
      startingPrice: 3499,
      optionsCount: 0,
      imageAsset: Images.furnishedApartment,
    ));

    add(HandymanServiceModel(
      id: 'unfurnished_home_deep_clean',
      name: 'Unfurnished home deep clean',
      category: 'Cleaning & Pest Control',
      rating: 4.70,
      reviewCount: '120K',
      startingPrice: 2499,
      optionsCount: 0,
      imageAsset: Images.houseClean,
    ));

    add(HandymanServiceModel(
      id: 'ant_control_kitchen_bathroom',
      name: 'Ant control – kitchen/bathroom',
      category: 'Cleaning & Pest Control',
      rating: 5.0,
      reviewCount: '22',
      startingPrice: 1249,
      optionsCount: 0,
      imageAsset: Images.antControl,
    ));

    add(HandymanServiceModel(
      id: 'cockroach_pest_control',
      name: 'Cockroach & general pest control',
      category: 'Cleaning & Pest Control',
      rating: 4.82,
      reviewCount: '140K',
      startingPrice: 999,
      optionsCount: 0,
      imageAsset: Images.antControl,
    ));

    add(HandymanServiceModel(
      id: 'painting_wall_touchups',
      name: 'Wall Touch-ups',
      category: 'Painting & Water - proofing',
      rating: 4.58,
      reviewCount: '540K',
      startingPrice: 599,
      optionsCount: 0,
      imageAsset: Images.handymanPainting,
    ));

    add(HandymanServiceModel(
      id: 'painting_full_room',
      name: 'Full Room Painting',
      category: 'Painting & Water - proofing',
      rating: 4.75,
      reviewCount: '85K',
      startingPrice: 2999,
      optionsCount: 0,
      imageAsset: Images.handymanPainting,
    ));

    add(HandymanServiceModel(
      id: 'waterproofing_wall',
      name: 'Wall Waterproofing',
      category: 'Painting & Water - proofing',
      rating: 4.60,
      reviewCount: '30K',
      startingPrice: 1499,
      optionsCount: 0,
      imageAsset: Images.handymanPainting,
    ));

    add(HandymanServiceModel(
      id: 'sink_repair',
      name: 'Sink Repair',
      category: 'Electrician, Plumber & Carpenter',
      rating: 4.70,
      reviewCount: '50K',
      startingPrice: 299,
      optionsCount: 0,
      imageAsset: Images.bathroomSink,
    ));

    add(HandymanServiceModel(
      id: 'switchboard_install',
      name: 'Switchboard Installation',
      category: 'Electrician, Plumber & Carpenter',
      rating: 4.80,
      reviewCount: '120K',
      startingPrice: 149,
      optionsCount: 0,
      imageAsset: Images.handymanElectricianBanner,
    ));

    add(HandymanServiceModel(
      id: 'furniture_assembly',
      name: 'Furniture Assembly',
      category: 'Electrician, Plumber & Carpenter',
      rating: 4.75,
      reviewCount: '95K',
      startingPrice: 399,
      optionsCount: 0,
      imageAsset: Images.handymanTools,
    ));

    add(HandymanServiceModel(
      id: 'cctv_install',
      name: 'CCTV Installation',
      category: 'CCTV & Smart Home',
      rating: 4.81,
      reviewCount: '320K',
      startingPrice: 899,
      optionsCount: 0,
      imageAsset: Images.handymanCctv,
    ));

    add(HandymanServiceModel(
      id: 'smart_lock_setup',
      name: 'Smart Lock Setup',
      category: 'CCTV & Smart Home',
      rating: 4.85,
      reviewCount: '12K',
      startingPrice: 1299,
      optionsCount: 0,
      imageAsset: Images.handymanCctv,
    ));

    add(HandymanServiceModel(
      id: 'lawn_mowing_trim',
      name: 'Lawn Mowing & Trim',
      category: 'Gardening & Lawn Care',
      rating: 4.82,
      reviewCount: '2K',
      startingPrice: 349,
      optionsCount: 0,
      imageAsset: Images.handymanGardening,
    ));

    add(HandymanServiceModel(
      id: 'weed_removal',
      name: 'Weed Removal',
      category: 'Gardening & Lawn Care',
      rating: 4.75,
      reviewCount: '1.5K',
      startingPrice: 299,
      optionsCount: 0,
      imageAsset: Images.handymanGardening,
    ));

    add(HandymanServiceModel(
      id: 'bathroom_renovation',
      name: 'Bathroom Renovation',
      category: 'Home Renovation',
      rating: 4.90,
      reviewCount: '800',
      startingPrice: 9999,
      optionsCount: 0,
      imageAsset: Images.handymanRenovation,
    ));

    add(HandymanServiceModel(
      id: 'modular_kitchen',
      name: 'Modular Kitchen Setup',
      category: 'Home Renovation',
      rating: 4.85,
      reviewCount: '500',
      startingPrice: 14999,
      optionsCount: 0,
      imageAsset: Images.handymanRenovation,
    ));

    add(HandymanServiceModel(
      id: 'tv_installation',
      name: 'Wall Mount TV Installation',
      category: 'TV Mount & Setup',
      rating: 4.80,
      reviewCount: '8K',
      startingPrice: 299,
      optionsCount: 0,
      imageAsset: Images.handymanTvmount,
    ));

    add(HandymanServiceModel(
      id: 'key_duplication',
      name: 'Key Duplication',
      category: 'Locksmith & Key Maker',
      rating: 4.78,
      reviewCount: '1.5K',
      startingPrice: 99,
      optionsCount: 0,
      imageAsset: Images.handymanLocksmith,
    ));

    allServices.assignAll(master);
  }

  void _loadMostBookedServices() {
    mostBookedServices.assignAll([
      allServices['ac_repair']!,
      allServices['women_salon']!,
      allServices['cleaning']!,
      allServices['tools_plumb']!,
      allServices['men_salon']!,
      allServices['painting']!,
      allServices['cctv']!,
    ]);
  }

  void _loadCategoryServices() {
    categorySections.assignAll([
      CategorySectionModel(
        title: 'Salon for Women',
        subtitle: 'Pamper yourself at home',
        services: [
          allServices['threading']!,
          allServices['head_massage']!,
          allServices['facial']!,
          allServices['full_arms_waxing']!,
        ],
      ),
      CategorySectionModel(
        title: 'AC & Appliance Repair',
        subtitle: 'Expert technicians at your doorstep',
        services: [
          allServices['ac_service']!,
          allServices['ac_deep_clean']!,
          allServices['ac_install']!,
          allServices['geyser_repair']!,
        ],
      ),
      CategorySectionModel(
        title: 'Cleaning & Pest Control',
        subtitle: 'Professional cleaning & sanitization',
        services: [
          allServices['complete_kitchen_cleaning']!,
          allServices['sofa_deep_cleaning']!,
          allServices['intense_bathroom_cleaning']!,
          allServices['cockroach_pest_control']!,
        ],
      ),
      CategorySectionModel(
        title: 'Electrician, Plumber & Carpenter',
        subtitle: 'Expert home repair & installation',
        services: [
          allServices['tools_plumb']!,
          allServices['sink_repair']!,
          allServices['switchboard_install']!,
          allServices['furniture_assembly']!,
        ],
      ),
    ]);
  }

  void _loadBookings() {
    bookings.assignAll([
      HandymanBookingModel(
        id: '100138',
        serviceName: 'Rent Ambulance',
        bookingDate: DateTime(2026, 6, 2, 16, 57),
        serviceDate: DateTime(2026, 6, 2, 16, 59),
        price: 11340.0,
        status: 'Pending',
        tasks: ['Ambulance with life support', 'Emergency ambulance'],
        timeSlot: '04:59 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Rent Ambulance',
            variantName: 'Ambulance with life support',
            quantity: 1,
            unitPrice: 8000.0,
          ),
          HandymanBookingItem(
            title: 'Rent Ambulance',
            variantName: 'Emergency ambulance',
            quantity: 1,
            unitPrice: 3000.0,
          ),
        ],
        subTotal: 11000.0,
        vat: 330.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100137',
        serviceName: 'Eyebrow & Upper Lip Threading',
        bookingDate: DateTime(2026, 6, 1, 17, 11),
        serviceDate: DateTime(2026, 6, 1, 17, 12),
        price: 938.0,
        status: 'Pending',
        tasks: ['Eyebrow threading', 'Upper lip threading'],
        timeSlot: '05:12 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Threading',
            variantName: 'Eyebrow threading',
            quantity: 1,
            unitPrice: 500.0,
          ),
          HandymanBookingItem(
            title: 'Threading',
            variantName: 'Upper lip threading',
            quantity: 1,
            unitPrice: 400.0,
          ),
        ],
        subTotal: 900.0,
        vat: 28.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100136',
        serviceName: 'Emergency Electrician',
        bookingDate: DateTime(2026, 5, 31, 10, 0),
        serviceDate: DateTime(2026, 5, 31, 11, 30),
        price: 150.0,
        status: 'Accepted',
        tasks: ['Switchboard repair'],
        timeSlot: '11:30 AM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Handy Wallet',
        paymentStatus: 'Paid',
        items: [
          HandymanBookingItem(
            title: 'Emergency Electrician',
            variantName: 'Switchboard repair',
            quantity: 1,
            unitPrice: 135.0,
          ),
        ],
        subTotal: 135.0,
        vat: 5.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100135',
        serviceName: 'Home Painting',
        bookingDate: DateTime(2026, 5, 30, 14, 0),
        serviceDate: DateTime(2026, 5, 30, 15, 0),
        price: 699.0,
        status: 'Ongoing',
        tasks: ['Wall touchup'],
        timeSlot: '03:00 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Home Painting',
            variantName: 'Wall touchup',
            quantity: 1,
            unitPrice: 669.0,
          ),
        ],
        subTotal: 669.0,
        vat: 20.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100134',
        serviceName: "Men's Haircut & Styling",
        bookingDate: DateTime(2026, 5, 29, 9, 0),
        serviceDate: DateTime(2026, 5, 29, 10, 0),
        price: 299.0,
        status: 'Completed',
        tasks: ['Haircut', 'Hair styling'],
        timeSlot: '10:00 AM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Handy Wallet',
        paymentStatus: 'Paid',
        items: [
          HandymanBookingItem(
            title: 'Haircut',
            variantName: 'Men\'s Haircut',
            quantity: 1,
            unitPrice: 150.0,
          ),
          HandymanBookingItem(
            title: 'Styling',
            variantName: 'Hair styling',
            quantity: 1,
            unitPrice: 120.0,
          ),
        ],
        subTotal: 270.0,
        vat: 19.0,
        fee: 10.0,
      ),
      HandymanBookingModel(
        id: '100133',
        serviceName: 'Urgent Lockout Service',
        bookingDate: DateTime(2026, 5, 28, 16, 0),
        serviceDate: DateTime(2026, 5, 28, 17, 0),
        price: 199.0,
        status: 'Cancelled',
        tasks: ['Door lock opening'],
        timeSlot: '05:00 PM',
        address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
        paymentMethod: 'Cash after service',
        paymentStatus: 'Unpaid',
        items: [
          HandymanBookingItem(
            title: 'Lockout Service',
            variantName: 'Door lock opening',
            quantity: 1,
            unitPrice: 180.0,
          ),
        ],
        subTotal: 180.0,
        vat: 9.0,
        fee: 10.0,
      ),
    ]);
  }

  void placeBooking({
    required String serviceName,
    required double price,
    required DateTime serviceDate,
    required List<String> tasks,
    required String timeSlot,
  }) {
    final nextNum = bookings.isEmpty ? 100139 : int.parse(bookings.first.id) + 1;
    final double calculatedSubTotal = price * 0.9;
    final double calculatedVat = price * 0.03;
    final double calculatedFee = price - calculatedSubTotal - calculatedVat;

    final newBooking = HandymanBookingModel(
      id: nextNum.toString(),
      serviceName: serviceName,
      bookingDate: DateTime.now(),
      serviceDate: serviceDate,
      price: price,
      status: 'Pending',
      tasks: tasks,
      timeSlot: timeSlot,
      address: 'Q93Q+GC2, Green Rd, Dhaka 1215, Bangladesh',
      paymentMethod: 'Cash after service',
      paymentStatus: 'Unpaid',
      items: tasks.map((t) => HandymanBookingItem(
        title: serviceName,
        variantName: t,
        quantity: 1,
        unitPrice: calculatedSubTotal / (tasks.isEmpty ? 1 : tasks.length),
      )).toList(),
      subTotal: calculatedSubTotal,
      vat: calculatedVat,
      fee: calculatedFee,
    );
    bookings.insert(0, newBooking);
  }
}
