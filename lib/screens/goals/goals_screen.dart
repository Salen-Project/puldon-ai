import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/financial_data_provider.dart';
import '../../providers/currency_provider.dart';
import '../../widgets/cards/glowing_card.dart';
import '../../models/financial_goal.dart';
import 'goal_detail_screen.dart';
import 'widgets/goal_form_dialog.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Goals', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddGoalDialog(context),
          ),
        ],
      ),
      body: Consumer<FinancialDataProvider>(
        builder: (context, financialData, child) {
          // Handle loading state (only for API provider)
          final isApiProvider = financialData.runtimeType.toString().contains('Api');
          if (isApiProvider && (financialData as dynamic).isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentCyan,
              ),
            );
          }

          final goals = financialData.goals;

          if (goals.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (isApiProvider) {
                await (financialData as dynamic).refresh();
              } else {
                await financialData.initialize();
              }
            },
            color: AppColors.accentCyan,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(context, goals[index], index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ).animate().fadeIn().scale(),
          const SizedBox(height: 24),
          Text(
            'No Goals Yet',
            style: AppTextStyles.h2,
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 12),
          Text(
            'Start setting your financial goals',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, FinancialGoal goal, int index) {
    final progress = goal.progress.clamp(0.0, 1.0);

    Color goalColor;
    IconData goalIcon;

    switch (goal.category) {
      case GoalCategory.house:
        goalColor = AppColors.purple;
        goalIcon = Icons.home;
        break;
      case GoalCategory.car:
        goalColor = AppColors.accentCyan;
        goalIcon = Icons.directions_car;
        break;
      case GoalCategory.wedding:
        goalColor = AppColors.pink;
        goalIcon = Icons.favorite;
        break;
      case GoalCategory.education:
        goalColor = AppColors.emerald;
        goalIcon = Icons.school;
        break;
      case GoalCategory.vacation:
        goalColor = AppColors.orange;
        goalIcon = Icons.flight;
        break;
      case GoalCategory.emergency:
        goalColor = AppColors.error;
        goalIcon = Icons.health_and_safety;
        break;
      default:
        goalColor = AppColors.accentCyan;
        goalIcon = Icons.savings;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailScreen(goal: goal),
            ),
          );
        },
        child: GlowingCard(
          glowColor: goalColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: goalColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.glowingShadow(
                        color: goalColor,
                        blur: 10,
                      ),
                    ),
                    child: Icon(goalIcon, color: goalColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name, style: AppTextStyles.h4),
                        if (goal.description != null)
                          Text(
                            goal.description!,
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Crystal Progress Bar
              _buildCrystalProgressBar(progress, goalColor),
              const SizedBox(height: 16),

              // Progress Info
              Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current', style: AppTextStyles.caption),
                          Text(
                            currencyProvider.formatAmount(goal.currentAmount),
                            style: AppTextStyles.h4.copyWith(color: goalColor),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Target', style: AppTextStyles.caption),
                          Text(
                            currencyProvider.formatAmount(goal.targetAmount),
                            style: AppTextStyles.h4,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Stats Row
              Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          'Complete',
                        ),
                        _buildStat(
                          '${goal.daysRemaining}',
                          'Days Left',
                        ),
                        _buildStat(
                          currencyProvider.formatAmount(goal.requiredMonthlySaving),
                          'Monthly',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: -0.2);
  }

  Widget _buildCrystalProgressBar(double progress, Color color) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassLight,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background grid pattern
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _GridPatternPainter(),
            ),
          ),

          // Progress fill with crystal effect
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 2000.ms,
                color: Colors.white.withValues(alpha: 0.3),
              ),

          // Percentage text
          Center(
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.labelLarge),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        onSave: (goal) => context.read<FinancialDataProvider>().addGoal(goal),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.glassLight.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const spacing = 10.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
