import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatRequest {
  @JsonKey(name: 'thread_id')
  final String? threadId;
  final String message;

  ChatRequest({
    this.threadId,
    required this.message,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}

@JsonSerializable()
class ChatResponse {
  final String reply;
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'tool_calls')
  final List<String>? toolCalls;

  ChatResponse({
    required this.reply,
    required this.threadId,
    this.toolCalls,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}

@JsonSerializable()
class ChatHistoryModel {
  @JsonKey(name: 'thread_id')
  final String threadId;
  @JsonKey(name: 'message_count')
  final int messageCount;
  final List<ChatMessage> messages;

  ChatHistoryModel({
    required this.threadId,
    required this.messageCount,
    required this.messages,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatHistoryModelToJson(this);
}

@JsonSerializable()
class ChatMessage {
  final String role;
  final String content;
  final String timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class SpeechToTextResponse {
  final String transcript;

  SpeechToTextResponse({required this.transcript});

  factory SpeechToTextResponse.fromJson(Map<String, dynamic> json) =>
      _$SpeechToTextResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpeechToTextResponseToJson(this);
}

@JsonSerializable()
class ClearChatResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'cleared_threads')
  final int? clearedThreads;

  ClearChatResponse({
    required this.success,
    required this.message,
    this.clearedThreads,
  });

  factory ClearChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ClearChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ClearChatResponseToJson(this);
}
