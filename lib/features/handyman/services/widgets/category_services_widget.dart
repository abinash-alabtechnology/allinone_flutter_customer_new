import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';

class CategoryServicesWidget extends GetView<HandymanHomeController> {
  final CategorySectionModel section;
  const CategoryServicesWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16, top: 8),
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
                  onTap: () {},
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
        // List
        SizedBox(
          height: 258,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: section.services.length,
              separatorBuilder: (context, index) => const Gap(16),
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
        Get.bottomSheet(
          ServiceOptionsBottomSheet(
            service: service,
            onOptionAdd: (optionId) {
              controller.addToCart(service.id);
            },
          ),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              service.imageAsset,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(12),
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
          const Gap(12),
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
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            Get.bottomSheet(
                              ServiceOptionsBottomSheet(
                                service: service,
                                onOptionAdd: (optionId) {
                                  controller.addToCart(service.id);
                                },
                              ),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
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
                  color: Colors.black.withValues(alpha: 0.02),
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
