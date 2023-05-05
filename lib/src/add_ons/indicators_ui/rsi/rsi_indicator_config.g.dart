// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RSIIndicatorConfig _$RSIIndicatorConfigFromJson(Map<String, dynamic> json) =>
    RSIIndicatorConfig(
      period: json['period'] as int? ?? 14,
      fieldType: json['fieldType'] as String? ?? 'close',
      oscillatorLinesConfig: json['oscillatorLinesConfig'] == null
          ? const OscillatorLinesConfig(overboughtValue: 80, oversoldValue: 20)
          : OscillatorLinesConfig.fromJson(
              json['oscillatorLinesConfig'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pinLabels: json['pinLabels'] as bool? ?? false,
      showZones: json['showZones'] as bool? ?? true,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$RSIIndicatorConfigToJson(RSIIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'period': instance.period,
      'lineStyle': instance.lineStyle,
      'fieldType': instance.fieldType,
      'pinLabels': instance.pinLabels,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'showZones': instance.showZones,
    };
