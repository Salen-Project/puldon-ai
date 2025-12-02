import 'dart:math';
import '../models/income_prediction.dart';
import '../models/ai_insight.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

class AIPredictionService {
  /// Predict next month's income based on historical data
  IncomePrediction predictNextMonthIncome(List<Transaction> transactions) {
    // Filter income transactions from last 6 months
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);

    final incomeTransactions = transactions
        .where((t) =>
            t.type == TransactionType.income && t.date.isAfter(sixMonthsAgo))
        .toList();

    if (incomeTransactions.isEmpty) {
      return IncomePrediction(
        month: DateTime(now.year, now.month + 1),
        predictedAmount: 0,
        confidence: 0,
        changePercentage: 0,
        reason: 'No historical data available',
        historicalData: [],
      );
    }

    // Calculate monthly averages
    final monthlyIncome = <DateTime, double>{};
    for (var transaction in incomeTransactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);
      monthlyIncome[monthKey] = (monthlyIncome[monthKey] ?? 0) + transaction.amount;
    }

    final historicalData = monthlyIncome.values.toList();
    final avgIncome = historicalData.reduce((a, b) => a + b) / historicalData.length;

    // Simple trend analysis
    final recentAvg = historicalData.length >= 3
        ? historicalData.sublist(historicalData.length - 3).reduce((a, b) => a + b) / 3
        : avgIncome;

    final trend = recentAvg - avgIncome;
    final prediction = recentAvg + (trend * 0.3); // Project trend forward

    // Calculate change percentage
    final lastMonthIncome = historicalData.isNotEmpty ? historicalData.last : 0.0;
    final changePercentage = lastMonthIncome > 0
        ? ((prediction - lastMonthIncome) / lastMonthIncome) * 100
        : 0.0;

    // Confidence based on data consistency
    final variance = _calculateVariance(historicalData);
    final confidence = 1 - (variance / avgIncome).clamp(0, 1);

    // Determine reason
    String reason;
    if (changePercentage.abs() < 2) {
      reason = 'Income stable based on recent trends';
    } else if (changePercentage < -10) {
      reason = 'Seasonal change detected - income might drop';
    } else if (changePercentage > 10) {
      reason = 'Growth pattern detected - income may increase';
    } else {
      reason = 'Minor fluctuations expected based on history';
    }

    return IncomePrediction(
      month: DateTime(now.year, now.month + 1),
      predictedAmount: prediction.toDouble(),
      confidence: confidence.toDouble(),
      changePercentage: changePercentage.toDouble(),
      reason: reason,
      historicalData: historicalData,
    );
  }

  /// Generate AI insights based on financial data
  List<AIInsight> generateInsights({
    required List<Transaction> transactions,
    required List<Budget> budgets,
    required IncomePrediction prediction,
  }) {
    final insights = <AIInsight>[];

    // Income prediction insight
    if (prediction.predictedAmount > 0) {
      if (prediction.changePercentage < -10) {
        insights.add(AIInsight(
          message:
              'Your income might drop ${prediction.changePercentage.abs().toStringAsFixed(0)}% next month. Consider saving \$${(prediction.predictedAmount * 0.1).toStringAsFixed(0)} more.',
          type: InsightType.warning,
          priority: InsightPriority.high,
        ));
      } else if (prediction.changePercentage > 10) {
        insights.add(AIInsight(
          message:
              'Great news! Your income may increase by ${prediction.changePercentage.toStringAsFixed(0)}% next month.',
          type: InsightType.achievement,
          priority: InsightPriority.medium,
        ));
      }
    }

    // Budget warnings
    for (var budget in budgets) {
      if (budget.isOverBudget) {
        insights.add(AIInsight(
          message:
              'You\'ve exceeded your ${_getCategoryName(budget.category)} budget by \$${budget.remaining.abs().toStringAsFixed(2)}',
          type: InsightType.warning,
          priority: InsightPriority.high,
        ));
      } else if (budget.progress >= 0.8) {
        insights.add(AIInsight(
          message:
              'You\'ve reached ${budget.percentageUsed.toStringAsFixed(0)}% of your ${_getCategoryName(budget.category)} budget.',
          type: InsightType.warning,
          priority: InsightPriority.medium,
        ));
      }
    }

    // Spending pattern insights
    final thisMonth = DateTime.now();
    final monthStart = DateTime(thisMonth.year, thisMonth.month, 1);
    final thisMonthExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense && t.date.isAfter(monthStart))
        .toList();

    if (thisMonthExpenses.length >= 3) {
      final totalExpenses =
          thisMonthExpenses.fold<double>(0, (sum, t) => sum + t.amount);
      final avgExpense = totalExpenses / thisMonthExpenses.length;

      insights.add(AIInsight(
        message:
            'Your average expense this month is \$${avgExpense.toStringAsFixed(2)}. You\'ve spent \$${totalExpenses.toStringAsFixed(2)} so far.',
        type: InsightType.info,
        priority: InsightPriority.low,
      ));
    }

    return insights;
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2)).toList();
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  String _getCategoryName(TransactionCategory category) {
    return category.toString().split('.').last;
  }
}
