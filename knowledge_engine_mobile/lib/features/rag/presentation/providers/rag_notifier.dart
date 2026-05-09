import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/models/rag_answer_response.dart';
import '../../../../core/models/search_response.dart';
import '../../data/repositories/answer_repository.dart';
import '../../data/repositories/search_repository.dart';

class RagState {
  const RagState({
    required this.currentProjectId,
    this.searchQuery = '',
    this.searchLimit = AppConfig.defaultSearchLimit,
    this.searchLimitError,
    this.isSearching = false,
    this.searchResponse,
    this.searchErrorMessage,
    this.expandedSearchIndex,
    this.question = '',
    this.answerLimit = AppConfig.defaultRagLimit,
    this.answerLimitError,
    this.isAnswering = false,
    this.answerResponse,
    this.answerErrorMessage,
    this.isDebugVisible = false,
  });

  factory RagState.initial(int projectId) {
    return RagState(currentProjectId: projectId);
  }

  final int currentProjectId;
  final String searchQuery;
  final int searchLimit;
  final String? searchLimitError;
  final bool isSearching;
  final SearchResponse? searchResponse;
  final String? searchErrorMessage;
  final int? expandedSearchIndex;
  final String question;
  final int answerLimit;
  final String? answerLimitError;
  final bool isAnswering;
  final RagAnswerResponse? answerResponse;
  final String? answerErrorMessage;
  final bool isDebugVisible;

  bool get isBusy => isSearching || isAnswering;
  bool get canSearch =>
      searchQuery.trim().isNotEmpty && searchLimitError == null && !isBusy;
  bool get canAsk =>
      question.trim().isNotEmpty && answerLimitError == null && !isBusy;

  bool get hasDebugData {
    return (answerResponse?.fullPrompt?.trim().isNotEmpty ?? false) ||
        ((answerResponse?.chatHistory?.isNotEmpty ?? false));
  }

  String? get activeLoadingMessage {
    if (isSearching) {
      return 'Searching indexed knowledge...';
    }
    if (isAnswering) {
      return 'Generating answer...';
    }
    return null;
  }

  static const Object _unset = Object();

  RagState copyWith({
    String? searchQuery,
    int? searchLimit,
    Object? searchLimitError = _unset,
    bool? isSearching,
    Object? searchResponse = _unset,
    Object? searchErrorMessage = _unset,
    Object? expandedSearchIndex = _unset,
    String? question,
    int? answerLimit,
    Object? answerLimitError = _unset,
    bool? isAnswering,
    Object? answerResponse = _unset,
    Object? answerErrorMessage = _unset,
    bool? isDebugVisible,
  }) {
    return RagState(
      currentProjectId: currentProjectId,
      searchQuery: searchQuery ?? this.searchQuery,
      searchLimit: searchLimit ?? this.searchLimit,
      searchLimitError: identical(searchLimitError, _unset)
          ? this.searchLimitError
          : searchLimitError as String?,
      isSearching: isSearching ?? this.isSearching,
      searchResponse: identical(searchResponse, _unset)
          ? this.searchResponse
          : searchResponse as SearchResponse?,
      searchErrorMessage: identical(searchErrorMessage, _unset)
          ? this.searchErrorMessage
          : searchErrorMessage as String?,
      expandedSearchIndex: identical(expandedSearchIndex, _unset)
          ? this.expandedSearchIndex
          : expandedSearchIndex as int?,
      question: question ?? this.question,
      answerLimit: answerLimit ?? this.answerLimit,
      answerLimitError: identical(answerLimitError, _unset)
          ? this.answerLimitError
          : answerLimitError as String?,
      isAnswering: isAnswering ?? this.isAnswering,
      answerResponse: identical(answerResponse, _unset)
          ? this.answerResponse
          : answerResponse as RagAnswerResponse?,
      answerErrorMessage: identical(answerErrorMessage, _unset)
          ? this.answerErrorMessage
          : answerErrorMessage as String?,
      isDebugVisible: isDebugVisible ?? this.isDebugVisible,
    );
  }
}

class RagNotifier extends AsyncNotifier<RagState> {
  RagNotifier(this._projectId);

  final int _projectId;
  late SearchRepository _searchRepository;
  late AnswerRepository _answerRepository;

  @override
  RagState build() {
    _searchRepository = SearchRepository();
    _answerRepository = AnswerRepository();
    return RagState.initial(_projectId);
  }

  RagState get _currentState =>
      state.maybeWhen(data: (value) => value, orElse: () => RagState.initial(_projectId));

  void _updateState(RagState nextState) {
    state = AsyncValue.data(nextState);
  }

  void updateSearchQuery(String value) {
    _updateState(_currentState.copyWith(
      searchQuery: value,
      searchErrorMessage: null,
    ));
  }

  void updateQuestion(String value) {
    _updateState(_currentState.copyWith(
      question: value,
      answerErrorMessage: null,
    ));
  }

  void updateSearchLimit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _updateState(_currentState.copyWith(
        searchLimitError:
            'Search limit must be between ${ValidationConstants.minSearchLimit} and ${ValidationConstants.maxSearchLimit}.',
      ));
      return;
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null ||
        parsed < ValidationConstants.minSearchLimit ||
        parsed > ValidationConstants.maxSearchLimit) {
      _updateState(_currentState.copyWith(
        searchLimitError:
            'Search limit must be between ${ValidationConstants.minSearchLimit} and ${ValidationConstants.maxSearchLimit}.',
      ));
      return;
    }

    _updateState(_currentState.copyWith(
      searchLimit: parsed,
      searchLimitError: null,
    ));
  }

  void updateAnswerLimit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _updateState(_currentState.copyWith(
        answerLimitError:
            'Answer limit must be between ${ValidationConstants.minRagLimit} and ${ValidationConstants.maxRagLimit}.',
      ));
      return;
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null ||
        parsed < ValidationConstants.minRagLimit ||
        parsed > ValidationConstants.maxRagLimit) {
      _updateState(_currentState.copyWith(
        answerLimitError:
            'Answer limit must be between ${ValidationConstants.minRagLimit} and ${ValidationConstants.maxRagLimit}.',
      ));
      return;
    }

    _updateState(_currentState.copyWith(
      answerLimit: parsed,
      answerLimitError: null,
    ));
  }

  void toggleSearchResultExpansion(int index) {
    final currentState = _currentState;
    _updateState(currentState.copyWith(
      expandedSearchIndex:
          currentState.expandedSearchIndex == index ? null : index,
    ));
  }

  void toggleDebugVisibility() {
    _updateState(
      _currentState.copyWith(isDebugVisible: !_currentState.isDebugVisible),
    );
  }

  Future<void> performSearch() async {
    final currentState = _currentState;
    final query = currentState.searchQuery.trim();

    if (query.isEmpty) {
      _updateState(currentState.copyWith(
        searchErrorMessage: 'Enter a search query first.',
      ));
      return;
    }

    if (currentState.searchLimitError != null) {
      return;
    }

    if (!_isSearchLimitValid(currentState.searchLimit)) {
      _updateState(currentState.copyWith(
        searchLimitError:
            'Search limit must be between ${ValidationConstants.minSearchLimit} and ${ValidationConstants.maxSearchLimit}.',
      ));
      return;
    }

    _updateState(currentState.copyWith(
      isSearching: true,
      searchErrorMessage: null,
      searchLimitError: null,
    ));

    try {
      final response = await _searchRepository.search(
        projectId: currentState.currentProjectId,
        text: query,
        limit: currentState.searchLimit,
      );

      _updateState(_currentState.copyWith(
        isSearching: false,
        searchResponse: response,
        searchErrorMessage: null,
        expandedSearchIndex: null,
      ));
    } catch (error) {
      _updateState(_currentState.copyWith(
        isSearching: false,
        searchErrorMessage: error.toString(),
      ));
    }
  }

  Future<void> askQuestion() async {
    final currentState = _currentState;
    final question = currentState.question.trim();

    if (question.isEmpty) {
      _updateState(currentState.copyWith(
        answerErrorMessage: 'Enter a question first.',
      ));
      return;
    }

    if (currentState.answerLimitError != null) {
      return;
    }

    if (!_isAnswerLimitValid(currentState.answerLimit)) {
      _updateState(currentState.copyWith(
        answerLimitError:
            'Answer limit must be between ${ValidationConstants.minRagLimit} and ${ValidationConstants.maxRagLimit}.',
      ));
      return;
    }

    _updateState(currentState.copyWith(
      isAnswering: true,
      answerErrorMessage: null,
      answerLimitError: null,
    ));

    try {
      final response = await _answerRepository.askQuestion(
        projectId: currentState.currentProjectId,
        text: question,
        limit: currentState.answerLimit,
      );

      _updateState(_currentState.copyWith(
        isAnswering: false,
        answerResponse: response,
        answerErrorMessage: null,
        isDebugVisible: false,
      ));
    } catch (error) {
      _updateState(_currentState.copyWith(
        isAnswering: false,
        answerErrorMessage: error.toString(),
      ));
    }
  }

  bool _isSearchLimitValid(int value) {
    return value >= ValidationConstants.minSearchLimit &&
        value <= ValidationConstants.maxSearchLimit;
  }

  bool _isAnswerLimitValid(int value) {
    return value >= ValidationConstants.minRagLimit &&
        value <= ValidationConstants.maxRagLimit;
  }
}
