// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draggable_edge_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraggableEdgePoint _$DraggableEdgePointFromJson(Map<String, dynamic> json) =>
    DraggableEdgePoint(
      epoch: json['epoch'] as int? ?? 0,
      quote: (json['quote'] as num?)?.toDouble() ?? 0,
      isDrawingDragged: json['isDrawingDragged'] as bool? ?? false,
      isDragged: json['isDragged'] as bool? ?? false,
    );

Map<String, dynamic> _$DraggableEdgePointToJson(DraggableEdgePoint instance) =>
    <String, dynamic>{
      'epoch': instance.epoch,
      'quote': instance.quote,
      'isDrawingDragged': instance.isDrawingDragged,
      'isDragged': instance.isDragged,
    };
