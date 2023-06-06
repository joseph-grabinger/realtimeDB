import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar(String title, String subText) {
  Get.snackbar(
      title, subText,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 10.0,
      margin: const EdgeInsets.all(10.0),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 2)
  );
}
