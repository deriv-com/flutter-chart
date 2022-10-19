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
  DrawingToolsConfig? _selectedDrawingTool;

  @override
  Widget build(BuildContext context) {
    final DrawingToolsRepository repo = context.watch<DrawingToolsRepository>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<DrawingToolsConfig>(
                value: _selectedDrawingTool,
                hint: const Text('Select drawing tool'),
                items: const <DropdownMenuItem<DrawingToolsConfig>>[
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Channel'),
                    // value: MAIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Continuous'),
                    // value: MAEnvIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Fib Fan'),
                    // value: BollingerBandsIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Horizontal'),
                    // value: DonchianChannelIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Line'),
                    // value: AlligatorIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Ray'),
                    // value: RainbowIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Rectangle'),
                    // value: ZigZagIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Trend'),
                    // value: IchimokuCloudIndicatorConfig(),
                  ),
                  DropdownMenuItem<DrawingToolsConfig>(
                    child: Text('Vertical'),
                    // value: ParabolicSARConfig(),
                  ),
                  // Add new drawing tools here.
                ],
                onChanged: (DrawingToolsConfig? config) {
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
                        repo.add(_selectedDrawingTool!);
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
