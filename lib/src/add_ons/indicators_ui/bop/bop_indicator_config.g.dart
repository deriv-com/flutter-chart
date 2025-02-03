// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bop_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BOPIndicatorConfig _$BOPIndicatorConfigFromJson(Map<String, dynamic> json) =>
    BOPIndicatorConfig(
      period: (json['period'] as num?)?.toInt() ?? 14,
      oscillatorLinesConfig: json['oscillatorLinesConfig'] == null
          ? const OscillatorLinesConfig(
              overboughtValue: 0.8, oversoldValue: -0.8)
          : OscillatorLinesConfig.fromJson(
              json['oscillatorLinesConfig'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: Colors.blue)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pinLabels: json['pinLabels'] as bool? ?? false,
      showZones: json['showZones'] as bool? ?? true,
      pipSize: (json['pipSize'] as num?)?.toInt() ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: (json['number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BOPIndicatorConfigToJson(BOPIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'lineStyle': instance.lineStyle,
      'pinLabels': instance.pinLabels,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'showZones': instance.showZones,
      'title': instance.title,
    };
