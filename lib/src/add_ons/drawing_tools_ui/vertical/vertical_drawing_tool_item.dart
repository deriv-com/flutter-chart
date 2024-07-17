import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/add_on_config_wrapper.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/color_selector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
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
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      VerticalDrawingToolItemState();
}

/// Vertival drawing tool Item State class
class VerticalDrawingToolItemState
    extends DrawingToolItemState<VerticalDrawingToolConfig> {
  LineStyle? _lineStyle;
  DrawingPatterns? _pattern;
  bool? _enableLabel;

  @override
  AddOnConfigWrapper<VerticalDrawingToolConfig> createDrawingToolConfig() =>
      AddOnConfigWrapper<VerticalDrawingToolConfig>(
        VerticalDrawingToolConfig(
          lineStyle: _currentLineStyle,
          pattern: _currentPattern,
          enableLabel: _getEnableLanel,
        ),
        generateRandomUniqueId(),
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[_buildColorField(), _buildEnableLabel()],
      );

  Widget _buildEnableLabel() => Row(
        children: <Widget>[
          const Text(
            'Enable Label',
            style: TextStyle(fontSize: 10),
          ),
          Switch(
            value: _getEnableLanel,
            onChanged: (bool value) {
              setState(() {
                _enableLabel = value;
              });
              updateDrawingTool();
            },
          ),
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
      _lineStyle ?? (widget.config as VerticalDrawingToolConfig).lineStyle;

  DrawingPatterns get _currentPattern =>
      _pattern ?? (widget.config as VerticalDrawingToolConfig).pattern;

  bool get _getEnableLanel =>
      _enableLabel ?? (widget.config as VerticalDrawingToolConfig).enableLabel;
}
