import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';

class PharmacyOrderAgainView extends StatelessWidget {
  const PharmacyOrderAgainView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? items = itemController.popularItemList;
      if (items == null || items.isEmpty) {
        items = itemController.reviewedItemList;
      }
      if (items == null || items.isEmpty) {
        items = itemController.recommendedItemList;
      }
      if (items == null || items.isEmpty) {
        items = itemController.basicMedicineModel?.products;
      }

      if (items != null && items.isNotEmpty) {
        List<Item> itemList = items;
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Again', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                TextButton(
                  onPressed: () {
                    // Navigate to view all items
                  },
                  child: Text('View all', style: robotoMedium.copyWith(color: const Color(0xFF1B5E5E))),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                Item item = itemList[index];
                double? discount = item.storeId != null ? item.discount : 0;
                String? discountType = item.storeId != null ? item.discountType : 'percent';
                double priceWithDiscount = PriceConverter.convertWithDiscount(item.price, discount, discountType)!;
                
                return CustomInkWell(
                  onTap: () => itemController.navigateToItemPage(item, context),
                  radius: 12,
                  child: Container(
                    width: 230,
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: 10),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 65,
                        width: 65,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImage(
                            image: item.imageFullUrl ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name ?? '',
                              style: robotoBold.copyWith(fontSize: 14, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.unitType ?? 'Tablet',
                              style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  PriceConverter.convertPrice(priceWithDiscount),
                                  style: robotoBold.copyWith(fontSize: 16, color: Colors.black),
                                ),
                                InkWell(
                                  onTap: () => itemController.itemDirectlyAddToCart(item, context),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2), width: 1),
                                    ),
                                    child: const Icon(Icons.add, color: Color(0xFF4CAF50), size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                );
              },
            ),
          ),
        ],
      );
      } else {
        return const SizedBox();
      }
    });
  }
}
