import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../drawing_tool_config.dart';
import '../drawing_tool_item.dart';

/// Vertical drawing tool item in the list of drawing tool which provide this
/// drawing tools options menu.
class VerticalDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const VerticalDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    VerticalDrawingToolConfig config = const VerticalDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Vertical',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createIndicatorItemState() =>
      VerticalDrawingToolItemState();
}

/// Vertival drawing tool Item State class
class VerticalDrawingToolItemState
    extends DrawingToolItemState<VerticalDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  VerticalDrawingToolConfig createDrawingToolConfig() =>
      VerticalDrawingToolConfig(
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
      _lineStyle ?? (widget.config as VerticalDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as VerticalDrawingToolConfig).pattern;
}
