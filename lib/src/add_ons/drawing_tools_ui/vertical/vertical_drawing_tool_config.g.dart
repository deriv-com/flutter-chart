// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vertical_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerticalDrawingToolConfig _$VerticalDrawingToolConfigFromJson(
    Map<String, dynamic> json) {
  return VerticalDrawingToolConfig(
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    pattern: json['pattern'] as String,
  );
}

Map<String, dynamic> _$VerticalDrawingToolConfigToJson(
        VerticalDrawingToolConfig instance) =>
    <String, dynamic>{
      'lineStyle': instance.lineStyle,
      'pattern': instance.pattern,
    };
