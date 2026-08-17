import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';

class CategoryServicesWidget extends GetView<HandymanHomeController> {
  final CategorySectionModel section;
  const CategoryServicesWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: robotoRegular.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    section.subtitle,
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
               Padding(
                 padding: const EdgeInsets.only(top: 4),
                 child: GestureDetector(
                   onTap: () {
                     Get.toNamed(
                       RouteHelper.getHandymanAvailableServicesRoute(),
                       arguments: {
                         'category': section.title,
                         'categoryId': section.categoryId,
                       },
                     );
                   },
                   child: Text(
                     'See all',
                     style: robotoRegular.copyWith(
                       fontSize: 14,
                       fontWeight: FontWeight.w600,
                       color: const Color(0xFF6C63FF),
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ),
        const Gap(10),
        // List (Capped at 5 items for home display)
        SizedBox(
          height: 215,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final int displayCount = section.services.length > 5 ? 5 : section.services.length;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: displayCount,
              separatorBuilder: (context, index) => const Gap(14),
              itemBuilder: (context, index) {
                final service = section.services[index];
                return _CategoryServiceCard(service: service);
              },
            );
          }),
        ),
      ],
    ),
    );
  }
}

class _CategoryServiceCard extends StatelessWidget {
  final HandymanServiceModel service;
  const _CategoryServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HandymanHomeController>();

    return GestureDetector(
      onTap: () {
        ServiceOptionsBottomSheet.show(context, service);
      },
      child: SizedBox(
        width: 135,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Image with favourite overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? CustomImage(
                        image: service.imageUrl!,
                        width: 135,
                        height: 105,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        service.imageAsset,
                        width: 135,
                        height: 105,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 135,
                            height: 105,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.construction,
                              size: 36,
                              color: Color(0xFF9CA3AF),
                            ),
                          );
                        },
                      ),
              ),
              // Favourite heart icon
              Positioned(
                top: 8,
                right: 8,
                child: Obx(() {
                  controller.allServices.length;
                  bool wishlisted = controller.isServiceWishlisted(service.id);
                  return GestureDetector(
                    onTap: () => controller.toggleWishlist(service.id),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(wishlisted),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
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
                          size: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const Gap(8),
          // Title
          Text(
            service.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Gap(4),
          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
              const Gap(4),
              Text(
                '${service.rating} (${service.reviewCount})',
                style: robotoRegular.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const Gap(8),
          // Price and Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starts at',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '₹${service.startingPrice}',
                    style: robotoRegular.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              CartCountViewHandyman(service: service),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
