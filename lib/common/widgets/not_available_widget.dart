import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/store/domain/models/store_model.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotAvailableWidget extends StatelessWidget {
  final double fontSize;
  final bool isStore;
  final bool isAllSideRound;
  final double? radius;
  final Store? store;
  final Item? item;
  const NotAvailableWidget({super.key, this.fontSize = 12, this.isStore = false, this.isAllSideRound = true, this.radius = Dimensions.radiusSmall, this.store, this.item});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, bottom: 0, right: 0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: isAllSideRound ? BorderRadius.circular(radius!) :  BorderRadius.vertical(top: Radius.circular(radius!)),
          color: Colors.black.withValues(alpha: 0.6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*Text(
              isStore ? 'closed_now'.tr : 'not_available_now'.tr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(color: Colors.white, fontSize: item != null ? 14 : fontSize),
            ),
            const SizedBox(height: 4),*/
            Text(
              isStore 
                  ? store != null && store!.active! && store!.schedules != null && store!.schedules!.isNotEmpty
                      ? '${'available_will_be'.tr}\n${getNextAvailableTime(store!.schedules!)}'
                      : ''
                  : item != null && item!.availableTimeStarts != null
                      ? '${'available_will_be'.tr}\n${item!.availableTimeStarts}'
                      : '',
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: item != null ? 18 : fontSize * 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
