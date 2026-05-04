import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_text_field.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/auth/widgets/condition_check_box_widget.dart';
import 'package:handy_allinone/features/auth/widgets/social_login_widget.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/validate_check.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  const OtpLoginWidget({super.key, required this.phoneController, required this.phoneFocus, required this.onCountryChanged, required this.countryDialCode,
    required this.onClickLoginButton, this.socialEnable = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text('login'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            titleText: 'xxx-xxx-xxxx'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
            labelText: 'phone',
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          InkWell(
            onTap: () => authController.toggleRememberMe(),
            child: Row(
              children: [
                SizedBox(
                  height: 24, width: 24,
                  child: Checkbox(
                    side: BorderSide(color: Theme.of(context).hintColor),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Theme.of(context).primaryColor,
                    value: authController.isActiveRememberMe,
                    onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Text('remember_me'.tr, style: robotoRegular)),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          const ConditionCheckBoxWidget(forSignUp: true),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButton(
            buttonText: 'login'.tr,
            radius: Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: onClickLoginButton,
            fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          socialEnable ? const SocialLoginWidget(onlySocialLogin: false) : const SizedBox(),

          socialEnable && isDesktop ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

          !socialEnable ? const SizedBox(height: 10) : const SizedBox(),

        ]),
      );
    });
  }
}
class OtpLoginWidgetApp extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  const OtpLoginWidgetApp({super.key, required this.phoneController, required this.phoneFocus, required this.onCountryChanged, required this.countryDialCode,
    required this.onClickLoginButton, this.socialEnable = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GlassContainer(
      width: Get.width,
      height: 380,
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.grey.withValues(alpha: 0.60),
          Colors.grey.withValues(alpha: 0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [ 0.5,1.0],
      ),
      blur: 3,
      color: Colors.grey,
      borderWidth: 1.0,
      elevation: 100.0,
      shadowColor: Colors.grey,

      child: GetBuilder<AuthController>(builder: (authController) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
          child: Column(mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('login'.tr, style: robotoBold.copyWith(color:Theme.of(context).cardColor,fontSize: Dimensions.fontSizeExtraLarge)),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomTextField(
                  titleText: 'Enter you Phone Number'.tr,
                  controller: phoneController,
                  focusNode: phoneFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  onCountryChanged: onCountryChanged,
                  countryDialCode: countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                  // labelText: 'phone2',
                  required: true,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                InkWell(
                  onTap: () => authController.toggleRememberMe(),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24, width: 24,
                        child: Checkbox(
                          side: BorderSide(color: Theme.of(context).hintColor),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          activeColor: Theme.of(context).primaryColor,
                          value: authController.isActiveRememberMe,
                          onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(child: Text('remember_me'.tr, style: robotoRegular.copyWith(color: Theme.of(context).cardColor))),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                const ConditionCheckBoxWidget(forSignUp: true),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomButton(
                  color: Colors.black,
                  buttonText: 'login'.tr,
                  radius: Dimensions.radiusDefault,
                  isBold: isDesktop ? false : true,
                  isLoading: authController.isLoading,
                  onPressed: onClickLoginButton,
                  fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                socialEnable ? const SocialLoginWidget(onlySocialLogin: false) : const SizedBox(),

                socialEnable && isDesktop ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                !socialEnable ? const SizedBox(height: 10) : const SizedBox(),

              ]),
        );
      }),
    );
  }
}

