// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roc_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ROCIndicatorConfig _$ROCIndicatorConfigFromJson(Map<String, dynamic> json) =>
    ROCIndicatorConfig(
      period: json['period'] as int? ?? 14,
      fieldType: json['fieldType'] as String? ?? 'close',
    );

Map<String, dynamic> _$ROCIndicatorConfigToJson(ROCIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'fieldType': instance.fieldType,
    };
