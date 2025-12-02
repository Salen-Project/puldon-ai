import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final double amount;
  final String category;
  final String? note;
  final String timestamp;
  @JsonKey(name: 'created_at')
  final String createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.note,
    required this.timestamp,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);
}

@JsonSerializable()
class AddExpenseRequest {
  final double amount;
  final String category;
  final String? note;
  final String? timestamp;

  AddExpenseRequest({
    required this.amount,
    required this.category,
    this.note,
    this.timestamp,
  });

  factory AddExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$AddExpenseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddExpenseRequestToJson(this);
}

@JsonSerializable()
class AddExpenseResponse {
  final bool success;
  final String message;
  final ExpenseModel expense;

  AddExpenseResponse({
    required this.success,
    required this.message,
    required this.expense,
  });

  factory AddExpenseResponse.fromJson(Map<String, dynamic> json) =>
      _$AddExpenseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddExpenseResponseToJson(this);
}

@JsonSerializable()
class SpendingSummaryModel {
  @JsonKey(name: 'user_id')
  final String userId;
  final String period;
  final double total;
  @JsonKey(name: 'by_category')
  final Map<String, double> byCategory;
  @JsonKey(name: 'transaction_count')
  final int transactionCount;

  SpendingSummaryModel({
    required this.userId,
    required this.period,
    required this.total,
    required this.byCategory,
    required this.transactionCount,
  });

  factory SpendingSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SpendingSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpendingSummaryModelToJson(this);
}

/// Expense categories enum
enum ExpenseCategory {
  groceries,
  dining,
  transportation,
  utilities,
  entertainment,
  healthcare,
  shopping,
  rent,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get value {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'groceries';
      case ExpenseCategory.dining:
        return 'dining';
      case ExpenseCategory.transportation:
        return 'transportation';
      case ExpenseCategory.utilities:
        return 'utilities';
      case ExpenseCategory.entertainment:
        return 'entertainment';
      case ExpenseCategory.healthcare:
        return 'healthcare';
      case ExpenseCategory.shopping:
        return 'shopping';
      case ExpenseCategory.rent:
        return 'rent';
      case ExpenseCategory.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.dining:
        return 'Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}
