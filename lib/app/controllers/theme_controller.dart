import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storageService.getDarkMode();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storageService.saveDarkMode(isDark: isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
