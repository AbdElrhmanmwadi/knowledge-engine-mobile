import 'api_response_base.dart';

class SearchResultItem {
  const SearchResultItem({
    required this.text,
    required this.score,
    required this.metaData,
    this.id,
  });

  final String text;
  final double score;
  final JsonMap metaData;
  final String? id;

  factory SearchResultItem.fromJson(JsonMap json) {
    return SearchResultItem(
      text: ApiResponseBase.readRequiredString(json, 'text'),
      score: ApiResponseBase.readRequiredDouble(json, 'score'),
      metaData:
          ApiResponseBase.readOptionalJsonMap(json, 'meta_data') ??
          <String, dynamic>{},
      id: ApiResponseBase.readOptionalString(json, 'id'),
    );
  }

  SearchResultItem copyWith({
    String? text,
    double? score,
    JsonMap? metaData,
    String? id,
  }) {
    return SearchResultItem(
      text: text ?? this.text,
      score: score ?? this.score,
      metaData: metaData ?? this.metaData,
      id: id ?? this.id,
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      'text': text,
      'score': score,
      'meta_data': metaData,
      if (id != null) 'id': id,
    };
  }
}
