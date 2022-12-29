// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GatorIndicatorConfig _$GatorIndicatorConfigFromJson(Map<String, dynamic> json) {
  return GatorIndicatorConfig(
    id: json['id'] as String?,
    jawPeriod: json['jawPeriod'] as int,
    teethPeriod: json['teethPeriod'] as int,
    lipsPeriod: json['lipsPeriod'] as int,
    jawOffset: json['jawOffset'] as int,
    teethOffset: json['teethOffset'] as int,
    lipsOffset: json['lipsOffset'] as int,
  );
}

Map<String, dynamic> _$GatorIndicatorConfigToJson(
        GatorIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jawOffset': instance.jawOffset,
      'jawPeriod': instance.jawPeriod,
      'teethOffset': instance.teethOffset,
      'teethPeriod': instance.teethPeriod,
      'lipsOffset': instance.lipsOffset,
      'lipsPeriod': instance.lipsPeriod,
    };
