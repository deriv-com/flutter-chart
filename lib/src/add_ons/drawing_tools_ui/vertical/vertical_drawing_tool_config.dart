import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'vertical_drawing_tool_config.g.dart';

/// Vertical drawing tool configurations.
@JsonSerializable()
class VerticalDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const VerticalDrawingToolConfig({
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = 'solid',
  }) : super();

  /// Initializes from JSON.
  factory VerticalDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$VerticalDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'vertical';

  @override
  Map<String, dynamic> toJson() => _$VerticalDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final String pattern;

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
}
