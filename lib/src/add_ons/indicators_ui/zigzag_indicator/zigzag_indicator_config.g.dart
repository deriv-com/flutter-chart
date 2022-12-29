// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zigzag_indicator_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZigZagIndicatorConfig _$ZigZagIndicatorConfigFromJson(
    Map<String, dynamic> json) {
  return ZigZagIndicatorConfig(
    id: json['id'] as String?,
    distance: (json['distance'] as num).toDouble(),
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ZigZagIndicatorConfigToJson(
        ZigZagIndicatorConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distance': instance.distance,
      'lineStyle': instance.lineStyle,
    };
