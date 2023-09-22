// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingData _$DrawingDataFromJson(Map<String, dynamic> json) => DrawingData(
      id: json['id'] as String,
      drawingParts: (json['drawingParts'] as List<dynamic>)
          .map((e) => Drawing.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDrawingFinished: json['isDrawingFinished'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
      isHovered: json['isHovered'] as bool? ?? false,
    );

Map<String, dynamic> _$DrawingDataToJson(DrawingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'drawingParts': instance.drawingParts,
      'isDrawingFinished': instance.isDrawingFinished,
      'isSelected': instance.isSelected,
      'isHovered': instance.isHovered,
    };
