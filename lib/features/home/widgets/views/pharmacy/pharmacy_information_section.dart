import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/helper/route_helper.dart';

class PharmacyInformationSection extends StatelessWidget {
  const PharmacyInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWhyChooseSection(),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
        _buildTrustSafetyAndPrescriptionSection(context),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
      ],
    );
  }

  Widget _buildWhyChooseSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHY CHOOSE HandyX PHARMACY?',
            style: robotoBold.copyWith(fontSize: 14, color: Colors.black.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildChooseItem(Icons.health_and_safety_outlined, '100% Genuine\nMedicines'),
                _buildChooseItem(Icons.description_outlined, 'Prescription\nSecure & Private'),
                _buildChooseItem(Icons.timer_outlined, 'On-time\nDelivery'),
                _buildChooseItem(Icons.assignment_return_outlined, 'Easy Returns\n& Refunds'),
                _buildChooseItem(Icons.headset_mic_outlined, '24/7 Customer\nSupport'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF16A34A), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: 10, color: Colors.grey.shade600, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSafetyAndPrescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: _buildTrustSafetyCard(),
    );
  }

  Widget _buildTrustSafetyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRUST & SAFETY',
            style: robotoBold.copyWith(fontSize: 14, color: Colors.black.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _buildTrustItem(Icons.verified_outlined, 'Licensed Pharmacies', 'Only verified & approved stores'),
          const SizedBox(height: 15),
          _buildTrustItem(Icons.payment_outlined, 'Secure Payments', 'Your transactions are safe with us'),
          const SizedBox(height: 15),
          _buildTrustItem(Icons.lock_outline, 'Your Data is Safe', 'We never share your personal data'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF16A34A), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: robotoBold.copyWith(fontSize: 13, color: Colors.black.withValues(alpha: 0.9))),
              Text(subtitle, style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}
