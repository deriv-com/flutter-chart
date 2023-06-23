import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'channel_drawing_tool_config.dart';
import '../callbacks.dart';
import '../drawing_tool_config.dart';

/// Channel drawing tool item in the list of drawing tools
class ChannelDrawingToolItem extends DrawingToolItem {
  /// Initializes
  const ChannelDrawingToolItem({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    ChannelDrawingToolConfig config = const ChannelDrawingToolConfig(),
  }) : super(
          key: key,
          title: 'Channel',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      ChannelDrawingToolItemState();
}

/// ChannelDrawingToolItem State class
class ChannelDrawingToolItemState
    extends DrawingToolItemState<ChannelDrawingToolConfig> {
  LineStyle? _fillStyle;
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  ChannelDrawingToolConfig createDrawingToolConfig() =>
      ChannelDrawingToolConfig(
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
          // TODO(maryia-binary): implement _buildPatternField() to set pattern
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
      _fillStyle ?? (widget.config as ChannelDrawingToolConfig).fillStyle;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as ChannelDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as ChannelDrawingToolConfig).pattern;
}
