import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'rectangle_drawing_tool_item.dart';

part 'rectangle_drawing_tool_config.g.dart';

/// Rectangle drawing tool config
@JsonSerializable()
class RectangleDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const RectangleDrawingToolConfig({
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = 'solid',
  }) : super();

  /// Initializes from JSON.
  factory RectangleDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$RectangleDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_rectangle';

  @override
  Map<String, dynamic> toJson() => _$RectangleDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(maryia-deriv): implement 'dotted' and 'dashed' patterns
  final String pattern;

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
