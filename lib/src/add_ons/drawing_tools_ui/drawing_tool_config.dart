import 'package:deriv_chart/src/add_ons/add_ons_config.dart';
import 'package:flutter/material.dart';
import 'drawing_tool_item.dart';
import 'callbacks.dart';

/// Drawing tools config
@immutable
abstract class DrawingToolConfig extends AddOnsConfig {
  /// Initializes
  const DrawingToolConfig({bool isOverlay = true})
      : super(isOverlay: isOverlay);

  /// Creates a concrete drawing tools config from JSON.
  factory DrawingToolConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(nameKey)) {
      throw ArgumentError.value(json, 'json', 'Missing drawing tool name.');
    }

    switch (json[nameKey]) {
      // Add cases with <config>.fromJson(json) for all drawing tools here
      default:
        throw ArgumentError.value(
            json, 'json', 'Unidentified drawing tool name.');
    }
  }

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'name';

  /// Creates drawing tool UI.
  DrawingToolItem getItem(
    UpdateDrawingTool updateDrawingTool,
    VoidCallback deleteDrawingTool,
  );
}
