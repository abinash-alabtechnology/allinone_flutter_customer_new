import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class DetailsWidget extends StatelessWidget {
  final String title;
  final AddressModel? address;
  const DetailsWidget({super.key, required this.title, required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text(title, style: robotoMedium),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      Text(
        address!.contactPersonName ?? '',
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
      ),

      Text(
        address!.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),

      Wrap(children: [
        (address!.streetNumber != null && address!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${address!.streetNumber!}, ',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),

        (address!.house != null && address?.house != 'null' && address!.house!.isNotEmpty) ? Text('${'house'.tr}: ${address!.house!}, ',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),

        (address!.floor != null && address!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${address!.floor!}',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),
      ]),

      Text(
        address!.contactPersonNumber ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),

      AuthHelper.isGuestLoggedIn() ? Text(
        address?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ) : const SizedBox(),

    ]);
  }
}
class DetailsWidget1 extends StatelessWidget {
  final String? title;
  final AddressModel? address;
  const DetailsWidget1({super.key,  this.title, required this.address});

  @override
  Widget build(BuildContext context) {

    String formatPhoneNumber(String? phone) {
      if (phone == null || phone.isEmpty) return '';

      // Remove all non-digit characters
      String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

      // If number starts with country code (like 91) and length > 10, trim it
      if (cleaned.length > 10) {
        cleaned = cleaned.substring(cleaned.length - 10);
      }

      return cleaned;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      if (title != null && title!.isNotEmpty) ...[
        Text(
          title!,
          style: robotoMedium,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      ],

      Row(
        children: [
          Text(
            "${address!.contactPersonName ?? ''} .",
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
          ),
          Text(
            formatPhoneNumber(address?.contactPersonNumber),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ],
      ),
SizedBox(height: Dimensions.paddingSizeExtraSmall,),
      Text(
        address!.address ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
      ),

      Wrap(children: [
        (address!.streetNumber != null && address!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${address!.streetNumber!}, ',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),

        (address!.house != null && address?.house != 'null' && address!.house!.isNotEmpty) ? Text('${'house'.tr}: ${address!.house!}, ',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),

        (address!.floor != null && address!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${address!.floor!}',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),
      ]),

      // Text(
      //   address!.contactPersonNumber ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
      //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      // ),

      AuthHelper.isGuestLoggedIn() ? Text(
        address?.email ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ) : const SizedBox(),

    ]);
  }
}