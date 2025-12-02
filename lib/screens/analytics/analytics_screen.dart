import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/income_prediction.dart';
import '../../providers/financial_data_provider.dart';
import '../../widgets/cards/glowing_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: AppTextStyles.h3),
      ),
      body: Consumer<FinancialDataProvider>(
        builder: (context, financialData, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (financialData.incomePrediction != null) ...[
                  Text('Income Trend', style: AppTextStyles.h3)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 12),
                  _IncomeChart(prediction: financialData.incomePrediction!),
                  const SizedBox(height: 24),
                  Text('AI Prediction Details', style: AppTextStyles.h3)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 12),
                  _PredictionDetails(prediction: financialData.incomePrediction!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

}

class _IncomeChart extends StatelessWidget {
  final IncomePrediction prediction;

  const _IncomeChart({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: 200.ms),
        ScaleEffect(begin: const Offset(0.9, 0.9)),
      ],
      child: GlowingCard(
        glowColor: AppColors.accentCyan,
        animate: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Projection',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.glassLight,
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
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec'
                          ];
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Text(
                              months[index],
                              style: AppTextStyles.caption,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: AppTextStyles.caption,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: prediction.historicalData.length.toDouble() + 1,
                  minY: 0,
                  maxY: ([
                    ...prediction.historicalData,
                    prediction.predictedAmount,
                  ].reduce((a, b) => a > b ? a : b) * 1.2),
                  lineBarsData: [
                    // Historical data
                    LineChartBarData(
                      spots: List.generate(
                        prediction.historicalData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          prediction.historicalData[index],
                        ),
                      ),
                      isCurved: true,
                      gradient: AppColors.accentGradient,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
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
                    // Prediction
                    LineChartBarData(
                      spots: [
                        FlSpot(
                          (prediction.historicalData.length - 1).toDouble(),
                          prediction.historicalData.last,
                        ),
                        FlSpot(
                          prediction.historicalData.length.toDouble(),
                          prediction.predictedAmount,
                        ),
                      ],
                      isCurved: true,
                      color: AppColors.emerald,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dashArray: [5, 5],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: AppColors.emerald,
                            strokeWidth: 2,
                            strokeColor: AppColors.primaryDark,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _LegendRow(),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendItem(label: 'Historical', color: AppColors.accentCyan),
        SizedBox(width: 20),
        _LegendItem(label: 'Predicted', color: AppColors.emerald),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: AppColors.glowingShadow(color: color, blur: 5),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _PredictionDetails extends StatelessWidget {
  final IncomePrediction prediction;

  const _PredictionDetails({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Animate(
      effects: [
        FadeEffect(delay: 400.ms),
        SlideEffect(begin: const Offset(0, 0.2)),
      ],
      child: GlowingCard(
        glowColor: AppColors.emerald,
        animate: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              'Predicted Amount',
              formatter.format(prediction.predictedAmount),
              AppColors.emerald,
            ),
            const Divider(height: 24),
            _DetailRow(
              'Change from Last Month',
              '${prediction.changePercentage.toStringAsFixed(1)}%',
              prediction.changePercentage >= 0
                  ? AppColors.emerald
                  : AppColors.error,
            ),
            const Divider(height: 24),
            _DetailRow(
              'Confidence Level',
              prediction.confidenceLevel,
              AppColors.accentCyan,
            ),
            const Divider(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Analysis', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Text(
                  prediction.reason,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(color: color),
        ),
      ],
    );
  }
}
