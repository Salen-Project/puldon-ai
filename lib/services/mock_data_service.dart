import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/financial_goal.dart';
import '../models/subscription.dart';
import '../models/budget.dart';

class MockDataService {
  static final Random _random = Random();

  /// Generate realistic mock transactions
  static List<Transaction> generateTransactions({int count = 50}) {
    final transactions = <Transaction>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final daysAgo = _random.nextInt(180);
      final date = now.subtract(Duration(days: daysAgo));

      final isIncome = _random.nextDouble() < 0.3;

      if (isIncome) {
        transactions.add(Transaction(
          title: _random.nextBool() ? 'Salary' : 'Freelance Payment',
          amount: 3000 + _random.nextDouble() * 2000,
          type: TransactionType.income,
          category: _random.nextBool()
              ? TransactionCategory.salary
              : TransactionCategory.freelance,
          date: date,
        ));
      } else {
        final expenseCategories = TransactionCategory.values.skip(4).toList();
        final category =
            expenseCategories[_random.nextInt(expenseCategories.length)];
        transactions.add(Transaction(
          title: _getTransactionTitle(category),
          amount: 10 + _random.nextDouble() * 200,
          type: TransactionType.expense,
          category: category,
          date: date,
        ));
      }
    }

    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// Generate financial goals
  static List<FinancialGoal> generateGoals() {
    return [
      FinancialGoal(
        name: 'Dream Wedding',
        targetAmount: 25000,
        currentAmount: 12500,
        deadline: DateTime.now().add(const Duration(days: 365)),
        category: GoalCategory.wedding,
        description: 'Save for the perfect wedding ceremony',
      ),
      FinancialGoal(
        name: 'New Car',
        targetAmount: 35000,
        currentAmount: 18000,
        deadline: DateTime.now().add(const Duration(days: 730)),
        category: GoalCategory.car,
        description: 'Tesla Model 3',
      ),
      FinancialGoal(
        name: 'Emergency Fund',
        targetAmount: 10000,
        currentAmount: 7200,
        deadline: DateTime.now().add(const Duration(days: 180)),
        category: GoalCategory.emergency,
        description: '6 months of expenses',
      ),
      FinancialGoal(
        name: 'House Down Payment',
        targetAmount: 50000,
        currentAmount: 8500,
        deadline: DateTime.now().add(const Duration(days: 1095)),
        category: GoalCategory.house,
        description: '20% down payment for dream home',
      ),
    ];
  }

  /// Generate goal contribution transactions
  static List<Transaction> generateGoalContributions() {
    final contributions = <Transaction>[];
    final now = DateTime.now();
    final goals = [
      {'name': 'Dream Wedding', 'total': 12500.0},
      {'name': 'New Car', 'total': 18000.0},
      {'name': 'Emergency Fund', 'total': 7200.0},
      {'name': 'House Down Payment', 'total': 8500.0},
    ];

    // Generate contributions spread over the past 6 months
    for (final goalData in goals) {
      final name = goalData['name'] as String;
      final total = goalData['total'] as double;
      
      // Spread contributions over 6 months (about 2-3 contributions per month)
      final numContributions = 12 + _random.nextInt(8); // 12-20 contributions
      double accumulated = 0;
      
      for (int i = 0; i < numContributions; i++) {
        if (accumulated >= total) break;
        
        // Contributions spread over 180 days
        final daysAgo = _random.nextInt(180);
        final amount = (total / numContributions) * (0.8 + _random.nextDouble() * 0.4);
        
        if (accumulated + amount <= total) {
          contributions.add(Transaction(
            title: 'Saved to $name',
            amount: amount,
            type: TransactionType.expense,
            category: TransactionCategory.other,
            date: now.subtract(Duration(days: daysAgo)),
            description: 'Contribution to goal: $name',
          ));
          accumulated += amount;
        }
      }
    }

    contributions.sort((a, b) => b.date.compareTo(a.date));
    return contributions;
  }

  /// Generate subscriptions
  static List<Subscription> generateSubscriptions() {
    return [
      Subscription(
        name: 'Netflix',
        amount: 15.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 12)),
        brandColor: const Color(0xFFE50914),
        icon: Icons.movie,
        description: 'Premium streaming plan',
      ),
      Subscription(
        name: 'Spotify',
        amount: 9.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 8)),
        brandColor: const Color(0xFF1DB954),
        icon: Icons.music_note,
        description: 'Premium music streaming',
      ),
      Subscription(
        name: 'Amazon Prime',
        amount: 139,
        billingCycle: BillingCycle.yearly,
        nextBillingDate: DateTime.now().add(const Duration(days: 145)),
        brandColor: const Color(0xFFFF9900),
        icon: Icons.shopping_bag,
        description: 'Prime membership',
      ),
      Subscription(
        name: 'Apple iCloud',
        amount: 2.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 5)),
        brandColor: const Color(0xFF007AFF),
        icon: Icons.cloud,
        description: '200GB storage',
      ),
      Subscription(
        name: 'Gym Membership',
        amount: 49.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 18)),
        brandColor: const Color(0xFFFF6B6B),
        icon: Icons.fitness_center,
        description: 'Premium fitness center',
      ),
      Subscription(
        name: 'Adobe Creative Cloud',
        amount: 54.99,
        billingCycle: BillingCycle.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 22)),
        brandColor: const Color(0xFFFF0000),
        icon: Icons.design_services,
        description: 'All apps plan',
      ),
    ];
  }

  /// Generate budgets
  static List<Budget> generateBudgets() {
    return [
      Budget(
        category: TransactionCategory.food,
        limit: 500,
        spent: 410,
        month: DateTime.now(),
      ),
      Budget(
        category: TransactionCategory.transport,
        limit: 200,
        spent: 145,
        month: DateTime.now(),
      ),
      Budget(
        category: TransactionCategory.entertainment,
        limit: 300,
        spent: 278,
        month: DateTime.now(),
      ),
      Budget(
        category: TransactionCategory.shopping,
        limit: 400,
        spent: 520,
        month: DateTime.now(),
      ),
      Budget(
        category: TransactionCategory.bills,
        limit: 800,
        spent: 750,
        month: DateTime.now(),
      ),
    ];
  }

  static String _getTransactionTitle(TransactionCategory category) {
    final titles = {
      TransactionCategory.food: [
        'Grocery Shopping',
        'Restaurant',
        'Coffee Shop',
        'Food Delivery'
      ],
      TransactionCategory.transport: [
        'Uber',
        'Gas Station',
        'Public Transport',
        'Parking'
      ],
      TransactionCategory.entertainment: [
        'Movie Tickets',
        'Concert',
        'Gaming',
        'Sports Event'
      ],
      TransactionCategory.shopping: [
        'Amazon',
        'Clothing Store',
        'Electronics',
        'Online Shopping'
      ],
      TransactionCategory.bills: [
        'Electricity',
        'Internet',
        'Phone Bill',
        'Water Bill'
      ],
      TransactionCategory.health: [
        'Pharmacy',
        'Doctor Visit',
        'Gym',
        'Health Insurance'
      ],
      TransactionCategory.education: [
        'Course Fee',
        'Books',
        'Online Learning',
        'Tuition'
      ],
    };

    final categoryTitles = titles[category] ?? ['Expense'];
    return categoryTitles[_random.nextInt(categoryTitles.length)];
  }
}
