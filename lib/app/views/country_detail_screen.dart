import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/country_controller.dart';
import '../models/country_model.dart';
import '../routes/app_routes.dart';
import '../utils/helpers.dart';

class CountryDetailScreen extends StatefulWidget {
  final CountryModel country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  late CountryModel _country;
  bool _isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    _country = widget.country;
    _fetchFullDetail();
  }

  Future<void> _fetchFullDetail() async {
    final CountryController controller = Get.find<CountryController>();
    final CountryModel? fullData =
        await controller.fetchCountryDetail(widget.country);
    if (mounted) {
      setState(() {
        _country = fullData ?? widget.country;
        _isLoadingDetail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CountryController controller = Get.find<CountryController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_country.name),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isFavorite(_country.cca3)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.isFavorite(_country.cca3)
                      ? Colors.red
                      : null,
                ),
                onPressed: () => controller.toggleFavorite(_country.cca3),
              )),
        ],
      ),
      body: _isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large flag
            Container(
              height: 220,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _country.flagUrl,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) =>
                      Container(
                        color: Colors.grey.shade300,
                        child:
                            const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.flag, size: 64),
                          ),
                ),
              ),
            ),

            // Country name with emoji
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _country.flagEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _country.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _country.officialName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Quick badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (_country.independent)
                    _Badge(label: 'Independent', color: Colors.green),
                  if (_country.unMember)
                    _Badge(label: 'UN Member', color: Colors.blue),
                  if (_country.landlocked)
                    _Badge(label: 'Landlocked', color: Colors.orange),
                  if (_country.region.isNotEmpty)
                    _Badge(
                        label: _country.region,
                        color: theme.colorScheme.primary),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info rows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _InfoSection(country: _country),
            ),

            // Coat of Arms
            if (_country.coatOfArmsPngUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Coat of Arms',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: CachedNetworkImage(
                  imageUrl: _country.coatOfArmsPngUrl,
                  height: 120,
                  fit: BoxFit.contain,
                  placeholder: (BuildContext context, String url) =>
                      const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator())),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          const SizedBox.shrink(),
                ),
              ),
            ],

            // Bordering countries
            if (_country.borders.isNotEmpty) ...[
              const SizedBox(height: 20),
              _BorderingCountries(borderCodes: _country.borders),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------- Badges ----------

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ---------- Info section ----------

class _InfoSection extends StatelessWidget {
  final CountryModel country;

  const _InfoSection({required this.country});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(context,
            icon: Icons.location_city,
            label: 'Capital',
            value: country.capital),
        _buildInfoRow(context,
            icon: Icons.people,
            label: 'Population',
            value: formatPopulation(country.population)),
        _buildInfoRow(context,
            icon: Icons.public,
            label: 'Region',
            value: country.region),
        _buildInfoRow(context,
            icon: Icons.map,
            label: 'Subregion',
            value: country.subregion.isNotEmpty
                ? country.subregion
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.terrain,
            label: 'Continent',
            value: country.continents.isNotEmpty
                ? country.continents.join(', ')
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.square_foot,
            label: 'Area',
            value: formatArea(country.area)),
        _buildInfoRow(context,
            icon: Icons.attach_money,
            label: 'Currencies',
            value: country.currencies.isNotEmpty
                ? country.currencies.join(', ')
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.language,
            label: 'Languages',
            value: country.languages.isNotEmpty
                ? country.languages.join(', ')
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.phone,
            label: 'Dialing Code',
            value: country.dialingCode.isNotEmpty
                ? country.dialingCode
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.web,
            label: 'Top-Level Domain',
            value:
                country.tld.isNotEmpty ? country.tld.join(', ') : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.access_time,
            label: 'Timezones',
            value: country.timezones.isNotEmpty
                ? country.timezones.join(', ')
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.calendar_today,
            label: 'Start of Week',
            value: country.startOfWeek.isNotEmpty
                ? country.startOfWeek[0].toUpperCase() +
                    country.startOfWeek.substring(1)
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.directions_car,
            label: 'Driving Side',
            value: country.carSide.isNotEmpty
                ? country.carSide[0].toUpperCase() +
                    country.carSide.substring(1)
                : 'N/A'),
        _buildInfoRow(context,
            icon: Icons.person,
            label: 'Demonym',
            value: country.demonymMale.isNotEmpty
                ? '${country.demonymMale} / ${country.demonymFemale}'
                : 'N/A'),
        if (country.fifaCode.isNotEmpty)
          _buildInfoRow(context,
              icon: Icons.sports_soccer,
              label: 'FIFA Code',
              value: country.fifaCode),
        if (country.latlng.length == 2)
          _buildInfoRow(context,
              icon: Icons.location_on,
              label: 'Coordinates',
              value:
                  '${country.latlng[0].toStringAsFixed(2)}°, ${country.latlng[1].toStringAsFixed(2)}°'),
        _buildInfoRow(context,
            icon: Icons.code,
            label: 'Country Codes',
            value:
                'CCA2: ${country.cca2}  •  CCA3: ${country.cca3}  •  CCN3: ${country.ccn3}'),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Bordering countries ----------

class _BorderingCountries extends StatelessWidget {
  final List<String> borderCodes;

  const _BorderingCountries({required this.borderCodes});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CountryController controller = Get.find<CountryController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bordering Countries',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: borderCodes.map((String code) {
              final String name = controller.borderCodeToName(code);
              final CountryModel? neighbor = controller.findByCode(code);
              return ActionChip(
                avatar: neighbor != null
                    ? Text(neighbor.flagEmoji,
                        style: const TextStyle(fontSize: 16))
                    : null,
                label: Text(name),
                onPressed: () {
                  if (neighbor != null) {
                    Get.toNamed(AppRoutes.countryDetail,
                        arguments: neighbor,
                        preventDuplicates: false);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
