import 'api_response_base.dart';

class IndexPushResponse extends ApiResponseBase {
  const IndexPushResponse({
    required super.signal,
    this.indexedCount,
    this.collectionInfo,
  });

  final int? indexedCount;
  final JsonMap? collectionInfo;

  factory IndexPushResponse.fromJson(JsonMap json) {
    return IndexPushResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      indexedCount: ApiResponseBase.readOptionalInt(json, 'indexed_count'),
      collectionInfo: ApiResponseBase.readOptionalJsonMap(
        json,
        'collection_info',
      ),
    );
  }

  @override
  IndexPushResponse copyWith({
    String? signal,
    int? indexedCount,
    JsonMap? collectionInfo,
  }) {
    return IndexPushResponse(
      signal: signal ?? this.signal,
      indexedCount: indexedCount ?? this.indexedCount,
      collectionInfo: collectionInfo ?? this.collectionInfo,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      if (indexedCount != null) 'indexed_count': indexedCount,
      if (collectionInfo != null) 'collection_info': collectionInfo,
    };
  }
}
