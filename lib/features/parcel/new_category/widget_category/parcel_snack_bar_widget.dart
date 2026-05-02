import 'package:flutter/material.dart';
import 'package:get/get.dart';

showSnackBarError(String title, BuildContext context,[String? content]) {
  Get.showSnackbar(
    GetSnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      title: title,
      message: content,
      titleText: Text(
        title,
        style: const TextStyle(
            height: 0.9, color: Colors.white, fontWeight: FontWeight.w600),
      ),
      messageText: content != null
          ? Text(content,
              style: const TextStyle(height: 0.9, color: Colors.white))
          : null,
    ),
  );
}
