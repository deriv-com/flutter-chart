// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continuous_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContinuousDrawingToolConfig _$ContinuousDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    ContinuousDrawingToolConfig(
      configId: json['configId'] as String?,
      drawingData: json['drawingData'] == null
          ? null
          : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
      edgePoints: (json['edgePoints'] as List<dynamic>?)
              ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EdgePoint>[],
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      pattern: $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
          DrawingPatterns.solid,
      number: (json['number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ContinuousDrawingToolConfigToJson(
        ContinuousDrawingToolConfig instance) =>
    <String, dynamic>{
      'number': instance.number,
      'drawingData': instance.drawingData,
      'edgePoints': instance.edgePoints,
      'configId': instance.configId,
      'lineStyle': instance.lineStyle,
      'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
    };

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
