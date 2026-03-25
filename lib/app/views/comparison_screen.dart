import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../models/country_model.dart';
import '../utils/helpers.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CountryController controller = Get.find<CountryController>();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Countries'),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearComparison();
              Get.back();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Obx(() {
        final List<CountryModel> countries = controller.comparisonList;

        if (countries.length < 2) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.compare_arrows,
                      size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Select 2 countries to compare',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Long press on countries in the list to select them for comparison',
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

        final CountryModel countryA = countries[0];
        final CountryModel countryB = countries[1];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Flags row
              Row(
                children: [
                  Expanded(child: _FlagHeader(country: countryA)),
                  const SizedBox(width: 16),
                  Expanded(child: _FlagHeader(country: countryB)),
                ],
              ),
              const SizedBox(height: 24),
              // Comparison rows
              _ComparisonRow(
                label: 'Capital',
                valueA: countryA.capital,
                valueB: countryB.capital,
              ),
              _ComparisonRow(
                label: 'Population',
                valueA: formatPopulation(countryA.population),
                valueB: formatPopulation(countryB.population),
                highlightHigher: countryA.population > countryB.population
                    ? 'A'
                    : countryB.population > countryA.population
                        ? 'B'
                        : null,
              ),
              _ComparisonRow(
                label: 'Region',
                valueA: countryA.region,
                valueB: countryB.region,
              ),
              _ComparisonRow(
                label: 'Subregion',
                valueA: countryA.subregion.isNotEmpty
                    ? countryA.subregion
                    : 'N/A',
                valueB: countryB.subregion.isNotEmpty
                    ? countryB.subregion
                    : 'N/A',
              ),
              _ComparisonRow(
                label: 'Continent',
                valueA: countryA.continents.isNotEmpty
                    ? countryA.continents.join(', ')
                    : 'N/A',
                valueB: countryB.continents.isNotEmpty
                    ? countryB.continents.join(', ')
                    : 'N/A',
              ),
              _ComparisonRow(
                label: 'Area',
                valueA: formatArea(countryA.area),
                valueB: formatArea(countryB.area),
                highlightHigher: countryA.area > countryB.area
                    ? 'A'
                    : countryB.area > countryA.area
                        ? 'B'
                        : null,
              ),
              _ComparisonRow(
                label: 'Languages',
                valueA: countryA.languages.isNotEmpty
                    ? countryA.languages.join(', ')
                    : 'N/A',
                valueB: countryB.languages.isNotEmpty
                    ? countryB.languages.join(', ')
                    : 'N/A',
              ),
              _ComparisonRow(
                label: 'Currencies',
                valueA: countryA.currencies.isNotEmpty
                    ? countryA.currencies.join(', ')
                    : 'N/A',
                valueB: countryB.currencies.isNotEmpty
                    ? countryB.currencies.join(', ')
                    : 'N/A',
              ),
              _ComparisonRow(
                label: 'Dialing Code',
                valueA: countryA.dialingCode.isNotEmpty
                    ? countryA.dialingCode
                    : 'N/A',
                valueB: countryB.dialingCode.isNotEmpty
                    ? countryB.dialingCode
                    : 'N/A',
              ),
              _ComparisonRow(
                label: 'Driving Side',
                valueA: countryA.carSide.isNotEmpty
                    ? countryA.carSide[0].toUpperCase() +
                        countryA.carSide.substring(1)
                    : 'N/A',
                valueB: countryB.carSide.isNotEmpty
                    ? countryB.carSide[0].toUpperCase() +
                        countryB.carSide.substring(1)
                    : 'N/A',
              ),
              _ComparisonRow(
                label: 'Timezones',
                valueA: countryA.timezones.isNotEmpty
                    ? countryA.timezones.join(', ')
                    : 'N/A',
                valueB: countryB.timezones.isNotEmpty
                    ? countryB.timezones.join(', ')
                    : 'N/A',
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _FlagHeader extends StatelessWidget {
  final CountryModel country;

  const _FlagHeader({required this.country});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: country.flagUrl,
            height: 80,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (BuildContext context, String url) => Container(
              height: 80,
              color: Colors.grey.shade300,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (BuildContext context, String url, Object error) =>
                Container(
              height: 80,
              color: Colors.grey.shade300,
              child: const Icon(Icons.flag, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          country.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

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
            style: theme.textTheme.bodySmall?.copyWith(
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: highlightHigher == 'A'
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: theme.dividerColor,
              ),
              Expanded(
                child: Text(
                  valueB,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
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
