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
  String? _selectedDrawingTool;

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
              DropdownButton<String>(
                value: _selectedDrawingTool,
                hint: const Text('Select drawing tool'),
                items: const <DropdownMenuItem<String>>[
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
                  DropdownMenuItem<String>(
                    child: Text('Line'),
                    value: 'Line',
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
                  // TODO(maryia-binary): replace string values with real drawing tools
                ],
                onChanged: (String? config) {
                  setState(() {
                    _selectedDrawingTool = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                  child: const Text('Add'),
                  onPressed:
                      _selectedDrawingTool is DrawingToolConfig ? () {} : null),
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: repo.addOns.length,
                itemBuilder: (BuildContext context, int index) => Container()),
          ),
        ],
      ),
    );
  }
}
