import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_item.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config_mobile.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'line_drawing_tool_config.dart';
import '../callbacks.dart';

/// Line drawing tool item in the list of drawing tools
class LineDrawingToolItemMobile extends DrawingToolItem {
  /// Initializes
  const LineDrawingToolItemMobile({
    required UpdateDrawingTool updateDrawingTool,
    required VoidCallback deleteDrawingTool,
    Key? key,
    LineDrawingToolConfigMobile config = const LineDrawingToolConfigMobile(),
  }) : super(
          key: key,
          title: 'Line',
          config: config,
          updateDrawingTool: updateDrawingTool,
          deleteDrawingTool: deleteDrawingTool,
        );

  @override
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      LineDrawingToolItemMobileState();
}

/// LineDrawingToolItem State class
class LineDrawingToolItemMobileState
    extends DrawingToolItemState<LineDrawingToolConfigMobile> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;

  @override
  LineDrawingToolConfigMobile createDrawingToolConfig() => LineDrawingToolConfigMobile(
        lineStyle: _currentLineStyle,
        pattern: _currentPattern,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildColorField(),
          // TODO(maryia-binary): implement _buildPatternField() to set pattern
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
      _lineStyle ?? (widget.config as LineDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as LineDrawingToolConfig).pattern;
}
