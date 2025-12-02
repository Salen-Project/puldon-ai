// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  note: json['note'] as String?,
  timestamp: json['timestamp'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'amount': instance.amount,
      'category': instance.category,
      'note': instance.note,
      'timestamp': instance.timestamp,
      'created_at': instance.createdAt,
    };

AddExpenseRequest _$AddExpenseRequestFromJson(Map<String, dynamic> json) =>
    AddExpenseRequest(
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      note: json['note'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$AddExpenseRequestToJson(AddExpenseRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'category': instance.category,
      'note': instance.note,
      'timestamp': instance.timestamp,
    };

AddExpenseResponse _$AddExpenseResponseFromJson(Map<String, dynamic> json) =>
    AddExpenseResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      expense: ExpenseModel.fromJson(json['expense'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddExpenseResponseToJson(AddExpenseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'expense': instance.expense,
    };

SpendingSummaryModel _$SpendingSummaryModelFromJson(
  Map<String, dynamic> json,
) => SpendingSummaryModel(
  userId: json['user_id'] as String,
  period: json['period'] as String,
  total: (json['total'] as num).toDouble(),
  byCategory: (json['by_category'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  transactionCount: (json['transaction_count'] as num).toInt(),
);

Map<String, dynamic> _$SpendingSummaryModelToJson(
  SpendingSummaryModel instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'period': instance.period,
  'total': instance.total,
  'by_category': instance.byCategory,
  'transaction_count': instance.transactionCount,
};
