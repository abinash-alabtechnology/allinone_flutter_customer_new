import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

import '../../util/images.dart';

class OrganicTag extends StatelessWidget {
  final double? fontSize;
  final Item item;
  final bool placeTop;
  final bool placeInImage;
  final bool fromDetails;
  const OrganicTag({super.key, this.fontSize, required this.item, this.placeTop = false, this.placeInImage = false, this.fromDetails = false});

  @override
  Widget build(BuildContext context) {
    return fromDetails ? item.organic == 1 && item.moduleType == 'grocery' ?
    Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
      margin: EdgeInsets.only(bottom: fromDetails ? Dimensions.paddingSizeSmall : 0),
      decoration: BoxDecoration(
        color: Colors.lightGreenAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(Icons.eco,
            color: Colors.lightGreenAccent,
          ),
          SizedBox(width: 5,),
          Text(
            'organic'.tr,
            style: robotoMedium.copyWith(
              color: Colors.lightGreenAccent,
              fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ) : const SizedBox() : Positioned(
      top: placeInImage ? null : placeTop ? 10 : 40, left: placeInImage ? 0 : 10, right: placeInImage ? 0 : null, bottom: placeInImage ? 0 : null,
      child: item.organic == 1 && item.moduleType == 'grocery' ? Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
        margin: EdgeInsets.only(bottom: fromDetails ? Dimensions.paddingSizeSmall : 0),
        decoration: BoxDecoration(
           color: Color(0xFFDBEDC7),
          borderRadius: fromDetails ? BorderRadius.circular(Dimensions.radiusSmall) : placeInImage ? const BorderRadius.vertical(
            bottom: Radius.circular(Dimensions.radiusDefault),
          ) : BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.eco,
              size: 12,
              color: Colors.green.shade500,
            ),
            SizedBox(width: 5,),
            Text(
              'organic'.tr,
              style: robotoMedium.copyWith(
                color: Colors.lightGreen,
                fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 12),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ) : const SizedBox(),
    );
  }
}
class OrganicTag1 extends StatelessWidget {
  final double? fontSize;
  final Item item;
  final bool placeTop;
  final bool placeInImage;
  final bool fromDetails;
  const OrganicTag1(
      {super.key,
        this.fontSize,
        required this.item,
        this.placeTop = false,
        this.placeInImage = false,
        this.fromDetails = false});

  @override
  Widget build(BuildContext context) {
    return fromDetails
        ? item.organic == 1 && item.moduleType == 'grocery'
        ? Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall, vertical: 3),
      margin: EdgeInsets.only(
          bottom: fromDetails ? Dimensions.paddingSizeSmall : 0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        'organic'.tr,
        style: robotoMedium.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: fontSize ??
              (ResponsiveHelper.isMobile(context) ? 10 : 12),
        ),
        textAlign: TextAlign.center,
      ),
    )
        : const SizedBox()
        : Positioned(
      bottom: 10,
      left: 15,
      child: item.organic == 1 && item.moduleType == 'grocery'
          ? Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall, vertical: 3),
          margin: EdgeInsets.only(
              bottom: fromDetails ? Dimensions.paddingSizeSmall : 0),
          decoration: BoxDecoration(
            borderRadius: fromDetails
                ? BorderRadius.circular(Dimensions.radiusSmall)
                : placeInImage
                ? const BorderRadius.vertical(
              bottom:
              Radius.circular(Dimensions.radiusDefault),
            )
                : BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Image.asset(
            Images.organic,
            height: 25,
            width: 25,
            fit: BoxFit.fill,
          )
        // Text(
        //   'organic'.tr,
        //   style: robotoMedium.copyWith(
        //     color: Colors.white,
        //     fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 12),
        //   ),
        //   textAlign: TextAlign.center,
        // ),
      )
          : const SizedBox(),
    );
  }
}
class OrganicTagGrocery extends StatelessWidget {
  final double? fontSize;
  final Item item;
  final bool placeTop;
  final bool placeInImage;
  final bool fromDetails;
  const OrganicTagGrocery(
      {super.key,
        this.fontSize,
        required this.item,
        this.placeTop = false,
        this.placeInImage = false,
        this.fromDetails = false});

  @override
  Widget build(BuildContext context) {
    return fromDetails
        ? item.organic == 1 && item.moduleType == 'grocery'
        ? Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall, vertical: 3),
      margin: EdgeInsets.only(
          bottom: fromDetails ? Dimensions.paddingSizeSmall : 0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        'organic'.tr,
        style: robotoMedium.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: fontSize ??
              (ResponsiveHelper.isMobile(context) ? 10 : 12),
        ),
        textAlign: TextAlign.center,
      ),
    )
        : const SizedBox()
        : item.organic == 1 && item.moduleType == 'grocery'
            ? Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall, vertical: 3),
            margin: EdgeInsets.only(
                bottom: fromDetails ? Dimensions.paddingSizeSmall : 0),
            decoration: BoxDecoration(
              borderRadius: fromDetails
                  ? BorderRadius.circular(Dimensions.radiusSmall)
                  : placeInImage
                  ? const BorderRadius.vertical(
                bottom:
                Radius.circular(Dimensions.radiusDefault),
              )
                  : BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Image.asset(
              Images.organic,
              height: 25,
              width: 25,
              fit: BoxFit.fill,
            )
          // Text(
          //   'organic'.tr,
          //   style: robotoMedium.copyWith(
          //     color: Colors.white,
          //     fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 10 : 12),
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        )
            : const SizedBox();
  }
}
