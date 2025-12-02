import 'package:uuid/uuid.dart';

class GoalContributionRecord {
  final String id;
  final String goalId;
  final String goalName;
  final double amount;
  final DateTime timestamp;

  GoalContributionRecord({
    String? id,
    required this.goalId,
    required this.goalName,
    required this.amount,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  GoalContributionRecord copyWith({
    String? id,
    String? goalId,
    String? goalName,
    double? amount,
    DateTime? timestamp,
  }) {
    return GoalContributionRecord(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      goalName: goalName ?? this.goalName,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory GoalContributionRecord.fromJson(Map<String, dynamic> json) {
    return GoalContributionRecord(
      id: json['id'] as String?,
      goalId: json['goalId'] as String,
      goalName: json['goalName'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'goalName': goalName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}




