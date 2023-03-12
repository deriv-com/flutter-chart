// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GatorIndicatorConfig _$GatorIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    GatorIndicatorConfig(
      jawPeriod: json['jawPeriod'] as int? ?? 13,
      teethPeriod: json['teethPeriod'] as int? ?? 8,
      lipsPeriod: json['lipsPeriod'] as int? ?? 5,
      jawOffset: json['jawOffset'] as int? ?? 8,
      teethOffset: json['teethOffset'] as int? ?? 5,
      lipsOffset: json['lipsOffset'] as int? ?? 3,
    );

Map<String, dynamic> _$GatorIndicatorConfigToJson(
        GatorIndicatorConfig instance) =>
    <String, dynamic>{
      'jawOffset': instance.jawOffset,
      'jawPeriod': instance.jawPeriod,
      'teethOffset': instance.teethOffset,
      'teethPeriod': instance.teethPeriod,
      'lipsOffset': instance.lipsOffset,
      'lipsPeriod': instance.lipsPeriod,
    };
