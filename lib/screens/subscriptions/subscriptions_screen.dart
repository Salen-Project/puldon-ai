import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/financial_data_provider.dart';
import '../../widgets/cards/glowing_card.dart';
import '../../models/subscription.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // Add subscription dialog
            },
          ),
        ],
      ),
      body: Consumer<FinancialDataProvider>(
        builder: (context, financialData, child) {
          final subscriptions = financialData.subscriptions;
          final totalMonthly = financialData.monthlySubscriptionsCost;

          return Column(
            children: [
              // Total Cost Header
              _buildTotalCostCard(totalMonthly),

              // Subscriptions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    return _buildSubscriptionCard(
                      context,
                      subscriptions[index],
                      index,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalCostCard(double totalMonthly) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.all(20),
      child: GlowingCard(
        glowColor: AppColors.purple,
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Cost',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatter.format(totalMonthly),
                  style: AppTextStyles.numberDisplay.copyWith(fontSize: 36),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.glowingShadow(
                  color: AppColors.purple,
                  blur: 15,
                ),
              ),
              child: const Icon(
                Icons.subscriptions_outlined,
                color: AppColors.purple,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSubscriptionCard(
      BuildContext context, Subscription subscription, int index) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlowingCard(
        glowColor: subscription.isActive
            ? subscription.brandColor
            : AppColors.textTertiary,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: subscription.brandColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                subscription.icon,
                color: subscription.brandColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subscription.name, style: AppTextStyles.h4),
                  const SizedBox(height: 4),
                  Text(
                    '${formatter.format(subscription.amount)} / ${_getBillingCycleText(subscription.billingCycle)}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Next: ${subscription.daysUntilNextBilling} days',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Monthly cost
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(subscription.monthlyAmount),
                  style: AppTextStyles.h4.copyWith(
                    color: subscription.brandColor,
                  ),
                ),
                Text(
                  '/month',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn()
        .slideX(begin: -0.2);
  }

  String _getBillingCycleText(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 'month';
      case BillingCycle.yearly:
        return 'year';
      case BillingCycle.weekly:
        return 'week';
    }
  }
}
