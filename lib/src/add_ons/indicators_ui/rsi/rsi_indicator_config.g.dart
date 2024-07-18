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
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$RSIIndicatorConfigToJson(RSIIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'lineStyle': instance.lineStyle,
      'fieldType': instance.fieldType,
      'pinLabels': instance.pinLabels,
      'oscillatorLinesConfig': instance.oscillatorLinesConfig,
      'showZones': instance.showZones,
    };
