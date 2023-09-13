// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rectangle_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RectangleDrawingToolConfig _$RectangleDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    RectangleDrawingToolConfig(
      configId: json['configId'] as String?,
      drawingData: json['drawingData'] == null
          ? null
          : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
      edgePoints: (json['edgePoints'] as List<dynamic>?)
              ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EdgePoint>[],
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
      'drawingData': instance.drawingData,
      'edgePoints': instance.edgePoints,
      'configId': instance.configId,
      'lineStyle': instance.lineStyle,
      'fillStyle': instance.fillStyle,
      'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
    };

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
