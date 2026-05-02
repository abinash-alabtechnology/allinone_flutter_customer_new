import 'package:get/get.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/util/app_constants.dart';

class TaxiHelper {

  static bool haveTaxiModule() {
    final moduleList = Get.find<SplashController>().moduleList;

    return moduleList?.any((module) => module.moduleType == AppConstants.taxi) ?? false;
  }

}