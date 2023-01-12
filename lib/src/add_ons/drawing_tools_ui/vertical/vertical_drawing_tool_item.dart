import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';

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
  DrawingToolItemState<DrawingToolConfig> createDrawingToolItemState() =>
      VerticalDrawingToolItemState();
}

/// Vertival drawing tool Item State class
class VerticalDrawingToolItemState
    extends DrawingToolItemState<VerticalDrawingToolConfig> {
  int? _period;

  @override
  VerticalDrawingToolConfig createDrawingToolConfig() =>
      VerticalDrawingToolConfig(
        period: _currentPeriod,
      );

  @override
  Widget getDrawingToolOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
        ],
      );

  Widget _buildPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _currentPeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _period = int.tryParse(text);
                } else {
                  _period = 14;
                }
                updateDrawingTool();
              },
            ),
          ),
        ],
      );

  int get _currentPeriod =>
      _period ?? (widget.config as VerticalDrawingToolConfig).period;
}
