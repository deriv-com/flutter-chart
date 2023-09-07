// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_drawing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelDrawing _$ChannelDrawingFromJson(Map<String, dynamic> json) =>
    ChannelDrawing(
      drawingPart: $enumDecode(_$DrawingPartsEnumMap, json['drawingPart']),
      startEdgePoint: json['startEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['startEdgePoint'] as Map<String, dynamic>),
      middleEdgePoint: json['middleEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['middleEdgePoint'] as Map<String, dynamic>),
      endEdgePoint: json['endEdgePoint'] == null
          ? const EdgePoint()
          : EdgePoint.fromJson(json['endEdgePoint'] as Map<String, dynamic>),
      isDrawingFinished: json['isDrawingFinished'] as bool? ?? false,
    );

Map<String, dynamic> _$ChannelDrawingToJson(ChannelDrawing instance) =>
    <String, dynamic>{
      'drawingPart': _$DrawingPartsEnumMap[instance.drawingPart]!,
      'startEdgePoint': instance.startEdgePoint,
      'middleEdgePoint': instance.middleEdgePoint,
      'endEdgePoint': instance.endEdgePoint,
      'isDrawingFinished': instance.isDrawingFinished,
    };

const _$DrawingPartsEnumMap = {
  DrawingParts.marker: 'marker',
  DrawingParts.line: 'line',
  DrawingParts.rectangle: 'rectangle',
};
