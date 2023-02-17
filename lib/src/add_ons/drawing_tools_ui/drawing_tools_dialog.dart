import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';

/// Drawing tools dialog with available drawing tools.
class DrawingToolsDialog extends StatefulWidget {
  /// Creates drawing tools dialog.
  const DrawingToolsDialog({
    required this.onDrawingToolSelection(DrawingToolConfig selectedDrawingTool),
    required this.onDrawingToolRemoval(int index),
    required this.onDrawingToolUpdate(
        int index, DrawingToolConfig updatedConfig),
    Key? key,
  }) : super(key: key);

  /// Callback to inform parent about drawing tool removal.
  final void Function(int) onDrawingToolRemoval;

  /// Callback to inform parent about drawing tool selection.
  final void Function(DrawingToolConfig) onDrawingToolSelection;

  /// Callback to inform parent about drawing tool update.
  final void Function(int, DrawingToolConfig) onDrawingToolUpdate;

  @override
  _DrawingToolsDialogState createState() => _DrawingToolsDialogState();
}

class _DrawingToolsDialogState extends State<DrawingToolsDialog> {
  DrawingToolConfig? _selectedDrawingTool;

  @override
  Widget build(BuildContext context) {
    final AddOnsRepository<DrawingToolConfig> repo =
        context.watch<AddOnsRepository<DrawingToolConfig>>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<DrawingToolConfig>(
                value: _selectedDrawingTool,
                hint: Text(ChartLocalization.of(context)!.selectDrawingTool),
                items: const <DropdownMenuItem<DrawingToolConfig>>[
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
                        widget.onDrawingToolSelection(_selectedDrawingTool!);
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.getAddOns().length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.getAddOns()[index].getItem(
                (DrawingToolConfig updatedConfig) {
                  widget.onDrawingToolUpdate(index, updatedConfig);
                  repo.updateAt(index, updatedConfig);
                },
                () {
                  widget.onDrawingToolRemoval(index);
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
