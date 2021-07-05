// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cci_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CCIIndicatorConfig _$CCIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return CCIIndicatorConfig(
    period: json['period'] as int,
    oscillatorLinesConfig: OscillatorLinesConfig.fromJson(
        json['oscillatorLinesConfig'] as Map<String, dynamic>),
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CCIIndicatorConfigToJson(CCIIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'lineStyle': instance.lineStyle,
    };
