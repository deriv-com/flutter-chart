// @dart=2.9

import 'package:deriv_chart/src/deriv_chart/indicators_ui/alligator/alligator_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/bollinger_bands/bollinger_bands_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/donchian_channel/donchian_channel_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_repository.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_env_indicator/ma_env_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/parabolic_sar/parabolic_sar_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rainbow_indicator/rainbow_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/zigzag_indicator/zigzag_indicator_config.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './ma_indicator/ma_indicator_config.dart';

/// Indicators dialog with selected indicators.
class IndicatorsDialog extends StatefulWidget {
  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<IndicatorsDialog> {
  IndicatorConfig _selectedIndicator;

  @override
  Widget build(BuildContext context) {
    final IndicatorsRepository repo = context.watch<IndicatorsRepository>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<IndicatorConfig>(
                value: _selectedIndicator,
                hint: const Text('Select indicator'),
                items: <DropdownMenuItem<IndicatorConfig>>[
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Moving average'),
                    value: MAIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Moving average envelope'),
                    value: MAEnvIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Bollinger bands'),
                    value: BollingerBandsIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Donchian channel'),
                    value: DonchianChannelIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Alligator'),
                    value: AlligatorIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: const Text('Rainbow'),
                    value: RainbowIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('ZigZag'),
                    value: ZigZagIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Ichimoku Clouds'),
                    value: IchimokuCloudIndicatorConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('Parabolic SAR'),
                    value: ParabolicSARConfig(),
                  ),
                  const DropdownMenuItem<IndicatorConfig>(
                    child: Text('RSI'),
                    value: RSIIndicatorConfig(),
                  ),
                  // Add new indicators here.
                ],
                onChanged: (IndicatorConfig config) {
                  setState(() {
                    _selectedIndicator = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              RaisedButton(
                child: const Text('Add'),
                onPressed: _selectedIndicator != null
                    ? () async {
                        await repo.add(_selectedIndicator);
                        setState(() {});
                      }
                    : null,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.indicators.length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.indicators[index].getItem(
                (IndicatorConfig updatedConfig) =>
                    repo.updateAt(index, updatedConfig),
                () async {
                  await repo.removeAt(index);
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
