import 'api_response_base.dart';

class RagAnswerResponse extends ApiResponseBase {
  const RagAnswerResponse({
    required super.signal,
    required this.answer,
    this.fullPrompt,
    this.chatHistory,
    this.retrievedChunks,
  });

  final String answer;
  final String? fullPrompt;
  final List<JsonMap>? chatHistory;
  final int? retrievedChunks;

  factory RagAnswerResponse.fromJson(JsonMap json) {
    return RagAnswerResponse(
      signal: ApiResponseBase.readRequiredString(json, 'signal'),
      answer: ApiResponseBase.readRequiredString(json, 'answer'),
      fullPrompt: ApiResponseBase.readOptionalString(json, 'full_prompt'),
      chatHistory: ApiResponseBase.readOptionalJsonMapList(
        json,
        'chat_history',
      ),
      retrievedChunks: ApiResponseBase.readOptionalInt(
        json,
        'retrieved_chunks',
      ),
    );
  }

  @override
  RagAnswerResponse copyWith({
    String? signal,
    String? answer,
    String? fullPrompt,
    List<JsonMap>? chatHistory,
    int? retrievedChunks,
  }) {
    return RagAnswerResponse(
      signal: signal ?? this.signal,
      answer: answer ?? this.answer,
      fullPrompt: fullPrompt ?? this.fullPrompt,
      chatHistory: chatHistory ?? this.chatHistory,
      retrievedChunks: retrievedChunks ?? this.retrievedChunks,
    );
  }

  @override
  JsonMap toJson() {
    return <String, dynamic>{
      'signal': signal,
      'answer': answer,
      if (fullPrompt != null) 'full_prompt': fullPrompt,
      if (chatHistory != null) 'chat_history': chatHistory,
      if (retrievedChunks != null) 'retrieved_chunks': retrievedChunks,
    };
  }
}
