import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:handy_allinone/features/parcel/new_category/widget_category/parcel_home_widget/parcel_icon_holder_widget.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../../../home/screens/modules/grocery_home_screen.dart';

class ParcelBannerSliverWidget extends SliverToBoxAdapter {
  final ScrollController controller;
  final ValueListenable<String?> weatherType;

  const ParcelBannerSliverWidget({super.key, required this.controller, required this.weatherType});
  final Color backgroundColor = const Color(0xFF2C2C2C);

  @override
  Widget? get child => Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            controller.animateTo(
              500,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
          },
          child: Stack(
            children: [
              _contentOfBanner(),
              ValueListenableBuilder<String?>(
                valueListenable: weatherType,
                builder: (_, value, __) {
                  if (value == "RAINY") {
                    return const Positioned.fill(
                      child: IgnorePointer(
                        child: RainAnimation(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              ValueListenableBuilder<String?>(
                valueListenable:weatherType,
                builder: (_, value, __) {
                  if (value == "RAINY") {
                    return const Positioned.fill(
                      child: IgnorePointer(
                        child: ThunderFlash(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );

  Widget _contentOfBanner() {
    return Column(
      spacing: 18,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Send Packages \nAnywhere",
          style: robotoBold.copyWith(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "Fast, reliable delivery with real-time tracking",
          style: robotoMedium.copyWith(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            spacing: 10,
            children: [
              SvgPicture.asset(
                Images.truckSearch,
                height: 25,
                width: 25,
              ),
              Expanded(
                child: Text(
                  "Start Sending",
                  style: robotoMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ParcelIconHolderWidget(
                icon: Icons.arrow_downward_rounded,
                iconColor: backgroundColor,
                backgroundColor: Colors.black12,
              )
            ],
          ),
        )
      ],
    );
  }
}
