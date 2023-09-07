import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'horizontal_drawing_tool_config.g.dart';

/// Horizontal drawing tool configurations.
@JsonSerializable()
class HorizontalDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const HorizontalDrawingToolConfig({
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = DrawingPatterns.solid,
  }) : super();

  /// Initializes from JSON.
  factory HorizontalDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$HorizontalDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_horizontal';

  @override
  Map<String, dynamic> toJson() => _$HorizontalDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      HorizontalDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );
}
