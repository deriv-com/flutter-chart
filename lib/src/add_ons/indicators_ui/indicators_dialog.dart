import 'package:deriv_chart/src/add_ons/extensions.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/commodity_channel_index/cci_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/roc/roc_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/dpo_indicator/dpo_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/gator/gator_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/smi/smi_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './ma_indicator/ma_indicator_config.dart';
import 'adx/adx_indicator_config.dart';
import 'alligator/alligator_indicator_config.dart';
import 'bollinger_bands/bollinger_bands_indicator_config.dart';
import 'donchian_channel/donchian_channel_indicator_config.dart';
import 'fcb_indicator/fcb_indicator_config.dart';
import 'ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'indicator_config.dart';
import 'ma_env_indicator/ma_env_indicator_config.dart';
import 'macd_indicator/macd_indicator_config.dart';
import 'parabolic_sar/parabolic_sar_indicator_config.dart';
import 'rainbow_indicator/rainbow_indicator_config.dart';
import 'rsi/rsi_indicator_config.dart';
import 'williams_r/williams_r_indicator_config.dart';
import 'zigzag_indicator/zigzag_indicator_config.dart';

/// Indicators dialog with selected indicators.
class IndicatorsDialog extends StatefulWidget {
  @override
  _IndicatorsDialogState createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<IndicatorsDialog> {
  IndicatorConfig? _selectedIndicator;

  @override
  Widget build(BuildContext context) {
    final Repository<IndicatorConfig> repo =
        context.watch<Repository<IndicatorConfig>>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<IndicatorConfig>(
                value: _selectedIndicator,
                hint: const Text('Select indicator'),
                items: const <DropdownMenuItem<IndicatorConfig>>[
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Moving average'),
                    value: MAIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Moving average envelope'),
                    value: MAEnvIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Bollinger bands'),
                    value: BollingerBandsIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Donchian channel'),
                    value: DonchianChannelIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Alligator'),
                    value: AlligatorIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Rainbow'),
                    value: RainbowIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('ZigZag'),
                    value: ZigZagIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Ichimoku Clouds'),
                    value: IchimokuCloudIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Parabolic SAR'),
                    value: ParabolicSARConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('RSI'),
                    value: RSIIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Commodity Channel Index'),
                    value: CCIIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('FCB'),
                    value: FractalChaosBandIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('StochasticOscillator'),
                    value: StochasticOscillatorIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('ADX'),
                    value: ADXIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('DPO'),
                    value: DPOIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Stochastic Momentum Index'),
                    value: SMIIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Williams %R'),
                    value: WilliamsRIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('AwesomeOscillator'),
                    value: AwesomeOscillatorIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('MACD'),
                    value: MACDIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Aroon'),
                    value: AroonIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Price Rate Of Changes'),
                    value: ROCIndicatorConfig(),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    child: Text('Gator Oscillator'),
                    value: GatorIndicatorConfig(),
                  )
                  // Add new indicators here.
                ],
                onChanged: (IndicatorConfig? config) {
                  setState(() {
                    _selectedIndicator = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: _selectedIndicator != null
                    ? () {
                        final IndicatorConfig config = _selectedIndicator!;
                        // TODO(Ramin): later this will handled internally by
                        // the repository itself.
                        final int postFixNumber =
                            repo.getNumberForNewAddOn(config);
                        repo.add(config.copyWith(number: postFixNumber));
                        setState(() {});
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
                (IndicatorConfig updatedConfig) =>
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
