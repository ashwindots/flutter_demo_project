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

class _CountryDetailScreenState extends State<CountryDetailScreen>
    with SingleTickerProviderStateMixin {
  late CountryModel _country;
  bool _isLoadingDetail = true;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _country = widget.country;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _fetchFullDetail();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CountryController controller = Get.find<CountryController>();
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _isLoadingDetail
          ? _buildLoadingState(theme)
          : CustomScrollView(
              slivers: [
                // ── Collapsing flag header ──
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  stretch: true,
                  title: Text(_country.name),
                  actions: [
                    Obx(() => IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (Widget child,
                                    Animation<double> animation) =>
                                ScaleTransition(
                                    scale: animation, child: child),
                            child: Icon(
                              controller.isFavorite(_country.cca3)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey<bool>(
                                  controller.isFavorite(_country.cca3)),
                              color: controller.isFavorite(_country.cca3)
                                  ? Colors.redAccent
                                  : null,
                            ),
                          ),
                          onPressed: () =>
                              controller.toggleFavorite(_country.cca3),
                        )),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'flag_${_country.cca3}',
                          child: CachedNetworkImage(
                            imageUrl: _country.flagUrl,
                            fit: BoxFit.cover,
                            placeholder: (BuildContext context, String url) =>
                                Container(color: theme.colorScheme.surfaceContainerHighest),
                            errorWidget: (BuildContext context, String url,
                                    Object error) =>
                                Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.flag, size: 64),
                                ),
                          ),
                        ),
                        // Gradient scrim for readability
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withAlpha(0),
                                Colors.black.withAlpha(120),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                        // Name overlay at bottom
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_country.flagEmoji}  ${_country.name}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                              if (_country.officialName.isNotEmpty &&
                                  _country.officialName != _country.name)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _country.officialName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white.withAlpha(200),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Body content ──
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick badges
                          _buildBadges(theme),
                          const SizedBox(height: 20),

                          // Overview card
                          _SectionCard(
                            title: 'Overview',
                            icon: Icons.info_outline_rounded,
                            theme: theme,
                            isDark: isDark,
                            rows: [
                              _InfoRowData(Icons.location_city, 'Capital',
                                  _country.capital),
                              _InfoRowData(Icons.people_alt_outlined,
                                  'Population',
                                  formatPopulation(_country.population)),
                              _InfoRowData(Icons.square_foot, 'Area',
                                  formatArea(_country.area)),
                              _InfoRowData(Icons.attach_money, 'Currencies',
                                  _country.currencies.isNotEmpty
                                      ? _country.currencies.join(', ')
                                      : 'N/A'),
                              _InfoRowData(Icons.language, 'Languages',
                                  _country.languages.isNotEmpty
                                      ? _country.languages.join(', ')
                                      : 'N/A'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Geography card
                          _SectionCard(
                            title: 'Geography',
                            icon: Icons.public_rounded,
                            theme: theme,
                            isDark: isDark,
                            rows: [
                              _InfoRowData(Icons.map_outlined, 'Region',
                                  _country.region),
                              _InfoRowData(
                                  Icons.explore_outlined,
                                  'Subregion',
                                  _country.subregion.isNotEmpty
                                      ? _country.subregion
                                      : 'N/A'),
                              _InfoRowData(
                                  Icons.terrain_outlined,
                                  'Continent',
                                  _country.continents.isNotEmpty
                                      ? _country.continents.join(', ')
                                      : 'N/A'),
                              if (_country.latlng.length == 2)
                                _InfoRowData(
                                    Icons.location_on_outlined,
                                    'Coordinates',
                                    '${_country.latlng[0].toStringAsFixed(2)}°, ${_country.latlng[1].toStringAsFixed(2)}°'),
                              _InfoRowData(
                                  Icons.access_time_outlined,
                                  'Timezones',
                                  _country.timezones.isNotEmpty
                                      ? _country.timezones.join(', ')
                                      : 'N/A'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Culture & Misc card
                          _SectionCard(
                            title: 'Culture & Misc',
                            icon: Icons.diversity_3_outlined,
                            theme: theme,
                            isDark: isDark,
                            rows: [
                              _InfoRowData(Icons.phone_outlined,
                                  'Dialing Code',
                                  _country.dialingCode.isNotEmpty
                                      ? _country.dialingCode
                                      : 'N/A'),
                              _InfoRowData(Icons.web_outlined,
                                  'Top-Level Domain',
                                  _country.tld.isNotEmpty
                                      ? _country.tld.join(', ')
                                      : 'N/A'),
                              _InfoRowData(
                                  Icons.calendar_today_outlined,
                                  'Start of Week',
                                  _country.startOfWeek.isNotEmpty
                                      ? _country.startOfWeek[0]
                                              .toUpperCase() +
                                          _country.startOfWeek.substring(1)
                                      : 'N/A'),
                              _InfoRowData(
                                  Icons.directions_car_outlined,
                                  'Driving Side',
                                  _country.carSide.isNotEmpty
                                      ? _country.carSide[0].toUpperCase() +
                                          _country.carSide.substring(1)
                                      : 'N/A'),
                              _InfoRowData(
                                  Icons.person_outline,
                                  'Demonym',
                                  _country.demonymMale.isNotEmpty
                                      ? '${_country.demonymMale} / ${_country.demonymFemale}'
                                      : 'N/A'),
                              if (_country.fifaCode.isNotEmpty)
                                _InfoRowData(Icons.sports_soccer,
                                    'FIFA Code', _country.fifaCode),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Codes card
                          _SectionCard(
                            title: 'Identifiers',
                            icon: Icons.qr_code_2_outlined,
                            theme: theme,
                            isDark: isDark,
                            rows: [
                              _InfoRowData(Icons.tag, 'CCA2', _country.cca2),
                              _InfoRowData(Icons.tag, 'CCA3', _country.cca3),
                              _InfoRowData(Icons.tag, 'CCN3',
                                  _country.ccn3.isNotEmpty
                                      ? _country.ccn3
                                      : 'N/A'),
                            ],
                          ),

                          // Coat of Arms
                          if (_country.coatOfArmsPngUrl.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildCoatOfArms(theme, isDark),
                          ],

                          // Bordering countries
                          if (_country.borders.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _BorderingCountries(
                                borderCodes: _country.borders),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading details...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_country.independent)
          _Badge(label: 'Independent', color: Colors.green.shade600),
        if (_country.unMember)
          _Badge(label: 'UN Member', color: Colors.blue.shade600),
        if (_country.landlocked)
          _Badge(label: 'Landlocked', color: Colors.orange.shade700),
        if (_country.region.isNotEmpty)
          _Badge(label: _country.region, color: theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildCoatOfArms(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Coat of Arms',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CachedNetworkImage(
            imageUrl: _country.coatOfArmsPngUrl,
            height: 130,
            fit: BoxFit.contain,
            placeholder: (BuildContext context, String url) => const SizedBox(
                height: 130,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            errorWidget:
                (BuildContext context, String url, Object error) =>
                    const SizedBox.shrink(),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(20), color.withAlpha(50)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ---------- Section card ----------

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRowData(this.icon, this.label, this.value);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;
  final bool isDark;
  final List<_InfoRowData> rows;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.theme,
    required this.isDark,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      size: 18, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withAlpha(40),
          ),
          // Rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: rows.asMap().entries.map((MapEntry<int, _InfoRowData> entry) {
                final _InfoRowData row = entry.value;
                final bool isLast = entry.key == rows.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(row.icon,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              row.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.share_location_outlined,
                    size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Bordering Countries',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
