// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roc_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ROCIndicatorConfig _$ROCIndicatorConfigFromJson(Map<String, dynamic> json) {
  return ROCIndicatorConfig(
    id: json['id'] as String?,
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
  );
}

Map<String, dynamic> _$ROCIndicatorConfigToJson(ROCIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period': instance.period,
      'fieldType': instance.fieldType,
    };
