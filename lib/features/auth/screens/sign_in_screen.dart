import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromNotification;
  final bool fromResetPassword;
  const SignInScreen(
      {super.key,
      required this.exitFromApp,
      required this.backFromThis,
      this.fromNotification = false,
      this.fromResetPassword = false});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification || widget.fromResetPassword) {
          Navigator.pushNamed(context, RouteHelper.getInitialRoute());
        } else if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          if (Get.find<AuthController>().isOtpViewEnable) {
            Get.find<AuthController>().enableOtpView(enable: false);
          } else {
            Get.back();
          }
        }
      },
      child: kIsWeb?
      Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
        extendBodyBehindAppBar: true,
        appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(leading: IconButton(
            onPressed: () {
              if(widget.fromNotification || widget.fromResetPassword) {
                Navigator.pushNamed(context, RouteHelper.getInitialRoute());
              }else if(Get.find<AuthController>().isOtpViewEnable){
                Get.find<AuthController>().enableOtpView(enable: false);
              }else{
                Get.back(result: false);
              }
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
          elevation: 0, backgroundColor: Colors.transparent, actions: const [SizedBox()],
        ) : null),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,

        body: Stack(
          children: [
            if (!ResponsiveHelper.isDesktop(context))
              SizedBox(
                height: context.height,
                width: context.width,
                child: Image.asset('assets/image/logimimge.png', fit: BoxFit.cover),
              ),
            SafeArea(
              child: Align(
                alignment: ResponsiveHelper.isDesktop(context) ? Alignment.center : Alignment.bottomCenter,
                child: Container(
                  width: context.width > 700 ? 500 : context.width,
                  padding: context.width > 700 ? const EdgeInsets.all(50) : const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                  margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: ResponsiveHelper.isDesktop(context) ? 1.0 : 0.95),
                    borderRadius: ResponsiveHelper.isDesktop(context) 
                        ? BorderRadius.circular(Dimensions.radiusLarge)
                        : const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: ResponsiveHelper.isDesktop(context) ? null : const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1, offset: Offset(0, -2))],
                  ),
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                      ResponsiveHelper.isDesktop(context) ? Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.clear),
                        ),
                      ) : const SizedBox(),

                      if (ResponsiveHelper.isDesktop(context)) ...[
                        Image.asset('assets/image/logimimge.png', width: 200),
                        const SizedBox(height: Dimensions.paddingSizeExtremeLarge),
                      ],

                      SignInView(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis, fromResetPassword: widget.fromResetPassword, isOtpViewEnable: (v){},),

                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ):
      Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
        extendBodyBehindAppBar: true,
        appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(
          leading: IconButton(
            onPressed: () {
              if(widget.fromNotification || widget.fromResetPassword) {
                Navigator.pushNamed(context, RouteHelper.getInitialRoute());
              }else if(Get.find<AuthController>().isOtpViewEnable){
                Get.find<AuthController>().enableOtpView(enable: false);
              }else{
                Get.back(result: false);
              }
            },
            icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
          elevation: 0, backgroundColor: Colors.transparent, actions: const [SizedBox()],
        ) : null),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,

        body: Stack(
          children: [
            SizedBox(
              height: context.height,
              width: context.width,
              child:Padding(padding: EdgeInsets.only(bottom: 140),child: Image.asset('assets/image/logimimge.png', fit: BoxFit.cover)),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: context.width > 700 ? 500 : context.width,
                  padding: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
                  margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1, offset: Offset(0, -2))],
                      ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                    SignInView(exitFromApp: widget.exitFromApp, backFromThis: widget.backFromThis, fromResetPassword: widget.fromResetPassword, isOtpViewEnable: (v){},),
                  ]),
                ),
              ),
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }
}
