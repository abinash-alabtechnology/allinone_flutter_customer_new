import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';

class PrescriptionBannerView extends StatelessWidget {
  const PrescriptionBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130, // Fixed height to prevent cell from growing
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFE8F5F5), const Color(0xFFF0FFF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF1B5E5E).withValues(alpha: 0.1)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Upload Prescription',
                        style: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF1B5E5E)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get medicines easily',
                        style: robotoRegular.copyWith(fontSize: 14, color: const Color(0xFF1B5E5E).withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Upload Now',
                              style: robotoBold.copyWith(color: const Color(0xFF1B5E5E), fontSize: 14),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1B5E5E)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 140), // Reserve more space for the overlapping image
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: -20,
            bottom: -20,
            child: Image.asset(
              Images.prescriptionBackground,
              width: 180,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
