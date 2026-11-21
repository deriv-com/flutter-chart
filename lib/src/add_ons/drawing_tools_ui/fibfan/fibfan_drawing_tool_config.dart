import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/color_converter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/text_style_json_converter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_context.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/types.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/fibfan/fibfan_interactable_drawing.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/light_theme_design_tokens.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fibfan_drawing_tool_item.dart';

part 'fibfan_drawing_tool_config.g.dart';

/// Fibfan drawing tool config
@JsonSerializable()
@ColorConverter()
class FibfanDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  FibfanDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.fibonacciLevelColors = const <String, Color>{
      'level0': CoreDesignTokens.coreColorSolidBlue700, // Blue for 0%
      'level38_2': LightThemeDesignTokens
          .semanticColorSeawaterSolidBorderStaticMid, // Cyan for 38.2%
      'level50': LightThemeDesignTokens
          .semanticColorMustardSolidBorderStaticHigh, // Amber for 50%
      'level61_8': LightThemeDesignTokens
          .semanticColorYellowSolidBorderStaticMid, // Orange for 61.8%
      'level100': CoreDesignTokens.coreColorSolidBlue700, // Blue for 100%
    },
    LineStyle? fillStyle,
    this.lineStyle =
        const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700),
    this.labelStyle = const TextStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
      fontSize: 12,
    ),
    super.number,
  })  : fillStyle =
            fillStyle ?? LineStyle(color: fibonacciLevelColors['level0']!),
        super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory FibfanDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$FibfanDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_fibfan';

  @override
  Map<String, dynamic> toJson() => _$FibfanDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Colors for each Fibonacci level
  final Map<String, Color> fibonacciLevelColors;

  /// The style of the label showing on y-axis.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      FibfanDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  FibfanDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    TextStyle? labelStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
    Map<String, Color>? fibonacciLevelColors,
  }) =>
      FibfanDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        lineStyle: lineStyle ?? this.lineStyle,
        fillStyle: fillStyle ?? this.fillStyle,
        labelStyle: labelStyle ?? this.labelStyle,
        edgePoints: edgePoints ?? this.edgePoints,
        number: number ?? this.number,
        fibonacciLevelColors: fibonacciLevelColors ?? this.fibonacciLevelColors,
      );

  @override
  FibfanInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) {
    final EdgePoint? startPoint =
        edgePoints.isNotEmpty ? edgePoints.first : null;
    final EdgePoint? endPoint = edgePoints.length > 1 ? edgePoints[1] : null;

    return FibfanInteractableDrawing(
      config: this,
      startPoint: startPoint,
      endPoint: endPoint,
      drawingContext: drawingContext,
      getDrawingState: getDrawingState,
    );
  }
}
