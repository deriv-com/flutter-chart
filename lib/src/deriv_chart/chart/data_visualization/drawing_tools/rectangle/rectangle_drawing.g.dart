// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rectangle_drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RectangleDrawing _$RectangleDrawingFromJson(Map<String, dynamic> json) =>
    RectangleDrawing(
      drawingPart: $enumDecode(_$DrawingPartsEnumMap, json['drawingPart']),
      startEdgePoint: json['startEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['startEdgePoint'] as Map<String, dynamic>),
      endEdgePoint: json['endEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['endEdgePoint'] as Map<String, dynamic>),
    )
      ..startXCoord = (json['startXCoord'] as num).toDouble()
      ..startYCoord = (json['startYCoord'] as num).toDouble()
      ..endXCoord = (json['endXCoord'] as num).toDouble()
      ..endYCoord = (json['endYCoord'] as num).toDouble();

Map<String, dynamic> _$RectangleDrawingToJson(RectangleDrawing instance) =>
    <String, dynamic>{
      'drawingPart': _$DrawingPartsEnumMap[instance.drawingPart]!,
      'startXCoord': instance.startXCoord,
      'startYCoord': instance.startYCoord,
      'endXCoord': instance.endXCoord,
      'endYCoord': instance.endYCoord,
      'startEdgePoint': instance.startEdgePoint,
      'endEdgePoint': instance.endEdgePoint,
    };

const _$DrawingPartsEnumMap = {
  DrawingParts.marker: 'marker',
  DrawingParts.line: 'line',
  DrawingParts.rectangle: 'rectangle',
};
