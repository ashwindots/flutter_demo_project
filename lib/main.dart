import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/controllers/country_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/storage_service.dart';
import 'app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<CountryController>(CountryController(), permanent: true);

  runApp(const CountryExplorerApp());
}

class CountryExplorerApp extends StatelessWidget {
  const CountryExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: 'Country Explorer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: AppRoutes.home,
          getPages: AppPages.pages,
        ));
  }
}
