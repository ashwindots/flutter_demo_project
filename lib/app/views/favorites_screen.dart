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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Obx(() {
        final List<CountryModel> favorites = controller.favoriteCountries;

        if (favorites.isEmpty) {
          return const Center(child: _EmptyFavoritesView());
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: favorites.length,
          itemBuilder: (BuildContext context, int index) {
            return CountryCard(
              key: ValueKey(favorites[index].cca3),
              country: favorites[index],
              index: index,
            );
          },
        );
      }),
    );
  }
}

class _EmptyFavoritesView extends StatefulWidget {
  const _EmptyFavoritesView();

  @override
  State<_EmptyFavoritesView> createState() => _EmptyFavoritesViewState();
}

class _EmptyFavoritesViewState extends State<_EmptyFavoritesView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Icon(
              Icons.favorite_border_rounded,
              size: 72,
              color: theme.colorScheme.primary.withAlpha(160),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any country\nto add it to your favorites',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
