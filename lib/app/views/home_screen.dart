import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/country_model.dart';
import '../routes/app_routes.dart';
import '../widgets/country_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final CountryController controller = Get.find<CountryController>();
      controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CountryController controller = Get.find<CountryController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Explorer'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  themeController.isDarkMode.value
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: themeController.toggleTheme,
                tooltip: 'Toggle Theme',
              )),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Get.toNamed(AppRoutes.favorites),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => Get.toNamed(AppRoutes.comparison),
            tooltip: 'Compare Countries',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (controller.isSearching.value) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        controller.updateSearch('');
                        FocusScope.of(context).unfocus();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ),
          ),
          // Filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Region filter
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                        initialValue: controller.selectedRegion.value,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                        isExpanded: true,
                        items: CountryController.regions
                            .map((String region) => DropdownMenuItem<String>(
                                  value: region,
                                  child: Text(
                                    region,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) controller.updateRegion(value);
                        },
                      )),
                ),
                const SizedBox(width: 8),
                // Sort button
                Obx(() => PopupMenuButton<SortOption>(
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort',
                      initialValue: controller.currentSort.value,
                      onSelected: controller.updateSort,
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<SortOption>(
                          value: SortOption.nameAsc,
                          child: Text('Name (A→Z)'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.nameDesc,
                          child: Text('Name (Z→A)'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.populationDesc,
                          child: Text('Population (High→Low)'),
                        ),
                        const PopupMenuItem<SortOption>(
                          value: SortOption.populationAsc,
                          child: Text('Population (Low→High)'),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Country count
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${controller.filteredCountries.length} countries',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )),
          const SizedBox(height: 4),
          // Country list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value) {
                return _ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchCountries,
                );
              }

              if (controller.filteredCountries.isEmpty) {
                return _EmptyView(
                  searchQuery: controller.searchQuery.value,
                  selectedRegion: controller.selectedRegion.value,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchCountries,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: controller.displayedCountries.length +
                      (controller.hasMorePages ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= controller.displayedCountries.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final CountryModel country =
                        controller.displayedCountries[index];
                    return CountryCard(
                      key: ValueKey(country.cca3),
                      country: country,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String searchQuery;
  final String selectedRegion;

  const _EmptyView({
    required this.searchQuery,
    required this.selectedRegion,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String message = searchQuery.isNotEmpty
        ? 'No countries found for "$searchQuery"'
        : selectedRegion != 'All'
            ? 'No countries found in $selectedRegion'
            : 'No countries available';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
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
}
