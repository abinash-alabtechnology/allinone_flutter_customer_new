import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_search_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';

class HandymanSearchScreen extends StatefulWidget {
  const HandymanSearchScreen({super.key});

  @override
  State<HandymanSearchScreen> createState() => _HandymanSearchScreenState();
}

class _HandymanSearchScreenState extends State<HandymanSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final HandymanSearchController _searchControllerObx;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HandymanHomeController>()) {
      Get.put(HandymanHomeController());
    }
    _searchControllerObx = Get.put(HandymanSearchController());
    
    // Auto focus the search field on entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Search Header Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (val) {
                          _searchControllerObx.updateQuery(val);
                        },
                        style: robotoRegular.copyWith(
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Look for services',
                          hintStyle: robotoRegular.copyWith(
                            fontSize: 15.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    Obx(() {
                      if (_searchControllerObx.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _searchControllerObx.clearSearch();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),

            const Gap(10),

            // Scrollable Search Body
            Expanded(
              child: Obx(() {
                final query = _searchControllerObx.searchQuery.value;
                final suggestions = _searchControllerObx.suggestions;
                final results = _searchControllerObx.searchResults;

                if (query.trim().isEmpty) {
                  return _buildTrendingSearches();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Suggestions list if available
                      if (suggestions.isNotEmpty && results.isEmpty) ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return InkWell(
                              onTap: () {
                                _searchController.text = suggestion;
                                _searchControllerObx.updateQuery(suggestion);
                                _focusNode.unfocus();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, color: Colors.grey, size: 20),
                                    const Gap(12),
                                    Text(
                                      suggestion,
                                      style: robotoRegular.copyWith(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 20, color: Color(0xFFF3F4F6)),
                      ],

                      // Categories Section (if categories are available)
                      if (_searchControllerObx.searchCategoryResults.isNotEmpty) ...[
                        Text(
                          'Categories',
                          style: robotoRegular.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Gap(12),
                        SizedBox(
                          height: 125.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _searchControllerObx.searchCategoryResults.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final cat = _searchControllerObx.searchCategoryResults[index];
                              return Padding(
                                padding: EdgeInsets.only(right: 16.w),
                                child: InkWell(
                                  onTap: () {
                                    Get.toNamed(
                                      RouteHelper.getHandymanSubCategoriesRoute(),
                                      arguments: {'category': cat.title.replaceAll('\n', ' ')},
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 72.w,
                                        height: 72.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          cat.imageAsset,
                                          width: 44.w,
                                          height: 44.h,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const Gap(6),
                                      Text(
                                        cat.title,
                                        textAlign: TextAlign.center,
                                        style: robotoRegular.copyWith(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF1F2937),
                                          fontWeight: FontWeight.w500,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Gap(12),
                        // Full width separator block
                        Transform.translate(
                          offset: Offset(-16.w, 0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 8.h,
                            color: const Color(0xFFF3F4F6),
                          ),
                        ),
                        const Gap(16),
                      ],

                      // Services Results Header
                      Text(
                        'Services',
                        style: robotoRegular.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(12),

                      // Services Results List
                      if (results.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Center(
                            child: Text(
                              'No services found matching "$query"',
                              style: robotoRegular.copyWith(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: results.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 24,
                            color: Color(0xFFF3F4F6),
                          ),
                          itemBuilder: (context, index) {
                            final service = results[index];
                            return _buildServiceItemCard(service);
                          },
                        ),

                      const Gap(30),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSearches() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending searches',
            style: robotoRegular.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Gap(16),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _searchControllerObx.trendingSearches.map((term) {
              return InkWell(
                onTap: () {
                  _searchController.text = term;
                  _searchControllerObx.updateQuery(term);
                  _focusNode.unfocus();
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16.sp,
                        color: Colors.grey.shade400,
                      ),
                      const Gap(6),
                      Text(
                        term,
                        style: robotoRegular.copyWith(
                          fontSize: 13.sp,
                          color: const Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItemCard(HandymanServiceModel service) {
    final homeController = Get.find<HandymanHomeController>();

    String formatPrice(int price) {
      if (price >= 1000) {
        final String str = price.toString();
        return '${str.substring(0, str.length - 3)},${str.substring(str.length - 3)}';
      }
      return price.toString();
    }

    return Obx(() {
      // Find the live quantity of this item in the home controller cart (or fallback to service default)
      int currentQty = 0;
      final liveMostBooked = homeController.mostBookedServices.firstWhereOrNull((s) => s.id == service.id);
      if (liveMostBooked != null) {
        currentQty = liveMostBooked.cartQuantity;
      } else {
        for (var section in homeController.categorySections) {
          final liveSec = section.services.firstWhereOrNull((s) => s.id == service.id);
          if (liveSec != null) {
            currentQty = liveSec.cartQuantity;
            break;
          }
        }
      }

      final bool isSink = service.id == 'kitchen_sink_cleaning';
      final String pricePrefix = isSink ? '' : 'Starts at ';
      final String priceText = '$pricePrefix₹${formatPrice(service.startingPrice)}';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: service.imageAsset.isNotEmpty
                ? Image.asset(
                    service.imageAsset,
                    width: 72.w,
                    height: 72.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 72.w,
                      height: 72.h,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 72.w,
                    height: 72.h,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.construction, color: Colors.grey),
                  ),
          ),
          const Gap(12),

          // Details (Title, Rating, Price)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: robotoRegular.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14.sp),
                    const Gap(2),
                    Text(
                      '${service.rating} (${service.reviewCount})',
                      style: robotoRegular.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Gap(6),
                Text(
                  priceText,
                  style: robotoRegular.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          CartCountViewHandyman(service: service),
        ],
      );
    });
  }
}
