import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_services_screen.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';

class HandymanServiceItem {
  final String id;
  final String title;
  final String description;
  final double rating;
  final String reviews;
  final int price;
  final String imageAsset;
  final int optionsCount;

  HandymanServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageAsset,
    this.optionsCount = 0,
  });
}

class SubCategoryModel {
  final String name;
  final List<HandymanServiceItem> services;

  SubCategoryModel({
    required this.name,
    required this.services,
  });
}

class HandymanAvailableServicesScreen extends StatefulWidget {
  const HandymanAvailableServicesScreen({super.key});

  @override
  State<HandymanAvailableServicesScreen> createState() => _HandymanAvailableServicesScreenState();
}

class _HandymanAvailableServicesScreenState extends State<HandymanAvailableServicesScreen> {
  String _activeCategoryName = 'Cleaning & Pest Control';
  String _activeSubCategoryName = '';
  final Set<String> _wishlistedServiceIds = <String>{};

  final Map<String, List<SubCategoryModel>> _categorySubCategories = {
    'InstaHelp': [
      SubCategoryModel(
        name: 'Emergency Repair',
        services: [
          HandymanServiceItem(
            id: 'emergency_electrician',
            title: 'Emergency Electrician',
            price: 399,
            rating: 4.85,
            reviews: '1.2K',
            imageAsset: Images.handymanElectricianBanner,
            description: 'Quick response emergency troubleshooting, wiring repair, short circuit fixes.',
          ),
          HandymanServiceItem(
            id: 'urgent_lockout',
            title: 'Urgent Lockout Service',
            price: 599,
            rating: 4.90,
            reviews: '800',
            imageAsset: Images.handymanLocksmith,
            description: '24/7 home lockout assistance, lock picking, and quick key duplicating.',
          ),
        ],
      ),
    ],
    "Women's Salon & Spa": [
      SubCategoryModel(
        name: 'Threading & Waxing',
        services: [
          HandymanServiceItem(
            id: 'threading_waxing_eyebrow',
            title: 'Eyebrow & Upper Lip Threading',
            price: 59,
            rating: 4.85,
            reviews: '2.8M',
            imageAsset: Images.handymanThreading,
            description: 'Precise threading service for eyebrows and upper lip.',
          ),
          HandymanServiceItem(
            id: 'full_arms_waxing',
            title: 'Full Arms Waxing',
            price: 149,
            rating: 4.82,
            reviews: '980K',
            imageAsset: Images.handymanWaxing,
            description: 'Smooth waxing for arms using premium honey wax.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Facial & Massage',
        services: [
          HandymanServiceItem(
            id: 'skin_brightening_facial',
            title: 'Skin Brightening Facial',
            price: 1399,
            rating: 4.74,
            reviews: '17K',
            imageAsset: Images.handymanFacial,
            description: 'Premium fruit/gold facial pack for skin glow and rejuvenation.',
          ),
          HandymanServiceItem(
            id: 'head_massage',
            title: 'Head Massage',
            price: 199,
            rating: 4.87,
            reviews: '194K',
            imageAsset: Images.handymanHeadMassage,
            description: 'Relaxing head massage with coconut/amla oil.',
          ),
        ],
      ),
    ],
    "Men's Salon & Massage": [
      SubCategoryModel(
        name: 'Haircut & Grooming',
        services: [
          HandymanServiceItem(
            id: 'men_haircut_styling',
            title: "Men's Haircut & Styling",
            price: 299,
            rating: 4.71,
            reviews: '760K',
            imageAsset: Images.handymanMenSalon,
            description: 'Professional haircut, hair wash, and blowdry styling.',
          ),
          HandymanServiceItem(
            id: 'beard_styling_trim',
            title: 'Beard Styling & Trim',
            price: 149,
            rating: 4.65,
            reviews: '120K',
            imageAsset: Images.handymanMenSalon,
            description: 'Beard trimming and shaping with razor finish.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Massage & Relief',
        services: [
          HandymanServiceItem(
            id: 'stress_relief_massage',
            title: 'Stress Relief Head Massage',
            price: 199,
            rating: 4.80,
            reviews: '90K',
            imageAsset: Images.handymanMenSalon,
            description: 'Acupressure head massage to relieve tension and stress.',
          ),
        ],
      ),
    ],
    'Cleaning & Pest Control': [
      SubCategoryModel(
        name: 'Bathroom cleaning',
        services: [
          HandymanServiceItem(
            id: 'intense_bathroom_cleaning',
            title: 'Intense bathroom cleaning',
            price: 549,
            rating: 4.80,
            reviews: '6.7M',
            imageAsset: Images.intenseBathroom,
            description: 'Intense descaling, scrubbing and sanitization of bathroom.',
          ),
          HandymanServiceItem(
            id: 'bathroom_kitchen_cleaning',
            title: 'Bathroom & kitchen cleaning',
            price: 899,
            rating: 4.75,
            reviews: '1.2M',
            imageAsset: Images.bathroomSink,
            description: 'Deep cleaning of bathroom floor, wall tiles, kitchen sink, and slab.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Complete kitchen cleaning',
        services: [
          HandymanServiceItem(
            id: 'complete_kitchen_cleaning',
            title: 'Complete kitchen cleaning',
            price: 1299,
            rating: 4.85,
            reviews: '450K',
            imageAsset: Images.kitchenCleaning,
            description: 'Deep cleaning of cabinets, counter, tiles, stove and chimney.',
          ),
          HandymanServiceItem(
            id: 'kitchen_sink_cleaning',
            title: 'Kitchen sink cleaning',
            price: 199,
            rating: 4.65,
            reviews: '89K',
            imageAsset: Images.kitchenSink,
            description: 'Thorough scaling and rust removal for kitchen sinks.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Sofa & Carpet Cleaning',
        services: [
          HandymanServiceItem(
            id: 'sofa_deep_cleaning',
            title: 'Sofa deep cleaning',
            price: 699,
            rating: 4.76,
            reviews: '2.6M',
            imageAsset: Images.sofaClean,
            description: 'Deep vacuuming, shampooing and stain extraction for sofas.',
          ),
          HandymanServiceItem(
            id: 'carpet_deep_cleaning',
            title: 'Carpet deep cleaning',
            price: 499,
            rating: 4.72,
            reviews: '890K',
            imageAsset: Images.sofaClean,
            description: 'Thorough sanitization and wash for carpets and rugs.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Full Home Cleaning',
        services: [
          HandymanServiceItem(
            id: 'furnished_apartment_deep_cleaning',
            title: 'Furnished apartment deep clean',
            price: 3499,
            rating: 4.80,
            reviews: '571K',
            imageAsset: Images.furnishedApartment,
            description: 'Complete dusting, mopping and deep cleaning of furnished homes.',
          ),
          HandymanServiceItem(
            id: 'unfurnished_home_deep_clean',
            title: 'Unfurnished home deep clean',
            price: 2499,
            rating: 4.70,
            reviews: '120K',
            imageAsset: Images.houseClean,
            description: 'Complete vacuuming, scrubbing and window cleaning for empty flats.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Ant & Pest Control',
        services: [
          HandymanServiceItem(
            id: 'ant_control_kitchen_bathroom',
            title: 'Ant control – kitchen/bathroom',
            price: 1249,
            rating: 5.0,
            reviews: '22',
            imageAsset: Images.antControl,
            description: 'Safe gel treatment with utensil removal, completely odorless.',
          ),
          HandymanServiceItem(
            id: 'cockroach_pest_control',
            title: 'Cockroach & general pest control',
            price: 999,
            rating: 4.82,
            reviews: '140K',
            imageAsset: Images.antControl,
            description: 'Spray and gel treatment to eliminate cockroaches and bugs.',
          ),
        ],
      ),
    ],
    'Painting & Water - proofing': [
      SubCategoryModel(
        name: 'Home Painting',
        services: [
          HandymanServiceItem(
            id: 'painting_wall_touchups',
            title: 'Wall Touch-ups',
            price: 599,
            rating: 4.58,
            reviews: '540K',
            imageAsset: Images.handymanPainting,
            description: 'Quick and clean patching and paint touch-ups for wall damages.',
          ),
          HandymanServiceItem(
            id: 'painting_full_room',
            title: 'Full Room Painting',
            price: 2999,
            rating: 4.75,
            reviews: '85K',
            imageAsset: Images.handymanPainting,
            description: 'Complete painting of walls and ceilings with premium colors.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Waterproofing',
        services: [
          HandymanServiceItem(
            id: 'waterproofing_wall',
            title: 'Wall Waterproofing',
            price: 1499,
            rating: 4.60,
            reviews: '30K',
            imageAsset: Images.handymanPainting,
            description: 'Professional waterproofing treatment to stop wall dampness.',
          ),
        ],
      ),
    ],
    'AC & Appliance Repair': [
      SubCategoryModel(
        name: 'AC Service',
        services: [
          HandymanServiceItem(
            id: 'ac_repair',
            title: 'Foam-jet AC service',
            price: 699,
            rating: 4.76,
            reviews: '2.6M',
            imageAsset: Images.handymanAc,
            description: 'Thorough filter cleaning, gas refill check, and foam diagnostic.',
          ),
          HandymanServiceItem(
            id: 'ac_deep_clean',
            title: 'AC Deep Clean',
            price: 899,
            rating: 4.72,
            reviews: '890K',
            imageAsset: Images.acDeepClean,
            description: 'Thorough filter and coil jet cleaning.',
          ),
          HandymanServiceItem(
            id: 'ac_install',
            title: 'AC Installation',
            price: 1500,
            rating: 4.68,
            reviews: '340K',
            imageAsset: Images.acInstallation,
            description: 'Professional AC unit installation and mounting.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Appliance Repair',
        services: [
          HandymanServiceItem(
            id: 'geyser_repair',
            title: 'Geyser Service & Repair',
            price: 399,
            rating: 4.65,
            reviews: '210K',
            imageAsset: Images.geyserClean,
            description: 'Expert repair and water heating diagnosis for geysers.',
          ),
        ],
      ),
    ],
    'Electrician, Plumber & Carpenter': [
      SubCategoryModel(
        name: 'Plumbing',
        services: [
          HandymanServiceItem(
            id: 'tools_plumb',
            title: 'Plumbing Checkup Service',
            price: 199,
            rating: 4.65,
            reviews: '890K',
            imageAsset: Images.kitchenSink,
            description: 'We are well-equipped and well-prepared to check your plumbing problems.',
          ),
          HandymanServiceItem(
            id: 'sink_repair',
            title: 'Sink Repair',
            price: 299,
            rating: 4.70,
            reviews: '50K',
            imageAsset: Images.bathroomSink,
            description: 'We are well-equipped and well-prepared to repair your sink.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Electrical',
        services: [
          HandymanServiceItem(
            id: 'switchboard_install',
            title: 'Switchboard Installation',
            price: 149,
            rating: 4.80,
            reviews: '120K',
            imageAsset: Images.handymanElectricianBanner,
            description: 'Installation/replacement of switches and boards.',
          ),
        ],
      ),
      SubCategoryModel(
        name: 'Carpentry',
        services: [
          HandymanServiceItem(
            id: 'furniture_assembly',
            title: 'Furniture Assembly',
            price: 399,
            rating: 4.75,
            reviews: '95K',
            imageAsset: Images.handymanTools,
            description: 'Professional carpentry assembly services.',
          ),
        ],
      ),
    ],
    'CCTV & Smart Home': [
      SubCategoryModel(
        name: 'Smart Solutions',
        services: [
          HandymanServiceItem(
            id: 'cctv_install',
            title: 'CCTV Installation',
            price: 899,
            rating: 4.81,
            reviews: '320K',
            imageAsset: Images.handymanCctv,
            description: 'Secure your home with professional CCTV installation and setup.',
          ),
          HandymanServiceItem(
            id: 'smart_lock_setup',
            title: 'Smart Lock Setup',
            price: 1299,
            rating: 4.85,
            reviews: '12K',
            imageAsset: Images.handymanCctv,
            description: 'Install and configure keyless smart lock entry systems.',
          ),
        ],
      ),
    ],
    'Gardening & Lawn Care': [
      SubCategoryModel(
        name: 'Garden Maintenance',
        services: [
          HandymanServiceItem(
            id: 'lawn_mowing_trim',
            title: 'Lawn Mowing & Trim',
            price: 349,
            rating: 4.82,
            reviews: '2K',
            imageAsset: Images.handymanGardening,
            description: 'Professional grass cutting, edging, and garden cleanup.',
          ),
          HandymanServiceItem(
            id: 'weed_removal',
            title: 'Weed Removal',
            price: 299,
            rating: 4.75,
            reviews: '1.5K',
            imageAsset: Images.handymanGardening,
            description: 'Safe weed spraying, root extraction, and soil treatment.',
          ),
        ],
      ),
    ],
    'Home Renovation': [
      SubCategoryModel(
        name: 'Renovation Services',
        services: [
          HandymanServiceItem(
            id: 'bathroom_renovation',
            title: 'Bathroom Renovation',
            price: 9999,
            rating: 4.90,
            reviews: '800',
            imageAsset: Images.handymanRenovation,
            description: 'Complete remodel of tiles, fixtures, and piping.',
          ),
          HandymanServiceItem(
            id: 'modular_kitchen',
            title: 'Modular Kitchen Setup',
            price: 14999,
            rating: 4.85,
            reviews: '500',
            imageAsset: Images.handymanRenovation,
            description: 'Installation of modular cabinets and countertops.',
          ),
        ],
      ),
    ],
    'TV Mount & Setup': [
      SubCategoryModel(
        name: 'TV Setup',
        services: [
          HandymanServiceItem(
            id: 'tv_installation',
            title: 'Wall Mount TV Installation',
            price: 299,
            rating: 4.80,
            reviews: '8K',
            imageAsset: Images.handymanTvmount,
            description: 'Secure wall mounting for LED/LCD TVs of all sizes.',
          ),
        ],
      ),
    ],
    'Locksmith & Key Maker': [
      SubCategoryModel(
        name: 'Lock & Key',
        services: [
          HandymanServiceItem(
            id: 'key_duplication',
            title: 'Key Duplication',
            price: 99,
            rating: 4.78,
            reviews: '1.5K',
            imageAsset: Images.handymanLocksmith,
            description: 'On-the-spot duplicate keys made for home and padlocks.',
          ),
        ],
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args.containsKey('category')) {
        final String passedCategory = args['category']
            .toString()
            .replaceAll('\n', ' ')
            .replaceAll('&', 'and')
            .replaceAll('-', ' ')
            .toLowerCase();

        for (final key in _categorySubCategories.keys) {
          final normalizedKey = key
              .replaceAll('&', 'and')
              .replaceAll('-', ' ')
              .toLowerCase();
          if ((passedCategory.contains('women') && passedCategory.contains('salon')) &&
              (normalizedKey.contains('women') && normalizedKey.contains('salon'))) {
            _activeCategoryName = key;
            break;
          }
          if (passedCategory.contains(normalizedKey) || normalizedKey.contains(passedCategory)) {
            _activeCategoryName = key;
            break;
          }
        }
      }
      if (args.containsKey('subCategoryName')) {
        _activeSubCategoryName = args['subCategoryName'].toString();
      }
    }

    // Default fallback if subcategory is empty
    if (_activeSubCategoryName.isEmpty) {
      final subs = _categorySubCategories[_activeCategoryName];
      if (subs != null && subs.isNotEmpty) {
        _activeSubCategoryName = subs[0].name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<SubCategoryModel> subCategories = _categorySubCategories[_activeCategoryName] ?? [];
    final SubCategoryModel? selectedSubCategory = subCategories.firstWhereOrNull(
      (sub) => sub.name.toLowerCase() == _activeSubCategoryName.toLowerCase(),
    ) ?? (subCategories.isNotEmpty ? subCategories[0] : null);
    
    final List<HandymanServiceItem> activeServices = selectedSubCategory?.services ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5), // Premium Indigo/Blue header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Available Service',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          // Shopping cart badge in App Bar
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Obx(() {
              final homeController = Get.find<HandymanHomeController>();
              final int qty = homeController.totalCartItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () => Get.to(() => HandymanCartScreen(onBackToHome: () => Get.back())),
                  ),
                  if (qty > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Text(
                          '$qty',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
      body: activeServices.isEmpty
          ? Center(
              child: Text(
                'No services available under this subcategory.',
                style: robotoRegular.copyWith(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: activeServices.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              itemBuilder: (context, index) {
                final service = activeServices[index];
                final homeController = Get.find<HandymanHomeController>();

                void openBottomSheet() {
                  final homeController = Get.find<HandymanHomeController>();
                  HandymanServiceModel? match;
                  for (var s in homeController.mostBookedServices) {
                    if (service.id.contains(s.id) || s.id.contains(service.id)) {
                      match = s;
                      break;
                    }
                  }
                  if (match == null) {
                    for (var section in homeController.categorySections) {
                      for (var s in section.services) {
                        if (service.id.contains(s.id) || s.id.contains(service.id) ||
                            service.title.toLowerCase().contains(s.name.toLowerCase()) ||
                            s.name.toLowerCase().contains(service.title.toLowerCase())) {
                          match = s;
                          break;
                        }
                      }
                      if (match != null) break;
                    }
                  }

                  match ??= HandymanServiceModel(
                    id: service.id,
                    name: service.title,
                    category: _activeCategoryName,
                    rating: service.rating,
                    reviewCount: service.reviews,
                    startingPrice: service.price,
                    optionsCount: service.optionsCount,
                    imageAsset: service.imageAsset,
                    options: [],
                  );

                  Get.bottomSheet(
                    ServiceOptionsBottomSheet(
                      service: match,
                      onOptionAdd: (optionId) {
                        homeController.addToCart(match!.id);
                      },
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                }

                return GestureDetector(
                  onTap: openBottomSheet,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left details side
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            service.title,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const Gap(4),

                          // Rating
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14.sp),
                              const Gap(4),
                              Text(
                                '${service.rating.toStringAsFixed(2)} (${service.reviews} reviews)',
                                style: robotoRegular.copyWith(
                                  fontSize: 11.5.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),

                          // Price
                          Text(
                            '₹${_formatPrice(service.price)}',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const Gap(8),

                          // Dotted Divider
                          SizedBox(
                            height: 1.h,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 5).floor(),
                                    (index) => SizedBox(
                                      width: 2.w,
                                      height: 1.h,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap(8),

                          // Description as bullet points
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: service.description
                                .split('.')
                                .where((s) => s.trim().isNotEmpty)
                                .map((bullet) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ', style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp)),
                                    Expanded(
                                      child: Text(
                                        bullet.trim(),
                                        style: robotoRegular.copyWith(
                                          fontSize: 11.5.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const Gap(12),

                          // View details
                          GestureDetector(
                            onTap: openBottomSheet,
                            child: Text(
                              'View details',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B4EFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),

                    // Right image and Add Button side
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              service.imageAsset,
                              width: 115.w,
                              height: 115.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) => Container(
                                width: 115.w,
                                height: 115.h,
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.construction, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        // Heart Icon overlay
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Obx(() {
                            final wishlisted = homeController.allServices[service.id]?.isWishlisted ?? false;
                            return GestureDetector(
                              onTap: () => homeController.toggleWishlist(service.id),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  key: ValueKey(wishlisted),
                                  width: 28.w,
                                  height: 28.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    wishlisted
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: wishlisted
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF9CA3AF),
                                    size: 15.sp,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        Positioned(
                          bottom: 0,
                          child: _buildAddButton(service),
                        ),
                      ],
                    ),
                  ],
                  ),
                );
              },
            ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 1000) {
      final String str = price.toString();
      return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
    }
    return price.toString();
  }

  Widget _buildAddButton(HandymanServiceItem service) {
    final homeController = Get.find<HandymanHomeController>();

    return Obx(() {
      final int currentQty = homeController.getServiceQuantity(service.id);

      return Container(
        height: 30.h,
        width: 75.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: currentQty > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      homeController.removeServiceFromCart(service.id);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: Icon(Icons.remove, size: 14.sp, color: const Color(0xFF6B4EFF)),
                    ),
                  ),
                  Text(
                    '$currentQty',
                    style: robotoRegular.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B4EFF),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      homeController.addServiceToCart(service.id);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                      child: Icon(Icons.add, size: 14.sp, color: const Color(0xFF6B4EFF)),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: () {
                  homeController.addServiceToCart(service.id);
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Add',
                    style: robotoRegular.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B4EFF),
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
