// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fibfan_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FibfanDrawingToolConfig _$FibfanDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    FibfanDrawingToolConfig(
      fillStyle: json['fillStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.blue)
          : LineStyle.fromJson(json['fillStyle'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(thickness: 0.9, color: Colors.white)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FibfanDrawingToolConfigToJson(
        FibfanDrawingToolConfig instance) =>
    <String, dynamic>{
      'lineStyle': instance.lineStyle,
      'fillStyle': instance.fillStyle,
    };
