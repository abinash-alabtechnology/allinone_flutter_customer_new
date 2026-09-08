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
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';
import 'package:shimmer/shimmer.dart';

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

  SubCategoryModel({required this.name, required this.services});
}

class HandymanAvailableServicesScreen extends StatefulWidget {
  const HandymanAvailableServicesScreen({super.key});

  @override
  State<HandymanAvailableServicesScreen> createState() =>
      _HandymanAvailableServicesScreenState();
}

class _HandymanAvailableServicesScreenState
    extends State<HandymanAvailableServicesScreen> {
  String _activeCategoryTitle = 'Available Services';
  int? _passedCategoryId;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HandymanHomeController>()) {
      Get.put(HandymanHomeController());
    }
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args.containsKey('category') && args['category'] != null) {
        final catStr = args['category'].toString().replaceAll('\n', ' ').trim();
        if (catStr.isNotEmpty) {
          _activeCategoryTitle = catStr;
        }
      }
      if (args.containsKey('categoryId') && args['categoryId'] != null) {
        _passedCategoryId = int.tryParse(args['categoryId'].toString());
      }
    }

    final categoryController = Get.find<CategoryController>();
    if (_passedCategoryId == null &&
        categoryController.categoryList != null &&
        _activeCategoryTitle.isNotEmpty) {
      final match = categoryController.categoryList!.firstWhereOrNull(
        (c) =>
            c.name != null &&
            (c.name!.toLowerCase() == _activeCategoryTitle.toLowerCase() ||
                c.name!.toLowerCase().contains(
                  _activeCategoryTitle.toLowerCase(),
                ) ||
                _activeCategoryTitle.toLowerCase().contains(
                  c.name!.toLowerCase(),
                )),
      );
      if (match != null && match.id != null) {
        _passedCategoryId = match.id;
      }
    }

    if (_passedCategoryId != null) {
      categoryController.fetchItemsForCategory(
        _passedCategoryId.toString(),
        1,
        'all',
        true,
      );
    }
  }

  Future<void> _onRefresh() async {
    final catIdStr = _passedCategoryId?.toString();
    if (catIdStr != null) {
      await Get.find<CategoryController>().fetchItemsForCategory(
        catIdStr,
        1,
        'all',
        true,
      );
    } else {
      await Get.find<CategoryController>().getCategoryList(true);
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.h),
                    Container(
                      width: 80.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.h),
                    Container(
                      width: 60.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(12.h),
                    Container(
                      width: 180.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(4.h),
                    Container(
                      width: 120.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(16.w),
              Container(
                width: 115.w,
                height: 115.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _activeCategoryTitle,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Obx(() {
              final homeController = Get.find<HandymanHomeController>();
              final int qty = homeController.totalCartItems;
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    if (qty > 0)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6C63FF),
                              width: 1.5,
                            ),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.w,
                          ),
                          child: Text(
                            '$qty',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => Get.to(
                  () => HandymanCartScreen(onBackToHome: () => Get.back()),
                ),
              );
            }),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF6C63FF),
        child: GetBuilder<CategoryController>(
          builder: (categoryController) {
            final catIdStr = _passedCategoryId?.toString();
            final apiItems = catIdStr != null
                ? categoryController.itemsByCategory[catIdStr]
                : null;
            final bool isCatLoading = catIdStr != null
                ? categoryController.isLoadingForCategory(catIdStr)
                : false;

            if (catIdStr != null &&
                (apiItems == null ||
                    isCatLoading ||
                    categoryController.isLoading ||
                    categoryController.isLoadingCategories)) {
              return _buildShimmerLoading();
            }

            List<HandymanServiceItem> effectiveServices = [];
            if (apiItems != null && apiItems.isNotEmpty) {
              effectiveServices = apiItems.map((item) {
                return HandymanServiceItem(
                  id: item.id.toString(),
                  title: item.name ?? '',
                  rating: item.avgRating ?? 4.8,
                  reviews: item.ratingCount != null
                      ? item.ratingCount.toString()
                      : '100+',
                  price: item.price?.toInt() ?? 0,
                  optionsCount: item.choiceOptions?.length ?? 1,
                  imageAsset: item.imageFullUrl ?? '',
                  description: item.description ?? '',
                );
              }).toList();
            } else if (!isCatLoading) {
              final homeController = Get.find<HandymanHomeController>();
              final sectionMatch = homeController.categorySections
                  .firstWhereOrNull(
                    (sec) =>
                        (_passedCategoryId != null &&
                            sec.categoryId == _passedCategoryId) ||
                        sec.title.toLowerCase().contains(
                          _activeCategoryTitle.toLowerCase(),
                        ) ||
                        _activeCategoryTitle.toLowerCase().contains(
                          sec.title.toLowerCase(),
                        ),
                  );

              if (sectionMatch != null && sectionMatch.services.isNotEmpty) {
                effectiveServices = sectionMatch.services.map((item) {
                  return HandymanServiceItem(
                    id: item.id,
                    title: item.name,
                    rating: item.rating,
                    reviews: item.reviewCount,
                    price: item.startingPrice,
                    optionsCount: item.optionsCount,
                    imageAsset: item.imageUrl ?? item.imageAsset,
                    description: item.coverDescription ?? item.name,
                  );
                }).toList();
              }
            }

            if (effectiveServices.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      'No services available under this category.',
                      style: robotoRegular.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: effectiveServices.length,
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              itemBuilder: (context, index) {
                final service = effectiveServices[index];
                final homeController = Get.find<HandymanHomeController>();

                void openBottomSheet() {
                  final homeController = Get.find<HandymanHomeController>();
                  HandymanServiceModel? match;
                  for (var s in homeController.mostBookedServices) {
                    if (service.id.contains(s.id) ||
                        s.id.contains(service.id)) {
                      match = s;
                      break;
                    }
                  }
                  if (match == null) {
                    for (var section in homeController.categorySections) {
                      for (var s in section.services) {
                        if (service.id.contains(s.id) ||
                            s.id.contains(service.id) ||
                            service.title.toLowerCase().contains(
                              s.name.toLowerCase(),
                            ) ||
                            s.name.toLowerCase().contains(
                              service.title.toLowerCase(),
                            )) {
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
                    category: _activeCategoryTitle,
                    rating: service.rating,
                    reviewCount: service.reviews,
                    startingPrice: service.price,
                    optionsCount: service.optionsCount,
                    imageAsset: service.imageAsset,
                    options: [],
                  );

                  ServiceOptionsBottomSheet.show(context, match!);
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
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14.sp,
                                ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      (constraints.constrainWidth() / 5)
                                          .floor(),
                                      (index) => SizedBox(
                                        width: 2.w,
                                        height: 1.h,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                          ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '• ',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12.sp,
                                            ),
                                          ),
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
                                  })
                                  .toList(),
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
                                  color: const Color(0xFF6C63FF),
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
                              child: (service.imageAsset.startsWith('http'))
                                  ? CustomImage(
                                      image: service.imageAsset,
                                      width: 115.w,
                                      height: 115.h,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      service.imageAsset,
                                      width: 115.w,
                                      height: 115.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, err, stack) =>
                                          Container(
                                            width: 115.w,
                                            height: 115.h,
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.construction,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                          // Heart Icon overlay
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Obx(() {
                              final wishlisted =
                                  homeController
                                      .allServices[service.id]
                                      ?.isWishlisted ??
                                  false;
                              return GestureDetector(
                                onTap: () =>
                                    homeController.toggleWishlist(service.id),
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
            );
          },
        ),
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
    return CartCountViewHandyman(
      service: HandymanServiceModel(
        id: service.id,
        name: service.title,
        category: _activeCategoryTitle,
        rating: service.rating,
        reviewCount: service.reviews,
        startingPrice: service.price,
        optionsCount: service.optionsCount,
        imageAsset: service.imageAsset,
        options: [],
      ),
    );
  }
}
