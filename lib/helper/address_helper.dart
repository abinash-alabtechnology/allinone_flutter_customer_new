import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/util/app_constants.dart';

class AddressHelper {

  ///newly added by ak
  static bool isLocationSelected() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    return (sharedPreferences.getBool('selected_location_status') ?? false) || sharedPreferences.containsKey(AppConstants.userAddress);
  }

  static void setLocationSelected() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.setBool('selected_location_status', true);
  }

  ///

  static Future<bool> saveUserAddressInSharedPref(AddressModel address) async {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    String userAddress = jsonEncode(address.toJson());
    Get.find<ApiClient>().updateHeader(
      sharedPreferences.getString(AppConstants.token),
      address.zoneIds,[],
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module?.id,
      address.latitude,
      address.longitude,
    );
    return await sharedPreferences.setString(AppConstants.userAddress, userAddress);
  }

  static AddressModel? getUserAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    AddressModel? addressModel;
    try {
      String? addressStr = sharedPreferences.getString(AppConstants.userAddress);
      if(addressStr != null) {
        addressModel = AddressModel.fromJson(jsonDecode(addressStr));
      }
    }catch(e) {
      if(!GetPlatform.isWeb) {
        debugPrint('Address Catch exception : $e');
      }
    }
    return addressModel;
  }

  static bool clearAddressFromSharedPref() {
    SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }

}