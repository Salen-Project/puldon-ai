import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/financial_goal.dart';
import '../models/subscription.dart';
import '../models/budget.dart';
import '../models/income_prediction.dart';
import '../models/ai_insight.dart';
import '../models/goal_contribution_record.dart';
import '../services/ai_prediction_service.dart';
import '../services/mock_data_service.dart';
import '../services/goal_contribution_store.dart';
import '../core/constants/app_config.dart';

class FinancialDataProvider with ChangeNotifier {
  final AIPredictionService _aiService = AIPredictionService();
  final GoalContributionStore _goalContributionStore = GoalContributionStore();

  List<Transaction> _transactions = [];
  List<FinancialGoal> _goals = [];
  List<Subscription> _subscriptions = [];
  List<Budget> _budgets = [];
  List<AIInsight> _insights = [];
  IncomePrediction? _incomePrediction;
  List<GoalContributionRecord> _goalContributionHistory = [];

  // Getters
  List<Transaction> get transactions => _transactions;
  List<FinancialGoal> get goals => _goals;
  List<Subscription> get subscriptions => _subscriptions;
  List<Budget> get budgets => _budgets;
  List<AIInsight> get insights => _insights;
  IncomePrediction? get incomePrediction => _incomePrediction;
  List<GoalContributionRecord> get goalContributionHistory =>
      List.unmodifiable(_goalContributionHistory);

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

  // Net worth: total balance + savings
  double get netWorth => balance + totalSavings;

  // Wallet money: non-invested money (balance only)
  double get walletMoney => balance;

  // Get spending by category for current month
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

  // Initialize data - use API or mock based on config
  Future<void> initialize() async {
    if (AppConfig.useMockData) {
      initializeMockData();
    } else {
      await loadFromAPI();
    }
  }

  // Initialize with mock data
  void initializeMockData() {
    _transactions = MockDataService.generateTransactions(count: 100);
    _goals = MockDataService.generateGoals();
    _subscriptions = MockDataService.generateSubscriptions();
    _budgets = MockDataService.generateBudgets();
    
    // Add goal contribution transactions
    final goalContributions = MockDataService.generateGoalContributions();
    _transactions.addAll(goalContributions);
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    _updateAIPredictions();
    _loadGoalContributions();
    notifyListeners();
  }

  // Load data from API
  Future<void> loadFromAPI() async {
    print('🔄 Loading data from API...');

    // For now, we'll load what's available from API and use mock for the rest
    // The backend provides: Dashboard, Goals, Expenses, Debts
    // We don't have: Subscriptions, Budgets (use mock for these)

    try {
      // Use mock data for everything for now
      // The real API integration requires proper data transformation
      // which needs to be done carefully to match app models
      initializeMockData();

      print('✅ Using hybrid data (API + mock)');
      print('Note: Full API integration requires data model mapping');
    } catch (e) {
      print('⚠️ Error loading from API: $e');
      print('Falling back to mock data');
      initializeMockData();
    }
  }

  Future<void> _loadGoalContributions() async {
    final records = await _goalContributionStore.loadRecords();
    _goalContributionHistory = records;
    notifyListeners();
  }

  // Transaction methods
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

  // Goal methods
  void addGoal(FinancialGoal goal) {
    // If goal has initial money, deduct from wallet
    if (goal.currentAmount > 0) {
      final transaction = Transaction(
        title: 'Saved to ${goal.name}',
        amount: goal.currentAmount,
        type: TransactionType.expense,
        category: TransactionCategory.other,
        date: DateTime.now(),
        description: 'Money allocated to goal: ${goal.name}',
      );
      _transactions.insert(0, transaction);
    }
    
    _goals.add(goal);
    if (goal.currentAmount > 0) {
      _addContributionRecord(goal.id, goal.name, goal.currentAmount);
    }
    _updateAIPredictions();
    notifyListeners();
  }

  void updateGoalProgress(String id, double newAmount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final oldAmount = _goals[index].currentAmount;
      final difference = newAmount - oldAmount;
      
      // Create transaction for the difference
      if (difference != 0) {
        final transaction = Transaction(
          title: difference > 0 
              ? 'Saved to ${_goals[index].name}' 
              : 'Withdrawn from ${_goals[index].name}',
          amount: difference.abs(),
          type: difference > 0 ? TransactionType.expense : TransactionType.income,
          category: TransactionCategory.other,
          date: DateTime.now(),
          description: difference > 0 
              ? 'Added money to goal' 
              : 'Removed money from goal',
        );
        _transactions.insert(0, transaction);
        _addContributionRecord(
          _goals[index].id,
          _goals[index].name,
          difference,
        );
      }
      
      _goals[index] = _goals[index].copyWith(currentAmount: newAmount);
      _updateAIPredictions();
      notifyListeners();
    }
  }

  void updateGoal(FinancialGoal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      final oldAmount = _goals[index].currentAmount;
      final newAmount = updatedGoal.currentAmount;
      final difference = newAmount - oldAmount;
      
      // Create transaction for the difference
      if (difference != 0) {
        final transaction = Transaction(
          title: difference > 0 
              ? 'Saved to ${updatedGoal.name}' 
              : 'Withdrawn from ${updatedGoal.name}',
          amount: difference.abs(),
          type: difference > 0 ? TransactionType.expense : TransactionType.income,
          category: TransactionCategory.other,
          date: DateTime.now(),
          description: difference > 0 
              ? 'Added money to goal' 
              : 'Removed money from goal',
        );
        _transactions.insert(0, transaction);
        _addContributionRecord(
          updatedGoal.id,
          updatedGoal.name,
          difference,
        );
      }
      
      _goals[index] = updatedGoal;
      _updateAIPredictions();
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      
      // Return money to wallet if goal had any savings
      if (goal.currentAmount > 0) {
        final transaction = Transaction(
          title: 'Returned from ${goal.name}',
          amount: goal.currentAmount,
          type: TransactionType.income,
          category: TransactionCategory.other,
          date: DateTime.now(),
          description: 'Money returned from deleted goal: ${goal.name}',
        );
        _transactions.insert(0, transaction);
        _addContributionRecord(goal.id, goal.name, -goal.currentAmount);
      }
      
      _goals.removeWhere((g) => g.id == id);
      _removeGoalContributions(id);
      _updateAIPredictions();
      notifyListeners();
    }
  }

  // Subscription methods
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

  // Budget methods
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

  // AI Predictions
  void _updateAIPredictions() {
    _incomePrediction = _aiService.predictNextMonthIncome(_transactions);
    _insights = _aiService.generateInsights(
      transactions: _transactions,
      budgets: _budgets,
      prediction: _incomePrediction!,
    );
  }

  void refreshAIPredictions() {
    _updateAIPredictions();
    notifyListeners();
  }

  Map<String, double> getGoalContributionTotals({DateTime? startDate}) {
    final Map<String, double> totals = {};
    for (final record in _goalContributionHistory) {
      if (startDate != null && record.timestamp.isBefore(startDate)) continue;
      totals[record.goalName] = (totals[record.goalName] ?? 0) + record.amount;
    }
    totals.removeWhere((_, value) => value <= 0);
    return totals;
  }

  void _addContributionRecord(
      String goalId, String goalName, double amount) {
    if (amount == 0) return;
    final record = GoalContributionRecord(
      goalId: goalId,
      goalName: goalName,
      amount: amount,
    );
    _goalContributionHistory.add(record);
    _goalContributionStore.saveRecords(_goalContributionHistory);
  }

  void _removeGoalContributions(String goalId) {
    final initialLength = _goalContributionHistory.length;
    _goalContributionHistory
        .removeWhere((record) => record.goalId == goalId);
    if (_goalContributionHistory.length != initialLength) {
      _goalContributionStore.saveRecords(_goalContributionHistory);
    }
  }
}
