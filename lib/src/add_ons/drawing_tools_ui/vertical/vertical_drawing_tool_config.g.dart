// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vertical_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerticalDrawingToolConfig _$VerticalDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    VerticalDrawingToolConfig(
      configId: json['configId'] as String?,
      drawingData: json['drawingData'] == null
          ? null
          : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
      edgePoints: (json['edgePoints'] as List<dynamic>?)
              ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EdgePoint>[],
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      labelStyle: json['labelStyle'] == null
          ? const TextStyle(
              color: CoreDesignTokens.coreColorSolidBlue700, fontSize: 12)
          : const TextStyleJsonConverter()
              .fromJson(json['labelStyle'] as Map<String, dynamic>),
      pattern: $enumDecodeNullable(_$DrawingPatternsEnumMap, json['pattern']) ??
          DrawingPatterns.solid,
      enableLabel: json['enableLabel'] as bool? ?? true,
      number: (json['number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VerticalDrawingToolConfigToJson(
        VerticalDrawingToolConfig instance) =>
    <String, dynamic>{
      'configId': instance.configId,
      'number': instance.number,
      'drawingData': instance.drawingData,
      'edgePoints': instance.edgePoints,
      'lineStyle': instance.lineStyle,
      'labelStyle': const TextStyleJsonConverter().toJson(instance.labelStyle),
      'pattern': _$DrawingPatternsEnumMap[instance.pattern]!,
      'enableLabel': instance.enableLabel,
    };

const _$DrawingPatternsEnumMap = {
  DrawingPatterns.solid: 'solid',
  DrawingPatterns.dotted: 'dotted',
  DrawingPatterns.dashed: 'dashed',
};
