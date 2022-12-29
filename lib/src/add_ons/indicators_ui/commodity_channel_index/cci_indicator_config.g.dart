// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cci_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CCIIndicatorConfig _$CCIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return CCIIndicatorConfig(
    id: json['id'] as String?,
    period: json['period'] as int,
    oscillatorLinesConfig: OscillatorLinesConfig.fromJson(
        json['oscillatorLinesConfig'] as Map<String, dynamic>),
    showZones: json['showZones'] as bool,
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CCIIndicatorConfigToJson(CCIIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period': instance.period,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'lineStyle': instance.lineStyle,
      'showZones': instance.showZones,
    };
