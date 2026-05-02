import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:handy_allinone/features/home/controllers/home_controller.dart';
import 'package:handy_allinone/helper/date_converter.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';

// class CashBackDialogWidget extends StatelessWidget {
//   const CashBackDialogWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     bool isDesktop = ResponsiveHelper.isDesktop(context);
//
//     return GetBuilder<HomeController>(
//       builder: (homeController) {
//         return homeController.cashBackOfferList != null ? Container(
//           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 50),
//           alignment: Get.find<LocalizationController>().isLtr ? Alignment.bottomRight : Alignment.bottomLeft,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//
//               isDesktop ? Padding(
//                 padding: const EdgeInsets.only(bottom: 5),
//                 child: InkWell(
//                   onTap: () => Get.back(),
//                   child: Icon(CupertinoIcons.clear_circled_solid, color: Theme.of(context).hintColor, size: 30),
//                 ),
//               ) : const SizedBox(),
//
//               homeController.cashBackOfferList!.isNotEmpty ? Container(
//                 constraints: BoxConstraints(maxHeight: context.height*0.5, minHeight: 30),
//                 width: isDesktop ? 400 : context.width * 0.8,
//                 margin: EdgeInsets.only(right: isDesktop ? 20 : 0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       constraints: BoxConstraints(maxHeight: context.height*0.5, minHeight: 30),
//                       padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                       child: ListView.builder(
//                         itemCount: homeController.cashBackOfferList!.length,
//                         shrinkWrap: true,
//                         itemBuilder: (context, index) {
//                           return Container(
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).cardColor,
//                               borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                             ),
//                             padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                             margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                               Container(
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
//                                   borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                                 ),
//                                 padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                                 child: Text(homeController.cashBackOfferList![index].title??'', style: robotoBold,),
//                               ),
//
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
//                                 child: Text(
//                                   '${'min_spent'.tr} ${PriceConverter.convertPrice(homeController.cashBackOfferList![index].minPurchase!)} '
//                                       '| ${'valid_till'.tr} ${DateConverter.stringToReadableString(homeController.cashBackOfferList![index].endDate!)}',
//                                   style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
//                                 ),
//                               ),
//                               // Text('Min Spent \$500 |Valid till 22 Sept, 2023', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
//
//                             ],),
//                           );
//                         }),
//                     ),
//                   ],
//                 ),
//               ) : Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//                   ),
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//                   child: Text('no_offer_available'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
//                 ),
//
//               Container(
//                 height: 80, width: 65,
//                 margin: EdgeInsets.only(bottom: 20, right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
//                 child: InkWell(onTap: () => Get.back(), child: const CashBackLogoWidget()),
//               ),
//             ],
//           ),
//         ) : const SizedBox();
//       }
//     );
//   }
// }



class CashBackDialogWidget extends StatelessWidget {
  const CashBackDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    double dialogHeight = context.height * 0.5; // half screen height

    return GetBuilder<HomeController>(
      builder: (homeController) {
        if (homeController.cashBackOfferList == null) return const SizedBox();

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              height: dialogHeight,
              width: isDesktop ? 500 : context.width,
             decoration: BoxDecoration(
               borderRadius: const BorderRadius.only(
                 topLeft: Radius.circular(30),
                 topRight: Radius.circular(30),
               ),
               color: Colors.yellow.shade50,
             ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Lottie.asset(
                            'assets/animation/gift.json',
                            fit: BoxFit.cover,
                            repeat: true,
                            height: 200,
                            width: 200
                          ),
                        ),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFF7043), // deep coral
                              Color(0xFFFFB74D), // amber gold
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            "Cashback Offers ✨",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Agne',
                              fontSize: 26,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// 🧾 Cashback List
                        Expanded(
                          child: homeController.cashBackOfferList!.isNotEmpty
                              ? ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            itemCount:
                            homeController.cashBackOfferList!.length,
                            itemBuilder: (context, index) {
                              final offer =
                              homeController.cashBackOfferList![index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                        borderRadius: BorderRadius.circular(15)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer.title ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Agne',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${'min_spent'.tr} ${PriceConverter.convertPrice(offer.minPurchase!)} | ${'valid_till'.tr} ${DateConverter.stringToReadableString(offer.endDate!)}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: Colors.white
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Text(
                              'no_offer_available'.tr,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Lottie.asset(
                      'assets/animation/congratulation.json',
                      fit: BoxFit.cover,
                      repeat: true,
                    height: dialogHeight,
                    width: isDesktop ? 500 : context.width,
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(50),
                      child: const ClayContainer(
                        height: 38,
                        width: 38,
                        borderRadius: 50,
                        color: Color(0xFFFFF3E0),
                        spread: 2,
                        depth: 20,
                        curveType: CurveType.concave,
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: Color(0xFFFF8A65),
                          size: 22,
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
