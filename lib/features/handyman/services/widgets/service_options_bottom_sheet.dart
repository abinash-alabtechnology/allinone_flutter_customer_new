import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/util/styles.dart';

class ServiceOptionsBottomSheet extends StatelessWidget {
  final HandymanServiceModel service;
  final Function(String optionId) onOptionAdd;

  const ServiceOptionsBottomSheet({
    super.key,
    required this.service,
    required this.onOptionAdd,
  });

  @override
  Widget build(BuildContext context) {
    bool hasDiscount = service.options.any((o) => o.discountText.isNotEmpty);
    bool hasOptionImages = service.options.any((o) => o.imageAsset != null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close Button outside the sheet
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.black),
              ),
            ),
          ),
        ),
        // Bottom Sheet Content
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header Section
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFF3F4F6),
                  child: Image.asset(
                    service.coverImageAsset ?? service.imageAsset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              const Gap(16),

              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: robotoRegular.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const Gap(6),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.black54),
                              const Gap(4),
                              Text(
                                '${service.rating} (${service.reviewCount} reviews)',
                                style: robotoRegular.copyWith(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            ],
                          ),
                          if (service.options.isEmpty) ...[
                            const Gap(8),
                            Text(
                              '₹${service.startingPrice}  •  15 mins',
                              style: robotoRegular.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          if (hasDiscount) ...[
                            const Gap(8),
                            Row(
                              children: [
                                const Icon(Icons.local_offer, size: 14, color: const Color(0xFF059669)),
                                const Gap(4),
                                Text(
                                  'Add more & save up to 21%',
                                  style: robotoRegular.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF059669),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (service.options.isEmpty) ...[
                      const Gap(16),
                      Obx(() {
                        final controller = Get.find<HandymanHomeController>();
                        int qty = 0;
                        final mbIdx = controller.mostBookedServices.indexWhere((s) => s.id == service.id);
                        if (mbIdx != -1) {
                          qty = controller.mostBookedServices[mbIdx].cartQuantity;
                        } else {
                          for (final section in controller.categorySections) {
                            final sIdx = section.services.indexWhere((s) => s.id == service.id);
                            if (sIdx != -1) {
                              qty = section.services[sIdx].cartQuantity;
                              break;
                            }
                          }
                        }

                        if (qty == 0) {
                          return Container(
                            width: 80,
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () {
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
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6C63FF),
                                side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Add',
                                style: robotoRegular.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            width: 80,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => controller.removeFromCart(service.id),
                                  behavior: HitTestBehavior.opaque,
                                  child: const SizedBox(
                                    width: 24,
                                    height: 36,
                                    child: Icon(
                                      Icons.remove_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$qty',
                                  style: robotoRegular.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => controller.addToCart(service.id),
                                  behavior: HitTestBehavior.opaque,
                                  child: const SizedBox(
                                    width: 24,
                                    height: 36,
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
                      }),
                    ],
                  ],
                ),
              ),

              if (service.options.isNotEmpty) ...[
                const Gap(16),
                const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                const Gap(16),

                // Options List
                SizedBox(
                  height: hasOptionImages ? 280 : 165,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: service.options.length,
                    itemBuilder: (context, index) {
                      final option = service.options[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (option.imageAsset != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  topRight: Radius.circular(11),
                                ),
                                child: Image.asset(
                                  option.imageAsset!,
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.title,
                                      style: robotoRegular.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (option.rating != null && option.reviewCount != null) ...[
                                      const Gap(4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 12, color: Colors.black54),
                                          const Gap(2),
                                          Expanded(
                                            child: Text(
                                              '${option.rating} (${option.reviewCount})',
                                              style: robotoRegular.copyWith(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const Gap(10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${option.discountedPrice}',
                                          style: robotoRegular.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (option.originalPrice > option.discountedPrice) ...[
                                          const Gap(4),
                                          Text(
                                            '₹${option.originalPrice}',
                                            style: robotoRegular.copyWith(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (option.subtitle.isNotEmpty) ...[
                                      const Gap(2),
                                      Text(
                                        option.subtitle,
                                        style: robotoRegular.copyWith(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                    if (option.discountText.isNotEmpty) ...[
                                      const Gap(4),
                                      Text(
                                        option.discountText,
                                        style: robotoRegular.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Obx(() {
                                      final controller = Get.find<HandymanHomeController>();
                                      int optionQty = 0;
                                      
                                      final mbIdx = controller.mostBookedServices.indexWhere((s) => s.id == service.id);
                                      HandymanServiceModel? controllerService;
                                      if (mbIdx != -1) {
                                        controllerService = controller.mostBookedServices[mbIdx];
                                      } else {
                                        for (final section in controller.categorySections) {
                                          final sIdx = section.services.indexWhere((s) => s.id == service.id);
                                          if (sIdx != -1) {
                                            controllerService = section.services[sIdx];
                                            break;
                                          }
                                        }
                                      }

                                      if (controllerService != null) {
                                        final opt = controllerService.options.firstWhereOrNull((o) => o.id == option.id);
                                        if (opt != null) {
                                          optionQty = opt.quantity;
                                        }
                                      }

                                      return SizedBox(
                                        width: double.infinity,
                                        height: 36,
                                        child: optionQty == 0
                                            ? OutlinedButton(
                                                onPressed: () {
                                                  controller.addOptionToCart(service.id, option.id);
                                                  Get.snackbar(
                                                    'Added',
                                                    '${option.title} added to cart',
                                                    snackPosition: SnackPosition.TOP,
                                                    backgroundColor: Colors.black87,
                                                    colorText: Colors.white,
                                                    margin: const EdgeInsets.all(16),
                                                    duration: const Duration(seconds: 2),
                                                  );
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(0xFF6366F1),
                                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: Text(
                                                  'Add',
                                                  style: robotoRegular.copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF6C63FF),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => controller.removeOptionFromCart(service.id, option.id),
                                                      behavior: HitTestBehavior.opaque,
                                                      child: const SizedBox(
                                                        width: 24,
                                                        height: 36,
                                                        child: Icon(
                                                          Icons.remove_rounded,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '$optionQty',
                                                      style: robotoRegular.copyWith(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => controller.addOptionToCart(service.id, option.id),
                                                      behavior: HitTestBehavior.opaque,
                                                      child: const SizedBox(
                                                        width: 24,
                                                        height: 36,
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
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const Divider(color: Color(0xFFF3F4F6), thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: robotoRegular.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      _getServiceDescription(service),
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Obx(() {
                final controller = Get.find<HandymanHomeController>();
                int totalQty = 0;
                int totalDiscounted = 0;
                int totalOriginal = 0;

                final mbIdx = controller.mostBookedServices.indexWhere((s) => s.id == service.id);
                HandymanServiceModel? controllerService;
                if (mbIdx != -1) {
                  controllerService = controller.mostBookedServices[mbIdx];
                } else {
                  for (final section in controller.categorySections) {
                    final sIdx = section.services.indexWhere((s) => s.id == service.id);
                    if (sIdx != -1) {
                      controllerService = section.services[sIdx];
                      break;
                    }
                  }
                }

                if (controllerService != null) {
                  if (controllerService.options.isEmpty) {
                    totalQty = controllerService.cartQuantity;
                    totalDiscounted = controllerService.startingPrice * totalQty;
                    totalOriginal = totalDiscounted;
                  } else {
                    for (final opt in controllerService.options) {
                      totalQty += opt.quantity;
                      totalDiscounted += opt.discountedPrice * opt.quantity;
                      totalOriginal += opt.originalPrice * opt.quantity;
                    }
                  }
                }

                if (totalQty == 0) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$totalQty',
                          style: robotoRegular.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹$totalDiscounted',
                                style: robotoRegular.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              if (totalOriginal > totalDiscounted) ...[
                                const Gap(4),
                                Text(
                                  '₹$totalOriginal',
                                  style: robotoRegular.copyWith(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Done',
                          style: robotoRegular.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // SafeArea for bottom notch
              const SafeArea(child: SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }

  String _getServiceDescription(HandymanServiceModel service) {
    if (service.coverDescription != null && service.coverDescription!.isNotEmpty) {
      return service.coverDescription!.replaceAll('\n', ' ');
    }
    final String nameLower = service.name.toLowerCase();
    if (nameLower.contains('ac')) {
      return "Get certified, expert AC mechanics at your doorstep. Professional repairs, gas filling, filter cleaning, and diagnostics for all brands of AC.";
    } else if (nameLower.contains('salon') && nameLower.contains('women')) {
      return "Pamper yourself with premium beauty and skincare services. Haircuts, styling, spa, waxing, threading, and facials at the comfort of your home.";
    } else if (nameLower.contains('massage')) {
      return "Relax and rejuvenate with our professional massage therapy. Relieve stress, improve blood circulation, and nourish your body and mind.";
    } else if (nameLower.contains('cleaning')) {
      return "Deep home cleaning, kitchen sanitization, bathroom disinfection, and eco-friendly pest control services performed by professionals.";
    } else if (nameLower.contains('plumb') || nameLower.contains('tool')) {
      return "Expert plumbing services for leakages, tap repairs, pipe fittings, bathroom installations, and emergency blockages.";
    } else if (nameLower.contains('salon') && nameLower.contains('men')) {
      return "Professional grooming services for men. Haircuts, beard styling, clean shaves, and relaxing massages by certified male stylists.";
    } else if (nameLower.contains('paint')) {
      return "Transform your home with professional interior and exterior painting services. Waterproofing, wall touch-ups, and expert color consults.";
    } else if (nameLower.contains('cctv') || nameLower.contains('smart')) {
      return "Secure your home and business with expert CCTV camera installations, smart door locks, and complete smart home configurations.";
    } else if (nameLower.contains('thread')) {
      return "Get precise threading for a smooth, hair-free finish. Professional eyebrow shaping, upper lip, chin, and full-face threading.";
    } else if (nameLower.contains('facial')) {
      return "Rejuvenate your skin with our premium facial and skincare therapies. Choose fruit, gold, de-tan, herbal, or glow facials.";
    } else if (nameLower.contains('wax')) {
      return "Smooth, clean, and hair-free skin with our gentle arms, legs, and full body waxing services using high-quality wax.";
    } else {
      return "Get certified, experienced professionals at your doorstep. High-quality service with transparent hourly rates and satisfaction guaranteed.";
    }
  }
}
