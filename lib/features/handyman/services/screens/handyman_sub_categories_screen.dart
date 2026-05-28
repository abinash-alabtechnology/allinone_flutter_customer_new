import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';

class SubCategoryItemModel {
  final String name;
  final String description;
  final int servicesCount;
  final String imageAsset;

  SubCategoryItemModel({
    required this.name,
    required this.description,
    required this.servicesCount,
    required this.imageAsset,
  });
}

class HandymanSubCategoriesScreen extends StatefulWidget {
  const HandymanSubCategoriesScreen({super.key});

  @override
  State<HandymanSubCategoriesScreen> createState() => _HandymanSubCategoriesScreenState();
}

class _HandymanSubCategoriesScreenState extends State<HandymanSubCategoriesScreen> {
  String _activeCategoryName = 'Cleaning & Pest Control';
  int _selectedSubCategoryIndex = 0;

  final Map<String, List<SubCategoryItemModel>> _categorySubCategoriesData = {
    'InstaHelp': [
      SubCategoryItemModel(
        name: 'Emergency Repair',
        description: 'Quick response emergency electrical troubleshooting, wiring repair, short circuit fixes.',
        servicesCount: 2,
        imageAsset: Images.handymanTools,
      ),
    ],
    "Women's Salon & Spa": [
      SubCategoryItemModel(
        name: 'Threading & Waxing',
        description: 'Precise facial threading and smooth waxing treatments.',
        servicesCount: 2,
        imageAsset: Images.handymanThreading,
      ),
      SubCategoryItemModel(
        name: 'Facial & Massage',
        description: 'Rejuvenating facials using top-tier herbal and gold packs.',
        servicesCount: 2,
        imageAsset: Images.handymanFacial,
      ),
    ],
    "Men's Salon & Massage": [
      SubCategoryItemModel(
        name: 'Haircut & Grooming',
        description: 'Professional haircut, hair wash, and blowdry styling.',
        servicesCount: 2,
        imageAsset: Images.handymanMenSalon,
      ),
      SubCategoryItemModel(
        name: 'Massage & Relief',
        description: 'Acupressure head massage to relieve tension and stress.',
        servicesCount: 1,
        imageAsset: Images.handymanMenSalon,
      ),
    ],
    'Cleaning & Pest Control': [
      SubCategoryItemModel(
        name: 'Bathroom cleaning',
        description: 'Intense descaling, scrubbing and sanitization of bathroom.',
        servicesCount: 2,
        imageAsset: Images.intenseBathroom,
      ),
      SubCategoryItemModel(
        name: 'Complete kitchen cleaning',
        description: 'Deep cleaning of cabinets, counter, tiles, stove and chimney.',
        servicesCount: 2,
        imageAsset: Images.kitchenCounter,
      ),
      SubCategoryItemModel(
        name: 'Sofa & Carpet Cleaning',
        description: 'Deep vacuuming, shampooing and stain extraction for sofas.',
        servicesCount: 2,
        imageAsset: Images.sofaClean,
      ),
      SubCategoryItemModel(
        name: 'Full Home Cleaning',
        description: 'Complete dusting, mopping and deep cleaning of furnished homes.',
        servicesCount: 2,
        imageAsset: Images.houseClean,
      ),
      SubCategoryItemModel(
        name: 'Ant & Pest Control',
        description: 'Safe gel treatment with utensil removal, completely odorless.',
        servicesCount: 2,
        imageAsset: Images.antControl,
      ),
    ],
    'Painting & Water - proofing': [
      SubCategoryItemModel(
        name: 'Home Painting',
        description: 'Quick and clean patching and paint touch-ups for wall damages.',
        servicesCount: 2,
        imageAsset: Images.handymanPainting,
      ),
      SubCategoryItemModel(
        name: 'Waterproofing',
        description: 'Professional waterproofing treatment to stop wall dampness.',
        servicesCount: 1,
        imageAsset: Images.handymanPainting,
      ),
    ],
    'AC & Appliance Repair': [
      SubCategoryItemModel(
        name: 'AC Service',
        description: 'Thorough filter cleaning, gas refill check, and foam diagnostic.',
        servicesCount: 3,
        imageAsset: Images.handymanAc,
      ),
      SubCategoryItemModel(
        name: 'Appliance Repair',
        description: 'Expert repair and water heating diagnosis for geysers.',
        servicesCount: 1,
        imageAsset: Images.geyserClean,
      ),
    ],
    'Electrician, Plumber & Carpenter': [
      SubCategoryItemModel(
        name: 'Plumbing',
        description: 'We are well-equipped and well-prepared to check your plumbing problems.',
        servicesCount: 2,
        imageAsset: Images.bathroomSink,
      ),
      SubCategoryItemModel(
        name: 'Electrical',
        description: 'Installation/replacement of switches and boards.',
        servicesCount: 1,
        imageAsset: Images.handymanTools,
      ),
      SubCategoryItemModel(
        name: 'Carpentry',
        description: 'Professional carpentry assembly services.',
        servicesCount: 1,
        imageAsset: Images.handymanTools,
      ),
    ],
    'CCTV & Smart Home': [
      SubCategoryItemModel(
        name: 'Smart Solutions',
        description: 'Secure your home with professional CCTV installation and setup.',
        servicesCount: 2,
        imageAsset: Images.handymanCctv,
      ),
    ],
    'Gardening & Lawn Care': [
      SubCategoryItemModel(
        name: 'Garden Maintenance',
        description: 'Professional grass cutting, edging, and garden cleanup.',
        servicesCount: 2,
        imageAsset: Images.handymanGardening,
      ),
    ],
    'Home Renovation': [
      SubCategoryItemModel(
        name: 'Renovation Services',
        description: 'Complete remodel of tiles, fixtures, and piping.',
        servicesCount: 2,
        imageAsset: Images.handymanRenovation,
      ),
    ],
    'TV Mount & Setup': [
      SubCategoryItemModel(
        name: 'TV Setup',
        description: 'Secure wall mounting for LED/LCD TVs of all sizes.',
        servicesCount: 1,
        imageAsset: Images.handymanTvmount,
      ),
    ],
    'Locksmith & Key Maker': [
      SubCategoryItemModel(
        name: 'Lock & Key',
        description: 'On-the-spot duplicate keys made for home and padlocks.',
        servicesCount: 1,
        imageAsset: Images.handymanLocksmith,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('category')) {
      final String passedCategory = args['category']
          .toString()
          .replaceAll('\n', ' ')
          .replaceAll('&', 'and')
          .replaceAll('-', ' ')
          .toLowerCase();

      for (final key in _categorySubCategoriesData.keys) {
        final normalizedKey = key
            .replaceAll('&', 'and')
            .replaceAll('-', ' ')
            .toLowerCase();
        if (passedCategory.contains(normalizedKey) || normalizedKey.contains(passedCategory)) {
          _activeCategoryName = key;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<SubCategoryItemModel> subCategories = _categorySubCategoriesData[_activeCategoryName] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Sub Categories',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Obx(() {
              final homeController = Get.find<HandymanHomeController>();
              final int qty = homeController.totalCartItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub Categories List below
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: subCategories.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final subCat = subCategories[index];

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSubCategoryIndex = index;
                        });
                        Get.toNamed(
                          RouteHelper.getHandymanAvailableServicesRoute(),
                          arguments: {
                            'category': _activeCategoryName,
                            'subCategoryName': subCat.name,
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.asset(
                                subCat.imageAsset,
                                width: 84.w,
                                height: 84.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, err, stack) => Container(
                                  width: 84.w,
                                  height: 84.h,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.construction, color: Colors.grey),
                                ),
                              ),
                            ),
                            const Gap(16),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subCat.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    subCat.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade500,
                                      height: 1.3,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '${subCat.servicesCount} Services',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3F51B5),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
