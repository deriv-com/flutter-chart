// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fibfan_drawing_tool_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FibfanDrawingToolConfig _$FibfanDrawingToolConfigFromJson(
        Map<String, dynamic> json) =>
    FibfanDrawingToolConfig(
      configId: json['configId'] as String?,
      drawingData: json['drawingData'] == null
          ? null
          : DrawingData.fromJson(json['drawingData'] as Map<String, dynamic>),
      edgePoints: (json['edgePoints'] as List<dynamic>?)
              ?.map((e) => EdgePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EdgePoint>[],
      fibonacciLevelColors:
          (json['fibonacciLevelColors'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, const ColorConverter().fromJson((e as num).toInt())),
              ) ??
              const <String, Color>{
                'level0': CoreDesignTokens.coreColorSolidBlue700,
                'level38_2': LightThemeDesignTokens
                    .semanticColorSeawaterSolidBorderStaticMid,
                'level50': LightThemeDesignTokens
                    .semanticColorMustardSolidBorderStaticHigh,
                'level61_8': LightThemeDesignTokens
                    .semanticColorYellowSolidBorderStaticMid,
                'level100': CoreDesignTokens.coreColorSolidBlue700
              },
      fillStyle: json['fillStyle'] == null
          ? null
          : LineStyle.fromJson(json['fillStyle'] as Map<String, dynamic>),
      lineStyle: json['lineStyle'] == null
          ? const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700)
          : LineStyle.fromJson(json['lineStyle'] as Map<String, dynamic>),
      labelStyle: json['labelStyle'] == null
          ? const TextStyle(
              color: CoreDesignTokens.coreColorSolidBlue700, fontSize: 12)
          : const TextStyleJsonConverter()
              .fromJson(json['labelStyle'] as Map<String, dynamic>),
      number: (json['number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$FibfanDrawingToolConfigToJson(
        FibfanDrawingToolConfig instance) =>
    <String, dynamic>{
      'configId': instance.configId,
      'number': instance.number,
      'drawingData': instance.drawingData,
      'edgePoints': instance.edgePoints,
      'lineStyle': instance.lineStyle,
      'fillStyle': instance.fillStyle,
      'fibonacciLevelColors': instance.fibonacciLevelColors
          .map((k, e) => MapEntry(k, const ColorConverter().toJson(e))),
      'labelStyle': const TextStyleJsonConverter().toJson(instance.labelStyle),
    };
