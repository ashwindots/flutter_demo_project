import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/country_model.dart';
import '../views/comparison_screen.dart';
import '../views/country_detail_screen.dart';
import '../views/favorites_screen.dart';
import '../views/home_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
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
    ),
    GetPage<dynamic>(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.comparison,
      page: () => const ComparisonScreen(),
    ),
  ];
}
