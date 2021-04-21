// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RSIIndicatorConfig _$RSIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return RSIIndicatorConfig(
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    overBoughtPrice: (json['overBoughtPrice'] as num)?.toDouble(),
    overSoldPrice: (json['overSoldPrice'] as num)?.toDouble(),
    lineStyle: json['lineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    zeroHorizontalLineStyle: json['zeroHorizontalLineStyle'] == null
        ? null
        : LineStyle.fromJson(
            json['zeroHorizontalLineStyle'] as Map<String, dynamic>),
    topHorizontalLineStyle: json['topHorizontalLineStyle'] == null
        ? null
        : LineStyle.fromJson(
            json['topHorizontalLineStyle'] as Map<String, dynamic>),
    bottomHorizontalLinesStyle: json['bottomHorizontalLinesStyle'] == null
        ? null
        : LineStyle.fromJson(
            json['bottomHorizontalLinesStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RSIIndicatorConfigToJson(RSIIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'lineStyle': instance.lineStyle,
      'zeroHorizontalLineStyle': instance.zeroHorizontalLineStyle,
      'topHorizontalLineStyle': instance.topHorizontalLineStyle,
      'bottomHorizontalLinesStyle': instance.bottomHorizontalLinesStyle,
      'fieldType': instance.fieldType,
    };
