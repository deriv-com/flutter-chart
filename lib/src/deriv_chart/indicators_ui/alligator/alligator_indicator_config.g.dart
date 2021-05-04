// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alligator_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlligatorIndicatorConfig _$AlligatorIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return AlligatorIndicatorConfig(
    jawPeriod: json['jawPeriod'] as int,
    teethPeriod: json['teethPeriod'] as int,
    lipsPeriod: json['lipsPeriod'] as int,
    jawOffset: json['jawOffset'] as int,
    teethOffset: json['teethOffset'] as int,
    lipsOffset: json['lipsOffset'] as int,
    showLines: json['showLines'] as bool,
    showFractal: json['showFractal'] as bool,
  );
}

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
