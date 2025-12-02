import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/financial_goal.dart';
import '../../providers/financial_data_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/cards/glowing_card.dart';
import 'widgets/goal_form_dialog.dart';
import 'dart:math' as math;

class GoalDetailScreen extends StatefulWidget {
  final FinancialGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  String _selectedPeriod = '1 Month';
  final List<String> _periods = ['1 Month', '6 Months', '1 Year', 'Max'];
  late FinancialGoal _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_goal.name, style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildContributionChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        final progress = _goal.progress.clamp(0.0, 1.0);
        Color goalColor = _getGoalColor();

        return GlowingCard(
          glowColor: goalColor,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                _getGoalIcon(),
                size: 60,
                color: goalColor,
              ),
              const SizedBox(height: 16),
              Text(
                _goal.name,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              if (_goal.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  _goal.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _buildProgressBar(progress, goalColor),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        currencyProvider.formatAmount(_goal.currentAmount),
                        style: AppTextStyles.h4.copyWith(color: goalColor),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Target', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        currencyProvider.formatAmount(_goal.targetAmount),
                        style: AppTextStyles.h4,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(double progress, Color color) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.glassLight, width: 1),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.6),
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Remaining',
                currencyProvider.formatAmount(_goal.remainingAmount),
                Icons.trending_up,
                AppColors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Days Left',
                '${_goal.daysRemaining}',
                Icons.calendar_today,
                AppColors.accentCyan,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlowingCard(
      glowColor: color,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContributionChart() {
    // Generate mock contribution data
    final contributions = _generateMockContributions();
    
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return GlowingCard(
          glowColor: AppColors.purple,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contribution History',
                    style: AppTextStyles.h4,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              SizedBox(
                height: 250,
                child: contributions.isEmpty
                    ? Center(
                        child: Text(
                          'No contributions yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _goal.targetAmount / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.glassLight.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value == meta.min || value == meta.max) {
                                return const Text('');
                              }
                              return Text(
                                DateFormat('MMM d').format(
                                  contributions[value.toInt()].date,
                                ),
                                style: AppTextStyles.caption,
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final formatted = currencyProvider.formatAmount(value, decimalDigits: 0);
                              // Abbreviate if too long
                              if (formatted.length > 8) {
                                return Text(
                                  '${formatted.substring(0, 5)}...',
                                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                                );
                              }
                              return Text(
                                formatted,
                                style: AppTextStyles.caption.copyWith(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (contributions.length - 1).toDouble(),
                      minY: 0,
                      maxY: _goal.targetAmount * 1.1,
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) => AppColors.primaryLight,
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '',
                                AppTextStyles.caption,
                                children: [
                                  TextSpan(
                                    text: DateFormat('MMM d, yyyy').format(
                                      contributions[spot.x.toInt()].date,
                                    ),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                    text: currencyProvider.formatAmount(spot.y),
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                        getTouchedSpotIndicator: (barData, spotIndexes) {
                          return spotIndexes.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: AppColors.accentCyan.withValues(alpha: 0.5),
                                strokeWidth: 2,
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: AppColors.accentCyan,
                                    strokeWidth: 2,
                                    strokeColor: AppColors.primaryDark,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: contributions.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.amount,
                            );
                          }).toList(),
                          isCurved: true,
                          gradient: AppColors.accentGradient,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: AppColors.accentCyan,
                                strokeWidth: 2,
                                strokeColor: AppColors.primaryDark,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentCyan.withValues(alpha: 0.3),
                                AppColors.accentCyan.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
        );
      },
    );
  }

  List<_Contribution> _generateMockContributions() {
    // Generate mock contribution data based on selected period
    final now = DateTime.now();
    List<_Contribution> contributions = [];
    
    int days;
    switch (_selectedPeriod) {
      case '1 Month':
        days = 30;
        break;
      case '6 Months':
        days = 180;
        break;
      case '1 Year':
        days = 365;
        break;
      case 'Max':
        days = _goal.daysRemaining + 100;
        break;
      default:
        days = 30;
    }

    final random = math.Random();
    double accumulated = 0;
    final increment = _goal.currentAmount / (days / 15);
    
    for (int i = 0; i < (days / 15).floor(); i++) {
      accumulated += increment + (random.nextDouble() * increment * 0.5);
      contributions.add(_Contribution(
        date: now.subtract(Duration(days: days - (i * 15))),
        amount: accumulated.clamp(0, _goal.currentAmount),
      ));
    }

    return contributions;
  }

  Color _getGoalColor() {
    switch (_goal.category) {
      case GoalCategory.house:
        return AppColors.purple;
      case GoalCategory.car:
        return AppColors.accentCyan;
      case GoalCategory.wedding:
        return AppColors.pink;
      case GoalCategory.education:
        return AppColors.emerald;
      case GoalCategory.vacation:
        return AppColors.orange;
      case GoalCategory.emergency:
        return AppColors.error;
      default:
        return AppColors.accentCyan;
    }
  }

  IconData _getGoalIcon() {
    switch (_goal.category) {
      case GoalCategory.house:
        return Icons.home;
      case GoalCategory.car:
        return Icons.directions_car;
      case GoalCategory.wedding:
        return Icons.favorite;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.vacation:
        return Icons.flight;
      case GoalCategory.emergency:
        return Icons.health_and_safety;
      default:
        return Icons.savings;
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        initialGoal: _goal,
        onSave: (updatedGoal) {
          context.read<FinancialDataProvider>().updateGoal(updatedGoal);
          setState(() => _goal = updatedGoal);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${_goal.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinancialDataProvider>().deleteGoal(_goal.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Contribution {
  final DateTime date;
  final double amount;

  _Contribution({required this.date, required this.amount});
}

