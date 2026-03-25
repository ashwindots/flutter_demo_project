import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../models/country_model.dart';
import '../utils/helpers.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  CountryModel? _countryA;
  CountryModel? _countryB;
  String _searchQuery = '';

  void _onCountryTap(CountryModel country) {
    setState(() {
      // If already selected in slot A → deselect it
      if (_countryA?.cca3 == country.cca3) {
        _countryA = null;
        return;
      }
      // If already selected in slot B → deselect it
      if (_countryB?.cca3 == country.cca3) {
        _countryB = null;
        return;
      }
      // Fill first empty slot
      if (_countryA == null) {
        _countryA = country;
      } else if (_countryB == null) {
        _countryB = country;
      } else {
        // Both slots full → replace slot B
        _countryB = country;
      }
    });
  }

  bool _isSelected(String cca3) =>
      _countryA?.cca3 == cca3 || _countryB?.cca3 == cca3;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Countries'),
        actions: [
          if (_countryA != null || _countryB != null)
            TextButton(
              onPressed: () => setState(() {
                _countryA = null;
                _countryB = null;
              }),
              child:
                  const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Obx(() {
        final CountryController controller = Get.find<CountryController>();
        final List<CountryModel> allCountries =
            List<CountryModel>.from(controller.allCountries);
        allCountries.sort((CountryModel a, CountryModel b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        // Apply local search filter
        final List<CountryModel> countries = _searchQuery.isEmpty
            ? allCountries
            : allCountries
                .where((CountryModel c) =>
                    c.name.toLowerCase().contains(_searchQuery))
                .toList();

        return Column(
          children: [
            // ── Two selection boxes ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _SelectionBox(
                      label: 'Country 1',
                      country: _countryA,
                      onClear: () => setState(() => _countryA = null),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.compare_arrows,
                        color: theme.colorScheme.primary, size: 24),
                  ),
                  Expanded(
                    child: _SelectionBox(
                      label: 'Country 2',
                      country: _countryB,
                      onClear: () => setState(() => _countryB = null),
                    ),
                  ),
                ],
              ),
            ),

            // ── Comparison result (real-time) ──
            if (_countryA != null && _countryB != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    _ComparisonRow(
                      label: 'Population',
                      valueA: formatPopulation(_countryA!.population),
                      valueB: formatPopulation(_countryB!.population),
                      highlightHigher:
                          _countryA!.population > _countryB!.population
                              ? 'A'
                              : _countryB!.population > _countryA!.population
                                  ? 'B'
                                  : null,
                    ),
                    _ComparisonRow(
                      label: 'Region',
                      valueA: _countryA!.region,
                      valueB: _countryB!.region,
                    ),
                    _ComparisonRow(
                      label: 'Capital',
                      valueA: _countryA!.capital,
                      valueB: _countryB!.capital,
                    ),
                  ],
                ),
              ),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (String value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search countries...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),

            // ── Country list ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${countries.length} countries — tap to select',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: countries.length,
                itemBuilder: (BuildContext context, int index) {
                  final CountryModel country = countries[index];
                  final bool selected = _isSelected(country.cca3);
                  return _CountryListTile(
                    key: ValueKey(country.cca3),
                    country: country,
                    isSelected: selected,
                    onTap: () => _onCountryTap(country),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Selection box (top) ──

class _SelectionBox extends StatelessWidget {
  final String label;
  final CountryModel? country;
  final VoidCallback onClear;

  const _SelectionBox({
    required this.label,
    required this.country,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: country != null
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: country != null ? 2 : 1,
        ),
      ),
      child: country != null
          ? Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: country!.flagUrl,
                          height: 32,
                          width: 48,
                          fit: BoxFit.cover,
                          errorWidget: (BuildContext context, String url,
                                  Object error) =>
                              const Icon(Icons.flag, size: 24),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          country!.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(Icons.close,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 28, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Country list tile ──

class _CountryListTile extends StatelessWidget {
  final CountryModel country;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryListTile({
    super.key,
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(80),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: country.flagUrl,
          width: 40,
          height: 28,
          fit: BoxFit.cover,
          errorWidget:
              (BuildContext context, String url, Object error) =>
                  const Icon(Icons.flag, size: 24),
        ),
      ),
      title: Text(
        country.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(country.region),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
    );
  }
}

// ── Comparison row ──

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String valueA;
  final String valueB;
  final String? highlightHigher;

  const _ComparisonRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    this.highlightHigher,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  valueA,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: highlightHigher == 'A'
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: theme.dividerColor,
              ),
              Expanded(
                child: Text(
                  valueB,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: highlightHigher == 'B'
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
