import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';

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
              Obx(() {
                int qty = 0;
                for (final section in controller.categorySections) {
                  final sIdx = section.services.indexWhere((s) => s.id == service.id);
                  if (sIdx != -1) {
                    qty = section.services[sIdx].cartQuantity;
                    break;
                  }
                }
                
                return qty == 0
                    ? _AddButton(
                        optionsCount: service.optionsCount,
                        onTap: () {
                          if (service.optionsCount == 0) {
                            controller.addToCart(service.id);
                            Get.snackbar(
                              'Added',
                              '${service.name} added to cart',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                                     ServiceOptionsBottomSheet.show(context, service);
                          }
                        },
                      )
                    : _QuantityButton(
                        quantity: qty,
                        optionsCount: service.optionsCount,
                        onAdd: () => controller.addToCart(service.id),
                        onRemove: () => controller.removeFromCart(service.id),
                      );
              }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Add Button ──────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final int optionsCount;
  final VoidCallback onTap;
  const _AddButton({required this.optionsCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 72,
            height: 34,
            margin: EdgeInsets.only(bottom: optionsCount > 0 ? 6 : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Add',
              style: robotoRegular.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ),
          if (optionsCount > 0)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white,
                child: Text(
                  '$optionsCount options',
                  style: robotoRegular.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Reusable Quantity Button ─────────────────────────────────────────────────

class _QuantityButton extends StatelessWidget {
  final int quantity;
  final int optionsCount;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityButton({
    required this.quantity,
    required this.optionsCount,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Minus
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 24,
              height: 34,
              child: Icon(
                Icons.remove_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          // Count
          Text(
            '$quantity',
            style: robotoRegular.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          // Plus
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 24,
              height: 34,
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
