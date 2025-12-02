import 'package:uuid/uuid.dart';

enum MessageSender { user, ai }

class ChatMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isVoice;

  ChatMessage({
    String? id,
    required this.content,
    required this.sender,
    DateTime? timestamp,
    this.isVoice = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  bool get isAI => sender == MessageSender.ai;
  bool get isUser => sender == MessageSender.user;

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isVoice,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isVoice: isVoice ?? this.isVoice,
    );
  }
}
