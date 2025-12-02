import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

enum BillingCycle { monthly, yearly, weekly }

class Subscription {
  final String id;
  final String name;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final String? description;
  final Color brandColor;
  final IconData icon;
  final bool isActive;

  Subscription({
    String? id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextBillingDate,
    this.description,
    required this.brandColor,
    required this.icon,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  double get monthlyAmount {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return amount;
      case BillingCycle.yearly:
        return amount / 12;
      case BillingCycle.weekly:
        return amount * 4;
    }
  }

  double get yearlyAmount {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return amount * 12;
      case BillingCycle.yearly:
        return amount;
      case BillingCycle.weekly:
        return amount * 52;
    }
  }

  int get daysUntilNextBilling =>
      nextBillingDate.difference(DateTime.now()).inDays;

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    BillingCycle? billingCycle,
    DateTime? nextBillingDate,
    String? description,
    Color? brandColor,
    IconData? icon,
    bool? isActive,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      description: description ?? this.description,
      brandColor: brandColor ?? this.brandColor,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}
