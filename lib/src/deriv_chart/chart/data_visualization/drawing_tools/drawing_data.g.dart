// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingData _$DrawingDataFromJson(Map<String, dynamic> json) => DrawingData(
      id: json['id'] as String,
      config:
          DrawingToolConfig.fromJson(json['config'] as Map<String, dynamic>),
      drawingParts: (json['drawingParts'] as List<dynamic>)
          .map((e) => Drawing.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDrawingFinished: json['isDrawingFinished'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? true,
      series: (json['series'] as List<dynamic>?)
          ?.map((e) => Tick.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DrawingDataToJson(DrawingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'config': instance.config,
      'series': instance.series,
      'drawingParts': instance.drawingParts,
      'isDrawingFinished': instance.isDrawingFinished,
      'isSelected': instance.isSelected,
    };
