import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/financial_goal.dart';
import '../../models/subscription.dart';
import '../../providers/currency_provider.dart';

class SpendingPieChart extends StatefulWidget {
  final Map<String, double> categorySpending;
  final List<FinancialGoal>? goals;
  final List<Subscription>? subscriptions;
  final double? taxes;

  const SpendingPieChart({
    super.key,
    required this.categorySpending,
    this.goals,
    this.subscriptions,
    this.taxes,
  });

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _touchedIndex;
  String? _selectedLabel;
  double? _selectedPercentage;
  double? _selectedAmount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Colors for different categories
  static const Map<String, Color> categoryColors = {
    'food': AppColors.orange,
    'transport': AppColors.accentCyan,
    'entertainment': AppColors.purple,
    'shopping': AppColors.pink,
    'bills': AppColors.emerald,
    'health': Color(0xFFEF4444), // Red
    'healthcare': Color(0xFFEC4899), // Pink-Red
    'education': Color(0xFF3B82F6), // Blue
    'taxes': Color(0xFF8B5CF6), // Purple
    'subscriptions': Color(0xFF06B6D4), // Cyan
    'other': AppColors.textTertiary,
  };

  static const List<Color> goalColors = [
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  @override
  Widget build(BuildContext context) {
    // Combine all spending data
    final Map<String, double> allSpending = Map.from(widget.categorySpending);
    
    // Add subscriptions
    if (widget.subscriptions != null) {
      final activeSubscriptions = widget.subscriptions!.where((s) => s.isActive);
      final subscriptionTotal = activeSubscriptions.fold<double>(
        0, 
        (sum, sub) => sum + sub.monthlyAmount,
      );
      if (subscriptionTotal > 0) {
        allSpending['subscriptions'] = subscriptionTotal;
      }
    }
    
    // Add taxes
    if (widget.taxes != null && widget.taxes! > 0) {
      allSpending['taxes'] = widget.taxes!;
    }
    
    // Add individual goals
    if (widget.goals != null) {
      for (int i = 0; i < widget.goals!.length; i++) {
        final goal = widget.goals![i];
        if (goal.currentAmount > 0) {
          allSpending['goal_${goal.name}'] = goal.currentAmount;
        }
      }
    }

    if (allSpending.isEmpty) {
      return const Center(
        child: Text('No spending data available'),
      );
    }

    final total = allSpending.values.fold<double>(0, (sum, val) => sum + val);
    if (total == 0) {
      return const Center(
        child: Text('No spending this month'),
      );
    }

    // Sort categories by spending (highest first)
    final sortedEntries = allSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        // Pie chart with tooltip
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  height: 250,
                  width: 250,
                  child: GestureDetector(
                    onTapDown: (details) {
                      _handleTouch(details.localPosition, sortedEntries, total);
                    },
                    child: CustomPaint(
                      size: const Size(250, 250),
                      painter: _PieChartPainter(
                        categorySpending: Map.fromEntries(sortedEntries),
                        total: total,
                        animation: _controller.value,
                        touchedIndex: _touchedIndex,
                      ),
                    ),
                  ),
                );
              },
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
            // Center tooltip
            if (_selectedLabel != null)
              _buildCenterTooltip(),
          ],
        ),
        const SizedBox(height: 32),
        // Legend
        _buildLegend(sortedEntries, total),
      ],
    );
  }

  void _handleTouch(Offset position, List<MapEntry<String, double>> entries, double total) {
    final center = const Offset(125, 125);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    if (distance < 100 && distance > 50) {
      var angle = math.atan2(dy, dx);
      if (angle < 0) angle += 2 * math.pi;
      angle = (angle + math.pi / 2) % (2 * math.pi);
      
      double currentAngle = 0;
      for (int i = 0; i < entries.length; i++) {
        final sweepAngle = (entries[i].value / total) * 2 * math.pi;
        if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
          setState(() {
            _touchedIndex = i;
            _selectedLabel = _getCategoryLabel(entries[i].key);
            _selectedPercentage = (entries[i].value / total * 100);
            _selectedAmount = entries[i].value;
          });
          return;
        }
        currentAngle += sweepAngle;
      }
    }
    setState(() {
      _touchedIndex = null;
      _selectedLabel = null;
      _selectedPercentage = null;
      _selectedAmount = null;
    });
  }

  Widget _buildCenterTooltip() {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentCyan.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedLabel!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${_selectedPercentage!.toStringAsFixed(1)}%',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.accentCyan.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currencyProvider.formatAmount(_selectedAmount!),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOut).fadeIn(duration: 200.ms);
      },
    );
  }

  Widget _buildLegend(List<MapEntry<String, double>> entries, double total) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            final color = _getColorForCategory(entry.key, index);
            final label = _getCategoryLabel(entry.key);

            return Animate(
              effects: [
                FadeEffect(delay: Duration(milliseconds: 50 * index)),
                SlideEffect(
                  begin: const Offset(-0.3, 0),
                  delay: Duration(milliseconds: 50 * index),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        _getIconForCategory(entry.key),
                        size: 18,
                        color: color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$percentage%',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            currencyProvider.formatAmount(entry.value),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getColorForCategory(String category, int index) {
    if (category.startsWith('goal_')) {
      return _SpendingPieChartState.goalColors[
        index % _SpendingPieChartState.goalColors.length
      ];
    }
    return _SpendingPieChartState.categoryColors[category] ?? AppColors.textTertiary;
  }

  IconData _getIconForCategory(String category) {
    if (category.startsWith('goal_')) return Icons.flag;
    
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'health':
      case 'healthcare':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'taxes':
        return Icons.account_balance;
      case 'subscriptions':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }

  String _getCategoryLabel(String category) {
    if (category.startsWith('goal_')) {
      return category.substring(5); // Remove 'goal_' prefix
    }
    return category[0].toUpperCase() + category.substring(1);
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> categorySpending;
  final double total;
  final double animation;
  final int? touchedIndex;

  _PieChartPainter({
    required this.categorySpending,
    required this.total,
    required this.animation,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 * 0.75;

    double startAngle = -math.pi / 2; // Start at top
    int index = 0;

    categorySpending.forEach((category, amount) {
      final sweepAngle = (amount / total) * 2 * math.pi * animation;
      Color color;
      
      if (category.startsWith('goal_')) {
        color = _SpendingPieChartState.goalColors[
          index % _SpendingPieChartState.goalColors.length
        ];
      } else {
        color = _SpendingPieChartState.categoryColors[category] ?? AppColors.textTertiary;
      }

      final isTouched = touchedIndex == index;
      final radius = isTouched ? baseRadius * 1.1 : baseRadius;

      // Draw outer glow for vibrant effect
      final outerGlowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 5),
        startAngle,
        sweepAngle,
        false,
        outerGlowPaint,
      );

      // Draw main pie slice with gradient effect
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color,
            color.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Draw border between slices (thinner)
      final borderPaint = Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawPath(path, borderPaint);

      // Draw inner glow
      final innerGlowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.52),
        startAngle,
        sweepAngle,
        false,
        innerGlowPaint,
      );

      startAngle += sweepAngle;
      index++;
    });

    // Draw center circle for donut effect with gradient
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryMid,
          AppColors.primaryDark,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 0.5))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius * 0.5, centerPaint);

    // Draw center border (thinner)
    final centerBorderPaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, baseRadius * 0.5, centerBorderPaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.categorySpending != categorySpending ||
        oldDelegate.total != total ||
        oldDelegate.animation != animation ||
        oldDelegate.touchedIndex != touchedIndex;
  }
}
