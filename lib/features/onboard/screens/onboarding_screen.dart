// import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
// import 'package:handy_allinone/features/location/controllers/location_controller.dart';
// import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
// import 'package:handy_allinone/features/onboard/controllers/onboard_controller.dart';
// import 'package:handy_allinone/helper/address_helper.dart';
// import 'package:handy_allinone/helper/responsive_helper.dart';
// import 'package:handy_allinone/helper/route_helper.dart';
// import 'package:handy_allinone/util/dimensions.dart';
// import 'package:handy_allinone/util/styles.dart';
// import 'package:handy_allinone/common/widgets/custom_button.dart';
// import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class OnBoardingScreen extends StatefulWidget {
//   const OnBoardingScreen({super.key});
//
//   @override
//   State<OnBoardingScreen> createState() => _OnBoardingScreenState();
// }
//
// class _OnBoardingScreenState extends State<OnBoardingScreen> {
//   final PageController _pageController = PageController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     Get.find<OnBoardingController>().getOnBoardingList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
//       body: SafeArea(
//         child: GetBuilder<OnBoardingController>(
//           builder: (onBoardingController) {
//             bool showIndicatorAndButton = onBoardingController.selectedIndex < onBoardingController.onBoardingList.length-1;
//             return onBoardingController.onBoardingList.isNotEmpty ? SafeArea(
//               child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(children: [
//
//                 Expanded(child: PageView.builder(
//                   itemCount: onBoardingController.onBoardingList.length,
//                   controller: _pageController,
//                   // physics: const BouncingScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//
//                       showIndicatorAndButton && onBoardingController.onBoardingList[index].imageUrl != '' ? Padding(
//                         padding: EdgeInsets.all(context.height*0.05),
//                         child: Image.asset(onBoardingController.onBoardingList[index].imageUrl, height: context.height*0.4),
//                       ) : const SizedBox(),
//
//                       Text(
//                         onBoardingController.onBoardingList[index].title,
//                         style: robotoMedium.copyWith(fontSize: context.height*0.022),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: context.height*0.025),
//
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
//                         child: Text(
//                           onBoardingController.onBoardingList[index].description,
//                           style: robotoRegular.copyWith(fontSize: context.height*0.015, color: Theme.of(context).disabledColor),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//
//                     ]);
//                   },
//                   onPageChanged: (index) {
//                     onBoardingController.changeSelectIndex(index);
//                     if(onBoardingController.selectedIndex == 3) {
//                       _configureToRouteInitialPage();
//                     }
//                   },
//                 )),
//
//                 showIndicatorAndButton ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: _pageIndicators(onBoardingController, context),
//                 ) : const SizedBox(),
//                 SizedBox(height: context.height*0.05),
//
//                 showIndicatorAndButton ? Padding(
//                   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                   child: Row(children: [
//                     onBoardingController.selectedIndex == 2 ? const SizedBox() : Expanded(
//                       child: CustomButton(
//                         transparent: true,
//                         onPressed: () {
//                           _configureToRouteInitialPage();
//                         },
//                         buttonText: 'skip'.tr,
//                       ),
//                     ),
//                     Expanded(
//                       child: CustomButton(
//                         buttonText: onBoardingController.selectedIndex != 2 ? 'next'.tr : 'get_started'.tr,
//                         onPressed: () {
//                           if(onBoardingController.selectedIndex != 2) {
//                             _pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.ease);
//                           } else {
//                             _configureToRouteInitialPage();
//                           }
//                         },
//                       ),
//                     ),
//                   ]),
//                 ) : const SizedBox(),
//
//               ]))),
//             ) : const SizedBox();
//           },
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _pageIndicators(OnBoardingController onBoardingController, BuildContext context) {
//     List<Container> indicators = [];
//
//     for (int i = 0; i < onBoardingController.onBoardingList.length-1; i++) {
//       indicators.add(
//         Container(
//           width: 7, height: 7,
//           margin: const EdgeInsets.only(right: 10),
//           decoration: BoxDecoration(
//             color: i == onBoardingController.selectedIndex ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
//             borderRadius: i == onBoardingController.selectedIndex ? BorderRadius.circular(50) : BorderRadius.circular(25),
//           ),
//         ),
//       );
//     }
//     return indicators;
//   }
//
//   void _configureToRouteInitialPage() async {
//     Get.find<SplashController>().disableIntro();
//     await Get.find<AuthController>().guestLogin();
//     if (AddressHelper.getUserAddressFromSharedPref() != null) {
//       Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
//     } else {
//       Get.find<LocationController>().navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true).then((v) {
//         _pageController.jumpToPage(Get.find<OnBoardingController>().onBoardingList.length-2);
//       });
//     }
//   }
// }

import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> onboardImages = [
    'assets/image/onboard_1.png',
    'assets/image/onboard_2.png',
    'assets/image/onboard_3.png',
  ];

  final List<String> onboardTitles = [
    'on_boarding_1_title'.tr,
    'on_boarding_2_title'.tr,
    'on_boarding_3_title'.tr,
  ];

  final List<String> onboardDescriptions = [
    'on_boarding_1_description'.tr,
    'on_boarding_2_description'.tr,
    'on_boarding_3_description'.tr,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: onboardImages.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(height: context.height * 0.08),
                  
                  // Clean Illustration Graphic (foreground + cityscape background)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                      child: Image.asset(
                        onboardImages[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  
                  // Title Text in Code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Text(
                      onboardTitles[index],
                      style: robotoBold.copyWith(
                        fontSize: context.height * 0.026,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.paddingSizeDefault),
                  
                  // Description Text in Code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                    child: Text(
                      onboardDescriptions[index],
                      style: robotoRegular.copyWith(
                        fontSize: context.height * 0.016,
                        color: Theme.of(context).disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: context.height * 0.16),
                ],
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          
          /// ⏮️⏭️ Buttons Row (Overlay)
          Positioned(
            bottom: Dimensions.paddingSizeExtraLarge,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            child: SafeArea(
              child: _currentIndex != onboardImages.length - 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardImages.length, (index) {
                        bool isActive = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 24 : 8,
                          decoration: BoxDecoration(
                            color: isActive ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    )
                  : CustomButton(
                      buttonText: 'get_started'.tr,
                      onPressed: () => _configureToRouteInitialPage(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>()
          .navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true)
          .then((v) {
        _pageController.jumpToPage(onboardImages.length - 1);
      });
    }
  }
}
