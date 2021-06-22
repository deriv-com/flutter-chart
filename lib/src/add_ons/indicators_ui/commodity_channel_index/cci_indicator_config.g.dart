// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cci_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CCIIndicatorConfig _$CCIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return CCIIndicatorConfig(
    period: json['period'] as int,
    overboughtValue: (json['overboughtValue'] as num)?.toDouble(),
    oversoldValue: (json['oversoldValue'] as num)?.toDouble(),
    lineStyle: json['lineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CCIIndicatorConfigToJson(CCIIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'overboughtValue': instance.overboughtValue,
      'oversoldValue': instance.oversoldValue,
      'lineStyle': instance.lineStyle,
    };
