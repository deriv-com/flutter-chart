// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainbow_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RainbowIndicatorConfig _$RainbowIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return RainbowIndicatorConfig(
    period: json['period'] as int,
    fieldType: json['fieldType'] as String,
    bandsCount: json['bandsCount'] as int,
  );
}

Map<String, dynamic> _$RainbowIndicatorConfigToJson(
        RainbowIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'fieldType': instance.fieldType,
      'bandsCount': instance.bandsCount,
    };
