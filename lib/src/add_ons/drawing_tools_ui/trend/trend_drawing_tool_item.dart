import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../drawing_tool_config.dart';
import '../drawing_tool_item.dart';

/// Trend drawing tool item in the list of drawing tool which provide this
/// drawing tools options menu.
class TrendDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const TrendDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    TrendDrawingToolConfig config = const TrendDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Trend',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      TrendDrawingToolItemState();
}

/// Trend drawing tool Item State class
class TrendDrawingToolItemState
    extends DrawingToolItemState<TrendDrawingToolConfig> {
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;
  String? _pattern;

  @override
  TrendDrawingToolConfig createDrawingToolConfig() => TrendDrawingToolConfig(
        fillStyle: _currentFillStyle,
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(
              ChartLocalization.of(context)!.labelColor, _currentLineStyle),
          _buildColorField(
              ChartLocalization.of(context)!.labelFillColor, _currentFillStyle),
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
                final LineStyle newColor = style.copyWith(color: selectedColor);
                if (label == ChartLocalization.of(context)!.labelColor) {
                  _lineStyle = newColor;
                } else {
                  _fillStyle = newColor;
                }
              });
              updateDrawingTool();
            },
          )
        ],
      );

  LineStyle get _currentFillStyle =>
      _fillStyle ?? (widget.config as TrendDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as TrendDrawingToolConfig).lineStyle;

  String get _currentPattern =>
      _pattern ?? (widget.config as TrendDrawingToolConfig).pattern;
}
