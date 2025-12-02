import 'package:json_annotation/json_annotation.dart';

part 'debt_model.g.dart';

@JsonSerializable()
class DebtModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String creditor;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'remaining_amount')
  final double remainingAmount;
  @JsonKey(name: 'monthly_payment')
  final double monthlyPayment;
  @JsonKey(name: 'due_date')
  final int dueDate;
  @JsonKey(name: 'created_at')
  final String createdAt;

  DebtModel({
    required this.id,
    required this.userId,
    required this.creditor,
    required this.totalAmount,
    required this.remainingAmount,
    required this.monthlyPayment,
    required this.dueDate,
    required this.createdAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) =>
      _$DebtModelFromJson(json);

  Map<String, dynamic> toJson() => _$DebtModelToJson(this);
}

@JsonSerializable()
class AddDebtRequest {
  final String creditor;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'remaining_amount')
  final double remainingAmount;
  @JsonKey(name: 'monthly_payment')
  final double monthlyPayment;
  @JsonKey(name: 'due_date')
  final int dueDate;

  AddDebtRequest({
    required this.creditor,
    required this.totalAmount,
    required this.remainingAmount,
    required this.monthlyPayment,
    required this.dueDate,
  });

  factory AddDebtRequest.fromJson(Map<String, dynamic> json) =>
      _$AddDebtRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddDebtRequestToJson(this);
}

@JsonSerializable()
class AddDebtResponse {
  final bool success;
  final String message;
  final DebtModel debt;

  AddDebtResponse({
    required this.success,
    required this.message,
    required this.debt,
  });

  factory AddDebtResponse.fromJson(Map<String, dynamic> json) =>
      _$AddDebtResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddDebtResponseToJson(this);
}

@JsonSerializable()
class DebtSummaryModel {
  @JsonKey(name: 'user_id')
  final String userId;
  final String month;
  @JsonKey(name: 'total_debt')
  final double totalDebt;
  @JsonKey(name: 'monthly_obligations')
  final double monthlyObligations;
  final List<DebtModel> debts;

  DebtSummaryModel({
    required this.userId,
    required this.month,
    required this.totalDebt,
    required this.monthlyObligations,
    required this.debts,
  });

  factory DebtSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DebtSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DebtSummaryModelToJson(this);
}
