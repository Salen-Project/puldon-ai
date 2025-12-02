import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/chat_model.dart';

/// Repository for chat-related API calls
class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Send a chat message
  /// Chat with AI can take 15-90 seconds, especially when using tools
  /// (e.g., creating goals, adding expenses, etc.)
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.chat,
      data: request.toJson(),
      options: Options(
        receiveTimeout: const Duration(seconds: 90), // AI + tools need time
        sendTimeout: const Duration(seconds: 90),
      ),
    );
    return ChatResponse.fromJson(response);
  }

  /// Get chat history for a thread
  Future<ChatHistoryModel> getChatHistory(
    String threadId, {
    int limit = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.chatHistory(threadId),
      queryParameters: {'limit': limit},
      useCache: true,
    );
    return ChatHistoryModel.fromJson(response);
  }

  /// Convert speech to text
  Future<SpeechToTextResponse> speechToText(File audioFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.path.split('/').last,
      ),
    });

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.speechToText,
      data: formData,
      options: Options(
        receiveTimeout: const Duration(seconds: 30), // Audio processing takes time
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    return SpeechToTextResponse.fromJson(response);
  }

  /// Clear chat history
  Future<ClearChatResponse> clearChat({String? threadId}) async {
    final queryParameters = <String, dynamic>{};
    if (threadId != null) {
      queryParameters['thread_id'] = threadId;
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.clearChat,
      queryParameters: queryParameters,
    );
    return ClearChatResponse.fromJson(response);
  }
}

/// Provider for ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRepository(apiClient: apiClient);
});

/// Provider to get chat history
final chatHistoryProvider = FutureProvider.family<ChatHistoryModel, ChatHistoryParams>(
  (ref, params) async {
    final repository = ref.watch(chatRepositoryProvider);
    return await repository.getChatHistory(
      params.threadId,
      limit: params.limit,
    );
  },
);

/// Parameters for chat history
class ChatHistoryParams {
  final String threadId;
  final int limit;

  ChatHistoryParams({
    required this.threadId,
    this.limit = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHistoryParams &&
          runtimeType == other.runtimeType &&
          threadId == other.threadId &&
          limit == other.limit;

  @override
  int get hashCode => threadId.hashCode ^ limit.hashCode;
}
