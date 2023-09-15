import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'line_drawing_tool_config.dart';
import '../callbacks.dart';

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
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      LineDrawingToolItemState();
}

/// LineDrawingToolItem State class
class LineDrawingToolItemState
    extends DrawingToolItemState<LineDrawingToolConfig> {
  LineStyle? _lineStyle;

  @override
  LineDrawingToolConfig createDrawingToolConfig() => LineDrawingToolConfig(
        lineStyle: _currentLineStyle,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(),
          _buildPatternField(),
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

  // DrawingPatterns selectedOption = DrawingPatterns.solid;

  Widget _buildPatternField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelPattern,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 10),
          DropdownButton<DrawingPatterns>(
            value: _currentLineStyle.pattern,
            onChanged: (DrawingPatterns? selectedPattern) {
              setState(() {
                _lineStyle =
                    _currentLineStyle.copyWith(pattern: selectedPattern);
              });
              updateDrawingTool();
            },
            items: DrawingPatterns.values
                .map((DrawingPatterns value) =>
                    DropdownMenuItem<DrawingPatterns>(
                      value: value,
                      child: Text(value
                          .toString()
                          .split('.')
                          .last), // Convert enum to string
                    ))
                .toList(),
          ),
        ],
      );

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as LineDrawingToolConfig).lineStyle;
}
