import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/financial_goal.dart';
import '../models/subscription.dart';
import '../models/budget.dart';
import '../models/income_prediction.dart';
import '../models/ai_insight.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../core/adapters/api_to_app_adapter.dart';
import '../services/ai_prediction_service.dart';

/// Financial Data Provider that fetches from real API
class ApiFinancialDataProvider with ChangeNotifier {
  final GoalRepository _goalRepository;
  final DashboardRepository _dashboardRepository;
  final AIPredictionService _aiService = AIPredictionService();

  List<Transaction> _transactions = [];
  List<FinancialGoal> _goals = [];
  List<Subscription> _subscriptions = [];
  List<Budget> _budgets = [];
  List<AIInsight> _insights = [];
  IncomePrediction? _incomePrediction;
  bool _isLoading = false;
  String? _error;

  ApiFinancialDataProvider({
    required GoalRepository goalRepository,
    required DashboardRepository dashboardRepository,
  })  : _goalRepository = goalRepository,
        _dashboardRepository = dashboardRepository;

  // Getters
  List<Transaction> get transactions => _transactions;
  List<FinancialGoal> get goals => _goals;
  List<Subscription> get subscriptions => _subscriptions;
  List<Budget> get budgets => _budgets;
  List<AIInsight> get insights => _insights;
  IncomePrediction? get incomePrediction => _incomePrediction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed values
  double get totalIncome {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.type == TransactionType.income && t.date.isAfter(monthStart))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.date.isAfter(monthStart))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  double get totalSavings {
    return _goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
  }

  double get monthlySubscriptionsCost {
    return _subscriptions
        .where((s) => s.isActive)
        .fold<double>(0, (sum, s) => sum + s.monthlyAmount);
  }

  double get netWorth => balance + totalSavings;
  double get walletMoney => balance;

  Map<String, double> get spendingByCategory {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final expenses = _transactions
        .where((t) => t.type == TransactionType.expense && t.date.isAfter(monthStart));

    Map<String, double> categorySpending = {};
    for (var transaction in expenses) {
      final categoryName = transaction.category.toString().split('.').last;
      categorySpending[categoryName] =
          (categorySpending[categoryName] ?? 0) + transaction.amount;
    }
    return categorySpending;
  }

  /// Load all data from API
  Future<void> loadFromAPI() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch goals from API
      final apiGoals = await _goalRepository.getGoals();
      _goals = ApiToAppAdapter.convertGoals(apiGoals);

      // Fetch dashboard data
      try {
        final dashboard = await _dashboardRepository.getDashboard();
        
        // Update insights from API
        _insights = dashboard.insights.map((insight) => AIInsight(
          type: InsightType.suggestion,
          message: insight,
          priority: InsightPriority.medium,
        )).toList();

        // For now, keep mock transactions and subscriptions
        // These need separate API endpoints that may not exist yet
        _generateMockTransactionsFromGoals();
        _generateMockSubscriptions();
        _generateMockBudgets();
        
      } catch (e) {
        print('Dashboard API error (non-critical): $e');
        // Continue with goals even if dashboard fails
        _generateMockTransactionsFromGoals();
        _generateMockSubscriptions();
        _generateMockBudgets();
      }

      _updateAIPredictions();
      _isLoading = false;
      _error = null;
      notifyListeners();
      
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load data: ${e.toString()}';
      print('❌ Error loading from API: $e');
      
      // Don't show error to user, just use empty data
      _goals = [];
      _transactions = [];
      _subscriptions = [];
      _budgets = [];
      _insights = [];
      
      notifyListeners();
    }
  }

  /// Generate mock transactions based on goals (temporary)
  void _generateMockTransactionsFromGoals() {
    _transactions = [];
    final now = DateTime.now();
    
    // Generate some income
    for (int i = 0; i < 3; i++) {
      _transactions.add(Transaction(
        title: 'Salary',
        amount: 3500 + (i * 200),
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: now.subtract(Duration(days: 30 * i)),
      ));
    }
    
    // Generate expenses
    final expenseCategories = [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.bills,
    ];
    
    for (int i = 0; i < 20; i++) {
      final category = expenseCategories[i % expenseCategories.length];
      _transactions.add(Transaction(
        title: _getTransactionTitle(category),
        amount: 50 + (i * 10).toDouble(),
        type: TransactionType.expense,
        category: category,
        date: now.subtract(Duration(days: i * 2)),
      ));
    }
    
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  String _getTransactionTitle(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Grocery Shopping';
      case TransactionCategory.transport:
        return 'Uber';
      case TransactionCategory.bills:
        return 'Electricity Bill';
      default:
        return 'Expense';
    }
  }

  void _generateMockSubscriptions() {
    // Keep empty for now or use minimal mock data
    _subscriptions = [];
  }

  void _generateMockBudgets() {
    _budgets = [];
  }

  void _updateAIPredictions() {
    if (_transactions.isNotEmpty) {
      _incomePrediction = _aiService.predictNextMonthIncome(_transactions);
      if (_incomePrediction != null) {
        final aiInsights = _aiService.generateInsights(
          transactions: _transactions,
          budgets: _budgets,
          prediction: _incomePrediction!,
        );
        _insights.addAll(aiInsights);
      }
    }
  }

  /// Refresh data from API
  Future<void> refresh() async {
    await loadFromAPI();
  }

  /// Add a new goal (to API)
  Future<void> addGoal(FinancialGoal goal) async {
    try {
      final request = ApiToAppAdapter.goalToCreateRequest(goal);
      final response = await _goalRepository.createGoal(request);
      
      // Convert response back to app model and add to list
      final newGoal = ApiToAppAdapter.convertGoalResponse(response.goal);
      _goals.add(newGoal);
      notifyListeners();
      
      // Refresh to get updated data
      await loadFromAPI();
    } catch (e) {
      _error = 'Failed to create goal: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Update a goal (to API)
  Future<void> updateGoal(FinancialGoal goal) async {
    try {
      final request = ApiToAppAdapter.goalToUpdateRequest(goal);
      final response = await _goalRepository.updateGoal(goal.id, request);
      
      // Update in local list
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = ApiToAppAdapter.convertGoalResponse(response.goal);
        notifyListeners();
      }
      
      // Refresh to get updated data
      await loadFromAPI();
    } catch (e) {
      _error = 'Failed to update goal: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a goal (from API)
  Future<void> deleteGoal(String id) async {
    try {
      await _goalRepository.deleteGoal(id);
      
      // Remove from local list
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
      
      // Refresh to get updated data
      await loadFromAPI();
    } catch (e) {
      _error = 'Failed to delete goal: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Update goal progress
  void updateGoalProgress(String id, double newAmount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(currentAmount: newAmount);
      notifyListeners();
      
      // Update on API (async, don't wait)
      _goalRepository.updateGoalProgress(id, newAmount).catchError((e) {
        print('Error updating goal progress: $e');
        return <String, dynamic>{};
      });
    }
  }

  // Transaction methods (mock for now)
  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _updateAIPredictions();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _updateAIPredictions();
    notifyListeners();
  }

  // Subscription methods (mock for now)
  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
  }

  void toggleSubscription(String id) {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subscriptions[index] =
          _subscriptions[index].copyWith(isActive: !_subscriptions[index].isActive);
      notifyListeners();
    }
  }

  void deleteSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Budget methods (mock for now)
  void updateBudget(TransactionCategory category, double newLimit) {
    final index = _budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(limit: newLimit);
    } else {
      _budgets.add(Budget(
        category: category,
        limit: newLimit,
        spent: 0,
        month: DateTime.now(),
      ));
    }
    _updateAIPredictions();
    notifyListeners();
  }

  void refreshAIPredictions() {
    _updateAIPredictions();
    notifyListeners();
  }
}

/// Provider for API-based FinancialDataProvider (Riverpod)
final apiFinancialDataProvider = ChangeNotifierProvider<ApiFinancialDataProvider>((ref) {
  final goalRepo = ref.watch(goalRepositoryProvider);
  final dashboardRepo = ref.watch(dashboardRepositoryProvider);
  
  final provider = ApiFinancialDataProvider(
    goalRepository: goalRepo,
    dashboardRepository: dashboardRepo,
  );
  
  // Load data immediately
  provider.loadFromAPI();
  
  return provider;
});

