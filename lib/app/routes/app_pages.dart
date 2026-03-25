import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/country_model.dart';
import '../views/comparison_screen.dart';
import '../views/country_detail_screen.dart';
import '../views/favorites_screen.dart';
import '../views/main_shell.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const MainShell(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CountryController>(() => CountryController());
        Get.lazyPut<ThemeController>(() => ThemeController());
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.countryDetail,
      page: () {
        final CountryModel country = Get.arguments as CountryModel;
        return CountryDetailScreen(country: country);
      },
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    // Standalone routes kept for direct deep-link navigation
    GetPage<dynamic>(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage<dynamic>(
      name: AppRoutes.comparison,
      page: () => const ComparisonScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
