import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';

/// "Most Booked Services" horizontal scroll section.
/// Uses [HandymanHomeController] (must be registered before use).
class MostBookedServicesWidget extends StatelessWidget {
  const MostBookedServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HandymanHomeController>();

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
        Obx(() {
          if (controller.isLoading.value) {
            return const SizedBox(
              height: 280,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF0091FF)),
              ),
            );
          }
          return SizedBox(
            height: 248,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.mostBookedServices.length,
              itemBuilder: (context, index) {
                final service = controller.mostBookedServices[index];
                return _ServiceCard(
                  service: service,
                  controller: controller,
                );
              },
            ),
          );
        }),

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
    return Container(
      width: 162,
      margin: const EdgeInsets.only(right: 12, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                child: Image.asset(
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
                  final wishlisted = controller
                      .mostBookedServices
                      .firstWhereOrNull((s) => s.id == service.id)
                      ?.isWishlisted ?? false;
                  return GestureDetector(
                    onTap: () => controller.toggleWishlist(service.id),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(wishlisted),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
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
                      Obx(() {
                        final qty = controller.mostBookedServices
                            .firstWhereOrNull((s) => s.id == service.id)
                            ?.cartQuantity ?? 0;
                        return qty == 0
                            ? _AddButton(
                                optionsCount: service.optionsCount,
                                onTap: () =>
                                    controller.addToCart(service.id),
                              )
                            : _QuantityButton(
                                quantity: qty,
                                optionsCount: service.optionsCount,
                                onAdd: () =>
                                    controller.addToCart(service.id),
                                onRemove: () =>
                                    controller.removeFromCart(service.id),
                              );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Button ───────────────────────────────────────────────────────────────

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

// ─── Quantity Stepper Button ──────────────────────────────────────────────────

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
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 72,
          height: 34,
          margin: EdgeInsets.only(bottom: optionsCount > 0 ? 6 : 0),
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
    );
  }
}
