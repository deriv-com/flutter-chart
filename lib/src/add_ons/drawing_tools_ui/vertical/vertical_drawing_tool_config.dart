import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
// import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/aroon_series.dart';
// import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/aroon_options.dart';
// import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
// import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';

part 'vertical_drawing_tool_config.g.dart';

/// Vertical drawing tool configurations.
@JsonSerializable()
class VerticalDrawingToolConfig extends DrawingToolConfig {
  /// Initializes
  const VerticalDrawingToolConfig({
    this.period = 14,
  }) : super(isOverlay: false);

  /// Initializes from JSON.
  factory VerticalDrawingToolConfig.fromJson(Map<String, dynamic> json) =>
      _$VerticalDrawingToolConfigFromJson(json);

  /// Unique name for this drawing tool.
  static const String name = 'Vertical';

  @override
  Map<String, dynamic> toJson() => _$VerticalDrawingToolConfigToJson(this)
    ..putIfAbsent(DrawingToolConfig.nameKey, () => name);

  /// The period
  final int period;

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
