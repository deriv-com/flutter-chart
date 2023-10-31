// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continuous_line_drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContinuousLineDrawing _$ContinuousLineDrawingFromJson(
        Map<String, dynamic> json) =>
    ContinuousLineDrawing(
      drawingPart: $enumDecode(_$DrawingPartsEnumMap, json['drawingPart']),
      startEdgePoint: json['startEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['startEdgePoint'] as Map<String, dynamic>),
      endEdgePoint: json['endEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['endEdgePoint'] as Map<String, dynamic>),
      exceedStart: json['exceedStart'] as bool? ?? false,
      exceedEnd: json['exceedEnd'] as bool? ?? false,
    );

Map<String, dynamic> _$ContinuousLineDrawingToJson(
        ContinuousLineDrawing instance) =>
    <String, dynamic>{
      'drawingPart': _$DrawingPartsEnumMap[instance.drawingPart]!,
      'startEdgePoint': instance.startEdgePoint,
      'endEdgePoint': instance.endEdgePoint,
      'exceedStart': instance.exceedStart,
      'exceedEnd': instance.exceedEnd,
    };

const _$DrawingPartsEnumMap = {
  DrawingParts.marker: 'marker',
  DrawingParts.line: 'line',
  DrawingParts.rectangle: 'rectangle',
};