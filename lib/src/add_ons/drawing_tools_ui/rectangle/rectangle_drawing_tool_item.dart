import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'rectangle_drawing_tool_config.dart';
import '../callbacks.dart';
import '../drawing_tool_config.dart';

/// Rectangle drawing tool item in the list of drawing tools
class RectangleDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const RectangleDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    RectangleDrawingToolConfig config = const RectangleDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Rectangle',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createIndicatorItemState() =>
      RectangleDrawingToolItemState();
}

/// RectangleDrawingToolItem State class
class RectangleDrawingToolItemState
    extends DrawingToolItemState<RectangleDrawingToolConfig> {
  LineStyle? _lineStyle;
  String? _pattern;

  @override
  RectangleDrawingToolConfig createDrawingToolConfig() =>
      RectangleDrawingToolConfig(
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(),
          // TODO(maryia-deriv): implement _buildPatternField() to set pattern
        ],
      );

  Widget _buildColorField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelColor,
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
      _lineStyle ?? (widget.config as RectangleDrawingToolConfig).lineStyle;

  String get _currentPattern =>
      _pattern ?? (widget.config as RectangleDrawingToolConfig).pattern;
}
