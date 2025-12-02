// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtModel _$DebtModelFromJson(Map<String, dynamic> json) => DebtModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  creditor: json['creditor'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  remainingAmount: (json['remaining_amount'] as num).toDouble(),
  monthlyPayment: (json['monthly_payment'] as num).toDouble(),
  dueDate: (json['due_date'] as num).toInt(),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$DebtModelToJson(DebtModel instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'creditor': instance.creditor,
  'total_amount': instance.totalAmount,
  'remaining_amount': instance.remainingAmount,
  'monthly_payment': instance.monthlyPayment,
  'due_date': instance.dueDate,
  'created_at': instance.createdAt,
};

AddDebtRequest _$AddDebtRequestFromJson(Map<String, dynamic> json) =>
    AddDebtRequest(
      creditor: json['creditor'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      monthlyPayment: (json['monthly_payment'] as num).toDouble(),
      dueDate: (json['due_date'] as num).toInt(),
    );

Map<String, dynamic> _$AddDebtRequestToJson(AddDebtRequest instance) =>
    <String, dynamic>{
      'creditor': instance.creditor,
      'total_amount': instance.totalAmount,
      'remaining_amount': instance.remainingAmount,
      'monthly_payment': instance.monthlyPayment,
      'due_date': instance.dueDate,
    };

AddDebtResponse _$AddDebtResponseFromJson(Map<String, dynamic> json) =>
    AddDebtResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      debt: DebtModel.fromJson(json['debt'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddDebtResponseToJson(AddDebtResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'debt': instance.debt,
    };

DebtSummaryModel _$DebtSummaryModelFromJson(Map<String, dynamic> json) =>
    DebtSummaryModel(
      userId: json['user_id'] as String,
      month: json['month'] as String,
      totalDebt: (json['total_debt'] as num).toDouble(),
      monthlyObligations: (json['monthly_obligations'] as num).toDouble(),
      debts: (json['debts'] as List<dynamic>)
          .map((e) => DebtModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DebtSummaryModelToJson(DebtSummaryModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'month': instance.month,
      'total_debt': instance.totalDebt,
      'monthly_obligations': instance.monthlyObligations,
      'debts': instance.debts,
    };
