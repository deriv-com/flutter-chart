// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_drawing_mobile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineDrawingMobile _$LineDrawingMobileFromJson(Map<String, dynamic> json) =>
    LineDrawingMobile(
      drawingPart: $enumDecode(_$DrawingPartsEnumMap, json['drawingPart']),
      startEdgePoint: json['startEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['startEdgePoint'] as Map<String, dynamic>),
      endEdgePoint: json['endEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['endEdgePoint'] as Map<String, dynamic>),
      exceedStart: json['exceedStart'] as bool? ?? false,
      exceedEnd: json['exceedEnd'] as bool? ?? false,
    )..markerFullSize = (json['markerFullSize'] as num).toDouble();

Map<String, dynamic> _$LineDrawingMobileToJson(LineDrawingMobile instance) =>
    <String, dynamic>{
      'drawingPart': _$DrawingPartsEnumMap[instance.drawingPart]!,
      'startEdgePoint': instance.startEdgePoint,
      'endEdgePoint': instance.endEdgePoint,
      'exceedStart': instance.exceedStart,
      'exceedEnd': instance.exceedEnd,
      'markerFullSize': instance.markerFullSize,
    };

const _$DrawingPartsEnumMap = {
  DrawingParts.marker: 'marker',
  DrawingParts.line: 'line',
  DrawingParts.rectangle: 'rectangle',
};
