import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/parcel/screens/parcel_category_screen.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/parcel/domain/models/parcel_category_model.dart';
class ParcelGrideSliverWidget extends StatelessWidget {
  const ParcelGrideSliverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return parcelController.parcelCategoryList != null
            ? parcelController.parcelCategoryList!.isNotEmpty
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    sliver: SliverList.builder(
                      itemCount: parcelController.parcelCategoryList!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          child: _ParcelCategoryListTile(
                            category: parcelController.parcelCategoryList![index],
                            path: RouteHelper.getParcelLocationRoute(
                              parcelController.parcelCategoryList![index],
                            ),
                          ),
                        );
                      },
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

class _ParcelCategoryListTile extends StatelessWidget {
  final ParcelCategoryModel category;
  final String path;

  const _ParcelCategoryListTile({
    super.key,
    required this.category,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(path),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CachedNetworkImage(
                  imageUrl: category.imageFullUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    category.description ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}
