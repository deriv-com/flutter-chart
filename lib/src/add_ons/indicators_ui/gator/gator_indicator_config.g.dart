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
      barStyle: json['barStyle'] == null
          ? const BarStyle()
          : BarStyle.fromJson(json['barStyle'] as Map<String, dynamic>),
      pipSize: json['pipSize'] as int? ?? 4,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$GatorIndicatorConfigToJson(
        GatorIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pipSize': instance.pipSize,
      'jawOffset': instance.jawOffset,
      'jawPeriod': instance.jawPeriod,
      'teethOffset': instance.teethOffset,
      'teethPeriod': instance.teethPeriod,
      'lipsOffset': instance.lipsOffset,
      'lipsPeriod': instance.lipsPeriod,
      'barStyle': instance.barStyle,
    };
