import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'vertical_drawing_tool_config.g.dart';

/// Vertical drawing tool configurations.
@JsonSerializable()
class VerticalDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const VerticalDrawingToolConfig({
    this.configId,
    this.drawingData,
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = DrawingPatterns.solid,
    this.edgePoints = const <EdgePoint>[],
  }) : super();

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

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

  /// Drawing tool data.
  final DrawingData? drawingData;

  /// Drawing tool edge points.
  final List<EdgePoint> edgePoints;

  /// Drawing tool config id.
  final String? configId;

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
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
  }) =>
      VerticalDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        lineStyle: lineStyle ?? this.lineStyle,
        pattern: pattern ?? this.pattern,
        edgePoints: edgePoints ?? this.edgePoints,
      );
}
