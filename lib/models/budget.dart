import 'transaction.dart';

class Budget {
  final TransactionCategory category;
  final double limit;
  final double spent;
  final DateTime month;

  Budget({
    required this.category,
    required this.limit,
    required this.spent,
    required this.month,
  });

  double get remaining => limit - spent;
  double get progress => spent / limit;
  bool get isOverBudget => spent > limit;
  double get percentageUsed => (progress * 100).clamp(0, 999);

  String get status {
    if (isOverBudget) return 'Over Budget';
    if (progress >= 0.9) return 'Critical';
    if (progress >= 0.7) return 'Warning';
    return 'On Track';
  }

  Budget copyWith({
    TransactionCategory? category,
    double? limit,
    double? spent,
    DateTime? month,
  }) {
    return Budget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      month: month ?? this.month,
    );
  }
}
