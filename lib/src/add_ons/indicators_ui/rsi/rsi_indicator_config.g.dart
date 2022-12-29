// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RSIIndicatorConfig _$RSIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return RSIIndicatorConfig(
    id: json['id'] as String?,
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    oscillatorLinesConfig: OscillatorLinesConfig.fromJson(
        json['oscillatorLinesConfig'] as Map<String, dynamic>),
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    pinLabels: json['pinLabels'] as bool,
    showZones: json['showZones'] as bool,
  );
}

Map<String, dynamic> _$RSIIndicatorConfigToJson(RSIIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period': instance.period,
      'lineStyle': instance.lineStyle,
      'fieldType': instance.fieldType,
      'pinLabels': instance.pinLabels,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'showZones': instance.showZones,
    };
