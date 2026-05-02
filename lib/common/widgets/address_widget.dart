import 'package:flutter/cupertino.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/route_helper.dart';
import '../../util/app_constants.dart';

class AddressWidget extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  const AddressWidget({super.key, required this.address, required this.fromAddress, this.onRemovePressed, this.onEditPressed,
    this.onTap, this.fromCheckout = false, this.isSelected = false, this.fromDashBoard = false});

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: fromDashBoard ? BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color:Colors.white,
        border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: isSelected ? 1 : 0),
      ) : fromCheckout ? BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(10),
      ) : BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor, width: isSelected ? 0.5 : 0),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
      ),
      child: CustomInkWell(
        onTap: onTap as void Function()?,
        radius: fromDashBoard ? Dimensions.radiusDefault : fromCheckout ? 0 : Dimensions.radiusSmall,
        child: Row(mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width:double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)
                  ),),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).primaryColor.withValues(alpha:0.1)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                address!.addressType == 'home' ? Images.homeIcon : address!.addressType == 'office' ? Images.workIcon : Images.location,
                                color: Theme.of(context).primaryColor, height: ResponsiveHelper.isDesktop(context) ? 25 : 20, width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            address!.addressType!.tr,
                            maxLines: 3,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),

                        ]),
                        !fromAddress ? Container(
                          height: 38,
                          width: 38,
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade300,
                              )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: FittedBox(
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueGrey, ),
                                onPressed:(){
                                  Get.toNamed(RouteHelper.getEditAddressRoute(address));
                                }

                              ),
                            ),
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 12),
                  child: Text(
                    address!.address!,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey.shade600),
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),

        SizedBox(width: 8,),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           fromAddress ? Container(
             margin: EdgeInsets.all(2),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10),
               color: Colors.white,
                 boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
                 border: Border.all(
                 width: 1,
                 color: Colors.grey.shade300,
               )
             ),
             child: Padding(
               padding: const EdgeInsets.all(2.0),
               child: IconButton(
                 icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 25),
                 onPressed: onEditPressed as void Function()?,
               ),
             ),
           ) : const SizedBox(),
           SizedBox(height: 10,),
           fromAddress ? Container(
             margin: EdgeInsets.all(2),
             decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(10),
                 color: Colors.white,
                 boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
                 border: Border.all(
                   width: 1,
                   color: Colors.grey.shade300,
                 )
             ),
             child: IconButton(
               icon: const Icon(Icons.delete_outline, color: Colors.red, size: 25),
               onPressed: onRemovePressed as void Function()?,
             ),
           ) : const SizedBox(),
         ]
        ),
          ],
        ),
      ),
    );
  }
}

class AddressWidget1 extends StatelessWidget {
  final AddressModel? address;
  final bool fromAddress;
  final bool fromCheckout;
  final Function? onRemovePressed;
  final Function? onEditPressed;
  final Function? onTap;
  final bool isSelected;
  final bool fromDashBoard;
  const AddressWidget1({super.key, required this.address, required this.fromAddress, this.onRemovePressed, this.onEditPressed,
    this.onTap, this.fromCheckout = false, this.isSelected = false, this.fromDashBoard = false});

  @override
  Widget build(BuildContext context) {
    debugPrint("kdndk: $isSelected");
    return Padding(
      padding: EdgeInsets.only(bottom: fromCheckout ? 0 : Dimensions.paddingSizeSmall),
      child: Container(
        decoration: fromDashBoard ? BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: isSelected ? 1 : 0),
        ) : fromCheckout ? const BoxDecoration() : BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor, width: isSelected ? 0.5 : 0),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 5, spreadRadius: 1)],
        ),
        child: CustomInkWell(
          onTap: onTap as void Function()?,
          radius: fromDashBoard ? Dimensions.radiusDefault : fromCheckout ? 0 : Dimensions.radiusSmall,
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Image.asset(
                        address!.addressType == 'home' ? Images.homeIcon : address!.addressType == 'office' ? Images.workIcon : Images.otherIcon,
                        color:isSelected? Theme.of(context).cardColor:Theme.of(context).primaryColor,
                        height: ResponsiveHelper.isDesktop(context) ? 25 : 20, width: ResponsiveHelper.isDesktop(context) ? 25 : 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
      
                      Text(
                        address!.addressType!.tr,
                        maxLines: 3,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge,color: isSelected?Theme.of(context).cardColor:Theme.of(context).textTheme.titleLarge?.backgroundColor),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Flexible(
                      child: Text(
                        address!.address!,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge,color: isSelected?Theme.of(context).cardColor:Theme.of(context).textTheme.titleLarge?.backgroundColor),
                        maxLines: 5, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ),
      
                fromAddress ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 25),
                  onPressed: onEditPressed as void Function()?,
                ) : const SizedBox(),
      
                fromAddress ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 25),
                  onPressed: onRemovePressed as void Function()?,
                ) : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




///
/// Created by saravanan
/// purpose of the below class it just for show case the
/// available address
///
class AddressWidgetCustom extends StatelessWidget {
  final AddressModel? address;
  const AddressWidgetCustom({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: (address!.addressType != 'home' &&
              address!.addressType != 'office')
              ? Icon(
            Icons.location_on_outlined,
            color: Colors.pink.shade400,
            size: 26,
          )
              : Image.asset(
            address!.addressType == 'home'
                ? Images.homeIcon
                : address!.addressType == 'office'
                ? Images.workIcon
                : Images.otherIcon,
            color: Theme.of(context).primaryColor,
            height: 26,
            width: 26,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address!.addressType!.tr,
                maxLines: 1,
                style: robotoBold.copyWith(
                ),
              ),
              Text(
                address!.address!,
                maxLines: 2,
                style: robotoRegular.copyWith(
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

///
/// created by saravanan
/// purpose of the below class it will have different
/// ui formate.
///
class AddressWidgetCustom2 extends StatelessWidget {
  final AddressModel? address;
  const AddressWidgetCustom2({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          spacing: 10,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (address!.addressType != 'home' &&
                    address!.addressType != 'office')
                    ? Colors.orange[50]
                    : address!.addressType == 'home'
                    ? Colors.green[50]
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: (address!.addressType != 'home' &&
                  address!.addressType != 'office')
                  ? Icon(
                CupertinoIcons.location_fill,
                color: Colors.orange.shade400,
                size: 20,
              )
                  : Image.asset(
                address!.addressType == 'home'
                    ? Images.homeIcon
                    : address!.addressType == 'office'
                    ? Images.workIcon
                    : Images.otherIcon,
                color: address!.addressType == 'home'
                    ? Colors.green.shade400
                    : Colors.blue.shade400,
                height: 20,
                width: 20,
              ),
            ),
            Text(
              address!.addressType!.tr,
              maxLines: 1,
              style: robotoBold.copyWith(
              ),
            ),
          ],
        ),
        Column(
          spacing: 2,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              address!.address!,
              maxLines: 2,
              style: robotoRegular.copyWith(
                color: Colors.black38,
              ),
              textAlign: TextAlign.start,
            ),
            if (address!.contactPersonName != null &&
                address!.contactPersonNumber != null)
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.black54,
                    size: 20,
                  ),
                  Text(
                    address!.contactPersonName!,
                    style: robotoRegular.copyWith(
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const Icon(
                    Icons.circle,
                    color: Colors.black54,
                    size: 5,
                  ),
                  Text(
                    address!.contactPersonNumber!,
                    style: robotoRegular.copyWith(
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              )
          ],
        ),
      ],
    );
  }
}