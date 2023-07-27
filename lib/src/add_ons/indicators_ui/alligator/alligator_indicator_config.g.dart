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
      jawLineStyle: json['jawLineStyle'] == null
          ? const LineStyle(color: Colors.blue)
          : LineStyle.fromJson(json['jawLineStyle'] as Map<String, dynamic>),
      teethLineStyle: json['teethLineStyle'] == null
          ? const LineStyle(color: Colors.red)
          : LineStyle.fromJson(json['teethLineStyle'] as Map<String, dynamic>),
      lipsLineStyle: json['lipsLineStyle'] == null
          ? const LineStyle(color: Colors.green)
          : LineStyle.fromJson(json['lipsLineStyle'] as Map<String, dynamic>),
      showLastIndicator: json['showLastIndicator'] as bool? ?? false,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$AlligatorIndicatorConfigToJson(
        AlligatorIndicatorConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'showLastIndicator': instance.showLastIndicator,
      'jawOffset': instance.jawOffset,
      'jawPeriod': instance.jawPeriod,
      'teethOffset': instance.teethOffset,
      'teethPeriod': instance.teethPeriod,
      'lipsOffset': instance.lipsOffset,
      'lipsPeriod': instance.lipsPeriod,
      'showLines': instance.showLines,
      'showFractal': instance.showFractal,
      'jawLineStyle': instance.jawLineStyle,
      'teethLineStyle': instance.teethLineStyle,
      'lipsLineStyle': instance.lipsLineStyle,
    };
