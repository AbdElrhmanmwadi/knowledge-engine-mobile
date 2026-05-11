import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/core/models/api_response_base.dart';
import 'package:knowledge_engine_mobile/core/models/index_push_response.dart';
import 'package:knowledge_engine_mobile/core/models/process_response.dart';
import 'package:knowledge_engine_mobile/core/models/rag_answer_response.dart';
import 'package:knowledge_engine_mobile/core/models/search_response.dart';
import 'package:knowledge_engine_mobile/core/models/search_result_item.dart';
import 'package:knowledge_engine_mobile/core/models/translation_job_create_response.dart';
import 'package:knowledge_engine_mobile/core/models/translation_job_status_response.dart';
import 'package:knowledge_engine_mobile/core/models/upload_response.dart';

void main() {
  group('ApiResponseBase', () {
    test('parses the common signal field', () {
      final response = ApiResponseBase.fromJson(<String, dynamic>{
        'signal': 'success',
      });

      expect(response.signal, 'success');
      expect(response.isSuccess, isTrue);
      expect(response.toJson(), <String, dynamic>{'signal': 'success'});
    });
  });

  group('UploadResponse', () {
    test('parses required and optional fields', () {
      final response = UploadResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'file_id': 'file-123',
        'timestamp': '2026-05-01T12:00:00Z',
      });

      expect(response.signal, 'success');
      expect(response.fileId, 'file-123');
      expect(response.timestamp, DateTime.parse('2026-05-01T12:00:00Z'));
      expect(response.toJson()['file_id'], 'file-123');
    });
  });

  group('ProcessResponse', () {
    test('parses chunk counts and settings', () {
      final response = ProcessResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'file_id': 'file-123',
        'inserted_chunks': 14,
        'processed_files': '1',
        'chunk_size': 512,
        'overlap_size': 50,
      });

      expect(response.fileId, 'file-123');
      expect(response.insertedChunks, 14);
      expect(response.processedFiles, 1);
      expect(response.chunkSize, 512);
      expect(response.overlapSize, 50);
    });

    test('accepts processing responses without file id', () {
      final response = ProcessResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'inserted_chunks': 1,
        'processed_files': 1,
      });

      expect(response.fileId, isNull);
      expect(response.insertedChunks, 1);
      expect(response.processedFiles, 1);
      expect(response.toJson().containsKey('file_id'), isFalse);
    });
  });

  group('IndexPushResponse', () {
    test('parses optional collection info', () {
      final response = IndexPushResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'indexed_count': 44,
        'collection_info': <String, dynamic>{'collection_name': 'project-1'},
      });

      expect(response.indexedCount, 44);
      expect(response.collectionInfo?['collection_name'], 'project-1');
    });
  });

  group('SearchResultItem', () {
    test('parses text score and metadata', () {
      final item = SearchResultItem.fromJson(<String, dynamic>{
        'text': 'Chunk text',
        'score': 0.93,
        'meta_data': <String, dynamic>{'page': 2},
        'id': 'chunk-1',
      });

      expect(item.text, 'Chunk text');
      expect(item.score, closeTo(0.93, 0.0001));
      expect(item.metaData['page'], 2);
      expect(item.id, 'chunk-1');
    });
  });

  group('SearchResponse', () {
    test('parses search_results payload', () {
      final response = SearchResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'search_results': <Map<String, dynamic>>[
          <String, dynamic>{
            'text': 'Result A',
            'score': 0.81,
            'meta_data': <String, dynamic>{'source': 'doc-a'},
          },
        ],
        'query': 'What is RAG?',
        'execution_time_ms': 120,
      });

      expect(response.searchResults, hasLength(1));
      expect(response.searchResults.first.text, 'Result A');
      expect(response.query, 'What is RAG?');
      expect(response.executionTimeMs, 120);
    });

    test('parses legacy search_result payload from the SRS wording', () {
      final response = SearchResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'search_result': <Map<String, dynamic>>[
          <String, dynamic>{
            'text': 'Result B',
            'score': '0.72',
            'meta_data': <String, dynamic>{'source': 'doc-b'},
          },
        ],
        'text': 'semantic search',
      });

      expect(response.searchResults, hasLength(1));
      expect(response.searchResults.first.score, closeTo(0.72, 0.0001));
      expect(response.query, 'semantic search');
    });
  });

  group('RagAnswerResponse', () {
    test('parses answer and debug fields', () {
      final response = RagAnswerResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'answer': 'RAG combines retrieval and generation.',
        'full_prompt': 'Prompt body',
        'chat_history': <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': 'Explain RAG'},
        ],
        'retrieved_chunks': 5,
      });

      expect(response.answer, 'RAG combines retrieval and generation.');
      expect(response.fullPrompt, 'Prompt body');
      expect(response.chatHistory, hasLength(1));
      expect(response.chatHistory?.first['role'], 'user');
      expect(response.retrievedChunks, 5);
    });
  });

  group('TranslationJobCreateResponse', () {
    test('parses job creation payload', () {
      final response = TranslationJobCreateResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'job_id': 'job-1',
        'status': 'pending',
        'asset_id': 'asset-99',
        'source_lang': 'en',
        'target_lang': 'ar',
        'created_at': '2026-05-01T12:00:00Z',
      });

      expect(response.jobId, 'job-1');
      expect(response.status, 'pending');
      expect(response.assetId, 'asset-99');
      expect(response.sourceLang, 'en');
      expect(response.targetLang, 'ar');
      expect(response.createdAt, DateTime.parse('2026-05-01T12:00:00Z'));
    });
  });

  group('TranslationJobStatusResponse', () {
    test('parses nested job payload', () {
      final response = TranslationJobStatusResponse.fromJson(<String, dynamic>{
        'signal': 'success',
        'job': <String, dynamic>{
          'job_id': 'job-1',
          'status': 'processing',
          'result_file_id': 'file-456',
          'error_message': null,
          'progress_percentage': '60',
        },
      });

      expect(response.job.jobId, 'job-1');
      expect(response.job.status, 'processing');
      expect(response.job.resultFileId, 'file-456');
      expect(response.job.errorMessage, isNull);
      expect(response.job.progressPercentage, 60);
    });
  });

  group('validation', () {
    test('throws when a required field is missing', () {
      expect(
        () => UploadResponse.fromJson(<String, dynamic>{'signal': 'success'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
