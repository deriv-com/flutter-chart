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
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;
  String? _pattern;

  @override
  RectangleDrawingToolConfig createDrawingToolConfig() =>
      RectangleDrawingToolConfig(
        fillStyle: _currentFillStyle,
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(
              ChartLocalization.of(context).labelColor, _currentLineStyle),
          _buildColorField(
              ChartLocalization.of(context).labelFillColor, _currentFillStyle),
          // TODO(maryia-deriv): implement _buildPatternField() to set pattern
        ],
      );

  Widget _buildColorField(String label, LineStyle style) => Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          ColorSelector(
            currentColor: style.color,
            onColorChanged: (Color selectedColor) {
              setState(() {
                if (label == ChartLocalization.of(context).labelColor) {
                  _lineStyle = style.copyWith(color: selectedColor);
                } else {
                  _fillStyle =
                      style.copyWith(color: selectedColor.withOpacity(0.3));
                }
              });
              updateDrawingTool();
            },
          )
        ],
      );

  LineStyle get _currentFillStyle =>
      _fillStyle ?? (widget.config as RectangleDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as RectangleDrawingToolConfig).lineStyle;

  String get _currentPattern =>
      _pattern ?? (widget.config as RectangleDrawingToolConfig).pattern;
}
