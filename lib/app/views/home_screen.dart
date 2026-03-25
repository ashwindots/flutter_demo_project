import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/country_model.dart';
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
          const SizedBox(height: 8),
          // Sort chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => _SortChipBar(
                  selected: controller.currentSort.value,
                  onSelected: controller.updateSort,
                )),
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
                return _ShimmerList();
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
                  padding: const EdgeInsets.only(bottom: 100),
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
                      index: index,
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

// ── Shimmer-style loading placeholder ──

class _ShimmerList extends StatefulWidget {
  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color baseColor =
        isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10);
    final Color highlightColor =
        isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(20);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: 8,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Flag placeholder
                  Container(
                    width: 68,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                          baseColor,
                          highlightColor,
                          (0.5 +
                                  0.5 *
                                      ((_controller.value * 2 -
                                                  index * 0.1) %
                                              1.0)
                                          .clamp(0.0, 1.0))
                              .clamp(0.0, 1.0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 10,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Sort chip bar ──

class _SortChipBar extends StatelessWidget {
  final SortOption selected;
  final ValueChanged<SortOption> onSelected;

  const _SortChipBar({required this.selected, required this.onSelected});

  static const List<_SortChipData> _chips = [
    _SortChipData(option: SortOption.nameAsc, label: 'A → Z', icon: Icons.sort_by_alpha),
    _SortChipData(option: SortOption.nameDesc, label: 'Z → A', icon: Icons.sort_by_alpha),
    _SortChipData(option: SortOption.populationDesc, label: 'Pop ↓', icon: Icons.people),
    _SortChipData(option: SortOption.populationAsc, label: 'Pop ↑', icon: Icons.people_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final _SortChipData chip = _chips[index];
          final bool isActive = selected == chip.option;

          return GestureDetector(
            onTap: () => onSelected(chip.option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chip.icon,
                    size: 16,
                    color: isActive
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chip.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SortChipData {
  final SortOption option;
  final String label;
  final IconData icon;

  const _SortChipData({
    required this.option,
    required this.label,
    required this.icon,
  });
}
