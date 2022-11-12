import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';

/// Drawing tools dialog with available drawing tools.
class DrawingToolsDialog extends StatefulWidget {
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
                        setState(() {});
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
                  repo.addOns[index].getItem(
                (DrawingToolConfig updatedConfig) =>
                    repo.updateAt(index, updatedConfig),
                () {
                  repo.removeAt(index);
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
