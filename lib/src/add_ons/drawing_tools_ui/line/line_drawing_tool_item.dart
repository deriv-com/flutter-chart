import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../drawing_tool_config.dart';
import '../drawing_tool_item.dart';
import 'line_drawing_tool_config.dart';

/// Line drawing tool item in the list of drawing tools
class LineDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const LineDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    LineDrawingToolConfig config = const LineDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Line',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createIndicatorItemState() =>
      LineDrawingToolItemState();
}

/// LineDrawingToolItem State class
class LineDrawingToolItemState
    extends DrawingToolItemState<LineDrawingToolConfig> {
  @override
  LineDrawingToolConfig createDrawingToolConfig() =>
      const LineDrawingToolConfig();
}
