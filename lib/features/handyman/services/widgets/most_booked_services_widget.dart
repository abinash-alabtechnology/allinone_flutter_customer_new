import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/cart_count_view.dart';

/// "Most Booked Services" horizontal scroll section.
/// Uses [HandymanHomeController] (must be registered before use).
class MostBookedServicesWidget extends StatelessWidget {
  const MostBookedServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Section Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Text(
            'Most booked services',
            style: robotoRegular.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              letterSpacing: -0.2,
            ),
          ),
        ),

        // ── Horizontal Card List ────────────────────────────────────────────
        GetBuilder<HandymanHomeController>(
          builder: (controller) {
            final displayServices = controller.mostBookedServices;

            if (displayServices.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 248,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: displayServices.length,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) {
                  final service = displayServices[index];
                  return _ServiceCard(
                    service: service,
                    controller: controller,
                  );
                },
              ),
            );
          },
        ),

        const Gap(4),
      ],
    ),
    );
  }
}

// ─── Individual Service Card ────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final HandymanServiceModel service;
  final HandymanHomeController controller;

  const _ServiceCard({
    required this.service,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ServiceOptionsBottomSheet.show(context, service);
      },
      child: Container(
        width: 162,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── Service Image ───────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? CustomImage(
                        image: service.imageUrl!,
                        width: 162,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        service.imageAsset,
                        width: 162,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 162,
                          height: 120,
                          color: const Color(0xFFEFF6FF),
                          child: const Icon(
                            Icons.build_rounded,
                            color: Color(0xFF0091FF),
                            size: 36,
                          ),
                        ),
                      ),
              ),
              // Wishlist heart
              Positioned(
                top: 8,
                right: 8,
                child: Obx(() {
                  controller.allServices.length;
                  final wishlisted = controller.isServiceWishlisted(service.id);
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

          // ── Card Content ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      height: 1.3,
                    ),
                  ),

                  const Gap(4),

                  // Rating row
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFACC15),
                        size: 13,
                      ),
                      const Gap(3),
                      Text(
                        service.rating.toStringAsFixed(2),
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const Gap(3),
                      Text(
                        '(${service.reviewCount})',
                        style: robotoRegular.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Starts at',
                            style: robotoRegular.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            '₹${service.startingPrice}',
                            style: robotoRegular.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Add / Quantity button
                      CartCountViewHandyman(service: service),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
     ),
    );
  }
}
