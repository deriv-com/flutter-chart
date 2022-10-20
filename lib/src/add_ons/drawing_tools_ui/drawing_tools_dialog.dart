// import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/commodity_channel_index/cci_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/roc/roc_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/dpo_indicator/dpo_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/gator/gator_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_config.dart';
// import 'package:deriv_chart/src/add_ons/indicators_ui/smi/smi_indicator_config.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import './ma_indicator/ma_indicator_config.dart';
// import 'adx/adx_indicator_config.dart';
// import 'alligator/alligator_indicator_config.dart';
// import 'bollinger_bands/bollinger_bands_indicator_config.dart';
// import 'donchian_channel/donchian_channel_indicator_config.dart';
// import 'fcb_indicator/fcb_indicator_config.dart';
// import 'ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'drawing_tools_config.dart';
import 'drawing_tools_repository.dart';

// import 'ma_env_indicator/ma_env_indicator_config.dart';
// import 'macd_indicator/macd_indicator_config.dart';
// import 'parabolic_sar/parabolic_sar_indicator_config.dart';
// import 'rainbow_indicator/rainbow_indicator_config.dart';
// import 'rsi/rsi_indicator_config.dart';
// import 'williams_r/williams_r_indicator_config.dart';
// import 'zigzag_indicator/zigzag_indicator_config.dart';

/// Drawing tools dialog with available drawing tools.
class DrawingToolsDialog extends StatefulWidget {
  @override
  _DrawingToolsDialogState createState() => _DrawingToolsDialogState();
}

class _DrawingToolsDialogState extends State<DrawingToolsDialog> {
  String? _selectedDrawingTool;

  @override
  Widget build(BuildContext context) {
    final DrawingToolsRepository repo = context.watch<DrawingToolsRepository>();

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
                  // Add new drawing tools here.
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
                onPressed: _selectedDrawingTool != null
                    ? () {
                        repo.add(_selectedDrawingTool! as DrawingToolsConfig);
                        setState(() {});
                      }
                    : null,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.drawingTools.length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.drawingTools[index].getItem(
                (DrawingToolsConfig updatedConfig) =>
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
