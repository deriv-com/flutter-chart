// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zigzag_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZigZagIndicatorConfig _$ZigZagIndicatorConfigFromJson(
        Map<String, dynamic> json) =>
    ZigZagIndicatorConfig(
      distance: (json['distance'] as num?)?.toDouble() ?? 10,
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.blue)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ZigZagIndicatorConfigToJson(
        ZigZagIndicatorConfig instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'lineStyle': instance.lineStyle,
    };
