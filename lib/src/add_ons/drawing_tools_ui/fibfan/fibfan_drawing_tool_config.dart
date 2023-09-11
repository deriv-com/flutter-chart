import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'fibfan_drawing_tool_item.dart';

part 'fibfan_drawing_tool_config.g.dart';

/// Fibfan drawing tool config
@JsonSerializable()
class FibfanDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const FibfanDrawingToolConfig({
    this.fillStyle = const LineStyle(thickness: 0.9, color: Colors.blue),
    this.lineStyle = const LineStyle(thickness: 0.9, color: Colors.white),
  }) : super();

  /// Initializes from JSON.
  factory FibfanDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$FibfanDrawingToolConfigFromJson(json);

  /// Drawing tool name
  static const String name = 'dt_fibfan';

  @override
  Map<String, dynamic> toJson() => _$FibfanDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// Drawing tool line style
  final LineStyle lineStyle;

  /// Drawing tool fill style
  final LineStyle fillStyle;

  @override
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  ) =>
      FibfanDrawingToolItem(
        config: this,
        updateDrawingTool: updateDrawingTool,
        deleteDrawingTool: deleteDrawingTool,
      );
}
