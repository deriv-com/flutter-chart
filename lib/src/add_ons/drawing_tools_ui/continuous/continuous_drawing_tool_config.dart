import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'continuous_drawing_tool_item.dart';

part 'continuous_drawing_tool_config.g.dart';

/// Continuous drawing tool config
@JsonSerializable()
class ContinuousDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const ContinuousDrawingToolConfig({
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = DrawingPatterns.solid,
  }) : super();

  /// Initializes from JSON.
  factory ContinuousDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$ContinuousDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_continuous';

  @override
  Map<String, dynamic> toJson() => _$ContinuousDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  // TODO(maryia-binary): implement 'dotted' and 'dashed' patterns
  final DrawingPatterns pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      ContinuousDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );
}