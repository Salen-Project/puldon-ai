import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart';

@JsonSerializable()
class GoalModel {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final double progress;
  @JsonKey(name: 'current_contribution')
  final double currentContribution;
  @JsonKey(name: 'total_contribution')
  final double totalContribution;
  @JsonKey(name: 'days_left')
  final int? daysLeft;
  @JsonKey(name: 'monthly_recurring_contribution')
  final double monthlyRecurringContribution;
  final String? color;

  GoalModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.progress,
    required this.currentContribution,
    required this.totalContribution,
    this.daysLeft,
    required this.monthlyRecurringContribution,
    this.color,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalModelToJson(this);
}

@JsonSerializable()
class GoalDetailModel {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  @JsonKey(name: 'current_contribution')
  final double currentContribution;
  @JsonKey(name: 'total_contribution')
  final double totalContribution;
  @JsonKey(name: 'days_left')
  final int? daysLeft;
  @JsonKey(name: 'monthly_recurring_contribution')
  final double monthlyRecurringContribution;
  final String? color;
  @JsonKey(name: 'contribution_history')
  final List<ContributionHistory> contributionHistory;

  GoalDetailModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.currentContribution,
    required this.totalContribution,
    this.daysLeft,
    required this.monthlyRecurringContribution,
    this.color,
    required this.contributionHistory,
  });

  factory GoalDetailModel.fromJson(Map<String, dynamic> json) =>
      _$GoalDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalDetailModelToJson(this);
}

@JsonSerializable()
class ContributionHistory {
  final double amount;
  final String date;
  @JsonKey(name: 'currency_type')
  final String currencyType;

  ContributionHistory({
    required this.amount,
    required this.date,
    required this.currencyType,
  });

  factory ContributionHistory.fromJson(Map<String, dynamic> json) =>
      _$ContributionHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionHistoryToJson(this);
}

@JsonSerializable()
class CreateGoalRequest {
  final String name;
  final String? icon;
  final String? description;
  @JsonKey(name: 'total_contribution')
  final double totalContribution;
  @JsonKey(name: 'current_contribution')
  final double? currentContribution;
  final String? deadline;
  final String? color;
  @JsonKey(name: 'monthly_recurring_contribution')
  final double? monthlyRecurringContribution;

  CreateGoalRequest({
    required this.name,
    this.icon,
    this.description,
    required this.totalContribution,
    this.currentContribution,
    this.deadline,
    this.color,
    this.monthlyRecurringContribution,
  });

  factory CreateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGoalRequestToJson(this);
}

@JsonSerializable()
class CreateGoalResponse {
  final bool success;
  final String message;
  final GoalResponseData goal;

  CreateGoalResponse({
    required this.success,
    required this.message,
    required this.goal,
  });

  factory CreateGoalResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateGoalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGoalResponseToJson(this);
}

@JsonSerializable()
class GoalResponseData {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String? icon;
  final String? description;
  @JsonKey(name: 'target_amount')
  final double targetAmount;
  @JsonKey(name: 'current_amount')
  final double currentAmount;
  final String? deadline;
  final String? color;
  @JsonKey(name: 'monthly_recurring_contribution')
  final double monthlyRecurringContribution;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  GoalResponseData({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.color,
    required this.monthlyRecurringContribution,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory GoalResponseData.fromJson(Map<String, dynamic> json) =>
      _$GoalResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$GoalResponseDataToJson(this);
}

@JsonSerializable()
class UpdateGoalRequest {
  final String? name;
  final String? icon;
  final String? description;
  @JsonKey(name: 'total_contribution')
  final double? totalContribution;
  @JsonKey(name: 'current_contribution')
  final double? currentContribution;
  final String? deadline;
  final String? color;
  @JsonKey(name: 'monthly_recurring_contribution')
  final double? monthlyRecurringContribution;

  UpdateGoalRequest({
    this.name,
    this.icon,
    this.description,
    this.totalContribution,
    this.currentContribution,
    this.deadline,
    this.color,
    this.monthlyRecurringContribution,
  });

  factory UpdateGoalRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateGoalRequestToJson(this);
}

@JsonSerializable()
class UpdateGoalResponse {
  final bool success;
  final String message;
  final GoalResponseData goal;

  UpdateGoalResponse({
    required this.success,
    required this.message,
    required this.goal,
  });

  factory UpdateGoalResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateGoalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateGoalResponseToJson(this);
}

@JsonSerializable()
class DeleteGoalResponse {
  final bool success;
  final String message;

  DeleteGoalResponse({
    required this.success,
    required this.message,
  });

  factory DeleteGoalResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteGoalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteGoalResponseToJson(this);
}
