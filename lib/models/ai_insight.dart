import 'package:uuid/uuid.dart';

enum InsightType { warning, suggestion, achievement, info }

enum InsightPriority { high, medium, low }

class AIInsight {
  final String id;
  final String message;
  final InsightType type;
  final InsightPriority priority;
  final DateTime timestamp;
  final String? actionText;
  final Function()? onAction;

  AIInsight({
    String? id,
    required this.message,
    required this.type,
    required this.priority,
    DateTime? timestamp,
    this.actionText,
    this.onAction,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  AIInsight copyWith({
    String? id,
    String? message,
    InsightType? type,
    InsightPriority? priority,
    DateTime? timestamp,
    String? actionText,
    Function()? onAction,
  }) {
    return AIInsight(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      actionText: actionText ?? this.actionText,
      onAction: onAction ?? this.onAction,
    );
  }
}
