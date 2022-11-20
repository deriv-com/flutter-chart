import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
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
    required this.onDrawingToolRemoval(DrawingToolConfig selectedDrawingTool),
    this.isDrawingToolDrawn = false,
    Key? key,
  }) : super(key: key);

  /// callback to inform parent about drawing tool selection;
  final void Function(DrawingToolConfig) onDrawingToolSelection;

  /// callback to inform parent about drawing tool removal;
  final void Function(DrawingToolConfig) onDrawingToolRemoval;

  /// if a drawing tool has been drawn, defaults to false;
  final bool isDrawingToolDrawn;

  @override
  _DrawingToolsDialogState createState() => _DrawingToolsDialogState();
}

class _DrawingToolsDialogState extends State<DrawingToolsDialog> {
  dynamic _selectedDrawingTool;

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
              DropdownButton<dynamic>(
                value: _selectedDrawingTool,
                hint: const Text('Select drawing tool'),
                items: const <DropdownMenuItem<dynamic>>[
                  DropdownMenuItem<String>(
                    child: Text('Channel'),
                    value: 'Channel',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Continuous'),
                    value: 'Continuous',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Fib Fan'),
                    value: 'Fib Fan',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Horizontal'),
                    value: 'Horizontal',
                  ),
                  DropdownMenuItem<DrawingToolConfig>(
                    child: Text('Line'),
                    value: LineDrawingToolConfig(),
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Ray'),
                    value: 'Ray',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Rectangle'),
                    value: 'Rectangle',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Trend'),
                    value: 'Trend',
                  ),
                  DropdownMenuItem<String>(
                    child: Text('Vertical'),
                    value: 'Vertical',
                  ),
                  // TODO(maryia-binary): add real drawing tools above
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
                        repo.add(_selectedDrawingTool! as DrawingToolConfig);
                        widget.onDrawingToolSelection(_selectedDrawingTool);
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.addOns.length,
              itemBuilder: (BuildContext context, int index) =>
                  widget.isDrawingToolDrawn
                      ? repo.addOns[index].getItem(
                          (DrawingToolConfig updatedConfig) =>
                              repo.updateAt(index, updatedConfig),
                          () {
                            widget.onDrawingToolRemoval(repo.addOns[index]);
                            repo.removeAt(index);
                            setState(() {});
                          },
                        )
                      : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
