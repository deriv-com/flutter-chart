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
      pipSize: json['pipSize'] as int? ?? 4,
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
      number: json['number'] as int? ?? 0,
    );

Map<String, dynamic> _$ROCIndicatorConfigToJson(ROCIndicatorConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'pipSize': instance.pipSize,
      'period': instance.period,
      'fieldType': instance.fieldType,
      'lineStyle': instance.lineStyle,
    };
