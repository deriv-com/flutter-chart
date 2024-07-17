import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/add_on_config_wrapper.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../drawing_tool_item.dart';

/// Rectangle drawing tool item in the list of drawing tool which provide this
/// drawing tools options menu.
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
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      RectangleDrawingToolItemState();
}

/// Rectangle drawing tool Item State class
class RectangleDrawingToolItemState
    extends DrawingToolItemState<RectangleDrawingToolConfig> {
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  AddOnConfigWrapper<RectangleDrawingToolConfig> createDrawingToolConfig() =>
      AddOnConfigWrapper<RectangleDrawingToolConfig>(
        RectangleDrawingToolConfig(
          fillStyle: _currentFillStyle,
          lineStyle: _currentLineStyle,
          pattern: _currentPattern,
        ),
        generateRandomUniqueId(),
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
              setState(
                () {
                  final LineStyle newColor =
                      style.copyWith(color: selectedColor);
                  if (label == ChartLocalization.of(context).labelColor) {
                    _lineStyle = newColor;
                  } else {
                    _fillStyle = newColor;
                  }
                },
              );
              updateDrawingTool();
            },
          )
        ],
      );

  LineStyle get _currentFillStyle =>
      _fillStyle ?? (widget.config as RectangleDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as RectangleDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as RectangleDrawingToolConfig).pattern;
}
