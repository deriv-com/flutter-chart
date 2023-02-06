// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rectangle_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RectangleDrawingToolConfig _$RectangleDrawingToolConfigFromJson(
    Map<String, dynamic> json) {
  return RectangleDrawingToolConfig(
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    pattern: json['pattern'] as String,
  );
}

Map<String, dynamic> _$RectangleDrawingToolConfigToJson(
        RectangleDrawingToolConfig instance) =>
    <String, dynamic>{
      'lineStyle': instance.lineStyle,
      'pattern': instance.pattern,
    };
