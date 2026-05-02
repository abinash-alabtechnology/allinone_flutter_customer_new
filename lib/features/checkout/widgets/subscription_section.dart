import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

import 'package:handy_allinone/util/app_constants.dart';

class SubscriptionSection extends StatefulWidget {
  final CheckoutController checkoutController;
  const SubscriptionSection({super.key, required this.checkoutController});

  @override
  State<SubscriptionSection> createState() => _SubscriptionSectionState();
}

class _SubscriptionSectionState extends State<SubscriptionSection> {
  @override
  Widget build(BuildContext context) {
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return Padding(      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
child:Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('subscription_details'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('start_date'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: tomorrow,
                  firstDate: tomorrow,
                  lastDate: tomorrow.add(const Duration(days: 365)), // Allow any month in the future
                );
                if (picked != null) {
                  String startDate = DateConverter.dateToDate(picked);
                  String endDate = widget.checkoutController.endDate ?? startDate;
                  widget.checkoutController.setSubscriptionDates(startDate, endDate);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).disabledColor),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(children: [
                  Text(widget.checkoutController.startDate ?? 'select_start_date'.tr, style: robotoRegular),
                  const Spacer(),
                  const Icon(Icons.calendar_today, size: 16),
                ]),
              ),
            ),
          ])),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('end_date'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            InkWell(
              onTap: () async {
                DateTime first = widget.checkoutController.startDate != null 
                    ? DateConverter.dateTimeStringToDate('${widget.checkoutController.startDate!} 00:00:00') 
                    : tomorrow;
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: first,
                  firstDate: first,
                  lastDate: first.add(const Duration(days: AppConstants.subscriptionDateRange)),
                );
                if (picked != null) {
                  widget.checkoutController.setSubscriptionDates(widget.checkoutController.startDate ?? DateConverter.dateToDate(first), DateConverter.dateToDate(picked));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).disabledColor),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(children: [
                  Text(widget.checkoutController.endDate ?? 'select_end_date'.tr, style: robotoRegular),
                  const Spacer(),
                  const Icon(Icons.calendar_today, size: 16),
                ]),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text('preferred_timing'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        InkWell(
          onTap: () async {
            List<String> timeSlots = [];
            for (int i = 0; i < 24; i++) {
              String hour = i < 10 ? '0$i' : '$i';
              timeSlots.add('$hour:00:00');
            }

            Get.bottomSheet(
              Container(
                height: 300,
                color: Theme.of(context).cardColor,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text('select_time'.tr, style: robotoMedium),
                  ),
                  Expanded(child: ListView.builder(
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(timeSlots[index]),
                        onTap: () {
                          widget.checkoutController.setSubscriptionTime(timeSlots[index]);
                          Get.back();
                        },
                      );
                    },
                  )),
                ]),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).disabledColor),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(children: [
              Text(widget.checkoutController.dropTime ?? 'select_time'.tr, style: robotoRegular),
              const Spacer(),
              const Icon(Icons.access_time, size: 16),
            ]),
          ),
        ),
      ]),
    ),);
  }
}
