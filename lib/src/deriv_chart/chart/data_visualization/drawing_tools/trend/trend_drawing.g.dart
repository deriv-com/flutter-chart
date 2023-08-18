// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendDrawing _$TrendDrawingFromJson(Map<String, dynamic> json) => TrendDrawing(
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
      ..prevMinimumEpoch = json['prevMinimumEpoch'] as int
      ..prevMaximumEpoch = json['prevMaximumEpoch'] as int;

Map<String, dynamic> _$TrendDrawingToJson(TrendDrawing instance) =>
    <String, dynamic>{
      'drawingPart': _$DrawingPartsEnumMap[instance.drawingPart]!,
      'startXCoord': instance.startXCoord,
      'startYCoord': instance.startYCoord,
      'endXCoord': instance.endXCoord,
      'startEdgePoint': instance.startEdgePoint,
      'endEdgePoint': instance.endEdgePoint,
      'prevMinimumEpoch': instance.prevMinimumEpoch,
      'prevMaximumEpoch': instance.prevMaximumEpoch,
    };

const _$DrawingPartsEnumMap = {
  DrawingParts.marker: 'marker',
  DrawingParts.line: 'line',
  DrawingParts.rectangle: 'rectangle',
};
