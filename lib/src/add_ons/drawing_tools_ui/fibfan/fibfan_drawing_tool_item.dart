import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import '../callbacks.dart';

/// Fibfan drawing tool item in the list of drawing tools
class FibfanDrawingToolItem extends DrawingToolItem {
  /// Initializes
  FibfanDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    FibfanDrawingToolConfig? config,
  }) : super(
          key: key,
          title: 'Fib fan',
          config: config ?? FibfanDrawingToolConfig(),
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      FibfanDrawingToolItemState();
}

/// FibfanDrawingToolItem State class
class FibfanDrawingToolItemState
    extends DrawingToolItemState<FibfanDrawingToolConfig> {
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;

  @override
  FibfanDrawingToolConfig createDrawingToolConfig() => FibfanDrawingToolConfig(
        fillStyle: _currentFillStyle,
        lineStyle: _currentLineStyle,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(
              ChartLocalization.of(context).labelColor, _currentLineStyle),
          _buildColorField(
              ChartLocalization.of(context).labelFillColor, _currentFillStyle),
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
                if (label == ChartLocalization.of(context).labelColor) {
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
      _fillStyle ?? (widget.config as FibfanDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as FibfanDrawingToolConfig).lineStyle;
}
