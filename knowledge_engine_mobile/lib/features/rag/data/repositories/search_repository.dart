import '../../../../core/config/app_config.dart';
import '../../../../core/models/search_response.dart';
import '../../../../core/network/api_service.dart';

/// Lightweight in-memory record for recent search requests.
class SearchRecord {
  const SearchRecord({
    required this.projectId,
    required this.query,
    required this.limit,
    required this.response,
  });

  final int projectId;
  final String query;
  final int limit;
  final SearchResponse response;
}

/// Repository wrapper for semantic search operations.
class SearchRepository {
  SearchRepository({
    ApiService? apiService,
    this.maxCacheEntries = 10,
  }) : _apiService = apiService ?? DioApiService();

  final ApiService _apiService;
  final int maxCacheEntries;
  final List<SearchRecord> _recentSearches = <SearchRecord>[];

  List<SearchRecord> get recentSearches =>
      List<SearchRecord>.unmodifiable(_recentSearches);

  Future<SearchResponse> search({
    required int projectId,
    required String text,
    int limit = AppConfig.defaultSearchLimit,
  }) async {
    final response = await _apiService.search(
      projectId: projectId,
      text: text,
      limit: limit,
    );

    _rememberSearch(
      SearchRecord(
        projectId: projectId,
        query: text,
        limit: limit,
        response: response,
      ),
    );

    return response;
  }

  void clearCache() {
    _recentSearches.clear();
  }

  void _rememberSearch(SearchRecord record) {
    _recentSearches.insert(0, record);
    if (_recentSearches.length > maxCacheEntries) {
      _recentSearches.removeRange(maxCacheEntries, _recentSearches.length);
    }
  }
}
