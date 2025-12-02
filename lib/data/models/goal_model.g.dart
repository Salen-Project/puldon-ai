// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String?,
  description: json['description'] as String?,
  progress: (json['progress'] as num).toDouble(),
  currentContribution: (json['current_contribution'] as num).toDouble(),
  totalContribution: (json['total_contribution'] as num).toDouble(),
  daysLeft: (json['days_left'] as num?)?.toInt(),
  monthlyRecurringContribution: (json['monthly_recurring_contribution'] as num)
      .toDouble(),
  color: json['color'] as String?,
);

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'description': instance.description,
  'progress': instance.progress,
  'current_contribution': instance.currentContribution,
  'total_contribution': instance.totalContribution,
  'days_left': instance.daysLeft,
  'monthly_recurring_contribution': instance.monthlyRecurringContribution,
  'color': instance.color,
};

GoalDetailModel _$GoalDetailModelFromJson(Map<String, dynamic> json) =>
    GoalDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      currentContribution: (json['current_contribution'] as num).toDouble(),
      totalContribution: (json['total_contribution'] as num).toDouble(),
      daysLeft: (json['days_left'] as num?)?.toInt(),
      monthlyRecurringContribution:
          (json['monthly_recurring_contribution'] as num).toDouble(),
      color: json['color'] as String?,
      contributionHistory: (json['contribution_history'] as List<dynamic>)
          .map((e) => ContributionHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GoalDetailModelToJson(GoalDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'current_contribution': instance.currentContribution,
      'total_contribution': instance.totalContribution,
      'days_left': instance.daysLeft,
      'monthly_recurring_contribution': instance.monthlyRecurringContribution,
      'color': instance.color,
      'contribution_history': instance.contributionHistory,
    };

ContributionHistory _$ContributionHistoryFromJson(Map<String, dynamic> json) =>
    ContributionHistory(
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] as String,
      currencyType: json['currency_type'] as String,
    );

Map<String, dynamic> _$ContributionHistoryToJson(
  ContributionHistory instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'date': instance.date,
  'currency_type': instance.currencyType,
};

CreateGoalRequest _$CreateGoalRequestFromJson(Map<String, dynamic> json) =>
    CreateGoalRequest(
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      totalContribution: (json['total_contribution'] as num).toDouble(),
      currentContribution: (json['current_contribution'] as num?)?.toDouble(),
      deadline: json['deadline'] as String?,
      color: json['color'] as String?,
      monthlyRecurringContribution:
          (json['monthly_recurring_contribution'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CreateGoalRequestToJson(CreateGoalRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'total_contribution': instance.totalContribution,
      'current_contribution': instance.currentContribution,
      'deadline': instance.deadline,
      'color': instance.color,
      'monthly_recurring_contribution': instance.monthlyRecurringContribution,
    };

CreateGoalResponse _$CreateGoalResponseFromJson(Map<String, dynamic> json) =>
    CreateGoalResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      goal: GoalResponseData.fromJson(json['goal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateGoalResponseToJson(CreateGoalResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'goal': instance.goal,
    };

GoalResponseData _$GoalResponseDataFromJson(Map<String, dynamic> json) =>
    GoalResponseData(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      deadline: json['deadline'] as String?,
      color: json['color'] as String?,
      monthlyRecurringContribution:
          (json['monthly_recurring_contribution'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$GoalResponseDataToJson(GoalResponseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'target_amount': instance.targetAmount,
      'current_amount': instance.currentAmount,
      'deadline': instance.deadline,
      'color': instance.color,
      'monthly_recurring_contribution': instance.monthlyRecurringContribution,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

UpdateGoalRequest _$UpdateGoalRequestFromJson(Map<String, dynamic> json) =>
    UpdateGoalRequest(
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      totalContribution: (json['total_contribution'] as num?)?.toDouble(),
      currentContribution: (json['current_contribution'] as num?)?.toDouble(),
      deadline: json['deadline'] as String?,
      color: json['color'] as String?,
      monthlyRecurringContribution:
          (json['monthly_recurring_contribution'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UpdateGoalRequestToJson(UpdateGoalRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'total_contribution': instance.totalContribution,
      'current_contribution': instance.currentContribution,
      'deadline': instance.deadline,
      'color': instance.color,
      'monthly_recurring_contribution': instance.monthlyRecurringContribution,
    };

UpdateGoalResponse _$UpdateGoalResponseFromJson(Map<String, dynamic> json) =>
    UpdateGoalResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      goal: GoalResponseData.fromJson(json['goal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateGoalResponseToJson(UpdateGoalResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'goal': instance.goal,
    };

DeleteGoalResponse _$DeleteGoalResponseFromJson(Map<String, dynamic> json) =>
    DeleteGoalResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$DeleteGoalResponseToJson(DeleteGoalResponse instance) =>
    <String, dynamic>{'success': instance.success, 'message': instance.message};
