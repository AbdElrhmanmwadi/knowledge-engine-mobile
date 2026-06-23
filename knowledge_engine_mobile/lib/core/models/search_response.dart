import 'api_response_base.dart';
import 'search_result_item.dart';

class SearchResponse extends ApiResponseBase {
  const SearchResponse({
    required super.signal,
    required this.searchResults,
    required this.query,
    this.executionTimeMs,
  });

  final List<SearchResultItem> searchResults;
  final String query;
  final int? executionTimeMs;

  factory SearchResponse.fromJson(JsonMap json) {
    return SearchResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      searchResults: _parseSearchResults(json),
      query:
          ApiResponseBase.readOptionalString(json, 'query') ??
          ApiResponseBase.readOptionalString(json, 'text') ??
          '',
      executionTimeMs: ApiResponseBase.readOptionalInt(
        json,
        'execution_time_ms',
      ),
    );
  }

  @override
  SearchResponse copyWith({
    String? signal,
    List<SearchResultItem>? searchResults,
    String? query,
    int? executionTimeMs,
  }) {
    return SearchResponse(
      signal: signal ?? this.signal,
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      executionTimeMs: executionTimeMs ?? this.executionTimeMs,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'search_results': searchResults.map((item) => item.toJson()).toList(),
      'query': query,
      if (executionTimeMs != null) 'execution_time_ms': executionTimeMs,
    };
  }

  static List<SearchResultItem> _parseSearchResults(JsonMap json) {
    final dynamic rawResults = json.containsKey('search_results')
        ? json['search_results']
        : json['search_result'];

    if (rawResults == null) {
      return const <SearchResultItem>[];
    }
    if (rawResults is! List) {
      throw const FormatException(
        'Field "search_results/search_result" must be a list.',
      );
    }

    return rawResults
        .map(
          (dynamic item) => SearchResultItem.fromJson(
            ApiResponseBase.normalizeJsonMap(
              item,
              fieldName: 'search_results/search_result',
            ),
          ),
        )
        .toList(growable: false);
  }
}
