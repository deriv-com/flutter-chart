// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RSIIndicatorConfig _$RSIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return RSIIndicatorConfig(
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    overBoughtPrice: (json['overBoughtPrice'] as num).toDouble(),
    overSoldPrice: (json['overSoldPrice'] as num).toDouble(),
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    mainHorizontalLinesStyle: LineStyle.fromJson(
        json['mainHorizontalLinesStyle'] as Map<String, dynamic>),
    pinLabels: json['pinLabels'] as bool,
  );
}

Map<String, dynamic> _$RSIIndicatorConfigToJson(RSIIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'overBoughtPrice': instance.overBoughtPrice,
      'overSoldPrice': instance.overSoldPrice,
      'lineStyle': instance.lineStyle,
      'mainHorizontalLinesStyle': instance.mainHorizontalLinesStyle,
      'fieldType': instance.fieldType,
    };
