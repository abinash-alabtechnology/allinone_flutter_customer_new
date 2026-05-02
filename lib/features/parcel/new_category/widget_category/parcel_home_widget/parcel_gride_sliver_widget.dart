import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/parcel/screens/parcel_category_screen.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';

class ParcelGrideSliverWidget extends StatelessWidget {
  const ParcelGrideSliverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return parcelController.parcelCategoryList != null
            ? parcelController.parcelCategoryList!.isNotEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: Dimensions.paddingSizeDefault,
                        mainAxisSpacing: Dimensions.paddingSizeDefault,
                      ),
                      itemBuilder: (c, i) {
                        return _ParcelCardImageHolder(
                          path: RouteHelper.getParcelLocationRoute(
                            parcelController.parcelCategoryList![i],
                          ),
                          image:
                              '${parcelController.parcelCategoryList![i].imageFullUrl}',
                        );
                      },
                      itemCount: parcelController.parcelCategoryList!.length,
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Text('no_parcel_category_found'.tr),
                  )
            : SliverToBoxAdapter(
                child: ParcelShimmer(
                  isEnabled: parcelController.parcelCategoryList == null,
                  isDeliveryItem: true,
                ),
              );
      },
    );
  }
}

class _ParcelCardImageHolder extends StatelessWidget {
  final String path;
  final String image;
  const _ParcelCardImageHolder({
    // ignore: unused_element_parameter
    super.key,
    required this.path,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          path,
        );
      },
      child: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.fill,
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error),
        ),
      ),
    );
  }
}
