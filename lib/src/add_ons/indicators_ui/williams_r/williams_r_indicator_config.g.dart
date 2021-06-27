// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'williams_r_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WilliamsRIndicatorConfig _$WilliamsRIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return WilliamsRIndicatorConfig(
    period: json['period'] as int,
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    zeroHorizontalLinesStyle: LineStyle.fromJson(
        json['zeroHorizontalLinesStyle'] as Map<String, dynamic>),
    showZones: json['showZones'] as bool,
    oscillatorLimits: OscillatorLinesConfig.fromJson(
        json['oscillatorLimits'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$WilliamsRIndicatorConfigToJson(
        WilliamsRIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'lineStyle': instance.lineStyle,
      'zeroHorizontalLinesStyle': instance.zeroHorizontalLinesStyle,
      'oscillatorLimits': instance.oscillatorLimits,
      'showZones': instance.showZones,
    };
