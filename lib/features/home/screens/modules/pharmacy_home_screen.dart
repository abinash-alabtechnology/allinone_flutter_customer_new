import 'package:flutter/material.dart';
import 'package:handy_allinone/features/home/widgets/highlight_widget.dart';
import 'package:handy_allinone/features/home/widgets/views/pharmacy/pharmacy_order_again_view.dart';
import 'package:handy_allinone/features/home/widgets/views/pharmacy/prescription_banner_view.dart';
import 'package:handy_allinone/features/home/widgets/views/product_with_categories_view.dart';
import 'package:handy_allinone/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:handy_allinone/features/home/widgets/views/common_condition_view.dart';
import 'package:handy_allinone/features/home/widgets/views/just_for_you_view.dart';
import 'package:handy_allinone/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:handy_allinone/features/home/widgets/views/new_on_mart_view.dart';
import 'package:handy_allinone/features/home/widgets/views/promotional_banner_view.dart';
import 'package:handy_allinone/features/home/widgets/views/recommended_store_view.dart';
import 'package:handy_allinone/features/home/widgets/views/top_offers_near_me.dart';
import 'package:handy_allinone/features/home/widgets/views/visit_again_view.dart';
import 'package:handy_allinone/features/home/widgets/banner_view.dart';
import 'package:handy_allinone/features/home/widgets/views/category_view.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/home/widgets/views/pharmacy/pharmacy_information_section.dart';
import 'package:handy_allinone/util/images.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const BannerView(isFeatured: false),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        const PrescriptionBannerView(),

        const PharmacyOrderAgainView(),

        const CategoryView(),

        const PharmacyPromotionalBanner(), // Custom banner matching the image
        const PharmacyInformationSection(),
        const SizedBox(height: 100),

        // const ProductWithCategoriesView(),
        // const NewOnMartView(isShop: false, isPharmacy: true, isNewStore: true),
        // const CommonConditionView(),
        // const PromotionalBannerView(),

      ]),
    );
  }
}

class PharmacyPromotionalBanner extends StatelessWidget {
  const PharmacyPromotionalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1F1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FLAT 20% OFF',
                      style: robotoBold.copyWith(fontSize: 18, color: Colors.black),
                    ),
                    Text(
                      'On Health Care Products',
                      style: robotoMedium.copyWith(fontSize: 12, color: Colors.black.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use Code: HEALTH20',
                      style: robotoBold.copyWith(fontSize: 14, color: const Color(0xFF1B5E5E)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 100),
            ],
          ),
          Positioned(
            right: 0,
            top: -10,
            bottom: -10,
            child: Image.asset(
              Images.pharmacyBanner,
              width: 140,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
