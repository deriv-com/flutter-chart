import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/text_style_json_converter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_context.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/types.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/vertical_line/vertical_line_interactable_drawing.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'vertical_drawing_tool_config.g.dart';

/// Vertical drawing tool configurations.
@JsonSerializable()
class VerticalDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const VerticalDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.lineStyle =
        const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700),
    this.labelStyle = const TextStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
      fontSize: 12,
    ),
    this.pattern = DrawingPatterns.solid,
    this.enableLabel = true,
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory VerticalDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$VerticalDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_vertical';

  @override
  Map<String, dynamic> toJson() => _$VerticalDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// The style of the label showing on x-axis when the tool is selected.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

  /// For enabling the label
  final bool enableLabel;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      VerticalDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  VerticalDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    TextStyle? labelStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      VerticalDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        edgePoints: edgePoints ?? this.edgePoints,
        lineStyle: lineStyle ?? this.lineStyle,
        labelStyle: labelStyle ?? this.labelStyle,
        pattern: pattern ?? this.pattern,
        enableLabel: enableLabel ?? this.enableLabel,
        number: number ?? this.number,
      );

  @override
  VerticalLineInteractableDrawing getInteractableDrawing(
    DrawingContext drawingContext,
    GetDrawingState getDrawingState,
  ) {
    final EdgePoint? startPoint =
        edgePoints.isNotEmpty ? edgePoints.first : null;

    return VerticalLineInteractableDrawing(
      config: this,
      startPoint: startPoint,
      drawingContext: drawingContext,
      getDrawingState: getDrawingState,
    );
  }
}
