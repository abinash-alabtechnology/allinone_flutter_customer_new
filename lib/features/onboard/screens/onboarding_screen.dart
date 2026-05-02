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

import 'dart:math';

import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/onboard/controllers/onboard_controller.dart';
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

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // 👇 Initialize GetX Onboarding Data
    Get.find<OnBoardingController>().getOnBoardingList();

    // 👇 Smooth wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _animateWave() {
    if (_waveController.status == AnimationStatus.completed) {
      _waveController.reverse();
    } else {
      _waveController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: Stack(
        children: [
          /// 🌊 Animated Wave Background
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return ClipPath(
                clipper: SmoothWaveClipper(progress: _waveAnimation.value),
                child: Container(
                  height: context.height * 0.35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.9),
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              );
            },
          ),

          /// 👇 Onboarding Pages
          GetBuilder<OnBoardingController>(
            builder: (onBoardingController) {
              final totalPages = 3; // 👈 Only 3 pages
              final currentIndex = onBoardingController.selectedIndex;

              return onBoardingController.onBoardingList.isNotEmpty
                  ? Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: totalPages,
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            final item = onBoardingController.onBoardingList[index];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: context.height * 0.2),
                                if (item.imageUrl.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(context.height * 0.05),
                                    child: Image.asset(
                                      item.imageUrl,
                                      height: context.height * 0.35,
                                    ),
                                  ),
                                Text(
                                  item.title,
                                  style: robotoMedium.copyWith(
                                    fontSize: context.height * 0.022,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: context.height * 0.025),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeLarge,
                                  ),
                                  child: Text(
                                    item.description,
                                    style: robotoRegular.copyWith(
                                      fontSize: context.height * 0.015,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                          onPageChanged: (index) {
                            onBoardingController.changeSelectIndex(index);
                            _animateWave();
                          },
                        ),
                      ),

                      /// 🔘 Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _pageIndicators(onBoardingController, context),
                      ),
                      SizedBox(height: context.height * 0.05),

                      /// ⏮️⏭️ Buttons Row
                      SafeArea(
                        minimum: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              /// ⏮️ Previous Button (only show if not first page)
                              if (currentIndex > 0)
                                Expanded(
                                  child: CustomButton(
                                    transparent: true,
                                    buttonText: 'Previous',
                                    onPressed: () {
                                      if (currentIndex > 0) {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.ease,
                                        );
                                        _animateWave();
                                      }
                                    },
                                  ),
                                )
                              else
                                const SizedBox(width: 0),

                              /// ⏭️ Next / Get Started Button
                              Expanded(
                                child: CustomButton(
                                  buttonText: currentIndex != totalPages - 1
                                      ? 'Next'
                                      : 'Get Started',
                                  onPressed: () {
                                    if (currentIndex != totalPages - 1) {
                                      _animateWave();
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.ease,
                                      );
                                    } else {
                                      _configureToRouteInitialPage(); // 🚀 Navigate
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              )
                  : const SizedBox();
            },
          ),
        ],
      )

    );
  }

  List<Widget> _pageIndicators(
      OnBoardingController onBoardingController, BuildContext context) {
    List<Widget> indicators = [];

    for (int i = 0; i < onBoardingController.onBoardingList.length - 1; i++) {
      bool isActive = i == onBoardingController.selectedIndex;

      indicators.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: CustomPaint(
              size: const Size(20, 20),
              painter: ApplePainter(
                color: isActive ? Colors.redAccent : Colors.white,
                borderColor: Colors.black,
                filled: isActive,
              ),
            ),
          ),
        ),
      );
    }

    return indicators;
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
        _pageController.jumpToPage(
            Get.find<OnBoardingController>().onBoardingList.length - 2);
      });
    }
  }
}

/// 🌊 Smooth, Animated Wave Clipper
class SmoothWaveClipper extends CustomClipper<Path> {
  final double progress;
  SmoothWaveClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();

    final double waveHeight = 30 * sin(progress * pi);
    final double waveDepth = 30 * cos(progress * pi);

    path.lineTo(0, size.height * 0.75 + waveHeight);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.75 + waveDepth,
      size.width * 0.5,
      size.height * 0.75 + waveHeight,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75 - waveDepth,
      size.width,
      size.height * 0.75 + waveHeight,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(SmoothWaveClipper oldClipper) =>
      oldClipper.progress != progress;
}
// i need the height of the vectore little bit smaller

class ApplePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool filled;

  ApplePainter({required this.color, required this.borderColor, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    // 🍎 Apple body (slightly curved top and wider bottom)
    Path applePath = Path();
    applePath.moveTo(size.width * 0.5, size.height * 0.2);
    applePath.cubicTo(
      size.width * 0.15, size.height * 0.15,
      size.width * 0.1, size.height * 0.75,
      size.width * 0.5, size.height * 0.9,
    );
    applePath.cubicTo(
      size.width * 0.9, size.height * 0.75,
      size.width * 0.85, size.height * 0.15,
      size.width * 0.5, size.height * 0.2,
    );
    applePath.close();
    canvas.drawPath(applePath, paint);

    // 🍃 Small leaf on top
    Paint leafPaint = Paint()
      ..color = filled ? Colors.green.shade600 : Colors.transparent
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Path leafPath = Path();
    leafPath.moveTo(size.width * 0.5, size.height * 0.1);
    leafPath.quadraticBezierTo(
      size.width * 0.65, size.height * 0.0,
      size.width * 0.7, size.height * 0.15,
    );
    leafPath.quadraticBezierTo(
      size.width * 0.6, size.height * 0.12,
      size.width * 0.5, size.height * 0.1,
    );
    canvas.drawPath(leafPath, leafPaint);

    // 🍏 Border outline (always visible)
    if (!filled) {
      Paint border = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(applePath, border);
      canvas.drawPath(leafPath, border);
    }
  }

  @override
  bool shouldRepaint(covariant ApplePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}
