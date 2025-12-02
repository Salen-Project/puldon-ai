// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      netWorth: (json['net_worth'] as num).toDouble(),
      notInvestedMoney: (json['not_invested_money'] as num).toDouble(),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      overview: (json['overview'] as List<dynamic>)
          .map((e) => SectorOverview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'net_worth': instance.netWorth,
      'not_invested_money': instance.notInvestedMoney,
      'insights': instance.insights,
      'overview': instance.overview,
    };

SectorOverview _$SectorOverviewFromJson(Map<String, dynamic> json) =>
    SectorOverview(
      sector: json['sector'] as String,
      portionPercent: (json['portion_percent'] as num).toDouble(),
    );

Map<String, dynamic> _$SectorOverviewToJson(SectorOverview instance) =>
    <String, dynamic>{
      'sector': instance.sector,
      'portion_percent': instance.portionPercent,
    };
