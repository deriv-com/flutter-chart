// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendDrawingToolConfig _$TrendDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    TrendDrawingToolConfig(
      fillStyle: json['fillStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.blue)
          : LineStyle.fromJson(json['fillStyle'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pattern: json['pattern'] as String? ?? 'solid',
    );

Map<String, dynamic> _$TrendDrawingToolConfigToJson(
        TrendDrawingToolConfig instance) =>
    <String, dynamic>{
      'fillStyle': instance.fillStyle,
      'lineStyle': instance.lineStyle,
      'pattern': instance.pattern,
    };
