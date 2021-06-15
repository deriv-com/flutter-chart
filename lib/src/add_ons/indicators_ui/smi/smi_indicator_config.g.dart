// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smi_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SMIIndicatorConfig _$SMIIndicatorConfigFromJson(Map<String, dynamic> json) {
  return SMIIndicatorConfig(
    period: json['period'] as int,
    smoothingPeriod: json['smoothingPeriod'] as int,
    doubleSmoothingPeriod: json['doubleSmoothingPeriod'] as int,
  );
}

Map<String, dynamic> _$SMIIndicatorConfigToJson(SMIIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'smoothingPeriod': instance.smoothingPeriod,
      'doubleSmoothingPeriod': instance.doubleSmoothingPeriod,
    };
