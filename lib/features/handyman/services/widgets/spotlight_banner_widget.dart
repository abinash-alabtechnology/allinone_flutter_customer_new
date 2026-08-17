import 'package:flutter/material.dart' hide Banner;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/features/banner/domain/models/banner_model.dart';
import 'package:handy_allinone/util/styles.dart';

class SpotlightBannerWidget extends StatelessWidget {
  final Banner banner;
  final String? categoryName;
  final int? categoryId;
  final VoidCallback? onTap;

  const SpotlightBannerWidget({
    super.key,
    required this.banner,
    this.categoryName,
    this.categoryId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = banner.imageFullUrl != null && banner.imageFullUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              if (hasImage)
                CustomImage(
                  image: banner.imageFullUrl!,
                  width: double.infinity,
                  height: 135.h,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 135.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF7E9D), Color(0xFF9B51E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'SPOTLIGHT',
                          style: robotoRegular.copyWith(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Gap(8.h),
                      Text(
                        banner.title ?? 'Exclusive Offer',
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpotlightCarouselWidget extends StatefulWidget {
  final List<Banner> banners;
  final Function(Banner banner)? onBannerTap;

  const SpotlightCarouselWidget({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  @override
  State<SpotlightCarouselWidget> createState() => _SpotlightCarouselWidgetState();
}

class _SpotlightCarouselWidgetState extends State<SpotlightCarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.banners.length,
          options: CarouselOptions(
            height: 140.h,
            autoPlay: widget.banners.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final banner = widget.banners[index];
            return SpotlightBannerWidget(
              banner: banner,
              onTap: () {
                if (widget.onBannerTap != null) {
                  widget.onBannerTap!(banner);
                }
              },
            );
          },
        ),
        Gap(10.h),
        if (widget.banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.banners.asMap().entries.map((entry) {
              bool isSelected = _currentIndex == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 20.w : 7.w,
                height: 7.h,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFFCBD5E1),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
