import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/agent_chat_response.dart';
import '../../../../core/models/agent_session.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/user_friendly_error.dart';
import '../../../feedback/data/repositories/feedback_repository.dart';
import '../../data/repositories/agent_repository.dart';

/// A single chat bubble rendered in the conversation.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.sources = const <AgentSource>[],
    this.isError = false,
    this.isStreaming = false,
    this.rating,
    this.isSubmittingFeedback = false,
  });

  /// "user" | "assistant"
  final String role;
  final String content;
  final List<AgentSource> sources;
  final bool isError;

  /// True while an assistant message is still receiving streamed tokens.
  final bool isStreaming;

  /// Submitted/optimistic answer rating: `1` (👍), `-1` (👎), or `null`.
  final int? rating;
  final bool isSubmittingFeedback;

  bool get isUser => role == 'user';

  static const Object _unset = Object();

  ChatMessage copyWith({
    String? role,
    String? content,
    List<AgentSource>? sources,
    bool? isError,
    bool? isStreaming,
    Object? rating = _unset,
    bool? isSubmittingFeedback,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      sources: sources ?? this.sources,
      isError: isError ?? this.isError,
      isStreaming: isStreaming ?? this.isStreaming,
      rating: identical(rating, _unset) ? this.rating : rating as int?,
      isSubmittingFeedback: isSubmittingFeedback ?? this.isSubmittingFeedback,
    );
  }

  factory ChatMessage.fromAgentMessage(AgentMessage message) {
    return ChatMessage(
      role: message.role,
      content: message.content,
      sources: message.sources,
    );
  }
}

class AgentState {
  const AgentState({
    required this.currentProjectId,
    this.sessionId,
    this.messages = const <ChatMessage>[],
    this.input = '',
    this.isSending = false,
    this.errorMessage,
    this.sessions = const <AgentSessionSummary>[],
    this.isLoadingSessions = false,
    this.sessionsError,
  });

  factory AgentState.initial(int projectId) {
    return AgentState(currentProjectId: projectId);
  }

  final int currentProjectId;

  /// Active conversation id; null means a fresh conversation.
  final int? sessionId;
  final List<ChatMessage> messages;
  final String input;
  final bool isSending;
  final String? errorMessage;
  final List<AgentSessionSummary> sessions;
  final bool isLoadingSessions;
  final String? sessionsError;

  bool get canSend => input.trim().isNotEmpty && !isSending;
  bool get hasMessages => messages.isNotEmpty;

  static const Object _unset = Object();

  AgentState copyWith({
    Object? sessionId = _unset,
    List<ChatMessage>? messages,
    String? input,
    bool? isSending,
    Object? errorMessage = _unset,
    List<AgentSessionSummary>? sessions,
    bool? isLoadingSessions,
    Object? sessionsError = _unset,
  }) {
    return AgentState(
      currentProjectId: currentProjectId,
      sessionId: identical(sessionId, _unset)
          ? this.sessionId
          : sessionId as int?,
      messages: messages ?? this.messages,
      input: input ?? this.input,
      isSending: isSending ?? this.isSending,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      sessions: sessions ?? this.sessions,
      isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
      sessionsError: identical(sessionsError, _unset)
          ? this.sessionsError
          : sessionsError as String?,
    );
  }
}

class AgentNotifier extends AsyncNotifier<AgentState> {
  AgentNotifier(this._projectId);

  final int _projectId;
  late AgentRepository _repository;
  late FeedbackRepository _feedbackRepository;
  CancelToken? _cancelToken;
  bool _disposed = false;

  @override
  AgentState build() {
    _repository = AgentRepository();
    _feedbackRepository = FeedbackRepository();
    ref.onDispose(() {
      _disposed = true;
      _cancelToken?.cancel('disposed');
    });
    return AgentState.initial(_projectId);
  }

  AgentState get _currentState => state.maybeWhen(
        data: (value) => value,
        orElse: () => AgentState.initial(_projectId),
      );

  void _update(AgentState next) {
    // A streamed answer can resolve after the user leaves the page and the
    // notifier is disposed; writing to `state` then throws. Drop late updates.
    if (_disposed) return;
    state = AsyncValue.data(next);
  }

  void updateInput(String value) {
    _update(_currentState.copyWith(input: value, errorMessage: null));
  }

  /// Reset to a brand new conversation (clears the active session id).
  void startNewConversation() {
    _update(_currentState.copyWith(
      sessionId: null,
      messages: const <ChatMessage>[],
      input: '',
      errorMessage: null,
    ));
  }

  /// Send a message and stream the answer token-by-token via SSE.
  Future<void> sendMessage() async {
    final current = _currentState;
    final text = current.input.trim();
    if (text.isEmpty || current.isSending) {
      return;
    }

    // Append the user turn plus an empty assistant placeholder that fills in
    // as `delta` events arrive.
    final seeded = <ChatMessage>[
      ...current.messages,
      ChatMessage(role: 'user', content: text),
      const ChatMessage(role: 'assistant', content: '', isStreaming: true),
    ];
    final assistantIndex = seeded.length - 1;

    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    _update(current.copyWith(
      messages: seeded,
      input: '',
      isSending: true,
      errorMessage: null,
    ));

    final answer = StringBuffer();
    var sources = const <AgentSource>[];
    var sessionId = current.sessionId;
    var finalized = false;

    try {
      final stream = _repository.chatStream(
        projectId: current.currentProjectId,
        message: text,
        sessionId: current.sessionId,
        cancelToken: cancelToken,
      );

      await for (final event in stream) {
        switch (event.event) {
          case 'meta':
            sessionId = _asInt(event.data['session_id']) ?? sessionId;
            sources = _parseSources(event.data['sources']);
            _writeAssistant(assistantIndex,
                content: answer.toString(), sources: sources, streaming: true);
            break;
          case 'delta':
            final chunk = event.data['text'] as String? ?? '';
            if (chunk.isEmpty) break;
            answer.write(chunk);
            _writeAssistant(assistantIndex,
                content: answer.toString(), sources: sources, streaming: true);
            break;
          case 'done':
            // done.answer is authoritative (guards dropped delta chunks).
            final full = event.data['answer'] as String? ?? answer.toString();
            _writeAssistant(assistantIndex,
                content: full, sources: sources, streaming: false);
            finalized = true;
            break;
          case 'error':
            throw _AgentStreamException(
              event.data['detail'] as String? ?? 'stream error',
            );
        }
      }

      // Finalize only if the stream ended without an explicit `done` event,
      // so we don't clobber the authoritative answer.
      if (!finalized) {
        _writeAssistant(assistantIndex,
            content: answer.toString(), sources: sources, streaming: false);
      }
      _update(_currentState.copyWith(sessionId: sessionId, isSending: false));
    } catch (error) {
      _handleStreamError(error, assistantIndex);
    } finally {
      if (identical(_cancelToken, cancelToken)) {
        _cancelToken = null;
      }
    }
  }

  /// Abort an in-progress streamed answer.
  void cancelStreaming() {
    _cancelToken?.cancel('cancelled by user');
  }

  /// Submit a 👍/👎 rating for the assistant message at [index]. The question
  /// is the nearest preceding user turn; the active [sessionId] is included so
  /// the backend can tie feedback to the conversation. Optimistic: the rating
  /// shows immediately and reverts if the request fails.
  Future<void> submitFeedback(int index, int rating, {String? comment}) async {
    final current = _currentState;
    if (index < 0 || index >= current.messages.length) {
      return;
    }
    final message = current.messages[index];
    if (message.isUser ||
        message.isError ||
        message.isStreaming ||
        message.isSubmittingFeedback ||
        message.content.trim().isEmpty) {
      return;
    }

    // Walk back to the user turn that prompted this answer.
    var question = '';
    for (var i = index - 1; i >= 0; i--) {
      if (current.messages[i].isUser) {
        question = current.messages[i].content;
        break;
      }
    }
    if (question.trim().isEmpty) {
      return;
    }

    final previousRating = message.rating;
    _setMessageAt(
      index,
      (m) => m.copyWith(rating: rating, isSubmittingFeedback: true),
    );

    try {
      await _feedbackRepository.submitFeedback(
        projectId: current.currentProjectId,
        question: question,
        answer: message.content,
        rating: rating,
        sessionId: current.sessionId,
        comment: comment,
      );
      _setMessageAt(index, (m) => m.copyWith(isSubmittingFeedback: false));
    } catch (error) {
      _setMessageAt(
        index,
        (m) => m.copyWith(
          rating: previousRating,
          isSubmittingFeedback: false,
        ),
      );
      _update(_currentState.copyWith(
        errorMessage: UserFriendlyError.message(
          error,
          fallback: 'Couldn’t submit feedback. Please try again.',
        ),
      ));
    }
  }

  /// Replace the message at [index] via [update], guarding the bounds since a
  /// session switch or delete can shift the list between async gaps.
  void _setMessageAt(int index, ChatMessage Function(ChatMessage) update) {
    final messages = <ChatMessage>[..._currentState.messages];
    if (index < 0 || index >= messages.length) {
      return;
    }
    messages[index] = update(messages[index]);
    _update(_currentState.copyWith(messages: messages));
  }

  void _handleStreamError(Object error, int assistantIndex) {
    final cancelled = error is ApiException && error.code == 'CANCELLED';
    final messages = <ChatMessage>[..._currentState.messages];

    if (assistantIndex >= 0 && assistantIndex < messages.length) {
      final partial = messages[assistantIndex];
      if (partial.content.isEmpty) {
        // Nothing streamed yet — drop the empty placeholder.
        messages.removeAt(assistantIndex);
      } else {
        // Keep the partial answer, just stop the streaming state.
        messages[assistantIndex] = ChatMessage(
          role: 'assistant',
          content: partial.content,
          sources: partial.sources,
        );
      }
    }

    _update(_currentState.copyWith(
      messages: messages,
      isSending: false,
      errorMessage: cancelled
          ? null
          : UserFriendlyError.message(
              error,
              fallback: 'Couldn’t reach the agent. Please try again.',
            ),
    ));
  }

  void _writeAssistant(
    int index, {
    required String content,
    required List<AgentSource> sources,
    required bool streaming,
  }) {
    final messages = <ChatMessage>[..._currentState.messages];
    if (index < 0 || index >= messages.length) {
      return;
    }
    messages[index] = ChatMessage(
      role: 'assistant',
      content: content,
      sources: sources,
      isStreaming: streaming,
    );
    _update(_currentState.copyWith(messages: messages));
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<AgentSource> _parseSources(dynamic raw) {
    if (raw is! List) {
      return const <AgentSource>[];
    }
    return raw
        .whereType<Map>()
        .map(
          (item) => AgentSource.fromJson(
            item.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<void> loadSessions() async {
    _update(_currentState.copyWith(
      isLoadingSessions: true,
      sessionsError: null,
    ));

    try {
      final sessions =
          await _repository.listSessions(_currentState.currentProjectId);
      _update(_currentState.copyWith(
        sessions: sessions,
        isLoadingSessions: false,
      ));
    } catch (error) {
      _update(_currentState.copyWith(
        isLoadingSessions: false,
        sessionsError: UserFriendlyError.message(
          error,
          fallback: 'Couldn’t load conversations.',
        ),
      ));
    }
  }

  /// Load a stored session and make it the active conversation.
  Future<void> openSession(int sessionId) async {
    final current = _currentState;
    _update(current.copyWith(isSending: true, errorMessage: null));

    try {
      final session = await _repository.getSession(
        current.currentProjectId,
        sessionId,
      );
      _update(_currentState.copyWith(
        sessionId: session.sessionId,
        messages: session.messages
            .map(ChatMessage.fromAgentMessage)
            .toList(growable: false),
        isSending: false,
      ));
    } catch (error) {
      _update(_currentState.copyWith(
        isSending: false,
        errorMessage: UserFriendlyError.message(
          error,
          fallback: 'Couldn’t open that conversation.',
        ),
      ));
    }
  }

  Future<void> deleteSession(int sessionId) async {
    final current = _currentState;
    try {
      await _repository.deleteSession(current.currentProjectId, sessionId);
    } catch (error) {
      _update(_currentState.copyWith(
        sessionsError: UserFriendlyError.message(
          error,
          fallback: 'Couldn’t delete that conversation.',
        ),
      ));
      return;
    }

    final updated = _currentState;
    final remaining = updated.sessions
        .where((session) => session.sessionId != sessionId)
        .toList(growable: false);

    // If the deleted session was the active one, drop back to a fresh chat.
    if (updated.sessionId == sessionId) {
      _update(updated.copyWith(
        sessions: remaining,
        sessionId: null,
        messages: const <ChatMessage>[],
      ));
    } else {
      _update(updated.copyWith(sessions: remaining));
    }
  }
}

/// Raised when the backend emits an SSE `error` event mid-stream.
class _AgentStreamException implements Exception {
  const _AgentStreamException(this.detail);

  final String detail;

  @override
  String toString() => detail;
}
