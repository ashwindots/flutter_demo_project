import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:get/get.dart';

import '../models/country_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum SortOption { nameAsc, nameDesc, populationAsc, populationDesc }

class CountryController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<CountryModel> allCountries = <CountryModel>[].obs;
  final RxList<CountryModel> filteredCountries = <CountryModel>[].obs;
  final RxList<String> favoriteCodes = <String>[].obs;
  final RxList<CountryModel> comparisonList = <CountryModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedRegion = 'All'.obs;
  final Rx<SortOption> currentSort = SortOption.nameAsc.obs;

  /// The paginated slice shown in the UI.
  final RxList<CountryModel> displayedCountries = <CountryModel>[].obs;
  static const int pageSize = 20;
  int _currentPage = 0;

  Timer? _searchDebounce;

  /// Fields used for the lightweight listing endpoint.
  static const List<String> _listingFields = [
    'name',
    'flags',
    'cca3',
    'cca2',
    'region',
    'population',
    'capital',
  ];

  static const List<String> regions = [
    'All',
    'Africa',
    'Americas',
    'Antarctic',
    'Asia',
    'Europe',
    'Oceania',
  ];

  void _log(String message) {
    developer.log(message);
    // ignore: avoid_print
    print('[CountryController] $message');
  }

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
    fetchCountries();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  void _loadFavorites() {
    favoriteCodes.assignAll(_storageService.getFavorites());
    _log('Loaded ${favoriteCodes.length} favorite codes from storage');
  }

  // ---------------------------------------------------------------------------
  // FETCH ALL COUNTRIES  — lightweight listing
  // Endpoint: GET /v3.1/all?fields=name,flags,cca3,cca2,region,population,capital
  // ---------------------------------------------------------------------------
  Future<void> fetchCountries() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    _log('fetchCountries() — calling /v3.1/all?fields=${_listingFields.join(",")}');

    try {
      // Try cache first
      final String? cached = _storageService.getCachedCountries();
      if (cached != null) {
        _log('Cache HIT — using cached listing data');
        final List<dynamic> data = json.decode(cached) as List<dynamic>;
        final List<CountryModel> countries = data
            .map<CountryModel>((dynamic item) =>
                CountryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        allCountries.assignAll(countries);
        _log('Parsed ${countries.length} countries from cache');
        _applyFilters();
        isLoading.value = false;
        return;
      }

      // Fetch lightweight listing: /v3.1/all?fields=name,flags,cca3,cca2,region,population,capital
      _log('Cache MISS — fetching from API');
      final List<Map<String, dynamic>> data =
          await _apiService.fetchAllWithFields(_listingFields);
      _log('API returned ${data.length} countries (listing fields only)');

      final List<CountryModel> countries = data
          .map<CountryModel>(
              (Map<String, dynamic> item) => CountryModel.fromJson(item))
          .toList();
      allCountries.assignAll(countries);
      _log('Parsed ${countries.length} countries for listing');

      // Cache the listing response
      await _storageService.cacheCountries(json.encode(data));
      _log('Cached listing data to storage');

      _applyFilters();
    } catch (e) {
      _log('ERROR in fetchCountries: $e');
      hasError.value = true;
      errorMessage.value =
          'Failed to load countries. Please check your internet connection.';
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // FETCH FULL DETAIL  — on-demand for detail screen
  // Endpoint: GET /v3.1/name/{name}?fullText=true
  // ---------------------------------------------------------------------------
  Future<CountryModel?> fetchCountryDetail(CountryModel country) async {
    isLoadingDetail.value = true;
    _log('fetchCountryDetail("${country.name}") — calling /v3.1/name/${country.name}?fullText=true');
    try {
      final List<Map<String, dynamic>> data =
          await _apiService.searchByFullName(country.name);
      if (data.isEmpty) {
        _log('No detail data returned for "${country.name}"');
        isLoadingDetail.value = false;
        return country;
      }
      _log('Detail API returned ${data.length} result(s) for "${country.name}"');

      final CountryModel fullCountry = CountryModel.fromJson(data.first);

      // Replace the lightweight entry in allCountries with full data
      final int index = allCountries
          .indexWhere((CountryModel c) => c.cca3 == fullCountry.cca3);
      if (index != -1) {
        allCountries[index] = fullCountry;
        _log('Replaced listing entry at index $index with full detail for "${fullCountry.name}"');
      } else {
        allCountries.add(fullCountry);
        _log('Added full detail for "${fullCountry.name}" to allCountries');
      }

      isLoadingDetail.value = false;
      return fullCountry;
    } catch (e) {
      _log('ERROR in fetchCountryDetail: $e');
      isLoadingDetail.value = false;
      return country;
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH BY NAME
  // Endpoint: GET /v3.1/name/{query}
  // ---------------------------------------------------------------------------
  void updateSearch(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _log('updateSearch("$query")');

    if (query.trim().isEmpty) {
      isSearching.value = false;
      _log('Search cleared — showing all countries');
      _applyFilters();
      return;
    }

    // Debounce 400ms then call the API /name/{name} endpoint
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _performApiSearch(query.trim());
    });
  }

  Future<void> _performApiSearch(String query) async {
    isSearching.value = true;
    _log('_performApiSearch("$query") — calling /v3.1/name/$query');
    try {
      final List<Map<String, dynamic>> data =
          await _apiService.searchByName(query);
      _log('Search API returned ${data.length} results for "$query"');

      final List<CountryModel> results = data
          .map<CountryModel>(
              (Map<String, dynamic> item) => CountryModel.fromJson(item))
          .toList();

      // Merge search results (full data) into allCountries
      for (final CountryModel c in results) {
        final int existingIndex =
            allCountries.indexWhere((CountryModel existing) => existing.cca3 == c.cca3);
        if (existingIndex != -1) {
          // Replace lightweight with full data from search
          allCountries[existingIndex] = c;
        } else {
          allCountries.add(c);
        }
      }
      _log('Merged ${results.length} full-data results into allCountries');

      // Apply region filter + sort on the API search results
      List<CountryModel> filtered = List<CountryModel>.from(results);
      if (selectedRegion.value != 'All') {
        filtered = filtered
            .where((CountryModel c) =>
                c.region.toLowerCase() ==
                selectedRegion.value.toLowerCase())
            .toList();
      }
      _sortList(filtered);
      filteredCountries.assignAll(filtered);
      _resetPagination();
      _log('Displayed ${filtered.length} results after region filter');
    } catch (e) {
      _log('ERROR in _performApiSearch: $e — falling back to local filter');
      _applyFilters();
    } finally {
      isSearching.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // REGION FILTER
  // Endpoint: GET /v3.1/region/{region}
  // ---------------------------------------------------------------------------
  void updateRegion(String region) {
    selectedRegion.value = region;
    _log('updateRegion("$region")');
    if (searchQuery.value.trim().isNotEmpty) {
      _performApiSearch(searchQuery.value.trim());
    } else if (region != 'All') {
      _fetchByRegion(region);
    } else {
      _applyFilters();
    }
  }

  Future<void> _fetchByRegion(String region) async {
    isLoading.value = true;
    _log('_fetchByRegion("$region") — calling /v3.1/region/$region');
    try {
      final List<Map<String, dynamic>> data =
          await _apiService.fetchByRegion(region);
      _log('Region API returned ${data.length} countries for "$region"');

      final List<CountryModel> results = data
          .map<CountryModel>(
              (Map<String, dynamic> item) => CountryModel.fromJson(item))
          .toList();

      // Merge full region data into allCountries
      for (final CountryModel c in results) {
        final int existingIndex =
            allCountries.indexWhere((CountryModel existing) => existing.cca3 == c.cca3);
        if (existingIndex != -1) {
          allCountries[existingIndex] = c;
        } else {
          allCountries.add(c);
        }
      }
      _log('Merged ${results.length} full-data results for region "$region"');

      _sortList(results);
      filteredCountries.assignAll(results);
      _resetPagination();
      _log('Displayed ${results.length} countries for region "$region"');
    } catch (e) {
      _log('ERROR in _fetchByRegion: $e — falling back to local filter');
      _applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // SORT
  // ---------------------------------------------------------------------------
  void updateSort(SortOption sort) {
    currentSort.value = sort;
    _log('updateSort(${sort.name})');
    if (searchQuery.value.trim().isNotEmpty) {
      _sortList(filteredCountries);
      filteredCountries.refresh();
      _resetPagination();
    } else {
      _applyFilters();
    }
  }

  // ---------------------------------------------------------------------------
  // LOCAL FILTERS (applied on cached/in-memory data)
  // ---------------------------------------------------------------------------
  void _applyFilters() {
    _log('_applyFilters() — region: ${selectedRegion.value}, query: "${searchQuery.value}"');
    List<CountryModel> result = List<CountryModel>.from(allCountries);

    if (selectedRegion.value != 'All') {
      result = result
          .where((CountryModel c) =>
              c.region.toLowerCase() == selectedRegion.value.toLowerCase())
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final String query = searchQuery.value.toLowerCase();
      result = result
          .where((CountryModel c) => c.name.toLowerCase().contains(query))
          .toList();
    }

    _sortList(result);
    filteredCountries.assignAll(result);
    _resetPagination();
    _log('_applyFilters() — showing ${result.length} countries');
  }

  void _sortList(List<CountryModel> list) {
    switch (currentSort.value) {
      case SortOption.nameAsc:
        list.sort((CountryModel a, CountryModel b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        list.sort((CountryModel a, CountryModel b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.populationAsc:
        list.sort((CountryModel a, CountryModel b) =>
            a.population.compareTo(b.population));
        break;
      case SortOption.populationDesc:
        list.sort((CountryModel a, CountryModel b) =>
            b.population.compareTo(a.population));
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // PAGINATION
  // ---------------------------------------------------------------------------
  void _resetPagination() {
    _currentPage = 0;
    final int end = pageSize.clamp(0, filteredCountries.length);
    displayedCountries.assignAll(filteredCountries.sublist(0, end));
    _currentPage = 1;
    _log('_resetPagination() — showing $end of ${filteredCountries.length}');
  }

  void loadNextPage() {
    if (isLoadingMore.value) return;
    final int totalLoaded = _currentPage * pageSize;
    if (totalLoaded >= filteredCountries.length) return;

    isLoadingMore.value = true;
    final int end =
        (totalLoaded + pageSize).clamp(0, filteredCountries.length);
    displayedCountries.addAll(filteredCountries.sublist(totalLoaded, end));
    _currentPage++;
    isLoadingMore.value = false;
    _log('loadNextPage() — now showing ${displayedCountries.length} of ${filteredCountries.length}');
  }

  bool get hasMorePages =>
      _currentPage * pageSize < filteredCountries.length;

  // ---------------------------------------------------------------------------
  // HELPERS — resolve border codes to names
  // ---------------------------------------------------------------------------
  String borderCodeToName(String cca3Code) {
    final int index = allCountries
        .indexWhere((CountryModel c) => c.cca3 == cca3Code);
    return index != -1 ? allCountries[index].name : cca3Code;
  }

  CountryModel? findByCode(String cca3Code) {
    final int index = allCountries
        .indexWhere((CountryModel c) => c.cca3 == cca3Code);
    return index != -1 ? allCountries[index] : null;
  }

  // ---------------------------------------------------------------------------
  // FAVORITES
  // ---------------------------------------------------------------------------
  bool isFavorite(String cca3) => favoriteCodes.contains(cca3);

  void toggleFavorite(String cca3) {
    if (favoriteCodes.contains(cca3)) {
      favoriteCodes.remove(cca3);
      _log('Removed $cca3 from favorites');
    } else {
      favoriteCodes.add(cca3);
      _log('Added $cca3 to favorites');
    }
    _storageService.saveFavorites(favoriteCodes.toList());
    _log('Favorites count: ${favoriteCodes.length}');
  }

  List<CountryModel> get favoriteCountries => allCountries
      .where((CountryModel c) => favoriteCodes.contains(c.cca3))
      .toList();

  // ---------------------------------------------------------------------------
  // COMPARISON
  // ---------------------------------------------------------------------------
  void toggleComparison(CountryModel country) {
    if (comparisonList.contains(country)) {
      comparisonList.remove(country);
      _log('Removed ${country.name} from comparison');
    } else if (comparisonList.length < 2) {
      comparisonList.add(country);
      _log('Added ${country.name} to comparison (${comparisonList.length}/2)');
    } else {
      _log('Comparison limit reached — cannot add ${country.name}');
      Get.snackbar(
        'Limit Reached',
        'You can only compare two countries at a time.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool isInComparison(String cca3) =>
      comparisonList.any((CountryModel c) => c.cca3 == cca3);

  void clearComparison() => comparisonList.clear();
}
