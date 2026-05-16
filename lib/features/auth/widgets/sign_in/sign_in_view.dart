import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/models/config_model.dart';
import 'package:handy_allinone/common/models/response_model.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/features/auth/controllers/auth_controller.dart';
import 'package:handy_allinone/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:handy_allinone/features/auth/screens/new_user_setup_screen.dart';
import 'package:handy_allinone/features/auth/widgets/sign_in/manual_login_widget.dart';
import 'package:handy_allinone/features/auth/widgets/sign_in/otp_login_widget.dart';
import 'package:handy_allinone/features/auth/widgets/social_login_widget.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/verification/domein/enum/verification_type_enum.dart';
import 'package:handy_allinone/features/verification/screens/verification_screen.dart';
import 'package:handy_allinone/helper/centralize_login_helper.dart';
import 'package:handy_allinone/helper/custom_validator.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/helper/validate_check.dart';
import 'package:handy_allinone/common/widgets/custom_button.dart';
import 'package:handy_allinone/common/widgets/custom_text_field.dart';
import 'package:handy_allinone/features/auth/widgets/condition_check_box_widget.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class SignInView extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  final Function(bool val)? isOtpViewEnable;
  const SignInView({super.key, required this.exitFromApp, required this.backFromThis, this.fromResetPassword = false, this.isOtpViewEnable});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeyLogin;
  bool _isOtp = true;
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    AuthController authController  = Get.find<AuthController>();
    SplashController splashController = Get.find<SplashController>();

    _countryDialCode = authController.getUserCountryCode().isNotEmpty ? authController.getUserCountryCode() : CountryCode.fromCountryCode(splashController.configModel!.country!).dialCode;
    _phoneController.text =  authController.getUserNumber();
    _passwordController.text = authController.getUserPassword();

    WidgetsBinding.instance.addPostFrameCallback((_){
      bool isOtpActive = CentralizeLoginHelper.getPreferredLoginMethod(splashController.configModel!.centralizeLoginSetup!, authController.isOtpViewEnable).type == CentralizeLoginType.otp
      || CentralizeLoginHelper.getPreferredLoginMethod(splashController.configModel!.centralizeLoginSetup!, authController.isOtpViewEnable).type == CentralizeLoginType.otpAndSocial ;

      if(_countryDialCode != "" && _phoneController.text != "" && _phoneController.text.contains('@') && isOtpActive) {
        _phoneController.text = '';
      } else if(_countryDialCode != "" && _phoneController.text != "" && !_phoneController.text.contains('@')){
        authController.toggleIsNumberLogin(value: true);
      }else{
        authController.toggleIsNumberLogin(value: false);
      }
      authController.initCountryCode(countryCode: _countryDialCode != "" ? _countryDialCode : null);

    });

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_phoneFocus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Form(
        key: _formKeyLogin,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text('login'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            ),
            SizedBox(height: Dimensions.paddingSizeLarge),

/*            Container(
              height: 45,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isOtp = true),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isOtp ? Theme.of(context).primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Text('OTP', style: robotoMedium.copyWith(color: _isOtp ? Colors.white : Theme.of(context).disabledColor)),
                      ),
                    ),
                  ),
                  /*Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isOtp = false),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_isOtp ? Theme.of(context).primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Text('EMAIL', style: robotoMedium.copyWith(color: !_isOtp ? Colors.white : Theme.of(context).disabledColor)),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeLarge),*/

            if(_isOtp)
              activeCentralizeLogin(Get.find<SplashController>().configModel!.centralizeLoginSetup!, authController)
            /*else
              _emailLoginWidget(authController)*/,

          ]),
        ),
      );
    });
  }

/*  Widget _emailLoginWidget(AuthController authController) {
    return Column(children: [
      CustomTextField(
        titleText: 'enter_email_address'.tr,
        controller: _emailController,
        focusNode: _emailFocus,
        nextFocus: _passwordFocus,
        inputType: TextInputType.emailAddress,
        prefixIcon: Icons.email_outlined,
        labelText: 'email'.tr,
        required: true,
        validator: (value) => ValidateCheck.validateEmail(value),
      ),
      SizedBox(height: Dimensions.paddingSizeExtraLarge),

      CustomTextField(
        titleText: '8_character'.tr,
        controller: _passwordController,
        focusNode: _passwordFocus,
        inputAction: TextInputAction.done,
        inputType: TextInputType.visiblePassword,
        prefixIcon: Icons.lock_outline,
        isPassword: true,
        labelText: 'password'.tr,
        required: true,
        validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_password".tr),
      ),
      SizedBox(height: Dimensions.paddingSizeDefault),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        InkWell(
          onTap: () => authController.toggleRememberMe(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
              Text('remember_me'.tr, style: robotoRegular),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(RouteHelper.getForgotPassRoute()),
          child: Text('${'forgot_password'.tr}?', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
        ),
      ]),
      SizedBox(height: Dimensions.paddingSizeLarge),

      const ConditionCheckBoxWidget(forSignUp: true),
      SizedBox(height: Dimensions.paddingSizeLarge),

      CustomButton(
        buttonText: 'login'.tr,
        radius: Dimensions.radiusDefault,
        isLoading: authController.isLoading,
        onPressed: () => _emailLogin(authController),
      ),
      SizedBox(height: Dimensions.paddingSizeLarge),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('do_not_have_account'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getSignUpRoute()),
          child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Text('sign_up'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
          ),
        ),
      ]),
      const SizedBox(height: Dimensions.paddingSizeLarge),
      const SocialLoginWidget(onlySocialLogin: false),
    ]);
  }

  void _emailLogin(AuthController authController) {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if(_formKeyLogin!.currentState!.validate()) {
      if(!authController.acceptTerms) {
        showCustomSnackBar("Accept Terms & Conditions!", isError: true);
        return;
      }
      
      authController.login(
        emailOrPhone: email,
        password: password,
        loginType: 'email',
        fieldType: VerificationTypeEnum.email.name,
        alreadyInApp: widget.backFromThis,
      ).then((status) {
        if (status.isSuccess) {
          if(!status.authResponseModel!.isPersonalInfo!) {
            Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: 'email', phone: '', email: email));
          } else {
            _processSuccessSetup(authController, email, email, password, status);
          }
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  } */


  Widget activeCentralizeLogin(CentralizeLoginSetup centralizeLoginSetup, AuthController authController) {
    CentralizeLoginType centralizeLogin = CentralizeLoginHelper.getPreferredLoginMethod(centralizeLoginSetup, authController.isOtpViewEnable).type;
    switch (centralizeLogin) {
      case CentralizeLoginType.otp:
        return OtpLoginWidget(
          phoneController: _phoneController, phoneFocus: _phoneFocus,
          countryDialCode: _countryDialCode,
          onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
          onClickLoginButton: () {
            _otpLogin(Get.find<AuthController>(), _countryDialCode!, CentralizeLoginType.otp);
          },
        );

      case CentralizeLoginType.manual:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController,
          phoneFocus: _phoneFocus, passwordFocus: _passwordFocus, onWebSubmit: (){},
          onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
        );

      case CentralizeLoginType.social:
        return const SocialLoginWidget(onlySocialLogin: true);

      case CentralizeLoginType.manualAndSocial:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController, phoneFocus: _phoneFocus, passwordFocus: _passwordFocus,
          socialEnable: true,
          onWebSubmit: (){}, onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
        );

      case CentralizeLoginType.manualAndOtp:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController, phoneFocus: _phoneFocus, passwordFocus: _passwordFocus,
          onOtpViewClick: () {
            widget.isOtpViewEnable!(true);
            if(_countryDialCode != "" && _phoneController.text != "" && _phoneController.text.contains('@')) {
              _phoneController.text = '';
            }
            setState(() {
              authController.enableOtpView(enable: true);
            });
          },
          onWebSubmit: (){},
          onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
        );

      case CentralizeLoginType.otpAndSocial:
        return SocialLoginWidget(onlySocialLogin: true, onOtpViewClick: (){
          widget.isOtpViewEnable!(true);
          if(_countryDialCode != "" && _phoneController.text != "" && _phoneController.text.contains('@')) {
            _phoneController.text = '';
          }
          setState(() {
            authController.enableOtpView(enable: true);
          });
        });

      case CentralizeLoginType.manualAndSocialAndOtp:
        return ManualLoginWidget(
          phoneController: _phoneController, passwordController: _passwordController, phoneFocus: _phoneFocus, passwordFocus: _passwordFocus,
          onWebSubmit: (){}, socialEnable: true,
          onClickLoginButton: () {
            _login(Get.find<AuthController>(), CentralizeLoginType.manual);
          },
          onOtpViewClick: () {
            widget.isOtpViewEnable!(true);
            if(_countryDialCode != "" && _phoneController.text != "" && _phoneController.text.contains('@')) {
              _phoneController.text = '';
            }
            setState(() {
              authController.enableOtpView(enable: true);
            });
          },
        );
      default:
        return const SizedBox();
    }
  }
  
  void _otpLogin(AuthController authController, String countryDialCode, CentralizeLoginType loginType) async {
    String phone = _phoneController.text.trim();
    String numberWithCountryCode = countryDialCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;
if(authController.acceptTerms){
    if(_formKeyLogin!.currentState!.validate()) {
      if(!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
print("fresrff ${loginType.name} ");
        authController.otpLogin(phone: numberWithCountryCode, otp: '', loginType: loginType.name, verified: '', alreadyInApp: widget.backFromThis).then((response) {
          if (response.isSuccess) {
            _processOtpSuccessSetup(response, authController, phone, countryDialCode);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      }
    }
  }
else{
  showCustomSnackBar("Accept Terms & Conditions!",isError: true);
}

  }

  void _login(AuthController authController, CentralizeLoginType loginType) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = authController.countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if(_formKeyLogin!.currentState!.validate()) {

      String isPhone = ValidateCheck.getValidPhone(authController.countryDialCode + _phoneController.text.trim(), withCountryCode: true);

      if(isPhone != "" && !phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        authController.login(
          emailOrPhone: isPhone != "" ? isPhone : phone, password: password,
          loginType: loginType.name, fieldType: isPhone !="" ? VerificationTypeEnum.phone.name : VerificationTypeEnum.email.name,
          alreadyInApp: widget.backFromThis,
        ).then((status) async {
          if (status.isSuccess) {
            if(status.isSuccess && !status.authResponseModel!.isPersonalInfo!) {
              if(ResponsiveHelper.isDesktop(Get.context)) {
                Get.back();
                Get.dialog(NewUserSetupScreen(name: '', loginType: loginType.name, phone: numberWithCountryCode, email: ''));
              } else {
                Get.toNamed(RouteHelper.getNewUserSetupScreen(name: '', loginType: loginType.name, phone: numberWithCountryCode, email: ''));
              }
            } else {
              _processSuccessSetup(authController, phone, isPhone, password, status);
            }
          } else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }

  Future<void> _processSuccessSetup(AuthController authController, String phone, String email, String password, ResponseModel status) async {
    if (authController.isActiveRememberMe) {
      authController.saveUserNumberAndPassword(phone, password, authController.countryDialCode);
    } else {
      authController.clearUserNumberAndPassword();
    }
    if(GetPlatform.isWeb){
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if(status.authResponseModel != null && !status.authResponseModel!.isPhoneVerified!) {
      List<int> encoded = utf8.encode(password);
      String data = base64Encode(encoded);
      String token = status.authResponseModel!.token??'';
      _phoneController.clear();
      _passwordController.clear();
      if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(phone, token, CentralizeLoginType.manual.name, fromSignUp: true);
      } else {
        Get.toNamed(RouteHelper.getVerificationRoute(phone, null, token, RouteHelper.signUp, data, CentralizeLoginType.manual.name),
        );
      }
    } else if(status.authResponseModel != null && !status.authResponseModel!.isEmailVerified!) {
      List<int> encoded = utf8.encode(password);
      String data = base64Encode(encoded);
      String token = status.authResponseModel!.token??'';
      _phoneController.clear();
      _passwordController.clear();
      Get.toNamed(RouteHelper.getVerificationRoute(null, email, token, RouteHelper.signUp, data, CentralizeLoginType.manual.name));
    } else {
      if(widget.backFromThis) {
        if(ResponsiveHelper.isDesktop(Get.context) || widget.fromResetPassword){
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
        }
      } else {
        Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }

  void _processOtpSuccessSetup(ResponseModel response, AuthController authController, String phone, String countryDialCode) async {
    if (authController.isActiveRememberMe) {
      authController.saveUserNumberAndPassword(phone, '', countryDialCode);
    } else {
      authController.clearUserNumberAndPassword();
    }
    if(GetPlatform.isWeb && response.authResponseModel == null){
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if(response.authResponseModel != null && !response.authResponseModel!.isPhoneVerified!) {
      _phoneController.clear();
      _passwordController.clear();
      if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(countryDialCode + phone, '', CentralizeLoginType.otp.name, fromSignUp: true);
      } else {
        if(ResponsiveHelper.isDesktop(Get.context)) {
          Get.back();
          Get.dialog(VerificationScreen(
            number: countryDialCode + phone, email: null, token: '', fromSignUp: true,
            fromForgetPassword: false, loginType: CentralizeLoginType.otp.name, password: '',
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            countryDialCode + phone, null, '', RouteHelper.signUp, null, CentralizeLoginType.otp.name,
          ));
        }
      }
    } else {
      if(widget.backFromThis) {
        if(ResponsiveHelper.isDesktop(Get.context)){
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
        }
      }else {
        Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }
}