import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'line_drawing_tool_item.dart';

part 'line_drawing_tool_config.g.dart';

/// Line drawing tool config
@JsonSerializable()
class LineDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const LineDrawingToolConfig({
    this.configId,
    this.drawingData,
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = DrawingPatterns.solid,
    this.edgePoints = const <EdgePoint>[],
  });

  /// Initializes from JSON.
  factory LineDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$LineDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_line';

  // static const String configId = 'LineDrawingToolConfig_';
  // 'LineDrawingToolConfig_${math.Random().nextInt(1000)}';

  @override
  Map<String, dynamic> toJson() => _$LineDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);
  // ..putIfAbsent(DrawingToolConfig.configIdKey, () => configId);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(maryia-binary): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  /// Drawing tool data.
  final DrawingData? drawingData;

  /// Drawing tool edge points.
  final List<EdgePoint> edgePoints;

  /// Drawing tool config id.
  final String? configId;
  // final String? configId;

  @override
  LineDrawingToolConfig copyWith({
    String? configId,
    DrawingData? drawingData,
    LineStyle? lineStyle,
    DrawingPatterns? pattern,
    List<EdgePoint>? edgePoints,
  }) =>
      LineDrawingToolConfig(
        configId: configId ?? this.configId,
        drawingData: drawingData ?? this.drawingData,
        lineStyle: lineStyle ?? this.lineStyle,
        pattern: pattern ?? this.pattern,
        edgePoints: edgePoints ?? this.edgePoints,
      );

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
}
