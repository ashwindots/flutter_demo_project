import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../models/country_model.dart';
import '../widgets/country_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CountryController controller = Get.find<CountryController>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Obx(() {
        final List<CountryModel> favorites = controller.favoriteCountries;

        if (favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any country to add it to your favorites',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favorites.length,
          itemBuilder: (BuildContext context, int index) {
            return CountryCard(
              key: ValueKey(favorites[index].cca3),
              country: favorites[index],
            );
          },
        );
      }),
    );
  }
}
