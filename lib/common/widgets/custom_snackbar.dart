import 'package:handy_allinone/common/widgets/coustom_toast.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(String? message, {bool isError = true, bool getXSnackBar = false, int? showDuration}) {
  if(message != null && message.isNotEmpty) {
    if(getXSnackBar || Get.context == null || !Get.context!.mounted) {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.transparent,
        messageText: CustomToast(text: message, isError: isError),
        maxWidth: 500,
        duration: Duration(seconds: showDuration ??3),
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right:  Dimensions.paddingSizeSmall, bottom:  100),
        borderRadius: 50,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ));
    }else {
      Get.showSnackbar(GetSnackBar(
        backgroundColor: Colors.transparent,
        messageText: CustomToast(text: message, isError: isError),
        duration: Duration(seconds: showDuration ?? 2),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.zero,
        borderRadius: 0,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ));
    }
  }
}