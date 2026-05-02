import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:handy_allinone/util/images.dart';

class ParcelCarouselBannerSliverWidget extends StatefulWidget {
  const ParcelCarouselBannerSliverWidget({super.key});

  @override
  State<ParcelCarouselBannerSliverWidget> createState() =>
      _ParcelCarouselBannerSliverWidgetState();
}

class _ParcelCarouselBannerSliverWidgetState
    extends State<ParcelCarouselBannerSliverWidget> {
  final ValueNotifier<int> _currentSlider = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CarouselSlider(
                items: List.generate(
                  Images.parcelCarsoulBannerList.length,
                  (e) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      Images.parcelCarsoulBannerList[e],
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                options: CarouselOptions(
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  viewportFraction: 1,
                  aspectRatio: 2.0,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    _currentSlider.value = index;
                  },
                ),
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _currentSlider,
              builder: (c, value, _) {
                return Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    Images.parcelCarsoulBannerList.length,
                    (e) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: e == value ? 30 : 8,
                      decoration: BoxDecoration(
                        color:  const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
