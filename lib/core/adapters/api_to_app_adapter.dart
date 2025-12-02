import '../../data/models/goal_model.dart';
import '../../models/financial_goal.dart';

/// Adapter to convert API models to App models
class ApiToAppAdapter {
  /// Convert API GoalModel to App FinancialGoal
  static FinancialGoal convertGoal(GoalModel apiGoal) {
    // Parse deadline if available
    DateTime? deadline;
    if (apiGoal.daysLeft != null) {
      deadline = DateTime.now().add(Duration(days: apiGoal.daysLeft!));
    }

    // Map category from API (icon/name) to app enum
    GoalCategory category = _mapGoalCategory(apiGoal.icon, apiGoal.name);

    return FinancialGoal(
      id: apiGoal.id,
      name: apiGoal.name,
      targetAmount: apiGoal.totalContribution,
      currentAmount: apiGoal.currentContribution,
      deadline: deadline ?? DateTime.now().add(const Duration(days: 365)),
      category: category,
      description: apiGoal.description,
      createdAt: DateTime.now(), // API doesn't provide this in list
    );
  }

  /// Convert list of API goals to app goals
  static List<FinancialGoal> convertGoals(List<GoalModel> apiGoals) {
    return apiGoals.map((g) => convertGoal(g)).toList();
  }

  /// Convert API GoalResponseData to App FinancialGoal
  static FinancialGoal convertGoalResponse(GoalResponseData apiGoal) {
    DateTime? deadline;
    if (apiGoal.deadline != null) {
      try {
        deadline = DateTime.parse(apiGoal.deadline!);
      } catch (e) {
        deadline = DateTime.now().add(const Duration(days: 365));
      }
    }

    GoalCategory category = _mapGoalCategory(apiGoal.icon, apiGoal.name);

    DateTime? createdAt;
    try {
      createdAt = DateTime.parse(apiGoal.createdAt);
    } catch (e) {
      createdAt = DateTime.now();
    }

    return FinancialGoal(
      id: apiGoal.id,
      name: apiGoal.name,
      targetAmount: apiGoal.targetAmount,
      currentAmount: apiGoal.currentAmount,
      deadline: deadline ?? DateTime.now().add(const Duration(days: 365)),
      category: category,
      description: apiGoal.description,
      createdAt: createdAt,
    );
  }

  /// Map goal icon/name to category enum
  static GoalCategory _mapGoalCategory(String? icon, String name) {
    final lowerName = name.toLowerCase();
    
    if (icon != null) {
      switch (icon) {
        case '🏠':
        case '🏡':
          return GoalCategory.house;
        case '🚗':
        case '🚙':
          return GoalCategory.car;
        case '💒':
        case '💍':
        case '❤️':
          return GoalCategory.wedding;
        case '🎓':
        case '📚':
          return GoalCategory.education;
        case '✈️':
        case '🏖️':
          return GoalCategory.vacation;
        case '🏥':
        case '💰':
          return GoalCategory.emergency;
      }
    }
    
    // Fallback to name-based detection
    if (lowerName.contains('house') || lowerName.contains('home')) {
      return GoalCategory.house;
    } else if (lowerName.contains('car') || lowerName.contains('vehicle')) {
      return GoalCategory.car;
    } else if (lowerName.contains('wedding') || lowerName.contains('marriage')) {
      return GoalCategory.wedding;
    } else if (lowerName.contains('education') || lowerName.contains('school') || lowerName.contains('college')) {
      return GoalCategory.education;
    } else if (lowerName.contains('vacation') || lowerName.contains('travel') || lowerName.contains('trip')) {
      return GoalCategory.vacation;
    } else if (lowerName.contains('emergency') || lowerName.contains('fund')) {
      return GoalCategory.emergency;
    }
    
    return GoalCategory.other;
  }

  /// Convert App FinancialGoal to API CreateGoalRequest
  static CreateGoalRequest goalToCreateRequest(FinancialGoal goal) {
    return CreateGoalRequest(
      name: goal.name,
      icon: _getCategoryIcon(goal.category),
      description: goal.description,
      totalContribution: goal.targetAmount,
      currentContribution: goal.currentAmount,
      deadline: goal.deadline.toIso8601String().split('T')[0], // YYYY-MM-DD
      color: _getCategoryColor(goal.category),
      monthlyRecurringContribution: goal.requiredMonthlySaving,
    );
  }

  /// Convert App FinancialGoal to API UpdateGoalRequest
  static UpdateGoalRequest goalToUpdateRequest(FinancialGoal goal) {
    return UpdateGoalRequest(
      name: goal.name,
      icon: _getCategoryIcon(goal.category),
      description: goal.description,
      totalContribution: goal.targetAmount,
      currentContribution: goal.currentAmount,
      deadline: goal.deadline.toIso8601String().split('T')[0],
      color: _getCategoryColor(goal.category),
      monthlyRecurringContribution: goal.requiredMonthlySaving,
    );
  }

  /// Get icon emoji for category
  static String _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.house:
        return '🏠';
      case GoalCategory.car:
        return '🚗';
      case GoalCategory.wedding:
        return '💒';
      case GoalCategory.education:
        return '🎓';
      case GoalCategory.vacation:
        return '✈️';
      case GoalCategory.emergency:
        return '💰';
      default:
        return '💰';
    }
  }

  /// Get color hex for category
  static String _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.house:
        return '#9333EA'; // Purple
      case GoalCategory.car:
        return '#00F0FF'; // Cyan
      case GoalCategory.wedding:
        return '#EC4899'; // Pink
      case GoalCategory.education:
        return '#10B981'; // Emerald
      case GoalCategory.vacation:
        return '#F59E0B'; // Orange
      case GoalCategory.emergency:
        return '#EF4444'; // Red
      default:
        return '#00F0FF'; // Cyan
    }
  }
}

