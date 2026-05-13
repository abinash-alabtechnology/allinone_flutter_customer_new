// import 'package:flutter/material.dart';
// import 'package:timelines_plus/timelines_plus.dart';
// import '../widget_category/parcel_custom_appbar.dart';
//
// // class ParcelNewRequestScreen extends StatefulWidget {
// //   const ParcelNewRequestScreen({super.key});
// //
// //   @override
// //   State<ParcelNewRequestScreen> createState() => _ParcelNewRequestScreenState();
// // }
// //
// // class _ParcelNewRequestScreenState extends State<ParcelNewRequestScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: const PreferredSize(
// //           preferredSize: Size.fromHeight(55),
// //           child: ParcelCustomAppbar(title: "PARCEL REQUEST")),
// //       body: CustomScrollView(
// //         slivers: [
// //           SliverToBoxAdapter(
// //             child: SizedBox(
// //               height: 100,
// //               width: double.infinity,
// //               child: Timeline.tileBuilder(
// //                 builder: TimelineTileBuilder.connected(
// //                   connectionDirection: ConnectionDirection.after,
// //                   indicatorPositionBuilder: (context, index) => 0.3,
// //                   nodePositionBuilder: (context, index) => 0.2,
// //                   indicatorBuilder: (context, index) => Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       DotIndicator(
// //                         size: 25,
// //                         color: Theme.of(context).primaryColor,
// //                         child: Center(
// //                           child: Text(
// //                             index.toString(),
// //                           ),
// //                         ),
// //                       ),
// //                       Text("${index + 1}")
// //                     ],
// //                   ),
// //                   connectorBuilder: (context, index, type) =>
// //                       const SolidLineConnector(),
// //                   itemExtentBuilder: (context, index) =>
// //                       (MediaQuery.sizeOf(context).width / 2.6),
// //                   contentsAlign: ContentsAlign.basic,
// //                   itemCount: 3,
// //                 ),
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 scrollDirection: Axis.horizontal,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// ///! header of the parcelNewRequestScreen it will show the process to complete
//
// class HeaderProcessTracker extends StatelessWidget {
//   const HeaderProcessTracker({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: Timeline.builder(
//         itemBuilder: (c, i) => Text("index $i"),
//         itemCount: 3,
//         physics: const NeverScrollableScrollPhysics(),
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/custom_text_field.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/features/checkout/widgets/guest_create_account.dart';
import 'package:handy_allinone/features/checkout/widgets/tips_widget.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/features/parcel/domain/models/parcel_category_model.dart';
import 'package:handy_allinone/features/parcel/widgets/delivery_instruction_bottom_sheet_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/helper/string_extension.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:lottie/lottie.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:dotted_line/dotted_line.dart';
import '../../../checkout/widgets/payment_section.dart';

class ParcelNewRequestScreen extends StatefulWidget {
  final ParcelCategoryModel parcelCategory;
  final AddressModel pickedUpAddress;
  final AddressModel destinationAddress;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;

  const ParcelNewRequestScreen({
    super.key,
    required this.parcelCategory,
    required this.pickedUpAddress,
    required this.destinationAddress,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
  });

  @override
  State<ParcelNewRequestScreen> createState() =>
      _ParcelNewRequestScreenState();
}

class _ParcelNewRequestScreenState extends State<ParcelNewRequestScreen> {
  bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
  final TextEditingController _guestPasswordController =
      TextEditingController();
  final TextEditingController _guestConfirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        double charge = -1;
        double total = 0;
        double dmTips = 0;
        double additionalCharge =
            Get.find<SplashController>().configModel!.additionalChargeStatus!
            ? Get.find<SplashController>().configModel!.additionCharge!
            : 0;
        bool isOfflinePaymentActive = Get.find<SplashController>()
            .configModel!
            .offlinePaymentStatus! /* && CheckoutHelper.checkZoneOfflinePaymentOnOff(addressModel: AddressHelper.getUserAddressFromSharedPref())*/;

        if (parcelController.distance != -1 &&
            parcelController.extraCharge != null) {
          charge = _calculateParcelDeliveryCharge(
            parcelController: parcelController,
            parcelCategory: widget.parcelCategory,
            zoneId: widget.pickedUpAddress.zoneId!,
          );
          dmTips = parcelController.tips;
          double expressCharge = parcelController.deliveryTypeIndex == 1
              ? (Get.find<SplashController>().configModel!.expressCheckoutCharge ??
                  150.0)
              : 0;
          total = charge + dmTips + additionalCharge + expressCharge;
        }
        return Scaffold(
          appBar: CustomAppBar3(title: "PARCEL REQUEST", backButton: true),
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: HeaderProcessTrackerDelegate(height: 150),
              ),
              ParcelDetails(
                parcelCategory: widget.parcelCategory,
                pickedUpAddress: widget.pickedUpAddress,
                destinationAddress: widget.destinationAddress,
              ),
              ParcelPickupAndDropDetails(
                destinationAddress: widget.destinationAddress,
                pickedUpAddress: widget.pickedUpAddress,
              ),
              DeliveryInformation(charge: charge),
              const DeliveryInstructions(),
              DeliveryManTips(
                isGuestLoggedIn: isGuestLoggedIn,
                guestConfirmPasswordController: _guestConfirmPasswordController,
                guestPasswordController: _guestPasswordController,
              ),
              WhoWantToPay(
                isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
              ),
              const DeliveryType(),
              SelectPaymentMethod(
                isCashOnDeliveryActive: widget.isCashOnDeliveryActive,
                isDigitalPaymentActive: widget.isDigitalPaymentActive,
                isGuestLoggedIn: isGuestLoggedIn,
              ),
              OrderSummaryBooking(total: total, charge: charge, dmTips: dmTips),
            ],
          ),
          bottomNavigationBar: ConfirmParcelRequest(
            total: total,
            isGuestLoggedIn: isGuestLoggedIn,
            charge: charge,
            parcelCategory: widget.parcelCategory,
            pickedUpAddress: widget.pickedUpAddress,
            destinationAddress: widget.destinationAddress,
            guestConfirmPasswordController: _guestConfirmPasswordController,
            guestPasswordController: _guestPasswordController,
          ),
        );
      },
    );
  }
}



class HeaderProcessTrackerDelegate extends SliverPersistentHeaderDelegate {
  final double height;

  HeaderProcessTrackerDelegate({this.height = 150});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 75,
            width: double.infinity,
            child: Timeline.tileBuilder(
              padding: EdgeInsets.zero,
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.after,
                indicatorPositionBuilder: (context, index) => 0.2,
                nodePositionBuilder: (context, index) => 0.2,
                indicatorBuilder: (context, index) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: getIndicator(index, context),
                    ),
                    Text(
                      getTitle(index),
                      style: index < 2
                          ? robotoRegular.copyWith(
                              color: Theme.of(context).primaryColor,
                            )
                          : robotoRegular.copyWith(),
                    ),
                  ],
                ),
                connectorBuilder: (context, index, type) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SolidLineConnector(
                    color: index < 1
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                  ),
                ),
                itemExtentBuilder: (context, index) =>
                    MediaQuery.sizeOf(context).width / 2.6,
                contentsAlign: ContentsAlign.basic,
                itemCount: 3,
              ),
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Please review you request and select a payment method",
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class ParcelPickupAndDropDetails extends StatelessWidget {
  final AddressModel pickedUpAddress;
  final AddressModel destinationAddress;

  const ParcelPickupAndDropDetails({
    super.key,
    required this.pickedUpAddress,
    required this.destinationAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 820,
        child: Timeline.tileBuilder(
          padding: EdgeInsets.zero,
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.after,
            indicatorPositionBuilder: (context, index) => 0.1,
            nodePositionBuilder: (context, index) => 0.04,
            indicatorBuilder: (context, index) =>
                DotIndicator(size: 20, color: Theme.of(context).primaryColor),
            connectorBuilder: (context, index, type) => DashedLineConnector(
              color: Theme.of(context).primaryColor,
              dash: 5,
              gap: 5,
            ),
            itemExtentBuilder: (context, index) => 400,
            contentsAlign: ContentsAlign.basic,
            itemCount: 2,
            contentsBuilder: (context, index) => index == 0
                ? PickUPAddressDetails(pickedUpAddress: pickedUpAddress)
                : DropAddressDetails(destinationAddress: destinationAddress),
          ),
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }
}

///! Parcel details like name ad image
class ParcelDetails extends StatelessWidget {
  final ParcelCategoryModel parcelCategory;
  final AddressModel pickedUpAddress;
  final AddressModel destinationAddress;

  const ParcelDetails({
    super.key,
    required this.parcelCategory,
    required this.pickedUpAddress,
    required this.destinationAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.6, color: Colors.white38),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 0.8,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomImage(
                  fit: BoxFit.fitWidth,
                  image: '${parcelCategory.imageFullUrl}',
                  height: 75,
                  width: 78,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parcelCategory.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBlack.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    parcelCategory.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///! Delivery Information like distance and delivery fee
class DeliveryInformation extends StatelessWidget {
  final double charge;

  const DeliveryInformation({super.key, required this.charge});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delivery Information",
                  style: robotoBold.copyWith(fontSize: 16),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.3),
                            ),
                            child: Icon(
                              Icons.route,
                              color: Theme.of(context).primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Text(
                            parcelController.distance == -1
                                ? 'calculating'.tr
                                : '${parcelController.distance!.toStringAsFixed(2)} ${'km'.tr}',
                            style: robotoBold,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 14,
                          bottom: 14,
                        ),
                        // decoration: BoxDecoration(
                        //   color: Colors.grey.shade100,
                        //   borderRadius: BorderRadius.circular(12),
                        //   border: Border.all(
                        //     width: 0.6,
                        //     color: Colors.grey.shade400,
                        //   ),
                        // ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.3),
                              ),
                              child: Icon(
                                Icons.delivery_dining_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Text(
                              parcelController.distance == -1
                                  ? 'calculating'.tr
                                  : PriceConverter.convertPrice(charge),
                              style: robotoBold.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

///! Delivery insturctions add delivery insturctions here
class DeliveryInstructions extends StatelessWidget {
  const DeliveryInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          bool haveValue =
              (parcelController.selectedIndexNote != -1 ||
              parcelController.customNote!.isNotEmpty);
          return Container(
            margin: const EdgeInsets.only(left: 12, right: 12, top: 18),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text("Delivery Instructions", style: robotoMedium),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.bottomSheet(
                          const DeliveryInstructionBottomSheetWidget(),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                        );
                      },
                      label: Text(
                        "Add",
                        style: robotoBold.copyWith(color: Colors.white),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                haveValue
                    ? Row(
                        children: [
                          Image.asset(
                            Images.parcelInstructionIcon,
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                parcelController.selectedIndexNote != -1
                                    ? Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              parcelController
                                                      .parcelInstructionList![parcelController
                                                          .selectedIndexNote!]
                                                      .instruction ??
                                                  '',
                                              style: robotoMedium.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              parcelController
                                                  .setInstructionselectedIndex(
                                                    -1,
                                                    notify: false,
                                                  );
                                              parcelController
                                                  .setCustomNoteController('');
                                              Get.find<ParcelController>()
                                                  .setSelectedIndex(-1);
                                              Get.find<ParcelController>()
                                                  .setCustomNote('');
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                parcelController.customNote!.isNotEmpty
                                    ? Text(
                                        parcelController.customNote ?? '',
                                        style: robotoMedium.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Add special delivery instructions",
                              style: robotoBold.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Help the delivery partner with specific details",
                              style: robotoRegular.copyWith(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

///! Delivery Man tips
class DeliveryManTips extends StatefulWidget {
  final bool isGuestLoggedIn;
  final TextEditingController guestPasswordController;
  final TextEditingController guestConfirmPasswordController;

  const DeliveryManTips({
    super.key,
    required this.isGuestLoggedIn,
    required this.guestPasswordController,
    required this.guestConfirmPasswordController,
  });

  @override
  State<DeliveryManTips> createState() => _DeliveryManTipsState();
}

class _DeliveryManTipsState extends State<DeliveryManTips> {
  final TextEditingController _tipController = TextEditingController();
  final FocusNode _guestPasswordNode = FocusNode();
  final FocusNode _guestConfirmPasswordNode = FocusNode();
  bool isConfettiVisible = false;
  late Timer _timer = Timer(Duration.zero, () {});

  void _showConfetti() {
    setState(() {
      isConfettiVisible = true;
    });

    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        isConfettiVisible = false;
      });
    });
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          bool haveTip =
              ((parcelController.selectedTips ==
                  AppConstants.tips.length - 1) &&
              parcelController.canShowTipsField);
          return Container(
            margin: const EdgeInsets.only(left: 12, right: 12, top: 13),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                widget.isGuestLoggedIn
                    ? GuestCreateAccount(
                        guestPasswordController: widget.guestPasswordController,
                        guestConfirmPasswordController:
                            widget.guestConfirmPasswordController,
                        guestPasswordNode: _guestPasswordNode,
                        guestConfirmPasswordNode: _guestConfirmPasswordNode,
                        fromParcel: true,
                      )
                    : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                (Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                    ? Stack(
                      children: [
                        Container(
                            color: Theme.of(context).cardColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                deliveryTipTitle(),
                                deliveryTipDescription(),
                                if (!haveTip)
                                  SizedBox(
                                    height: 65,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(left: 2),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: AppConstants.tips.length,
                                      itemBuilder: (context, index) {
                                        return TipsWidgetParcel(
                                          title: AppConstants.tips[index] == '0'
                                              ? "No Tip"
                                              : (index !=
                                                    AppConstants.tips.length - 1)
                                              ? PriceConverter.convertPrice(
                                                  double.parse(
                                                    AppConstants.tips[index]
                                                        .toString(),
                                                  ),
                                                  forDM: true,
                                                )
                                              : AppConstants.tips[index].tr,
                                          isSelected:
                                              parcelController.selectedTips ==
                                              index,
                                          isSuggested:
                                              index != 0 &&
                                              AppConstants.tips[index] ==
                                                  parcelController.mostDmTipAmount
                                                      .toString(),
                                          onTap: () {
                                            index!=0?_showConfetti():null;
                                            parcelController.updateTips(index);
                                            if (parcelController.selectedTips !=
                                                    0 &&
                                                parcelController.selectedTips !=
                                                    AppConstants.tips.length - 1) {
                                              parcelController.addTips(
                                                double.parse(
                                                  AppConstants.tips[index],
                                                ),
                                              );
                                            }
                                            if (parcelController.selectedTips ==
                                                AppConstants.tips.length - 1) {
                                              parcelController.showTipsField();
                                            }
                                            _tipController.text = parcelController
                                                .tips
                                                .toString();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(
                                  height: haveTip
                                      ? Dimensions.paddingSizeExtraSmall
                                      : 0,
                                ),

                                // parcelController.selectedTips ==
                                //         AppConstants.tips.length - 1
                                //     ? const SizedBox()
                                //     : ListTile(
                                //         onTap: () =>
                                //             parcelController.toggleDmTipSave(),
                                //         leading: Checkbox(
                                //           visualDensity: const VisualDensity(
                                //               horizontal: -4, vertical: -4),
                                //           activeColor:
                                //               Theme.of(context).primaryColor,
                                //           value: parcelController.isDmTipSave,
                                //           onChanged: (bool? isChecked) =>
                                //               parcelController.toggleDmTipSave(),
                                //         ),
                                //         title: Text('save_for_later'.tr,
                                //             style: robotoMedium.copyWith(
                                //                 color: Theme.of(context)
                                //                     .primaryColor)),
                                //         contentPadding: EdgeInsets.zero,
                                //         visualDensity: const VisualDensity(
                                //             horizontal: 0, vertical: -4),
                                //         dense: true,
                                //         horizontalTitleGap: 0,
                                //       ),
                                SizedBox(
                                  height:
                                      parcelController.selectedTips ==
                                          AppConstants.tips.length - 1
                                      ? Dimensions.paddingSizeSmall
                                      : 0,
                                ),

                                parcelController.selectedTips ==
                                        AppConstants.tips.length - 1
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextField(
                                              titleText: 'enter_amount'.tr,
                                              controller: _tipController,
                                              inputAction: TextInputAction.done,
                                              inputType: TextInputType.number,
                                              onSubmit: (value) {
                                                if (value.isNotEmpty) {
                                                  if (double.parse(value) >= 0) {
                                                    parcelController.addTips(
                                                      double.parse(value),
                                                    );
                                                  } else {
                                                    showCustomSnackBar(
                                                      'tips_can_not_be_negative'.tr,
                                                    );
                                                  }
                                                } else {
                                                  parcelController.addTips(0.0);
                                                }
                                              },
                                              onChanged: (String value) {
                                                if (value.isNotEmpty) {
                                                  if (double.parse(value) >= 0) {
                                                    parcelController.addTips(
                                                      double.parse(value),
                                                    );
                                                  } else {
                                                    showCustomSnackBar(
                                                      'tips_can_not_be_negative'.tr,
                                                    );
                                                  }
                                                } else {
                                                  parcelController.addTips(0.0);
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              parcelController.updateTips(0);
                                              parcelController.showTipsField();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.5),
                                              ),
                                              padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeSmall,
                                              ),
                                              child: const Icon(Icons.clear),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        if (isConfettiVisible)
                          Positioned(
                            left: 0,
                            bottom: -40,
                            right: 0,
                            child: Lottie.asset(
                              'assets/animation/c.json',
                              repeat: false,
                              animate: true,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox();
                              },
                            ),
                          ),
                      ],
                    )
                    : const SizedBox.shrink(),
                SizedBox(
                  height:
                      (Get.find<SplashController>().configModel!.dmTipsStatus ==
                          1)
                      ? Dimensions.paddingSizeExtraSmall
                      : 0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget deliveryTipTitle() => Padding(
    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    child: Row(
      spacing: 8,
      children: [
        Icon(Icons.volunteer_activism, color: Theme.of(context).primaryColor),
        Text(
          "Tip your Delivery Partner",
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
      ],
    ),
  );

  Widget deliveryTipDescription() => Padding(
    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    child: Text(
      "Add a tip to Thank your delivery partner",
      style: robotoRegular.copyWith(color: Colors.black45),
    ),
  );
}

///! who want to pay for delivery ?
class WhoWantToPay extends StatelessWidget {
  final bool isCashOnDeliveryActive;

  const WhoWantToPay({super.key, required this.isCashOnDeliveryActive});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          return Container(
            margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text("Who Pays?", style: robotoBold.copyWith()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => parcelController.setPayerIndex(0, true),
                          child: whoPayContainer(
                            parcelController.payerIndex == 0,
                            parcelController.payerTypes[0],
                            context,
                          ),
                        ),
                      ),
                      isCashOnDeliveryActive
                          ? Expanded(
                              child: InkWell(
                                onTap: () =>
                                    parcelController.setPayerIndex(1, true),
                                child: whoPayContainer(
                                  parcelController.payerIndex == 1,
                                  parcelController.payerTypes[1],
                                  context,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget whoPayContainer(bool isSelected, String title, BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8).copyWith(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          border: Border.all(
            width: isSelected ? 1.5 : 1,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade500,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  shape: const CircleBorder(),
                  value: isSelected,
                  onChanged: (_) {},
                ),
                Text("${title.toCapitalized()}\nPays", style: robotoRegular),
              ],
            ),
            isSelected
                ? Icon(Icons.person, color: Theme.of(context).primaryColor)
                : Icon(
                    Icons.person_outline_rounded,
                    color: Colors.grey.shade800,
                  ),
          ],
        ),
      );
}

class DeliveryType extends StatelessWidget {
  const DeliveryType({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          double expressCharge = Get.find<SplashController>()
                  .configModel!
                  .expressCheckoutCharge ??
              150.0;
          return Container(
            margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.speed_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      "Delivery Type",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => parcelController.setDeliveryTypeIndex(0, true),
                        child: deliveryTypeContainer(
                          parcelController.deliveryTypeIndex == 0,
                          "Standard",
                          "Regular delivery time",
                          0,
                          context,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => parcelController.setDeliveryTypeIndex(1, true),
                        child: deliveryTypeContainer(
                          parcelController.deliveryTypeIndex == 1,
                          "Express",
                          "Faster delivery",
                          expressCharge,
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget deliveryTypeContainer(
          bool isSelected, String title, String subTitle, double charge, BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Colors.grey.shade100,
          border: Border.all(
            width: isSelected ? 1.5 : 1,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade500,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: robotoBold),
                if (isSelected)
                  Icon(Icons.check_circle,
                      color: Theme.of(context).primaryColor, size: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(subTitle,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                ),
                if (charge > 0)
                  Text(
                    "+ ${PriceConverter.convertPrice(charge)}",
                    style: robotoBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
              ],
            ),
          ],
        ),
      );
}

///! Select payment method
class SelectPaymentMethod extends StatelessWidget {
  final bool isGuestLoggedIn;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;

  const SelectPaymentMethod({
    super.key,
    required this.isGuestLoggedIn,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          return Container(
            margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      "Choose Payment Method",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (isCashOnDeliveryActive)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: paymentButtonParcel(
                            icon: Images.codIcon,
                            title: 'COD'.tr,
                            isSelected: parcelController.paymentIndex == 0,
                            onTap: () => parcelController.setPaymentIndex(0, true),
                            context: context,
                          ),
                        ),
                      if (isDigitalPaymentActive && parcelController.payerIndex == 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: paymentButtonParcel(
                            icon: Images.digitalPayment,
                            title: 'Online'.tr,
                            isSelected: parcelController.paymentIndex == 2,
                            onTap: () {
                              parcelController.setPaymentIndex(2, true);
                              parcelController.changeDigitalPaymentName(
                                Get.find<SplashController>()
                                    .configModel!
                                    .activePaymentMethodList![0]
                                    .getWay!,
                              );
                            },
                            context: context,
                          ),
                        ),
                      if (Get.find<SplashController>()
                                      .configModel!
                                      .customerWalletStatus ==
                                  1 &&
                              parcelController.payerIndex == 0 &&
                              !isGuestLoggedIn)
                        paymentButtonParcel(
                          icon: Images.walletIcon,
                          title: 'Wallet'.tr,
                          isSelected: parcelController.paymentIndex == 1,
                          onTap: () => parcelController.setPaymentIndex(1, true),
                          context: context,
                        ),
                    ],
                  ),
                ),
                if (parcelController.paymentIndex == 2)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Online Payment Options",
                        style: robotoBold.copyWith(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                parcelController.changeDigitalPaymentName(
                                  Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  border: Border.all(
                                    color: parcelController.digitalPaymentName == Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  child: CustomImage(
                                    image: '${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl}',
                                    height: 50,
                                    width: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                // if (parcelController.offlineMethodList != null &&
                //         parcelController.payerIndex == 0)
                //   Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const SizedBox(height: 10),
                //       Text(
                //         "Offline Payment Options",
                //         style: robotoBold.copyWith(),
                //       ),
                //       PaymentButtonNewCustom(
                //         paymentMethod: PaymentMethod.offline,
                //         icon: Images.codIcon,
                //         title: 'offline'.tr,
                //         isSelected: parcelController.paymentIndex == 3,
                //         onTap: () =>
                //             parcelController.setPaymentIndex(3, true),
                //         subTitle: 'pay via offline methods',
                //       ),
                //     ],
                //   ),
             
              ],
            ),
          );
        },
      ),
    );
  }

  Widget paymentButtonParcel({
    required String icon,
    required String title,
    required bool isSelected,
    required Function onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, height: 30, width: 30),
            const SizedBox(width: 10),
            Text(
              title,
              style: robotoMedium.copyWith(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ! Order Summary booking
class OrderSummaryBooking extends StatelessWidget {
  final double total;
  final double charge;
  final double dmTips;

  const OrderSummaryBooking({
    super.key,
    required this.total,
    required this.charge,
    required this.dmTips,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GetBuilder<ParcelController>(
        builder: (parcelController) {
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
            ).copyWith(top: 12, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: Colors.white38),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      "Order Summary",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('delivery_fee'.tr, style: robotoRegular),
                    Text(
                      parcelController.distance == -1
                          ? 'calculating'.tr
                          : PriceConverter.convertPrice(charge),
                      style: robotoRegular.copyWith(
                        color: parcelController.distance == -1
                            ? Colors.red
                            : Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height:
                      Get.find<SplashController>().configModel!.dmTipsStatus ==
                          1
                      ? Dimensions.paddingSizeSmall
                      : 0.0,
                ),
                (Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('delivery_man_tips'.tr, style: robotoRegular),
                          Text(
                            '(+) ${PriceConverter.convertPrice(dmTips)}',
                            style: robotoRegular.copyWith(
                              color: Colors.blueGrey,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  height:
                      Get.find<SplashController>()
                          .configModel!
                          .additionalChargeStatus!
                      ? Dimensions.paddingSizeSmall
                      : 0,
                ),
                Get.find<SplashController>()
                        .configModel!
                        .additionalChargeStatus!
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Get.find<SplashController>()
                                .configModel!
                                .additionalChargeName!,
                            style: robotoRegular,
                          ),
                          Text(
                            '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                            style: robotoRegular.copyWith(
                              color: Colors.blueGrey,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      )
                    : const SizedBox(),
                (parcelController.deliveryTypeIndex == 1)
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeSmall),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Express Delivery Charge',
                                style: robotoRegular),
                            Text(
                              '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.expressCheckoutCharge ?? 150.0)}',
                              style: robotoRegular.copyWith(
                                color: Colors.blueGrey,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Divider(
                    thickness: 1,
                    color: Theme.of(context).hintColor.withOpacity(0.5),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total_amount'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: PriceConverter.convertAnimationPrice(
                        total,
                        textStyle: robotoMedium.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

///! confirm parcel request button
class ConfirmParcelRequest extends StatelessWidget {
  final double total;
  final bool isGuestLoggedIn;
  final ParcelCategoryModel parcelCategory;
  final AddressModel pickedUpAddress;
  final AddressModel destinationAddress;
  final double charge;
  final TextEditingController guestPasswordController;
  final TextEditingController guestConfirmPasswordController;

  const ConfirmParcelRequest({
    super.key,
    required this.total,
    required this.isGuestLoggedIn,
    required this.parcelCategory,
    required this.pickedUpAddress,
    required this.destinationAddress,
    required this.charge,
    required this.guestPasswordController,
    required this.guestConfirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        return GetBuilder<ParcelController>(
          builder: (parcelController) {
            bool isInstructionSelected = parcelController.selectedIndexNote != -1;
            bool isCustomNote = parcelController.customNote!.isNotEmpty;

        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5.0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total_amount'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    PriceConverter.convertAnimationPrice(
                      total,
                      textStyle: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                buttonText: checkoutController.isDeliveryAvailable
                    ? 'confirm_parcel_request'.tr
                    : 'Delivery is unavailable',
                isLoading: parcelController.isLoading,
                onPressed: (parcelController.acceptTerms && checkoutController.isDeliveryAvailable)
                    ? () {
                        if (parcelController.distance == -1) {
                          showCustomSnackBar('delivery_fee_not_set_yet'.tr);
                        } else if (parcelController.tips < 0) {
                          showCustomSnackBar('tips_can_not_be_negative'.tr);
                        } else if (parcelController.paymentIndex == -1) {
                          showCustomSnackBar(
                            'please_select_payment_method_first'.tr,
                          );
                        } else if (isGuestLoggedIn &&
                            Get.find<CheckoutController>().isCreateAccount &&
                            guestPasswordController.text.isEmpty) {
                          showCustomSnackBar('enter_password'.tr);
                        } else if (isGuestLoggedIn &&
                            Get.find<CheckoutController>().isCreateAccount &&
                            guestConfirmPasswordController.text.isEmpty) {
                          showCustomSnackBar('enter_confirm_password'.tr);
                        } else if (isGuestLoggedIn &&
                            Get.find<CheckoutController>().isCreateAccount &&
                            (guestPasswordController.text !=
                                guestConfirmPasswordController.text)) {
                          showCustomSnackBar(
                            'confirm_password_does_not_matched'.tr,
                          );
                        } else {
                          PlaceOrderBodyModel
                          placeOrderBody = PlaceOrderBodyModel(
                            cart: [],
                            couponDiscountAmount: null,
                            distance: parcelController.distance,
                            scheduleAt: null,
                            orderAmount: charge,
                            orderNote: '',
                            orderType: 'parcel',
                            receiverDetails: destinationAddress,
                            paymentMethod: parcelController.paymentIndex == 0
                                ? 'cash_on_delivery'
                                : parcelController.paymentIndex == 1
                                ? 'wallet'
                                : parcelController.paymentIndex == 2
                                ? 'digital_payment'
                                : 'offline_payment',
                            couponCode: null,
                            storeId: null,
                            address: pickedUpAddress.address,
                            latitude: pickedUpAddress.latitude,
                            longitude: pickedUpAddress.longitude,
                            senderZoneId: pickedUpAddress.zoneId,
                            addressType: pickedUpAddress.addressType,
                            contactPersonName:
                                pickedUpAddress.contactPersonName ?? '',
                            contactPersonNumber:
                                pickedUpAddress.contactPersonNumber ?? '',
                            streetNumber: pickedUpAddress.streetNumber ?? '',
                            house: pickedUpAddress.house ?? '',
                            floor: pickedUpAddress.floor ?? '',
                            discountAmount: 0,
                            taxAmount: 0,
                            parcelCategoryId: parcelCategory.id.toString(),
                            chargePayer: parcelController
                                .payerTypes[parcelController.payerIndex],
                            dmTips: parcelController.tips.toString(),
                            cutlery: 0,
                            unavailableItemNote: '',
                            deliveryInstruction:
                                (isInstructionSelected
                                    ? '${parcelController.parcelInstructionList![parcelController.selectedIndexNote!].instruction}'
                                    : '') +
                                (isInstructionSelected
                                    ? (isCustomNote
                                          ? " (${parcelController.customNote})"
                                          : '')
                                    : (isCustomNote
                                          ? parcelController.customNote ?? ''
                                          : '')),
                            partialPayment: 0,
                            guestId: AuthHelper.isGuestLoggedIn()
                                ? int.parse(AuthHelper.getGuestId())
                                : 0,
                            isBuyNow: 0,
                            guestEmail: pickedUpAddress.email ?? '',
                            extraPackagingAmount: null,
                            createNewUser:
                                Get.find<CheckoutController>().isCreateAccount
                                ? 1
                                : 0,
                            password: guestPasswordController.text,
                          );

                          if (parcelController.paymentIndex == 3) {
                            Get.toNamed(
                              RouteHelper.getOfflinePaymentScreen(
                                placeOrderBody: placeOrderBody,
                                zoneId: pickedUpAddress.zoneId,
                                total: charge,
                                maxCodOrderAmount: 0,
                                fromCart: false,
                                isCodActive: false,
                                forParcel: true,
                              ),
                            );
                          }
                          else {
                            parcelController.startLoader(true);
                            parcelController.placeOrder(
                              placeOrderBody,
                              pickedUpAddress.zoneId,
                              charge,
                              0,
                              false,
                              false,
                              forParcel: true,
                            );
                          }
                        }
                      }
                    : null,
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }
}

///! Pickup Address Detials
class PickUPAddressDetails extends StatelessWidget {
  final AddressModel pickedUpAddress;

  const PickUPAddressDetails({super.key, required this.pickedUpAddress});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(31, 185, 185, 185),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 0.7, color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      width: double.infinity,
      // height: 350,
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 0.8,
                    color: primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.store_mall_directory_outlined,
                  color: primaryColor,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pickup Address",
                    style: robotoBold.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Where we'll collect your parcel",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,

                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                          width: 0.8,
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        (pickedUpAddress.contactPersonName != null && pickedUpAddress.contactPersonName!.isNotEmpty)
                            ? pickedUpAddress.contactPersonName!.substring(0, 1).toUpperCase()
                            : "",
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickedUpAddress.contactPersonName ?? "",
                          style: robotoBold.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Recipient",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,

                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      child: DottedLine(dashColor: Colors.black26),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.location_on_sharp, color: primaryColor),
                    ),
                    const Expanded(
                      child: DottedLine(dashColor: Colors.black26),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Address Details',
                  style: robotoBold.copyWith(color: Colors.black38),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.4, color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        spreadRadius: 0.8,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          pickedUpAddress.address ?? "",
                          maxLines: 3,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,

                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: pickedUpAddress.address ?? ""),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.black26,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 5,
            children: [
              Icon(Icons.contact_phone_outlined, color: primaryColor),
              Text("Contact information", style: robotoBold),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.4, color: primaryColor),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, color: primaryColor),
                Text(
                  pickedUpAddress.contactPersonNumber ?? "",
                  style: robotoBold.copyWith(color: primaryColor),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: pickedUpAddress.address ?? ""),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Colors.black26,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///! drop address detials
class DropAddressDetails extends StatelessWidget {
  final AddressModel destinationAddress;

  const DropAddressDetails({super.key, required this.destinationAddress});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(31, 185, 185, 185),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 0.7, color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      width: double.infinity,
      // height: 350,
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 0.8,
                    color: primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.store_mall_directory_outlined,
                  color: primaryColor,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery Address",
                    style: robotoBold.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Where we'll collect your parcel",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,

                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                          width: 0.8,
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        (destinationAddress.contactPersonName != null && destinationAddress.contactPersonName!.isNotEmpty)
                            ? destinationAddress.contactPersonName!.substring(0, 1).toUpperCase()
                            : "",
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destinationAddress.contactPersonName ?? "",
                          style: robotoBold.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Recipient",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,

                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      child: DottedLine(dashColor: Colors.black26),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.location_on_sharp, color: primaryColor),
                    ),
                    const Expanded(
                      child: DottedLine(dashColor: Colors.black26),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Address Details',
                  style: robotoBold.copyWith(color: Colors.black38),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.4, color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        spreadRadius: 0.8,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          destinationAddress.address ?? "",
                          maxLines: 3,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,

                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: destinationAddress.address ?? "",
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.black26,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 5,
            children: [
              Icon(Icons.contact_phone_outlined, color: primaryColor),
              Text("Contact information", style: robotoBold),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.4, color: primaryColor),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, color: primaryColor),
                Text(
                  destinationAddress.contactPersonNumber ?? "",
                  style: robotoBold.copyWith(color: primaryColor),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: destinationAddress.address ?? ""),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Colors.black26,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ! helper pase below code or used in some aother widgets kindly check in globally
/// ! i have used only in this file

String getTitle(int index) => switch (index) {
  0 => "Category",
  1 => "Address",
  _ => "Payment",
};

Widget getIndicator(int index, BuildContext context) => switch (index) {
  0 => Container(
    height: 30,
    width: 30,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
          spreadRadius: 1,
          blurRadius: 2,
        ),
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          spreadRadius: 3,
          blurRadius: 5,
        ),
      ],
    ),
    child: const Center(child: Icon(Icons.done, color: Colors.white)),
  ),
  1 => Container(
    height: 30,
    width: 30,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
          spreadRadius: 1,
          blurRadius: 2,
        ),
        BoxShadow(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          spreadRadius: 3,
          blurRadius: 5,
        ),
      ],
    ),
    child: const Center(
      child: Text(
        "2",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    ),
  ),
  _ => Container(
    height: 30,
    width: 30,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      shape: BoxShape.circle,
      border: Border.all(width: 1, color: Colors.black45),
    ),
    child: const Center(
      child: Text(
        "3",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
    ),
  ),
};

double _calculateParcelDeliveryCharge({
  required ParcelController parcelController,
  required ParcelCategoryModel parcelCategory,
  required int zoneId,
}) {
  double charge = 0;
  ZoneData? zoneData;
  for (ZoneData zData
      in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
    if (zData.id == zoneId) {
      zoneData = zData;
    }
  }

  if (parcelController.distance != -1 && parcelController.extraCharge != null) {
    double parcelPerKmShippingCharge =
        parcelCategory.parcelPerKmShippingCharge! > 0
        ? parcelCategory.parcelPerKmShippingCharge!
        : Get.find<SplashController>().configModel!.parcelPerKmShippingCharge!;
    double parcelMinimumShippingCharge =
        parcelCategory.parcelMinimumShippingCharge! > 0
        ? parcelCategory.parcelMinimumShippingCharge!
        : Get.find<SplashController>()
              .configModel!
              .parcelMinimumShippingCharge!;
    charge = parcelController.distance! * parcelPerKmShippingCharge;
    if (charge < parcelMinimumShippingCharge) {
      charge = parcelMinimumShippingCharge;
    }

    if (parcelController.extraCharge != null) {
      charge = charge + parcelController.extraCharge!;
    }

    if (zoneData != null && zoneData.increaseDeliveryFeeStatus == 1) {
      charge = charge + (charge * (zoneData.increaseDeliveryFee! / 100));
    }
  }

  return PriceConverter.toFixed(charge);
}
