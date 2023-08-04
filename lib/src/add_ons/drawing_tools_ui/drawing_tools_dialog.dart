import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/continuous/continuous_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';

/// Drawing tools dialog with available drawing tools.
class DrawingToolsDialog extends StatefulWidget {
  /// Creates drawing tools dialog.
  const DrawingToolsDialog({
    required this.drawingTools,
    Key? key,
  }) : super(key: key);

  /// Keep the reference to the drawing tools class for
  /// sharing data between the DerivChart and the DrawingToolsDialog
  final DrawingTools drawingTools;

  @override
  _DrawingToolsDialogState createState() => _DrawingToolsDialogState();
}

class _DrawingToolsDialogState extends State<DrawingToolsDialog> {
  DrawingToolConfig? _selectedDrawingTool;

  @override
  Widget build(BuildContext context) {
    final Repository<DrawingToolConfig> repo =
        context.watch<Repository<DrawingToolConfig>>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<DrawingToolConfig>(
                value: _selectedDrawingTool,
                hint: Text(ChartLocalization.of(context).selectDrawingTool),
                items: const <DropdownMenuItem<DrawingToolConfig>>[
                  DropdownMenuItem<DrawingToolConfig>(
                    child: Text('Continuous'),
                    value: ContinuousDrawingToolConfig(),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    child: Text('Line'),
                    value: LineDrawingToolConfig(),
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    child: Text('Vertical'),
                    value: VerticalDrawingToolConfig(),
                  ),
                  // TODO(maryia-binary): add the rest of drawing tools above
                ],
                onChanged: (dynamic config) {
                  setState(() {
                    _selectedDrawingTool = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: _selectedDrawingTool != null &&
                        _selectedDrawingTool is DrawingToolConfig
                    ? () {
                        widget.drawingTools
                            .onDrawingToolSelection(_selectedDrawingTool!);
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.items.length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.items[index].getItem(
                (DrawingToolConfig updatedConfig) {
                  widget.drawingTools.onDrawingToolUpdate(index, updatedConfig);
                  repo.updateAt(index, updatedConfig);
                },
                () {
                  widget.drawingTools.onDrawingToolRemoval(index);
                  repo.removeAt(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
