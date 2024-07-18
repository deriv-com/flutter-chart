// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'williams_r_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WilliamsRIndicatorConfig _$WilliamsRIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    WilliamsRIndicatorConfig(
      period: json['period'] as int? ?? 14,
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      zeroHorizontalLinesStyle: json['zeroHorizontalLinesStyle'] == null
          ? const LineStyle(color: Colors.red)
          : LineStyle.fromJson(
              json['zeroHorizontalLinesStyle'] as Map<String, dynamic>),
      showZones: json['showZones'] as bool? ?? true,
      oscillatorLimits: json['oscillatorLimits'] == null
          ? const OscillatorLinesConfig(
              oversoldValue: -80, overboughtValue: -20)
          : OscillatorLinesConfig.fromJson(
              json['oscillatorLimits'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$WilliamsRIndicatorConfigToJson(
        WilliamsRIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'lineStyle': instance.lineStyle,
      'zeroHorizontalLinesStyle': instance.zeroHorizontalLinesStyle,
      'oscillatorLimits': instance.oscillatorLimits,
      'showZones': instance.showZones,
    };
