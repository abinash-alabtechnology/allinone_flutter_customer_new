import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:handy_allinone/common/models/transaction_model.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';

class HistoryItemWidget extends StatelessWidget {
  final int index;
  final bool fromWallet;
  final List<Transaction>? data;
  const HistoryItemWidget(
      {super.key,
        required this.index,
        required this.fromWallet,
        required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Flexible(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fromWallet
                ? Row(children: [
              data![index].transactionType == 'order_place' ||
                  data![index].transactionType == 'partial_payment'
                  ? Image.asset(Images.walletDebitIcon,
                  height: 15, width: 15)
                  : Image.asset(Images.walletCreditIcon,
                  height: 15, width: 15),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                data![index].transactionType == 'order_place' ||
                    data![index].transactionType == 'partial_payment'
                    ? '- ${PriceConverter.convertPrice(data![index].debit! + data![index].adminBonus!)}'
                    : '+ ${PriceConverter.convertPrice(data![index].credit! + data![index].adminBonus!)}',
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
              ),
            ])
                : Row(children: [
              data![index].transactionType == 'point_to_wallet'
                  ? Image.asset(Images.debitIcon, height: 13, width: 13)
                  : Image.asset(Images.creditIcon, height: 13, width: 13),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                  data![index].transactionType == 'point_to_wallet'
                      ? '-${data![index].debit!.toStringAsFixed(0)}'
                      : '+${data![index].credit!.toStringAsFixed(0)}',
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                'points'.tr,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor),
              )
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              data![index].transactionType == 'add_fund'
                  ? '${'added_via'.tr} ${data![index].reference!.replaceAll('_', ' ')} ${data![index].adminBonus != 0 ? '(${'bonus'.tr} = ${data![index].adminBonus})' : ''}'
                  : data![index].transactionType == 'partial_payment'
                  ? '${'spend_on_order'.tr} # ${data![index].reference}'
                  : data![index].transactionType == 'loyalty_point'
                  ? 'converted_from_loyalty_point'.tr
                  : data![index].transactionType == 'referrer'
                  ? 'earned_by_referral'.tr
                  : data![index].transactionType == 'order_place'
                  ? '${'order_place'.tr} # ${data![index].reference}'
                  : data![index].transactionType!.tr,
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            DateConverter.dateToDateAndTimeAm(data![index].createdAt!),
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            fromWallet
                ? data![index].transactionType == 'order_place' ||
                data![index].transactionType == 'partial_payment'
                ? 'debit'.tr
                : 'credit'.tr
                : data![index].transactionType == 'point_to_wallet'
                ? 'debit'.tr
                : 'credit'.tr,
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: fromWallet
                    ? data![index].transactionType == 'order_place' ||
                    data![index].transactionType == 'partial_payment'
                    ? Colors.red
                    : Colors.green
                    : data![index].transactionType == 'point_to_wallet'
                    ? Colors.red
                    : Colors.green),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ]),
      index == data!.length - 1
          ? const SizedBox()
          : Padding(
        padding:
        const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: Divider(color: Theme.of(context).disabledColor),
      ),
    ]);
  }
}

///
/// AUTHORE: saravanan
/// PURPOSE: CHANGE THE NEW CARD WIDGET
///

class WalletItem extends StatelessWidget {
  final Transaction data;
  const WalletItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.06,
          vertical: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (data.credit == 0) ?Colors.red.withAlpha(10):Colors.green.withAlpha(10),
              child: Image.asset((data.credit == 0) ?Images.addMoney:Images.spendMoney,height: 20,width: 20,),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (data.credit == 0) ? "Balance Spend" : "Balance Added",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "on ${actualDate(data.createdAt!)}",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        height: 1.2
                    ),

                  ),
                ],
              ),
            ),
            Text(
              (data.credit == 0)
                  ? '- ${PriceConverter.convertPrice(data.debit! + data.adminBonus!)}'
                  : '+ ${PriceConverter.convertPrice(data.credit! + data.adminBonus!)}',
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: (data.credit == 0) ? Colors.red : Colors.green),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }

  String actualDate(DateTime on) {
    String adjustedDate = intl.DateFormat('dd MMM yyyy').format(on);
    String time = intl.DateFormat('hh:mm a').format(on);
    return "$adjustedDate at $time";
  }
}