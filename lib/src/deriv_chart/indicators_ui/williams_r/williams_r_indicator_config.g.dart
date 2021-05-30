// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'williams_r_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WilliamsRIndicatorConfig _$WilliamsRIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return WilliamsRIndicatorConfig(
    period: json['period'] as int,
    overBoughtPrice: (json['overBoughtPrice'] as num)?.toDouble(),
    overSoldPrice: (json['overSoldPrice'] as num)?.toDouble(),
    lineStyle: json['lineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    zeroHorizontalLinesStyle: json['zeroHorizontalLinesStyle'] == null
        ? null
        : LineStyle.fromJson(
            json['zeroHorizontalLinesStyle'] as Map<String, dynamic>),
    mainHorizontalLinesStyle: json['mainHorizontalLinesStyle'] == null
        ? null
        : LineStyle.fromJson(
            json['mainHorizontalLinesStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$WilliamsRIndicatorConfigToJson(
        WilliamsRIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'lineStyle': instance.lineStyle,
      'zeroHorizontalLinesStyle': instance.zeroHorizontalLinesStyle,
      'mainHorizontalLinesStyle': instance.mainHorizontalLinesStyle,
    };
