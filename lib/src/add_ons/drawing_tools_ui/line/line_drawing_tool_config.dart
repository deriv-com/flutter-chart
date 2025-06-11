import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_label_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/text_style_json_converter.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_drawing_tool_config.g.dart';

/// Line drawing tool config
@JsonSerializable()
class LineDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const LineDrawingToolConfig({
    String? configId,
    DrawingData? drawingData,
    List<EdgePoint> edgePoints = const <EdgePoint>[],
    this.lineStyle =
        const LineStyle(color: CoreDesignTokens.coreColorSolidBlue700),
    this.labelStyle = const TextStyle(
      color: CoreDesignTokens.coreColorSolidBlue700,
      fontSize: 12,
    ),
    this.overlayStyle,
    this.pattern = DrawingPatterns.solid,
    super.number,
  }) : super(
          configId: configId,
          drawingData: drawingData,
          edgePoints: edgePoints,
        );

  /// Initializes from JSON.
  factory LineDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$LineDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_line';

  @override
  Map<String, dynamic> toJson() => _$LineDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// The style of the label showing on y-axis.
  @TextStyleJsonConverter()
  final TextStyle labelStyle;

  /// Drawing tool overlay style
  final OverlayStyle? overlayStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(maryia-binary): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      LineDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );

  @override
  LineDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    LineStyle? fillStyle,
    TextStyle? labelStyle,
    OverlayStyle? overlayStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
    bool? enableLabel,
    int? number,
  }) =>
      LineDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        lineStyle: lineStyle ?? this.lineStyle,
        labelStyle: labelStyle ?? this.labelStyle,
        overlayStyle: overlayStyle ?? this.overlayStyle,
        pattern: pattern ?? this.pattern,
        edgePoints: edgePoints ?? this.edgePoints,
        number: number ?? this.number,
      );

  @override
  LineDrawingToolLabelPainter? getLabelPainter({
    required Point startPoint,
    required Point endPoint,
  }) {
    if (kIsWeb) {
      return null;
    } else {
      return MobileLineDrawingToolLabelPainter(
        this,
        startPoint: startPoint,
        endPoint: endPoint,
      );
    }
  }

  @override
  InteractableDrawing getInteractableDrawing() => TrendLineInteractableDrawing(
        config: this,
        // TODO(NA): improve the logic.
        startPoint: edgePoints.isNotEmpty ? edgePoints.first : null,
        endPoint: edgePoints.isNotEmpty ? edgePoints.last : null,
      );
}
