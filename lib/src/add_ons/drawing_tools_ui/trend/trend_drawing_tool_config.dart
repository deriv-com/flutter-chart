import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_item.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'trend_drawing_tool_config.g.dart';

/// Trend drawing tool configurations.
@JsonSerializable()
class TrendDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const TrendDrawingToolConfig({
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
    this.pattern = 'solid',
  }) : super();

  /// Initializes from JSON.
  factory TrendDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$TrendDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'dt_trend';

  @override
  Map<String, dynamic> toJson() => _$TrendDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  /// Drawing tool line pattern: 'solid', 'dotted', 'dashed'
  final String pattern;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      TrendDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );
}
