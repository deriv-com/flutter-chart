import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../drawing_tool_config.dart';
import '../drawing_tool_item.dart';

/// Horizontal drawing tool item in the list of drawing tool which provide this
/// drawing tools options menu.
class HorizontalDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const HorizontalDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    HorizontalDrawingToolConfig config = const HorizontalDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Horizontal',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createIndicatorItemState() =>
      HorizontalDrawingToolItemState();
}

/// Vertival drawing tool Item State class
class HorizontalDrawingToolItemState
    extends DrawingToolItemState<HorizontalDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  HorizontalDrawingToolConfig createDrawingToolConfig() =>
      HorizontalDrawingToolConfig(
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(),
        ],
      );

  Widget _buildColorField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context)!.labelColor,
            style: const TextStyle(fontSize: 16),
          ),
          ColorSelector(
            currentColor: _currentLineStyle.color,
            onColorChanged: (Color selectedColor) {
              setState(() {
                _lineStyle = _currentLineStyle.copyWith(color: selectedColor);
              });
              updateDrawingTool();
            },
          )
        ],
      );

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as HorizontalDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as HorizontalDrawingToolConfig).pattern;
}
