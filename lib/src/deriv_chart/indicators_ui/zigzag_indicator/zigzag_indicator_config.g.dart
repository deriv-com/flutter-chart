// GENERATED CODE - DO NOT MODIFY BY HAND

// @dart=2.9

part of 'zigzag_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZigZagIndicatorConfig _$ZigZagIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return ZigZagIndicatorConfig(
    distance: (json['distance'] as num)?.toDouble(),
    lineStyle: json['lineStyle'] == null
        ? null
        : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ZigZagIndicatorConfigToJson(
        ZigZagIndicatorConfig instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'lineStyle': instance.lineStyle,
    };
