import 'package:uuid/uuid.dart';

enum GoalCategory { house, car, wedding, education, vacation, emergency, other }

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final GoalCategory category;
  final String? description;
  final DateTime createdAt;

  FinancialGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.category,
    this.description,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get progress => currentAmount / targetAmount;

  double get remainingAmount => targetAmount - currentAmount;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  double get requiredMonthlySaving {
    final monthsRemaining = daysRemaining / 30;
    return monthsRemaining > 0 ? remainingAmount / monthsRemaining : 0;
  }

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    GoalCategory? category,
    String? description,
    DateTime? createdAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
