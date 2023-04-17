// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roc_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ROCIndicatorConfig _$ROCIndicatorConfigFromJson(Map<String, dynamic> json) =>
    ROCIndicatorConfig(
      period: json['period'] as int? ?? 14,
      fieldType: json['fieldType'] as String? ?? 'close',
      lineStyle: json['lineStyle'] == null
          ? null
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ROCIndicatorConfigToJson(ROCIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'fieldType': instance.fieldType,
      'lineStyle': instance.lineStyle,
    };
