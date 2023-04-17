// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aroon_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AroonIndicatorConfig _$AroonIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    AroonIndicatorConfig(
      period: json['period'] as int? ?? 14,
      upLineStyle: json['upLineStyle'] == null
          ? const LineStyle(color: Colors.green)
          : LineStyle.fromJson(json['upLineStyle'] as Map<String, dynamic>),
      downLineStyle: json['downLineStyle'] == null
          ? const LineStyle(color: Colors.red)
          : LineStyle.fromJson(json['downLineStyle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AroonIndicatorConfigToJson(
        AroonIndicatorConfig instance) =>
    <String, dynamic>{
      'period': instance.period,
      'upLineStyle': instance.upLineStyle,
      'downLineStyle': instance.downLineStyle,
    };
