// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rectangle_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RectangleDrawingToolConfig _$RectangleDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    RectangleDrawingToolConfig(
      fillStyle: json['fillStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.blue)
          : LineStyle.fromJson(json['fillStyle'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pattern: $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
          DrawingPatterns.solid,
    );

Map<String, dynamic> _$RectangleDrawingToolConfigToJson(
        RectangleDrawingToolConfig instance) =>
    <String, dynamic>{
      'fillStyle': instance.fillStyle,
      'lineStyle': instance.lineStyle,
      'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
    };

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
