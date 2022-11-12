// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineDrawingToolConfig _$LineDrawingToolConfigFromJson(
    Map<String, dynamic> json) {
  return LineDrawingToolConfig(
    lineStyle: LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LineDrawingToolConfigToJson(
        LineDrawingToolConfig instance) =>
    <String, dynamic>{
      'lineStyle': instance.lineStyle,
    };
