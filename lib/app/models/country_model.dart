import 'dart:convert';

class CountryModel {
  final String name;
  final String officialName;
  final String cca2;
  final String cca3;
  final String ccn3;
  final String cioc;
  final String flagUrl;
  final String flagSvgUrl;
  final String flagAlt;
  final String flagEmoji;
  final String region;
  final String subregion;
  final String capital;
  final int population;
  final List<String> languages;
  final List<String> currencies;
  final double area;
  final List<String> timezones;
  final List<String> continents;
  final List<String> borders;
  final List<double> latlng;
  final List<String> tld;
  final String startOfWeek;
  final String carSide;
  final bool independent;
  final bool landlocked;
  final bool unMember;
  final String googleMapsUrl;
  final String openStreetMapsUrl;
  final String coatOfArmsPngUrl;
  final String coatOfArmsSvgUrl;
  final String dialingCode;
  final String demonymMale;
  final String demonymFemale;
  final String fifaCode;
  final Map<String, dynamic> rawJson;

  const CountryModel({
    required this.name,
    required this.officialName,
    required this.cca2,
    required this.cca3,
    required this.ccn3,
    required this.cioc,
    required this.flagUrl,
    required this.flagSvgUrl,
    required this.flagAlt,
    required this.flagEmoji,
    required this.region,
    required this.subregion,
    required this.capital,
    required this.population,
    required this.languages,
    required this.currencies,
    required this.area,
    required this.timezones,
    required this.continents,
    required this.borders,
    required this.latlng,
    required this.tld,
    required this.startOfWeek,
    required this.carSide,
    required this.independent,
    required this.landlocked,
    required this.unMember,
    required this.googleMapsUrl,
    required this.openStreetMapsUrl,
    required this.coatOfArmsPngUrl,
    required this.coatOfArmsSvgUrl,
    required this.dialingCode,
    required this.demonymMale,
    required this.demonymFemale,
    required this.fifaCode,
    required this.rawJson,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> nameMap =
        (json['name'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> flagsMap =
        (json['flags'] as Map<String, dynamic>?) ?? {};
    final List<dynamic> capitalList =
        (json['capital'] as List<dynamic>?) ?? [];
    final Map<String, dynamic> languagesMap =
        (json['languages'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> currenciesMap =
        (json['currencies'] as Map<String, dynamic>?) ?? {};
    final List<dynamic> timezonesList =
        (json['timezones'] as List<dynamic>?) ?? [];
    final List<dynamic> continentsList =
        (json['continents'] as List<dynamic>?) ?? [];
    final List<dynamic> bordersList =
        (json['borders'] as List<dynamic>?) ?? [];
    final List<dynamic> latlngList =
        (json['latlng'] as List<dynamic>?) ?? [];
    final List<dynamic> tldList =
        (json['tld'] as List<dynamic>?) ?? [];
    final Map<String, dynamic> mapsMap =
        (json['maps'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> coatOfArmsMap =
        (json['coatOfArms'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> carMap =
        (json['car'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> iddMap =
        (json['idd'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> demonymsMap =
        (json['demonyms'] as Map<String, dynamic>?) ?? {};
    final Map<String, dynamic> engDemonym =
        (demonymsMap['eng'] as Map<String, dynamic>?) ?? {};

    // Build dialing code
    final String iddRoot = (iddMap['root'] as String?) ?? '';
    final List<dynamic> iddSuffixes =
        (iddMap['suffixes'] as List<dynamic>?) ?? [];
    final String dialingCode = iddSuffixes.isNotEmpty
        ? '$iddRoot${iddSuffixes.first}'
        : iddRoot;

    // Build currency display strings
    final List<String> currencyNames = currenciesMap.values
        .map<String>((dynamic c) {
      final Map<String, dynamic> cm = c as Map<String, dynamic>;
      return '${cm['name'] ?? ''} (${cm['symbol'] ?? ''})';
    }).toList();

    return CountryModel(
      name: (nameMap['common'] as String?) ?? '',
      officialName: (nameMap['official'] as String?) ?? '',
      cca2: (json['cca2'] as String?) ?? '',
      cca3: (json['cca3'] as String?) ?? '',
      ccn3: (json['ccn3'] as String?) ?? '',
      cioc: (json['cioc'] as String?) ?? '',
      flagUrl: (flagsMap['png'] as String?) ?? '',
      flagSvgUrl: (flagsMap['svg'] as String?) ?? '',
      flagAlt: (flagsMap['alt'] as String?) ?? '',
      flagEmoji: (json['flag'] as String?) ?? '',
      region: (json['region'] as String?) ?? '',
      subregion: (json['subregion'] as String?) ?? '',
      capital:
          capitalList.isNotEmpty ? capitalList.first.toString() : 'N/A',
      population: (json['population'] as int?) ?? 0,
      languages: languagesMap.values
          .map<String>((dynamic e) => e.toString())
          .toList(),
      currencies: currencyNames,
      area: ((json['area'] ?? 0) as num).toDouble(),
      timezones: timezonesList
          .map<String>((dynamic e) => e.toString())
          .toList(),
      continents: continentsList
          .map<String>((dynamic e) => e.toString())
          .toList(),
      borders: bordersList
          .map<String>((dynamic e) => e.toString())
          .toList(),
      latlng: latlngList
          .map<double>((dynamic e) => (e as num).toDouble())
          .toList(),
      tld: tldList.map<String>((dynamic e) => e.toString()).toList(),
      startOfWeek: (json['startOfWeek'] as String?) ?? '',
      carSide: (carMap['side'] as String?) ?? '',
      independent: (json['independent'] as bool?) ?? false,
      landlocked: (json['landlocked'] as bool?) ?? false,
      unMember: (json['unMember'] as bool?) ?? false,
      googleMapsUrl: (mapsMap['googleMaps'] as String?) ?? '',
      openStreetMapsUrl: (mapsMap['openStreetMaps'] as String?) ?? '',
      coatOfArmsPngUrl: (coatOfArmsMap['png'] as String?) ?? '',
      coatOfArmsSvgUrl: (coatOfArmsMap['svg'] as String?) ?? '',
      dialingCode: dialingCode,
      demonymMale: (engDemonym['m'] as String?) ?? '',
      demonymFemale: (engDemonym['f'] as String?) ?? '',
      fifaCode: (json['fifa'] as String?) ?? '',
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => rawJson;

  static List<CountryModel> fromJsonList(String jsonString) {
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
    return data
        .map<CountryModel>((dynamic item) =>
            CountryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String toJsonList(List<CountryModel> countries) {
    return json.encode(countries.map((CountryModel c) => c.toJson()).toList());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          cca3 == other.cca3;

  @override
  int get hashCode => cca3.hashCode;
}
