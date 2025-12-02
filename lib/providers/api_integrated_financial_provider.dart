import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/debt_repository.dart';
import '../data/models/expense_model.dart';
import '../models/transaction.dart';
import '../models/financial_goal.dart';
import '../core/adapters/api_to_app_adapter.dart';
import 'financial_data_provider.dart';

/// Financial data provider that integrates real API data
/// Extends FinancialDataProvider for compatibility with existing UI
class ApiIntegratedFinancialProvider extends FinancialDataProvider {
  final DashboardRepository _dashboardRepo;
  final GoalRepository _goalRepo;
  final ExpenseRepository _expenseRepo;
  final DebtRepository _debtRepo;

  // Override parent's private fields with our own
  final List<Transaction> _apiTransactions = [];
  final List<FinancialGoal> _apiGoals = [];
  bool _isLoading = false;
  String? _error;

  // Add getters for loading state
  bool get isLoading => _isLoading;
  String? get error => _error;

  ApiIntegratedFinancialProvider({
    required DashboardRepository dashboardRepo,
    required GoalRepository goalRepo,
    required ExpenseRepository expenseRepo,
    required DebtRepository debtRepo,
  })  : _dashboardRepo = dashboardRepo,
        _goalRepo = goalRepo,
        _expenseRepo = expenseRepo,
        _debtRepo = debtRepo,
        super(); // Call parent constructor

  // Override getters to return our API data
  @override
  List<Transaction> get transactions => _apiTransactions;

  @override
  List<FinancialGoal> get goals => _apiGoals;

  /// Initialize and load all data from APIs
  @override
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔄 Loading real data from API...');

    try {
      // Load dashboard data
      await _loadDashboard();

      // Load goals
      await _loadGoals();

      // Load expenses
      await _loadExpenses();

      print('✅ Successfully loaded API data');
      print('   - Net worth: \$${netWorth}');
      print('   - Goals: ${_apiGoals.length}');
      print('   - Expenses: ${_apiTransactions.length}');

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load data: ${e.toString()}';
      print('⚠️ Error loading from API: $e');
      print('Falling back to mock data');
      super.initialize(); // Call parent's initialize for mock data
    }
  }

  Future<void> _loadDashboard() async {
    try {
      final dashboard = await _dashboardRepo.getDashboard();
      print('📊 Dashboard loaded: Net worth = \$${dashboard.netWorth}');
      // Dashboard data is informational, we calculate from transactions/goals
    } catch (e) {
      print('Error loading dashboard: $e');
      rethrow;
    }
  }

  Future<void> _loadGoals() async {
    try {
      final apiGoals = await _goalRepo.getGoals();

      // Clear existing goals and add API goals
      _apiGoals.clear();

      // Convert API goals to app FinancialGoal model
      for (final apiGoal in apiGoals) {
        final goal = FinancialGoal(
          id: apiGoal.id,
          name: apiGoal.name,
          targetAmount: apiGoal.totalContribution,
          currentAmount: apiGoal.currentContribution,
          deadline: apiGoal.daysLeft != null
              ? DateTime.now().add(Duration(days: apiGoal.daysLeft!))
              : DateTime.now().add(const Duration(days: 365)), // Default 1 year if no deadline
          category: _mapGoalCategory(apiGoal.name), // Map based on goal name
          description: apiGoal.description,
        );
        _apiGoals.add(goal);
      }

      print('🎯 Loaded ${_apiGoals.length} goals from API');
    } catch (e) {
      print('Error loading goals: $e');
      // Don't rethrow, keep empty goals list
    }
  }

  Future<void> _loadExpenses() async {
    try {
      final apiExpenses = await _expenseRepo.getExpenses(limit: 100);

      // Clear existing transactions and add API expenses
      _apiTransactions.clear();

      // Convert API expenses to app Transaction model
      for (final apiExpense in apiExpenses) {
        final transaction = Transaction(
          id: apiExpense.id,
          title: apiExpense.note ?? _getCategoryName(apiExpense.category),
          amount: apiExpense.amount,
          type: TransactionType.expense,
          category: _mapCategory(apiExpense.category),
          date: DateTime.parse(apiExpense.timestamp),
          description: apiExpense.note,
        );
        _apiTransactions.add(transaction);
      }

      print('💰 Loaded ${_apiTransactions.length} expenses from API');
    } catch (e) {
      print('Error loading expenses: $e');
      // Don't rethrow, keep empty transactions list
    }
  }

  String _getCategoryName(String category) {
    final Map<String, String> names = {
      'groceries': 'Groceries',
      'dining': 'Dining Out',
      'transportation': 'Transportation',
      'utilities': 'Utilities',
      'entertainment': 'Entertainment',
      'healthcare': 'Healthcare',
      'shopping': 'Shopping',
      'rent': 'Rent',
      'other': 'Other',
    };
    return names[category] ?? 'Expense';
  }

  TransactionCategory _mapCategory(String apiCategory) {
    final Map<String, TransactionCategory> mapping = {
      'groceries': TransactionCategory.food,
      'dining': TransactionCategory.food,
      'transportation': TransactionCategory.transport,
      'utilities': TransactionCategory.bills,
      'entertainment': TransactionCategory.entertainment,
      'healthcare': TransactionCategory.health,
      'shopping': TransactionCategory.shopping,
      'rent': TransactionCategory.bills,
      'other': TransactionCategory.other,
    };
    return mapping[apiCategory] ?? TransactionCategory.other;
  }

  GoalCategory _mapGoalCategory(String goalName) {
    // Map goal names to categories based on keywords
    final nameLower = goalName.toLowerCase();
    if (nameLower.contains('house') || nameLower.contains('home')) {
      return GoalCategory.house;
    } else if (nameLower.contains('car') || nameLower.contains('vehicle')) {
      return GoalCategory.car;
    } else if (nameLower.contains('wedding') || nameLower.contains('marriage')) {
      return GoalCategory.wedding;
    } else if (nameLower.contains('education') || nameLower.contains('school') || nameLower.contains('university')) {
      return GoalCategory.education;
    } else if (nameLower.contains('vacation') || nameLower.contains('travel') || nameLower.contains('trip')) {
      return GoalCategory.vacation;
    } else if (nameLower.contains('emergency') || nameLower.contains('saving')) {
      return GoalCategory.emergency;
    }
    return GoalCategory.other;
  }

  /// Override addGoal to persist to API
  @override
  void addGoal(FinancialGoal goal) {
    print('📝 Creating goal via API: ${goal.name}');

    // Don't call super - we're replacing the behavior entirely
    _createGoalOnAPI(goal);
  }

  Future<void> _createGoalOnAPI(FinancialGoal goal) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Convert to API request
      final request = ApiToAppAdapter.goalToCreateRequest(goal);

      // Create on server
      final response = await _goalRepo.createGoal(request);

      print('✅ Goal created: ${response.goal.id}');

      // Reload all goals from API to get updated list
      await _loadGoals();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create goal: $e';
      print('❌ Error creating goal: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Override updateGoal to persist to API
  @override
  void updateGoal(FinancialGoal updatedGoal) {
    print('📝 Updating goal via API: ${updatedGoal.name}');
    _updateGoalOnAPI(updatedGoal);
  }

  Future<void> _updateGoalOnAPI(FinancialGoal goal) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Convert to API request
      final request = ApiToAppAdapter.goalToUpdateRequest(goal);

      // Update on server
      final response = await _goalRepo.updateGoal(goal.id, request);

      print('✅ Goal updated: ${response.goal.id}');

      // Reload all goals from API to get updated list
      await _loadGoals();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update goal: $e';
      print('❌ Error updating goal: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Override updateGoalProgress to persist to API
  @override
  void updateGoalProgress(String id, double newAmount) {
    print('📝 Updating goal progress via API: $id = $newAmount');
    _updateGoalProgressOnAPI(id, newAmount);
  }

  Future<void> _updateGoalProgressOnAPI(String id, double newAmount) async {
    try {
      // Optimistically update UI first
      final index = _apiGoals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _apiGoals[index] = _apiGoals[index].copyWith(currentAmount: newAmount);
        notifyListeners();
      }

      // Update on server
      await _goalRepo.updateGoalProgress(id, newAmount);

      print('✅ Goal progress updated');

      // Reload all goals from API to get accurate data
      await _loadGoals();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update goal progress: $e';
      print('❌ Error updating goal progress: $e');

      // Reload to revert optimistic update
      await _loadGoals();
      notifyListeners();
    }
  }

  /// Override deleteGoal to delete from API
  @override
  void deleteGoal(String id) {
    print('🗑️ Deleting goal via API: $id');
    _deleteGoalOnAPI(id);
  }

  Future<void> _deleteGoalOnAPI(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Delete from server
      await _goalRepo.deleteGoal(id);

      print('✅ Goal deleted');

      // Reload all goals from API to get updated list
      await _loadGoals();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete goal: $e';
      print('❌ Error deleting goal: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh all data from API
  Future<void> refresh() async {
    print('🔄 Refreshing data from API...');
    await initialize();
  }

  /// Add expense via API
  Future<void> addExpenseViaAPI({
    required double amount,
    required String category,
    String? note,
  }) async {
    print('💸 Adding expense via API: \$$amount ($category)');

    try {
      _isLoading = true;
      notifyListeners();

      // Create expense request
      final request = AddExpenseRequest(
        amount: amount,
        category: category,
        note: note,
        timestamp: DateTime.now().toIso8601String(),
      );

      // Send to API
      final response = await _expenseRepo.addExpense(request);

      print('✅ Expense added: ${response.expense.id}');

      // Reload expenses to update local state
      await _loadExpenses();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add expense: $e';
      print('❌ Error adding expense: $e');
      notifyListeners();
      rethrow;
    }
  }

}

