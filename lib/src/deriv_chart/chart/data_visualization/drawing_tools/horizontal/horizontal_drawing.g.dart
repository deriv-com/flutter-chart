// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horizontal_drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HorizontalDrawing _$HorizontalDrawingFromJson(Map<String, dynamic> json) =>
    HorizontalDrawing(
      drawingPart: $enumDecode(_$DrawingPartsEnumMap, json['drawingPart']),
      chartConfig: json['chartConfig'] == null
          ? null
          : ChartConfig.fromJson(json['chartConfig'] as Map<String, dynamic>),
      edgePoint: EdgePoint.fromJson(json['edgePoint'] as Map<String, dynamic>),
    )..startPoint = json['startPoint'] == null
        ? null
        : Point.fromJson(json['startPoint'] as Map<String, dynamic>);

Map<String, dynamic> _$HorizontalDrawingToJson(HorizontalDrawing instance) =>
    <String, dynamic>{
      'chartConfig': instance.chartConfig,
      'drawingPart': _$DrawingPartsEnumMap[instance.drawingPart]!,
      'edgePoint': instance.edgePoint,
      'startPoint': instance.startPoint,
    };

const _$DrawingPartsEnumMap = {
  DrawingParts.marker: 'marker',
  DrawingParts.line: 'line',
  DrawingParts.rectangle: 'rectangle',
};
