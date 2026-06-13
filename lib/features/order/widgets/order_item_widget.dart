import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/order/domain/models/order_details_model.dart';
import 'package:handy_allinone/features/order/domain/models/order_model.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  const OrderItemWidget({super.key, required this.order, required this.orderDetails});
  
  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText = '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';
    if(orderDetails.variation!.isNotEmpty) {
      if(orderDetails.variation!.isNotEmpty) {
        List<String> variationTypes = orderDetails.variation![0].type!.split('-');
        if(variationTypes.length == orderDetails.itemDetails!.choiceOptions!.length) {
          int index = 0;
          for (var choice in orderDetails.itemDetails!.choiceOptions!) {
            variationText = '${variationText!}${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
            index = index + 1;
          }
        }else {
          variationText = orderDetails.itemDetails!.variations![0].type;
        }
      }
    }else if(orderDetails.foodVariation!.isNotEmpty) {
      for(FoodVariation variation in orderDetails.foodVariation!) {
        variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        if(variation.variationValues != null){
          for(VariationValue value in variation.variationValues!) {
            variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
          }
        }
        variationText = '${variationText!})';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        // boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomImage(
                height: 100, width: 90, fit: BoxFit.cover,
                image: '${orderDetails.imageFullUrl}',
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(
                  orderDetails.itemDetails!.name!,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 4),
                        child: Text('Qty:${orderDetails.quantity.toString()}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall,fontWeight:FontWeight.w700,color: Colors.green.shade400)),
                      )),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  ((Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && orderDetails.itemDetails!.unitType != null)
                      || (order.moduleType == AppConstants.food && Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!))
                      ? (Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation! && order.moduleType == AppConstants.food) ? CustomAssetImageWidget(
                    orderDetails.itemDetails!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                    height: 11, width: 11,
                  ) : Container(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      orderDetails.itemDetails!.unitType ?? '',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.grey),
                    ),
                  ) : const SizedBox(),
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(children: [
                Expanded(child: Text(
                  PriceConverter.convertPrice(orderDetails.price),
                  style: robotoMedium, textDirection: TextDirection.ltr,
                )),



                SizedBox(width: orderDetails.itemDetails!.isStoreHalalActive! && orderDetails.itemDetails!.isHalalItem! ? Dimensions.paddingSizeExtraSmall : 0),

                orderDetails.itemDetails!.isStoreHalalActive! && orderDetails.itemDetails!.isHalalItem! ? const CustomAssetImageWidget(
                 Images.halalTag, height: 13, width: 13) : const SizedBox(),

              ]),

              (Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! && addOnText.isNotEmpty) ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  Flexible(child: Text(
                      addOnText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                      ))),
                ]),
              ) : const SizedBox(),

              variationText!.isNotEmpty ? Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  Text('${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  Flexible(child: Text(
                      variationText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                      ))),
                ]),
              ) : const SizedBox(),


            ]),
          ),
        ]),


      ]),
    );
  }
}
