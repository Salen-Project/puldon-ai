import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/financial_data_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/cards/glass_container.dart';
import '../../widgets/cards/glowing_card.dart';
import '../../widgets/charts/spending_pie_chart.dart';
import '../../models/transaction.dart';
import '../../models/financial_goal.dart';
import 'widgets/quick_add_expense_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FinancialDataProvider>(
          builder: (context, financialData, child) {
            // Handle loading state (only works with ApiFinancialDataProvider)
            final isApiProvider = financialData.runtimeType.toString().contains('Api');
            if (isApiProvider && (financialData as dynamic).isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentCyan,
                ),
              );
            }

            // Handle error state (only for API provider)
            final hasError = isApiProvider && (financialData as dynamic).error != null;
            if (hasError) {
              final errorMsg = (financialData as dynamic).error;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        errorMsg.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (isApiProvider) {
                          (financialData as dynamic).refresh();
                        } else {
                          financialData.initialize();
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final insights = financialData.insights;

            return RefreshIndicator(
              onRefresh: () async {
                if (isApiProvider) {
                  await (financialData as dynamic).refresh();
                } else {
                  await financialData.initialize();
                }
              },
              color: AppColors.accentCyan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const _DashboardHeader(),
                  const SizedBox(height: 30),

                  // Net Worth Card
                  _NetWorthCard(
                    data: financialData,
                    onAddIncome: () => _showQuickAddIncome(context, financialData),
                  ),
                  const SizedBox(height: 24),

                  // AI Insights
                  if (insights.isNotEmpty) ...[
                    Text('AI Insights', style: AppTextStyles.h3)
                        .animate()
                        .fadeIn()
                        .slideX(begin: -0.2),
                    const SizedBox(height: 12),
                    _AIInsightCard(insight: insights.first),
                    const SizedBox(height: 24),
                  ],

                  // Spending Overview Pie Chart
                  Text('Overview', style: AppTextStyles.h3)
                      .animate()
                      .fadeIn()
                      .slideX(begin: -0.2),
                  const SizedBox(height: 12),
                  _SpendingOverview(data: financialData),
                ],
              ),
            ),
          );
          },
        ),
      ),
      floatingActionButton: Consumer<FinancialDataProvider>(
        builder: (context, financialData, child) {
          return FloatingActionButton.extended(
            onPressed: () => _showQuickAddTransaction(context, financialData),
            backgroundColor: AppColors.accentCyan,
            icon: const Icon(Icons.add, color: AppColors.primaryDark),
            label: Text(
              'Add Transaction',
              style: AppTextStyles.button.copyWith(color: AppColors.primaryDark),
            ),
          ).animate().scale(delay: 600.ms);
        },
      ),
    );
  }

  void _showQuickAddTransaction(BuildContext context, FinancialDataProvider financialData) {
    // Get available goals for the dropdown
    final availableGoals = financialData.goals.map((g) => g.name).toList();

    showDialog(
      context: context,
      builder: (context) => QuickAddExpenseDialog(
        availableGoals: availableGoals,
        onAdd: (amount, category, note) async {
          // Check if provider is API-integrated
          final isApiProvider = financialData.runtimeType.toString().contains('Api');

          if (isApiProvider) {
            // Add via API
            // NOTE: API doesn't accept "goal" as category, use "other" instead
            final apiCategory = category == 'goal' ? 'other' : category;
            await (financialData as dynamic).addExpenseViaAPI(
              amount: amount,
              category: apiCategory,
              note: note,
            );
          } else {
            // Add locally (mock mode)
            final transaction = Transaction(
              title: note ?? _getCategoryName(category),
              amount: amount,
              type: TransactionType.expense,
              category: _mapToTransactionCategory(category),
              date: DateTime.now(),
              description: note,
            );
            financialData.addTransaction(transaction);
          }

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expense added: \$$amount'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
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
      'goal': 'Goal Contribution',
    };
    return names[category] ?? 'Expense';
  }

  TransactionCategory _mapToTransactionCategory(String apiCategory) {
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
      'goal': TransactionCategory.other,
    };
    return mapping[apiCategory] ?? TransactionCategory.other;
  }

  void _showQuickAddIncome(BuildContext context, FinancialDataProvider financialData) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedSource = 'salary';

    final sources = {
      'salary': {'label': 'Salary', 'icon': Icons.work, 'color': AppColors.emerald},
      'freelance': {'label': 'Freelance', 'icon': Icons.computer, 'color': AppColors.accentCyan},
      'investment': {'label': 'Investment', 'icon': Icons.trending_up, 'color': AppColors.purple},
      'other': {'label': 'Other', 'icon': Icons.attach_money, 'color': AppColors.info},
    };

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.glassLight, width: 1),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.glowingShadow(color: AppColors.emerald, blur: 10),
                    ),
                    child: const Icon(
                      Icons.add_circle,
                      color: AppColors.emerald,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Add Income', style: AppTextStyles.h2),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount
              Text('Amount', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.h1.copyWith(color: AppColors.emerald),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Text('\$', style: AppTextStyles.h2),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  hintText: '0.00',
                  filled: true,
                  fillColor: AppColors.primaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Source
              Text('Source', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sources.entries.map((entry) {
                      final isSelected = selectedSource == entry.key;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSource = entry.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (entry.value['color'] as Color).withValues(alpha: 0.2)
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (entry.value['color'] as Color)
                                  : AppColors.glassLight,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.value['icon'] as IconData,
                                color: isSelected
                                    ? (entry.value['color'] as Color)
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.value['label'] as String,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected
                                      ? (entry.value['color'] as Color)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Note
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  filled: true,
                  fillColor: AppColors.primaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(dialogContext);

                        // Add income transaction
                        final transaction = Transaction(
                          title: noteController.text.isNotEmpty
                              ? noteController.text
                              : sources[selectedSource]!['label'] as String,
                          amount: amount,
                          type: TransactionType.income,
                          category: selectedSource == 'salary'
                              ? TransactionCategory.salary
                              : selectedSource == 'freelance'
                                  ? TransactionCategory.freelance
                                  : selectedSource == 'investment'
                                      ? TransactionCategory.investment
                                      : TransactionCategory.other,
                          date: DateTime.now(),
                          description: noteController.text.isNotEmpty ? noteController.text : null,
                        );

                        financialData.addTransaction(transaction);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Income added: \$${amount.toStringAsFixed(2)}'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Income'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
        ).animate().fadeIn().slideY(begin: -0.2),
        const SizedBox(height: 4),
        Text(
          'Financial Overview',
          style: AppTextStyles.display2,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
      ],
    );
  }
}

class _NetWorthCard extends StatelessWidget {
  final FinancialDataProvider data;
  final VoidCallback onAddIncome;

  const _NetWorthCard({
    required this.data,
    required this.onAddIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Animate(
          effects: [
            FadeEffect(delay: 200.ms),
            ScaleEffect(begin: const Offset(0.8, 0.8)),
          ],
          child: GlowingCard(
            glowColor: AppColors.emerald,
            animate: false,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Total Net Worth',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Text(
                  currencyProvider.formatAmount(data.netWorth),
                  style: AppTextStyles.numberDisplay,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.accentCyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet Money',
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                currencyProvider.formatAmount(data.walletMoney),
                                style: AppTextStyles.h4,
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Add income button
                      GestureDetector(
                        onTap: onAddIncome,
                        child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.emerald.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.emerald,
                                size: 24,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AIInsightCard extends StatelessWidget {
  final dynamic insight;

  const _AIInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (insight.type.toString()) {
      case 'InsightType.warning':
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
        break;
      case 'InsightType.achievement':
        icon = Icons.star_rounded;
        color = AppColors.emerald;
        break;
      case 'InsightType.suggestion':
        icon = Icons.lightbulb_outline_rounded;
        color = AppColors.accentCyan;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = AppColors.info;
    }

    return GlassContainer(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              insight.message,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2);
  }
}

class _SpendingOverview extends StatefulWidget {
  final FinancialDataProvider data;

  const _SpendingOverview({required this.data});

  @override
  State<_SpendingOverview> createState() => _SpendingOverviewState();
}

class _SpendingOverviewState extends State<_SpendingOverview> {
  String _selectedPeriod = '1 Month';
  final List<String> _periods = ['1 Month', '6 Months', '1 Year', 'Max'];

  @override
  Widget build(BuildContext context) {
    final startDate = _getPeriodStartDate();
    final transactions = widget.data.transactions;
    bool withinPeriod(DateTime date) =>
        startDate == null || !date.isBefore(startDate);

    final filteredExpenses = transactions
        .where(
            (t) => t.type == TransactionType.expense && withinPeriod(t.date))
        .toList();
    final filteredIncomes = transactions
        .where((t) => t.type == TransactionType.income && withinPeriod(t.date))
        .toList();

    Map<String, double> categorySpending;
    if (filteredExpenses.isEmpty) {
      categorySpending =
          Map<String, double>.from(widget.data.spendingByCategory);
    } else {
      categorySpending = _aggregateExpenses(filteredExpenses);
    }

    final taxes = filteredIncomes.fold<double>(
          0,
          (sum, tx) => sum + tx.amount,
        ) *
        0.15;
    if (taxes > 0) {
      categorySpending['taxes'] =
          (categorySpending['taxes'] ?? 0) + taxes;
    }

    final monthsFactor = _getMonthsFactor(startDate, transactions);
    final subscriptionTotal = widget.data.subscriptions
        .where((s) => s.isActive)
        .fold<double>(0, (sum, sub) => sum + sub.monthlyAmount * monthsFactor);
    if (subscriptionTotal > 0) {
      categorySpending['subscriptions'] =
          (categorySpending['subscriptions'] ?? 0) + subscriptionTotal;
    }

    final goalsForChart = _buildGoalSlices(startDate, filteredExpenses);
    
    return Animate(
      effects: [
        FadeEffect(delay: 400.ms),
        ScaleEffect(begin: const Offset(0.8, 0.8)),
      ],
      child: GlowingCard(
        glowColor: AppColors.purple,
        animate: false,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Time period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spending Overview',
                  style: AppTextStyles.h4,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.accentCyan,
                        size: 20,
                      ),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w600,
                      ),
                      dropdownColor: AppColors.primaryLight,
                      items: _periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedPeriod = newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SpendingPieChart(
              categorySpending: categorySpending,
              goals: goalsForChart.isEmpty ? null : goalsForChart,
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _getPeriodStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case '1 Month':
        return now.subtract(const Duration(days: 30));
      case '6 Months':
        return now.subtract(const Duration(days: 182));
      case '1 Year':
        return now.subtract(const Duration(days: 365));
      default:
        return null;
    }
  }

  int _getMonthsFactor(DateTime? startDate, List<Transaction> transactions) {
    switch (_selectedPeriod) {
      case '1 Month':
        return 1;
      case '6 Months':
        return 6;
      case '1 Year':
        return 12;
      default:
        if (transactions.isEmpty) return 1;
        final earliest = transactions
            .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
            .date;
        final now = DateTime.now();
        int months = (now.year - earliest.year) * 12 + now.month - earliest.month;
        return months <= 0 ? 1 : months;
    }
  }

  Map<String, double> _aggregateExpenses(List<Transaction> expenses) {
    final Map<String, double> result = {};
    for (final tx in expenses) {
      final categoryName = tx.category.toString().split('.').last;
      result[categoryName] = (result[categoryName] ?? 0) + tx.amount;
    }
    return result;
  }

  List<FinancialGoal> _buildGoalSlices(
      DateTime? startDate, List<Transaction> expenses) {
    // For Max period, use actual goal balances
    if (startDate == null) {
      return widget.data.goals;
    }

    // Calculate contributions only from transactions in the selected period
    final Map<String, double> contributions = {};
    for (final tx in expenses) {
      if (tx.title.startsWith('Saved to ')) {
        final name = tx.title.substring('Saved to '.length).trim();
        contributions[name] = (contributions[name] ?? 0) + tx.amount;
      }
    }

    // Only show goals that had contributions in this period
    // Don't fallback to total balances
    return widget.data.goals
        .map((goal) {
          final amount = contributions[goal.name];
          if (amount == null || amount <= 0) return null;
          return goal.copyWith(currentAmount: amount);
        })
        .whereType<FinancialGoal>()
        .toList();
  }
}
