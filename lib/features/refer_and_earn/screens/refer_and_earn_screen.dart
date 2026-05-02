import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';
import 'package:handy_allinone/features/refer_and_earn/widgets/bottom_sheet_view_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/common/widgets/footer_view.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/not_logged_in_screen.dart';
import 'package:handy_allinone/common/widgets/web_page_title_widget.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall() {
    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar3(title: 'refer_and_earn'.tr),
      body: GetPlatform.isMobile
          ? SafeArea(
              child: ExpandableBottomSheet(
                background: isLoggedIn
                    ? SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context)
                                ? 0
                                : Dimensions.paddingSizeLarge),
                        child: Column(
                          children: [
                            FooterView(
                              child: Center(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: GetBuilder<ProfileController>(
                                      builder: (profileController) {
                                    return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Column(children: [
                                                Image.asset(
                                                  Images.referImage,
                                                  width: 500,
                                                  height: ResponsiveHelper
                                                          .isDesktop(context)
                                                      ? 250
                                                      : 150,
                                                  fit: BoxFit.cover,
                                                ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraLarge),
                                                ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? const SizedBox()
                                                    : Text(
                                                        'Refer friend & earn rewards'
                                                            .tr,
                                                        style: robotoBold.copyWith(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: Dimensions
                                                                    .fontSizeExtraLarge *
                                                                1.1)),
                                                ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? const SizedBox()
                                                    : const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraSmall),
                                                ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? const SizedBox()
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    12.0),
                                                        child: Text(
                                                            'Invite your friends to ${AppConstants.appName}.They get instant rewards, you earn when they complete their first order.'
                                                                .tr,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: robotoRegular
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black38,
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeDefault)),
                                                      ),
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraLarge),
                                              ])),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeDefault),
                                          Card(
                                            elevation: 1,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                   Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        child: Column(
                                                          children: [
                                                            Text("You Earn",
                                                                style: robotoRegular.copyWith(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall)),
                                                            Text(
                                                                PriceConverter.convertPrice(Get.find<
                                                                                SplashController>()
                                                                            .configModel !=
                                                                        null
                                                                    ? Get.find<
                                                                            SplashController>()
                                                                        .configModel!
                                                                        .refEarningExchangeRate!
                                                                        .toDouble()
                                                                    : 0.0),
                                                                style: robotoBold.copyWith(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade700,
                                                                    fontSize:
                                                                        Dimensions
                                                                                .fontSizeExtraLarge *
                                                                            1.1)),
                                                          ],
                                                        ),
                                                      ),
                                                    SizedBox(
                                                      height: 40,
                                                      // ensure measurable vertical space
                                                      child:
                                                      VerticalDivider(
                                                        width: 1,
                                                        color: Colors
                                                            .grey.shade200,
                                                        thickness: 1,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .all(8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                              "Friends Get",
                                                              style: robotoRegular.copyWith(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize:
                                                                  Dimensions
                                                                      .fontSizeSmall)),
                                                          Text(
                                                              "Discount on first\norder",
                                                              style: robotoBold.copyWith(
                                                                  fontSize:
                                                                  Dimensions
                                                                      .fontSizeSmall,
                                                                  color: Colors
                                                                      .black87)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          ResponsiveHelper.isDesktop(context)
                                              ? const SizedBox()
                                              : const SizedBox(height: 20),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('Your Referral Code'.tr,
                                                style: robotoMedium.copyWith(
                                                  color:Colors.black87,
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,fontWeight: FontWeight.w700),
                                                textAlign: TextAlign.start),
                                          ),
                                          // const SizedBox(
                                          //     height:
                                          //         Dimensions.paddingSizeSmall),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? Row(
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment.center,
                                          //         children: [
                                          //             Text(
                                          //               '${'one_referral'.tr}= ',
                                          //               style: robotoMedium.copyWith(
                                          //                   fontSize: Dimensions
                                          //                       .fontSizeSmall),
                                          //             ),
                                          //             Text(
                                          //               PriceConverter.convertPrice(Get
                                          //                               .find<
                                          //                                   SplashController>()
                                          //                           .configModel !=
                                          //                       null
                                          //                   ? Get.find<
                                          //                           SplashController>()
                                          //                       .configModel!
                                          //                       .refEarningExchangeRate!
                                          //                       .toDouble()
                                          //                   : 0.0),
                                          //               style: robotoMedium.copyWith(
                                          //                   fontSize: Dimensions
                                          //                       .fontSizeSmall),
                                          //               textDirection:
                                          //                   TextDirection.ltr,
                                          //             ),
                                          //           ])
                                          //     : const SizedBox(),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? const SizedBox(height: 40)
                                          //     : const SizedBox(),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? const SizedBox()
                                          //     : Text(
                                          //         'copy_your_code_share_it_with_your_friends'
                                          //             .tr,
                                          //         style: robotoRegular.copyWith(
                                          //             fontSize: Dimensions
                                          //                 .fontSizeSmall),
                                          //         textAlign: TextAlign.center),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? const SizedBox()
                                          //     : const SizedBox(
                                          //         height: Dimensions
                                          //             .paddingSizeExtraLarge),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? Align(
                                          //         alignment: Alignment.topLeft,
                                          //         child: Text(
                                          //             'your_personal_code'.tr,
                                          //             style: robotoRegular.copyWith(
                                          //                 fontSize: Dimensions
                                          //                     .fontSizeSmall),
                                          //             textAlign:
                                          //                 TextAlign.center),
                                          //       )
                                          //     : const SizedBox(),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? const SizedBox()
                                          //     : Text('your_personal_code'.tr,
                                          //         style: robotoRegular.copyWith(
                                          //             fontSize: Dimensions
                                          //                 .fontSizeSmall,
                                          //             color: Theme.of(context)
                                          //                 .hintColor),
                                          //         textAlign: TextAlign.center),
                                          // const SizedBox(
                                          //     height:
                                          //         Dimensions.paddingSizeSmall),
                                          const SizedBox(height: 10,),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color:Colors.grey.shade50,
                                              border: Border.all(color: Colors.grey.shade200),
                                              borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)
                                                ),),
                                            child: SizedBox(
                                              width:Get.width,
                                              child: (profileController
                                                          .userInfoModel !=
                                                      null)
                                                  ? IntrinsicHeight(
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: Dimensions
                                                                    .paddingSizeLarge,
                                                                right: Dimensions
                                                                    .paddingSizeLarge),
                                                            child: Text(
                                                              profileController
                                                                          .userInfoModel !=
                                                                      null
                                                                  ? profileController
                                                                          .userInfoModel!
                                                                          .refCode ??
                                                                      ''
                                                                  : '',
                                                              style: robotoBold
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeOverLarge),
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            if (profileController
                                                                .userInfoModel!
                                                                .refCode!
                                                                .isNotEmpty) {
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text:
                                                                          '${profileController.userInfoModel != null ? profileController.userInfoModel!.refCode : ''}'));
                                                              showCustomSnackBar(
                                                                  'referral_code_copied'
                                                                      .tr,
                                                                  isError: false);
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                border:Border.all(color: Colors.grey.shade300),
                                                                borderRadius: BorderRadius.circular(5)),
                                                            padding: const EdgeInsets
                                                                .symmetric(horizontal: 30,
                                                               vertical: Dimensions.paddingSizeExtraSmall),
                                                            margin: const EdgeInsets
                                                                .all(Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            child: IntrinsicWidth(
                                                              child: Row(
                                                                children: [
                                                                  Icon(Icons.copy,size:14,color: Colors.deepOrange.shade700,),
                                                                  const SizedBox(width: 10,),
                                                                  Text('copy code'.toUpperCase(),
                                                                      style: robotoMedium.copyWith(
                                                                          color: Colors.deepOrange.shade700,
                                                                          fontSize:
                                                                              Dimensions
                                                                                  .fontSizeSmall)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                  )
                                                  : const CircularProgressIndicator(),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Share.share(
                                                Get.find<SplashController>()
                                                    .configModel
                                                    ?.appUrlAndroid !=
                                                    null
                                                    ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                                                    : '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode}',
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(top: 15, bottom: 15),
                                              width: double.infinity,
                                              decoration:  BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.deepOrange, Colors.deepOrange.shade700],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius: const BorderRadius.only(
                                                  bottomLeft: Radius.circular(10),
                                                  bottomRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.share, size: 18, color: Colors.white),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          "SHARE",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white,
                                                            letterSpacing: .5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ])
                                              ),
                                          ),


                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height:20,),
                                              const Text(
                                                "How It Works",
                                                style: TextStyle(fontSize: 14.5,color:Colors.black54,fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(height: 20),

                                              // Step 1
                                              const Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: Colors.deepOrange,
                                                    child: Text("1",
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700,
                                                        )),
                                                  ),
                                                  SizedBox(width: 14),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Invite Friends",
                                                          style: TextStyle(
                                                              fontSize: 14.5,color:Colors.black54, fontWeight: FontWeight.w700)),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        "Share your unique referral code with friends",
                                                        overflow: TextOverflow.ellipsis,

                                                        style: TextStyle(
                                                          fontSize: 11.5,
                                                          color: Colors.black54,
                                                          height: 1.35,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Step 2
                                              const Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: Colors.deepOrange,
                                                    child: Text("2",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.w700,
                                                        )),
                                                  ),
                                                  SizedBox(width: 14),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Friends Order",
                                                          style: TextStyle(
                                                              fontSize: 14.5,color:Colors.black54, fontWeight: FontWeight.w700)),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        "Your friend places their first order using your code",
                                                        style: TextStyle(
                                                          fontSize: 11.5,
                                                          color: Colors.black54,
                                                          height: 1.35,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Step 3
                                              const Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: Colors.deepOrange,
                                                    child: Text("3",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.w700,
                                                        )),
                                                  ),
                                                  SizedBox(width: 14),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("You Get Rewarded",
                                                          style: TextStyle(
                                                              fontSize: 14.5,color:Colors.black54, fontWeight: FontWeight.w700)),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        "Earn rewards once they complete their order",
                                                        style: TextStyle(
                                                          fontSize: 11.5,
                                                          color: Colors.black54,
                                                          height: 1.35,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),

                                              const SizedBox(height: 35),

                                              Container(
                                                padding: const EdgeInsets.all(18),
                                                decoration: BoxDecoration(
                                                  color:  Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: const Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Frequently Asked Questions",
                                                      style: TextStyle(
                                                        fontSize: 14.5,color:Colors.black54,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    SizedBox(height: 18),

                                                    Text(
                                                      "When will I get my referral reward?",
                                                      style: TextStyle(fontSize: 14.5,color:Colors.black54, fontWeight: FontWeight.w700),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      "You’ll receive your reward once your friend completes their first order using your referral code.",
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        height: 1.4,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    SizedBox(height: 22),

                                                    Text(
                                                      "Is there a limit to how many friends I can refer?",
                                                      style: TextStyle(fontSize: 14.5,color:Colors.black54, fontWeight: FontWeight.w700),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      "No, you can refer as many friends as you want and earn rewards for each successful referral.",
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        height: 1.4,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    SizedBox(height: 22),

                                                    Text(
                                                      "How can my friend use my referral code?",
                                                      style: TextStyle(fontSize: 14.5,color:Colors.black54, fontWeight: FontWeight.w700),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      "They need to enter your code during signup or on their account page before placing their first order.",
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        height: 1.4,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Wrap(children: [
                                          //   InkWell(
                                          //     onTap: () {
                                          //       Share.share(
                                          //         Get.find<SplashController>()
                                          //                     .configModel
                                          //                     ?.appUrlAndroid !=
                                          //                 null
                                          //             ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                                          //             : '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode}',
                                          //       );
                                          //     },
                                          //     child: Container(
                                          //       width:Get.width,
                                          //       decoration: BoxDecoration(
                                          //         shape: BoxShape.circle,
                                          //         color: Theme.of(context)
                                          //             .cardColor,
                                          //         boxShadow: [
                                          //           BoxShadow(
                                          //               color: Theme.of(context)
                                          //                   .primaryColor
                                          //                   .withValues(
                                          //                       alpha: 0.2),
                                          //               blurRadius: 5)
                                          //         ],
                                          //       ),
                                          //       padding:
                                          //           const EdgeInsets.all(7),
                                          //       child: const Icon(Icons.share),
                                          //     ),
                                          //   )
                                          // ]),
                                          // ResponsiveHelper.isDesktop(context)
                                          //     ? const Padding(
                                          //         padding: EdgeInsets.only(
                                          //             top: Dimensions
                                          //                 .paddingSizeExtraLarge),
                                          //         child:
                                          //             BottomSheetViewWidget(),
                                          //       )
                                          //     : const SizedBox(),
                                        ]);
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : NotLoggedInScreen(callBack: (value) {
                        _initCall();
                        setState(() {});
                      }),
                key: key,
                persistentHeader: null,
                expandableContent: const SizedBox(),
                // persistentHeader: ResponsiveHelper.isDesktop(context)
                //     ? null
                //     : InkWell(
                //         onTap: () {
                //           if (key.currentState?.expansionStatus ==
                //               ExpansionStatus.expanded) {
                //             setState(() {
                //               key.currentState!.contract();
                //             });
                //           } else {
                //             setState(() {
                //               key.currentState!.expand();
                //             });
                //           }
                //         },
                //         child: Container(
                //           constraints: const BoxConstraints.expand(height: 60),
                //           decoration: BoxDecoration(
                //             borderRadius: const BorderRadius.only(
                //                 topLeft: Radius.circular(
                //                     Dimensions.paddingSizeExtraLarge),
                //                 topRight: Radius.circular(
                //                     Dimensions.paddingSizeExtraLarge)),
                //             color: Theme.of(context)
                //                 .primaryColor
                //                 .withValues(alpha: 0.1),
                //             border: Border(
                //               top: BorderSide(
                //                   color: Theme.of(context).primaryColor,
                //                   width: 0.3),
                //             ),
                //           ),
                //           child: Column(children: [
                //             Center(
                //               child: Container(
                //                 margin: const EdgeInsets.only(
                //                     top: Dimensions.paddingSizeDefault),
                //                 height: 3,
                //                 width: 40,
                //                 decoration: BoxDecoration(
                //                   color: Theme.of(context).primaryColor,
                //                   borderRadius: BorderRadius.circular(
                //                       Dimensions.paddingSizeExtraSmall),
                //                 ),
                //               ),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.only(
                //                   left: Dimensions.paddingSizeDefault,
                //                   top: Dimensions.paddingSizeSmall,
                //                   right: Dimensions.paddingSizeDefault),
                //               child: Row(children: [
                //                 const Icon(Icons.error_outline, size: 16),
                //                 const SizedBox(
                //                     width: Dimensions.paddingSizeExtraSmall),
                //                 Text('how_it_works'.tr,
                //                     style: robotoMedium.copyWith(
                //                         fontSize: Dimensions.fontSizeDefault),
                //                     textAlign: TextAlign.center),
                //               ]),
                //             ),
                //           ]),
                //         ),
                //       ),
                // expandableContent:
                //     ResponsiveHelper.isDesktop(context) || !isLoggedIn
                //         ? const SizedBox()
                //         : const BottomSheetViewWidget(),
              ),
            )
          : ExpandableBottomSheet(
              background: isLoggedIn
                  ? SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context)
                              ? 0
                              : Dimensions.paddingSizeLarge),
                      child: Column(
                        children: [
                          WebScreenTitleWidget(title: 'refer_and_earn'.tr),
                          FooterView(
                            child: Center(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: GetBuilder<ProfileController>(
                                    builder: (profileController) {
                                  return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          Images.referImage,
                                          width: 500,
                                          height: ResponsiveHelper.isDesktop(
                                                  context)
                                              ? 250
                                              : 150,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(
                                            height: Dimensions
                                                .paddingSizeExtraLarge),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : Text(
                                                'earn_money_on_every_referral'
                                                    .tr,
                                                style: robotoRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: Dimensions
                                                        .fontSizeSmall)),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraSmall),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    Text(
                                                      '${'one_referral'.tr}= ',
                                                      style: robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault),
                                                    ),
                                                    Text(
                                                      PriceConverter.convertPrice(Get
                                                                      .find<
                                                                          SplashController>()
                                                                  .configModel !=
                                                              null
                                                          ? Get.find<
                                                                  SplashController>()
                                                              .configModel!
                                                              .refEarningExchangeRate!
                                                              .toDouble()
                                                          : 0.0),
                                                      style: robotoBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                    ),
                                                  ]),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : const SizedBox(height: 40),
                                        Text('invite_friends_and_business'.tr,
                                            style: robotoBold.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeOverLarge),
                                            textAlign: TextAlign.center),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        ResponsiveHelper.isDesktop(context)
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                    Text(
                                                      '${'one_referral'.tr}= ',
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall),
                                                    ),
                                                    Text(
                                                      PriceConverter.convertPrice(Get
                                                                      .find<
                                                                          SplashController>()
                                                                  .configModel !=
                                                              null
                                                          ? Get.find<
                                                                  SplashController>()
                                                              .configModel!
                                                              .refEarningExchangeRate!
                                                              .toDouble()
                                                          : 0.0),
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                    ),
                                                  ])
                                            : const SizedBox(),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox(height: 40)
                                            : const SizedBox(),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : Text(
                                                'copy_your_code_share_it_with_your_friends'
                                                    .tr,
                                                style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall),
                                                textAlign: TextAlign.center),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeExtraLarge),
                                        ResponsiveHelper.isDesktop(context)
                                            ? Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                    'your_personal_code'.tr,
                                                    style:
                                                        robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall),
                                                    textAlign:
                                                        TextAlign.center),
                                              )
                                            : const SizedBox(),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const SizedBox()
                                            : Text('your_personal_code'.tr,
                                                style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .hintColor),
                                                textAlign: TextAlign.center),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeSmall),
                                        DottedBorder(
                                      options: RoundedRectDottedBorderOptions(

                                      color: Theme.of(context).primaryColor,
                                          strokeWidth: 1,
                                          strokeCap: StrokeCap.butt,
                                          dashPattern: const [8, 5],
                                          padding: const EdgeInsets.all(0),
                                          radius: Radius.circular(
                                              ResponsiveHelper.isDesktop(
                                                      context)
                                                  ? Dimensions.radiusDefault
                                                  : 50),),
                                          child: SizedBox(
                                            height: 50,
                                            child: (profileController
                                                        .userInfoModel !=
                                                    null)
                                                ? Row(children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            left: Dimensions
                                                                .paddingSizeLarge,
                                                            right: Dimensions
                                                                .paddingSizeLarge),
                                                        child: Text(
                                                          profileController
                                                                      .userInfoModel !=
                                                                  null
                                                              ? profileController
                                                                      .userInfoModel!
                                                                      .refCode ??
                                                                  ''
                                                              : '',
                                                          style: robotoMedium
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeExtraLarge),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (profileController
                                                            .userInfoModel!
                                                            .refCode!
                                                            .isNotEmpty) {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      '${profileController.userInfoModel != null ? profileController.userInfoModel!.refCode : ''}'));
                                                          showCustomSnackBar(
                                                              'referral_code_copied'
                                                                  .tr,
                                                              isError: false);
                                                        }
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            borderRadius: BorderRadius.circular(
                                                                ResponsiveHelper
                                                                        .isDesktop(
                                                                            context)
                                                                    ? Dimensions
                                                                        .radiusDefault
                                                                    : 50)),
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeExtraLarge),
                                                        margin: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeExtraSmall),
                                                        child: Text('copy'.tr,
                                                            style: robotoMedium.copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeDefault)),
                                                      ),
                                                    ),
                                                  ])
                                                : const CircularProgressIndicator(),
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                Dimensions.paddingSizeLarge),
                                        Wrap(children: [
                                          InkWell(
                                            onTap: () {
                                              Share.share(
                                                Get.find<SplashController>()
                                                            .configModel
                                                            ?.appUrlAndroid !=
                                                        null
                                                    ? '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                                                    : '${AppConstants.appName} ${'referral_code'.tr}: ${profileController.userInfoModel!.refCode}',
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    Theme.of(context).cardColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                              alpha: 0.2),
                                                      blurRadius: 5)
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(7),
                                              child: const Icon(Icons.share),
                                            ),
                                          )
                                        ]),
                                        ResponsiveHelper.isDesktop(context)
                                            ? const Padding(
                                                padding: EdgeInsets.only(
                                                    top: Dimensions
                                                        .paddingSizeExtraLarge),
                                                child: BottomSheetViewWidget(),
                                              )
                                            : const SizedBox(),
                                      ]);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : NotLoggedInScreen(callBack: (value) {
                      _initCall();
                      setState(() {});
                    }),
              key: key,
              persistentHeader: ResponsiveHelper.isDesktop(context)
                  ? null
                  : InkWell(
                      onTap: () {
                        if (key.currentState?.expansionStatus ==
                            ExpansionStatus.expanded) {
                          setState(() {
                            key.currentState!.contract();
                          });
                        } else {
                          setState(() {
                            key.currentState!.expand();
                          });
                        }
                      },
                      child: Container(
                        constraints: const BoxConstraints.expand(height: 60),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(
                                  Dimensions.paddingSizeExtraLarge),
                              topRight: Radius.circular(
                                  Dimensions.paddingSizeExtraLarge)),
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          border: Border(
                            top: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 0.3),
                          ),
                        ),
                        child: Column(children: [
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeDefault),
                              height: 3,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeExtraSmall),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeDefault,
                                top: Dimensions.paddingSizeSmall,
                                right: Dimensions.paddingSizeDefault),
                            child: Row(children: [
                              const Icon(Icons.error_outline, size: 16),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text('how_it_works'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeDefault),
                                  textAlign: TextAlign.center),
                            ]),
                          ),
                        ]),
                      ),
                    ),
              expandableContent:
                  ResponsiveHelper.isDesktop(context) || !isLoggedIn
                      ? const SizedBox()
                      : const BottomSheetViewWidget(),
            ),
    );
  }
}
