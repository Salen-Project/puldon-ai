import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardModel {
  @JsonKey(name: 'net_worth')
  final double netWorth;
  @JsonKey(name: 'not_invested_money')
  final double notInvestedMoney;
  final List<String> insights;
  final List<SectorOverview> overview;

  DashboardModel({
    required this.netWorth,
    required this.notInvestedMoney,
    required this.insights,
    required this.overview,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);
}

@JsonSerializable()
class SectorOverview {
  final String sector;
  @JsonKey(name: 'portion_percent')
  final double portionPercent;

  SectorOverview({
    required this.sector,
    required this.portionPercent,
  });

  factory SectorOverview.fromJson(Map<String, dynamic> json) =>
      _$SectorOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$SectorOverviewToJson(this);
}
