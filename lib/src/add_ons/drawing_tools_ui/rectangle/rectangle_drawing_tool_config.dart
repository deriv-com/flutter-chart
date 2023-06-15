import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'rectangle_drawing_tool_config.g.dart';

/// Rectangle drawing tool configurations.
@JsonSerializable()
class RectangleDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const RectangleDrawingToolConfig({
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = DrawingPatterns.solid,
  }) : super();

  /// Initializes from JSON.
  factory RectangleDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$RectangleDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_rectangle';

  @override
  Map<String, dynamic> toJson() => _$RectangleDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      RectangleDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );
}
