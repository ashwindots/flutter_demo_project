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

class _ComparisonScreenState extends State<ComparisonScreen>
    with TickerProviderStateMixin {
  CountryModel? _countryA;
  CountryModel? _countryB;
  String _searchQuery = '';
  bool _showComparison = false;

  late final AnimationController _comparisonSlide;
  late final Animation<Offset> _slideAnim;
  late final AnimationController _vsController;
  late final Animation<double> _vsPulse;

  @override
  void initState() {
    super.initState();
    _comparisonSlide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _comparisonSlide,
      curve: Curves.easeOutCubic,
    ));
    _vsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _vsPulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _vsController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _comparisonSlide.dispose();
    _vsController.dispose();
    super.dispose();
  }

  void _onCountryTap(CountryModel country) {
    setState(() {
      if (_countryA?.cca3 == country.cca3) {
        _countryA = null;
        _hideComparison();
        return;
      }
      if (_countryB?.cca3 == country.cca3) {
        _countryB = null;
        _hideComparison();
        return;
      }
      if (_countryA == null) {
        _countryA = country;
      } else if (_countryB == null) {
        _countryB = country;
      } else {
        _countryB = country;
      }
      if (_countryA != null && _countryB != null) {
        _showComparisonPanel();
      }
    });
  }

  void _showComparisonPanel() {
    _showComparison = true;
    _comparisonSlide.forward(from: 0);
    _vsController.repeat(reverse: true);
  }

  void _hideComparison() {
    _comparisonSlide.reverse();
    _vsController.stop();
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showComparison = false);
    });
  }

  void _resetAll() {
    setState(() {
      _countryA = null;
      _countryB = null;
    });
    _hideComparison();
  }

  bool _isSelected(String cca3) =>
      _countryA?.cca3 == cca3 || _countryB?.cca3 == cca3;

  String _slotLabel(String cca3) {
    if (_countryA?.cca3 == cca3) return 'A';
    if (_countryB?.cca3 == cca3) return 'B';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Countries'),
        actions: [
          if (_countryA != null || _countryB != null)
            IconButton(
              onPressed: _resetAll,
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Obx(() {
        final CountryController controller = Get.find<CountryController>();
        final List<CountryModel> allCountries =
            List<CountryModel>.from(controller.allCountries);
        allCountries.sort((CountryModel a, CountryModel b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        final List<CountryModel> countries = _searchQuery.isEmpty
            ? allCountries
            : allCountries
                .where((CountryModel c) =>
                    c.name.toLowerCase().contains(_searchQuery))
                .toList();

        return Column(
          children: [
            // ── Selection row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _SelectionBox(
                      label: 'Country A',
                      slotLetter: 'A',
                      country: _countryA,
                      onClear: () {
                        setState(() => _countryA = null);
                        _hideComparison();
                      },
                    ),
                  ),
                  // Animated VS badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _countryA != null && _countryB != null
                        ? ScaleTransition(
                            scale: _vsPulse,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.tertiary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withAlpha(60),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'VS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Icon(Icons.compare_arrows_rounded,
                            color: theme.colorScheme.onSurfaceVariant
                                .withAlpha(120),
                            size: 24),
                  ),
                  Expanded(
                    child: _SelectionBox(
                      label: 'Country B',
                      slotLetter: 'B',
                      country: _countryB,
                      onClear: () {
                        setState(() => _countryB = null);
                        _hideComparison();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Comparison panel ──
            if (_showComparison && _countryA != null && _countryB != null)
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _comparisonSlide,
                  child: _ComparisonPanel(
                    countryA: _countryA!,
                    countryB: _countryB!,
                  ),
                ),
              ),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (String value) =>
                    setState(() => _searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search countries...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),

            // ── Instruction / count ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
              child: Row(
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _countryA == null && _countryB == null
                          ? 'Tap two countries to compare them'
                          : '${countries.length} countries',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Country list ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 100),
                itemCount: countries.length,
                itemBuilder: (BuildContext context, int index) {
                  final CountryModel country = countries[index];
                  final bool selected = _isSelected(country.cca3);
                  return _CountryListTile(
                    key: ValueKey(country.cca3),
                    country: country,
                    isSelected: selected,
                    slotLabel: _slotLabel(country.cca3),
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

// ══════════════════════════════════════════════════════════════════════════════
// SELECTION BOX
// ══════════════════════════════════════════════════════════════════════════════

class _SelectionBox extends StatelessWidget {
  final String label;
  final String slotLetter;
  final CountryModel? country;
  final VoidCallback onClear;

  const _SelectionBox({
    required this.label,
    required this.slotLetter,
    required this.country,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool filled = country != null;
    final bool isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 120,
      decoration: BoxDecoration(
        color: filled
            ? (isDark
                ? theme.colorScheme.primary.withAlpha(15)
                : theme.colorScheme.primary.withAlpha(8))
            : (isDark ? const Color(0xFF1A1D24) : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: filled
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withAlpha(80),
          width: filled ? 2 : 1,
        ),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: filled
            ? Stack(
                key: ValueKey('filled_${country!.cca3}'),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Flag with rounded corners
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: country!.flagUrl,
                                height: 40,
                                width: 58,
                                fit: BoxFit.cover,
                                errorWidget: (BuildContext context, String url,
                                        Object error) =>
                                    const Icon(Icons.flag, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            country!.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Slot letter badge
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          slotLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onClear,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 14,
                            color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                key: ValueKey('empty_$slotLetter'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPARISON PANEL  — slide-in results card
// ══════════════════════════════════════════════════════════════════════════════

class _ComparisonPanel extends StatelessWidget {
  final CountryModel countryA;
  final CountryModel countryB;

  const _ComparisonPanel({
    required this.countryA,
    required this.countryB,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final List<_ComparisonData> rows = [
      _ComparisonData(
        icon: Icons.people_alt_outlined,
        label: 'Population',
        valueA: formatPopulation(countryA.population),
        valueB: formatPopulation(countryB.population),
        winnerSide: countryA.population > countryB.population
            ? 'A'
            : countryB.population > countryA.population
                ? 'B'
                : null,
      ),
      _ComparisonData(
        icon: Icons.square_foot_outlined,
        label: 'Area',
        valueA: formatArea(countryA.area),
        valueB: formatArea(countryB.area),
        winnerSide: countryA.area > countryB.area
            ? 'A'
            : countryB.area > countryA.area
                ? 'B'
                : null,
      ),
      _ComparisonData(
        icon: Icons.location_city_outlined,
        label: 'Capital',
        valueA: countryA.capital,
        valueB: countryB.capital,
      ),
      _ComparisonData(
        icon: Icons.map_outlined,
        label: 'Region',
        valueA: countryA.region,
        valueB: countryB.region,
      ),
      _ComparisonData(
        icon: Icons.explore_outlined,
        label: 'Subregion',
        valueA: countryA.subregion.isNotEmpty ? countryA.subregion : '—',
        valueB: countryB.subregion.isNotEmpty ? countryB.subregion : '—',
      ),
      _ComparisonData(
        icon: Icons.language_rounded,
        label: 'Languages',
        valueA: countryA.languages.isNotEmpty
            ? countryA.languages.take(2).join(', ')
            : '—',
        valueB: countryB.languages.isNotEmpty
            ? countryB.languages.take(2).join(', ')
            : '—',
      ),
      _ComparisonData(
        icon: Icons.attach_money_rounded,
        label: 'Currency',
        valueA: countryA.currencies.isNotEmpty
            ? countryA.currencies.first
            : '—',
        valueB: countryB.currencies.isNotEmpty
            ? countryB.currencies.first
            : '—',
      ),
      _ComparisonData(
        icon: Icons.access_time_rounded,
        label: 'Timezones',
        valueA: countryA.timezones.isNotEmpty
            ? countryA.timezones.first
            : '—',
        valueB: countryB.timezones.isNotEmpty
            ? countryB.timezones.first
            : '—',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D24) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(isDark ? 15 : 10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with flag emojis
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(countryA.flagEmoji,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    countryA.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    countryB.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 6),
                Text(countryB.flagEmoji,
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withAlpha(40),
          ),
          // Scrollable comparison rows
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              shrinkWrap: true,
              itemCount: rows.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant.withAlpha(25),
              ),
              itemBuilder: (BuildContext context, int index) {
                return _ComparisonRow(data: rows[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonData {
  final IconData icon;
  final String label;
  final String valueA;
  final String valueB;
  final String? winnerSide;

  const _ComparisonData({
    required this.icon,
    required this.label,
    required this.valueA,
    required this.valueB,
    this.winnerSide,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPARISON ROW
// ══════════════════════════════════════════════════════════════════════════════

class _ComparisonRow extends StatelessWidget {
  final _ComparisonData data;

  const _ComparisonRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color winColor = Colors.green.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Value A
          Expanded(
            child: Row(
              children: [
                if (data.winnerSide == 'A')
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.emoji_events_rounded,
                        size: 14, color: winColor),
                  ),
                Expanded(
                  child: Text(
                    data.valueA,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: data.winnerSide == 'A'
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: data.winnerSide == 'A' ? winColor : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Center label + icon
          Container(
            width: 90,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    data.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Value B
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    data.valueB,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: data.winnerSide == 'B'
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: data.winnerSide == 'B' ? winColor : null,
                    ),
                  ),
                ),
                if (data.winnerSide == 'B')
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.emoji_events_rounded,
                        size: 14, color: winColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COUNTRY LIST TILE
// ══════════════════════════════════════════════════════════════════════════════

class _CountryListTile extends StatelessWidget {
  final CountryModel country;
  final bool isSelected;
  final String slotLabel;
  final VoidCallback onTap;

  const _CountryListTile({
    super.key,
    required this.country,
    required this.isSelected,
    required this.slotLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary.withAlpha(70),
                )
              : Border.all(color: Colors.transparent),
        ),
        child: ListTile(
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: country.flagUrl,
                  width: 42,
                  height: 30,
                  fit: BoxFit.cover,
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          const Icon(Icons.flag, size: 24),
                ),
              ),
              // Slot badge on flag
              if (isSelected && slotLabel.isNotEmpty)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slotLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            country.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            '${country.region}  •  ${formatPopulation(country.population)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                ScaleTransition(scale: animation, child: child),
            child: isSelected
                ? Container(
                    key: const ValueKey('selected'),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white),
                  )
                : Icon(
                    Icons.add_circle_outline_rounded,
                    key: const ValueKey('unselected'),
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
          ),
        ),
      ),
    );
  }
}
