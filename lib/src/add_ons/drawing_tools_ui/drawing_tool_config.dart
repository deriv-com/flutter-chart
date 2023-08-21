import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/continuous/continuous_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/ray/ray_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';

import 'package:flutter/material.dart';
import 'line/line_drawing_tool_config.dart';
import 'vertical/vertical_drawing_tool_config.dart';

/// Drawing tools config
@immutable
abstract class DrawingToolConfig extends AddOnConfig {
  /// Initializes
  const DrawingToolConfig({bool isOverlay = true})
      : super(isOverlay: isOverlay);

  /// Creates a concrete drawing tool config from JSON.
  factory DrawingToolConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(nameKey)) {
      throw ArgumentError.value(json, 'json', 'Missing drawing tool name.');
    }

    switch (json[nameKey]) {
      case ContinuousDrawingToolConfig.name:
        return ContinuousDrawingToolConfig.fromJson(json);
      case LineDrawingToolConfig.name:
        return LineDrawingToolConfig.fromJson(json);
      case RayDrawingToolConfig.name:
        return RayDrawingToolConfig.fromJson(json);
      case RectangleDrawingToolConfig.name:
        return RectangleDrawingToolConfig.fromJson(json);
      case TrendDrawingToolConfig.name:
        return TrendDrawingToolConfig.fromJson(json);
      case VerticalDrawingToolConfig.name:
        return VerticalDrawingToolConfig.fromJson(json);

      // Add new drawing tools here.
      default:
        throw ArgumentError.value(
            json, 'json', 'Unidentified drawing tool name.');
    }
  }

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'name';

  /// Creates drawing tool.
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  );
}
