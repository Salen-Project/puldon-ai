// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) => ChatRequest(
  threadId: json['thread_id'] as String?,
  message: json['message'] as String,
);

Map<String, dynamic> _$ChatRequestToJson(ChatRequest instance) =>
    <String, dynamic>{
      'thread_id': instance.threadId,
      'message': instance.message,
    };

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
  reply: json['reply'] as String,
  threadId: json['thread_id'] as String,
  toolCalls: (json['tool_calls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'reply': instance.reply,
      'thread_id': instance.threadId,
      'tool_calls': instance.toolCalls,
    };

ChatHistoryModel _$ChatHistoryModelFromJson(Map<String, dynamic> json) =>
    ChatHistoryModel(
      threadId: json['thread_id'] as String,
      messageCount: (json['message_count'] as num).toInt(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatHistoryModelToJson(ChatHistoryModel instance) =>
    <String, dynamic>{
      'thread_id': instance.threadId,
      'message_count': instance.messageCount,
      'messages': instance.messages,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  role: json['role'] as String,
  content: json['content'] as String,
  timestamp: json['timestamp'] as String,
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp,
    };

SpeechToTextResponse _$SpeechToTextResponseFromJson(
  Map<String, dynamic> json,
) => SpeechToTextResponse(transcript: json['transcript'] as String);

Map<String, dynamic> _$SpeechToTextResponseToJson(
  SpeechToTextResponse instance,
) => <String, dynamic>{'transcript': instance.transcript};

ClearChatResponse _$ClearChatResponseFromJson(Map<String, dynamic> json) =>
    ClearChatResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      clearedThreads: (json['cleared_threads'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClearChatResponseToJson(ClearChatResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'cleared_threads': instance.clearedThreads,
    };
