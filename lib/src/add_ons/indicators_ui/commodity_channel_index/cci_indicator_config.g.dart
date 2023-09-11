// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cci_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CCIIndicatorConfig _$CCIIndicatorConfigFromJson(Map<String, dynamic> json) =>
    CCIIndicatorConfig(
      period: json['period'] as int? ?? 20,
      oscillatorLinesConfig: json['oscillatorLinesConfig'] == null
          ? const OscillatorLinesConfig(
              overboughtValue: 100, oversoldValue: -100)
          : OscillatorLinesConfig.fromJson(
              json['oscillatorLinesConfig'] as Map<String, dynamic>),
      showZones: json['showZones'] as bool? ?? true,
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$CCIIndicatorConfigToJson(CCIIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'lineStyle': instance.lineStyle,
      'showZones': instance.showZones,
    };
