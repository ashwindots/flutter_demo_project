import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void _logRequest(String method, Uri url) {
    developer.log('──────── API REQUEST ────────');
    developer.log('$method $url');
    // ignore: avoid_print
    print('[API REQUEST] $method $url');
  }

  void _logResponse(Uri url, int statusCode, String body) {
    final int bodyLength = body.length;
    final String preview =
        bodyLength > 500 ? '${body.substring(0, 500)}...' : body;
    developer.log('──────── API RESPONSE ────────');
    developer.log('URL: $url');
    developer.log('Status: $statusCode');
    developer.log('Body length: $bodyLength chars');
    developer.log('Preview: $preview');
    // ignore: avoid_print
    print('[API RESPONSE] Status: $statusCode | URL: $url | Body length: $bodyLength chars');
  }

  Future<List<Map<String, dynamic>>> _getList(Uri url) async {
    _logRequest('GET', url);
    final http.Response response = await _client.get(url);
    _logResponse(url, response.statusCode, response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      // ignore: avoid_print
      print('[API PARSED] ${data.length} items returned');
      return data.cast<Map<String, dynamic>>();
    }
    if (response.statusCode == 404) {
      // ignore: avoid_print
      print('[API] 404 — No results found');
      return [];
    }
    throw Exception('API request failed: ${response.statusCode}');
  }

  /// GET /v3.1/all?fields=name,flags — fetch all countries (lightweight list).
  Future<List<Map<String, dynamic>>> fetchAllCountries() async {
    final Uri url = Uri.parse('$_baseUrl/all?fields=name,flags');
    return _getList(url);
  }

  /// GET /v3.1/all — fetch every country with full payload.
  Future<List<Map<String, dynamic>>> fetchAllCountriesFull() async {
    final Uri url = Uri.parse('$_baseUrl/all');
    return _getList(url);
  }

  /// GET /v3.1/all?fields={fields} — fetch all with specific fields.
  Future<List<Map<String, dynamic>>> fetchAllWithFields(
      List<String> fields) async {
    final String joined = fields.join(',');
    final Uri url = Uri.parse('$_baseUrl/all?fields=$joined');
    return _getList(url);
  }

  /// GET /v3.1/name/{name} — search by common or official name (partial match).
  Future<List<Map<String, dynamic>>> searchByName(String name) async {
    final Uri url =
        Uri.parse('$_baseUrl/name/${Uri.encodeComponent(name)}');
    return _getList(url);
  }

  /// GET /v3.1/name/{name}?fullText=true — search by exact full name.
  Future<List<Map<String, dynamic>>> searchByFullName(String name) async {
    final Uri url = Uri.parse(
        '$_baseUrl/name/${Uri.encodeComponent(name)}?fullText=true');
    return _getList(url);
  }

  /// GET /v3.1/alpha/{code} — search by cca2, ccn3, cca3 or cioc code.
  Future<List<Map<String, dynamic>>> fetchByCode(String code) async {
    final Uri url =
        Uri.parse('$_baseUrl/alpha/${Uri.encodeComponent(code)}');
    return _getList(url);
  }

  /// GET /v3.1/alpha?codes={code},{code} — fetch multiple codes at once.
  Future<List<Map<String, dynamic>>> fetchByCodes(List<String> codes) async {
    final String joined = codes.map(Uri.encodeComponent).join(',');
    final Uri url = Uri.parse('$_baseUrl/alpha?codes=$joined');
    return _getList(url);
  }

  /// GET /v3.1/currency/{currency} — search by currency code or name.
  Future<List<Map<String, dynamic>>> fetchByCurrency(String currency) async {
    final Uri url =
        Uri.parse('$_baseUrl/currency/${Uri.encodeComponent(currency)}');
    return _getList(url);
  }

  /// GET /v3.1/lang/{language} — search by language code or name.
  Future<List<Map<String, dynamic>>> fetchByLanguage(String language) async {
    final Uri url =
        Uri.parse('$_baseUrl/lang/${Uri.encodeComponent(language)}');
    return _getList(url);
  }

  /// GET /v3.1/capital/{capital} — search by capital city.
  Future<List<Map<String, dynamic>>> fetchByCapital(String capital) async {
    final Uri url =
        Uri.parse('$_baseUrl/capital/${Uri.encodeComponent(capital)}');
    return _getList(url);
  }

  /// GET /v3.1/region/{region} — filter by region.
  Future<List<Map<String, dynamic>>> fetchByRegion(String region) async {
    final Uri url =
        Uri.parse('$_baseUrl/region/${Uri.encodeComponent(region)}');
    return _getList(url);
  }

  /// GET /v3.1/subregion/{subregion} — filter by subregion.
  Future<List<Map<String, dynamic>>> fetchBySubregion(
      String subregion) async {
    final Uri url =
        Uri.parse('$_baseUrl/subregion/${Uri.encodeComponent(subregion)}');
    return _getList(url);
  }

  /// GET /v3.1/demonym/{demonym} — search by demonym.
  Future<List<Map<String, dynamic>>> fetchByDemonym(String demonym) async {
    final Uri url =
        Uri.parse('$_baseUrl/demonym/${Uri.encodeComponent(demonym)}');
    return _getList(url);
  }

  /// GET /v3.1/translation/{translation} — search by translation name.
  Future<List<Map<String, dynamic>>> fetchByTranslation(
      String translation) async {
    final Uri url = Uri.parse(
        '$_baseUrl/translation/${Uri.encodeComponent(translation)}');
    return _getList(url);
  }

  /// GET /v3.1/independent?status={true|false} — independent countries.
  Future<List<Map<String, dynamic>>> fetchIndependent({
    bool status = true,
  }) async {
    final Uri url =
        Uri.parse('$_baseUrl/independent?status=$status');
    return _getList(url);
  }
}
