import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/wallet/widgets/add_fund_dialogue_widget.dart';

class WalletCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const WalletCardWidget({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final ScrollController cardScrollController = ScrollController();

    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // isDesktop
            //     ? const SizedBox()
            //     : const SizedBox(height: Dimensions.paddingSizeSmall),
            Stack(children: [
              Container(
                // height: 430,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.6),
                      Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      Colors.white38,
                      Colors.white,
                    ],
                  ),
                ),
                child: const Column(
                  children: [
                    WalletscreenAppBar(),
                    // SizedBox(height: 20),
                  ],
                ),
              ),
              context.isPhone
                  ? const SizedBox.shrink()
                  : Get.find<SplashController>().configModel!.addFundStatus! &&
                  Get.find<SplashController>()
                      .configModel!
                      .digitalPayment!
                  ? Positioned(
                top: 30,
                right: Get.find<LocalizationController>().isLtr
                    ? 20
                    : null,
                left: Get.find<LocalizationController>().isLtr
                    ? null
                    : 10,
                child: InkWell(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        child: SizedBox(
                          width: 500,
                          child: SingleChildScrollView(
                              controller: cardScrollController,
                              child: AddFundDialogueWidget(
                                  cardScrollController:
                                  cardScrollController)),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor),
                    padding: const EdgeInsets.all(
                        Dimensions.paddingSizeExtraSmall),
                    child: const Icon(Icons.add),
                  ),
                ),
              )
                  : const SizedBox(),
            ]),
            isDesktop
                ? const SizedBox()
                : const SizedBox(height: Dimensions.paddingSizeSmall),
            isDesktop
                ? const SizedBox(height: Dimensions.paddingSizeDefault)
                : const SizedBox(),
            isDesktop
                ? Text('how_to_use'.tr,
                style:
                robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))
                : const SizedBox(),
            isDesktop
                ? const SizedBox(height: Dimensions.paddingSizeDefault)
                : const SizedBox(),
            !isDesktop ? const SizedBox() : const WalletStepper(),
          ],
        );
      },
    );
  }
}

class WalletStepper extends StatelessWidget {
  const WalletStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: Dimensions.paddingSizeExtraSmall),
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).primaryColor, width: 2)),
              ),
            ],
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'earn_money_to_your_wallet_by_completing_the_offer_challenged'
                        .tr,
                    style: robotoRegular),
                Text('convert_your_loyalty_points_into_wallet_money'.tr,
                    style: robotoRegular),
                Text(
                    'amin_also_reward_their_top_customers_with_wallet_money'.tr,
                    style: robotoRegular),
                Text('send_your_wallet_money_while_order'.tr,
                    style: robotoRegular),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletscreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Size size;

  const WalletscreenAppBar({
    super.key,
    this.size = const Size.fromHeight(300),
  });

  @override
  Size get preferredSize => size;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return SizedBox(
        height: preferredSize.height,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: -80,
              child: Opacity(
                opacity: 0.5,
                child: Transform.rotate(
                  angle: -0.01,
                  child: Image.asset(
                    Images.money,
                    colorBlendMode: BlendMode.color,
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                AppBar(
                  toolbarHeight: 40,
                  elevation: 0,
                  bottomOpacity: 0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade500.withOpacity(0.2),
                          shape: BoxShape.circle),
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  title: const Text(
                    "Wallet",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  actions: const [
                    SizedBox(),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Available wallet Balance',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  PriceConverter.convertPrice(
                    profileController.userInfoModel!.walletBalance,
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'your wallet balance is low, Please add \nmoney to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Get.find<SplashController>().configModel!.addFundStatus! &&
                    Get.find<SplashController>()
                        .configModel!
                        .digitalPayment!
                    ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width / 5,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _showWalletBottomSheet(context);
                  },
                  child: Text(
                    "Add Money",
                    style: robotoBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                )
                    : const SizedBox(),
                const Spacer(),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showWalletBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: MediaQuery.of(context).viewInsets,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const WalletBottomSheetContent(),
            ),
          ),
        );
      },
    );
  }
}





//  Container(
//                 padding: EdgeInsets.all(
//                   isDesktop ? 35 : Dimensions.paddingSizeExtraLarge,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'wallet_amount'.tr,
//                       style: robotoRegular.copyWith(
//                         fontSize: Dimensions.fontSizeSmall,
//                         color: Theme.of(context).cardColor,
//                       ),
//                     ),
//                     const SizedBox(height: Dimensions.paddingSizeSmall),
//                     Row(children: [
//                       Text(
// PriceConverter.convertPrice(
//   profileController.userInfoModel!.walletBalance,
// ),
//                         textDirection: TextDirection.ltr,
//                         style: robotoBold.copyWith(
//                             fontSize: Dimensions.fontSizeOverLarge,
//                             color: Theme.of(context).cardColor),
//                       ),
//                       const SizedBox(width: Dimensions.paddingSizeSmall),
//                       Get.find<SplashController>()
//                                   .configModel!
//                                   .addFundStatus! &&
//                               Get.find<SplashController>()
//                                   .configModel!
//                                   .digitalPayment!
//                           ? JustTheTooltip(
//                               backgroundColor: Colors.black87,
//                               controller: tooltipController,
//                               preferredDirection: AxisDirection.right,
//                               tailLength: 14,
//                               tailBaseWidth: 20,
//                               content: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   'if_you_want_to_add_fund_to_your_wallet_then_click_add_fund_button'
//                                       .tr,
//                                   style: robotoRegular.copyWith(
//                                       color: Colors.white),
//                                 ),
//                               ),
//                               child: InkWell(
//                                 onTap: () => tooltipController.showTooltip(),
//                                 child: Icon(Icons.info_outline,
//                                     color: Theme.of(context).cardColor),
//                               ),
//                             )
//                           : const SizedBox(),
//                     ]),

//                   ],
//                 ),