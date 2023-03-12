// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alligator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlligatorIndicatorConfig _$AlligatorIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    AlligatorIndicatorConfig(
      jawPeriod: json['jawPeriod'] as int? ?? 13,
      teethPeriod: json['teethPeriod'] as int? ?? 8,
      lipsPeriod: json['lipsPeriod'] as int? ?? 5,
      jawOffset: json['jawOffset'] as int? ?? 8,
      teethOffset: json['teethOffset'] as int? ?? 5,
      lipsOffset: json['lipsOffset'] as int? ?? 3,
      showLines: json['showLines'] as bool? ?? true,
      showFractal: json['showFractal'] as bool? ?? false,
    );

Map<String, dynamic> _$AlligatorIndicatorConfigToJson(
        AlligatorIndicatorConfig instance) =>
    <String, dynamic>{
      'jawOffset': instance.jawOffset,
      'jawPeriod': instance.jawPeriod,
      'teethOffset': instance.teethOffset,
      'teethPeriod': instance.teethPeriod,
      'lipsOffset': instance.lipsOffset,
      'lipsPeriod': instance.lipsPeriod,
      'showLines': instance.showLines,
      'showFractal': instance.showFractal,
    };
