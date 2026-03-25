import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _countryCacheKey = 'cached_countries';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const String _favoritesKey = 'favorite_countries';
  static const String _darkModeKey = 'dark_mode';
  static const Duration _cacheDuration = Duration(hours: 1);

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Country Cache ---

  Future<void> cacheCountries(String jsonData) async {
    await _prefs.setString(_countryCacheKey, jsonData);
    await _prefs.setInt(
        _cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  String? getCachedCountries() {
    final int? timestamp = _prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return null;

    final DateTime cachedTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cachedTime) > _cacheDuration) {
      return null;
    }
    return _prefs.getString(_countryCacheKey);
  }

  // --- Favorites ---

  List<String> getFavorites() {
    final String? data = _prefs.getString(_favoritesKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data) as List<dynamic>;
    return decoded.cast<String>();
  }

  Future<void> saveFavorites(List<String> favoriteCodes) async {
    await _prefs.setString(_favoritesKey, json.encode(favoriteCodes));
  }

  // --- Dark Mode ---

  bool getDarkMode() {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode({required bool isDark}) async {
    await _prefs.setBool(_darkModeKey, isDark);
  }
}
