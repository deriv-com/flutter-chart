import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';

/// Rainbow indicator item in the list of indicator which provide this
/// indicators options menu.
class StochasticOscillatorIndicatorItem extends IndicatorItem {
  /// Initializes
  const StochasticOscillatorIndicatorItem({
    Key key,
    StochasticOscillatorIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'Fractal Chaos Band Indicator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      StochasticOscillatorIndicatorItemState();
}

/// RSIItem State class
class StochasticOscillatorIndicatorItemState
    extends IndicatorItemState<StochasticOscillatorIndicatorConfig> {
  int _period;
  double _overBoughtPrice;
  double _overSoldPrice;
  String _field;

  @override
  StochasticOscillatorIndicatorConfig createIndicatorConfig() =>
      StochasticOscillatorIndicatorConfig(
        period: _getCurrentPeriod(),
        overBoughtPrice: _getCurrentOverBoughtPrice(),
        overSoldPrice: _getCurrentOverSoldPrice(),
        fieldType: _getCurrentField(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildFieldTypeMenu(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
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
              initialValue: _getCurrentPeriod().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _period = int.tryParse(text);
                } else {
                  _period = 14;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  int _getCurrentPeriod() =>
      _period ??
      (widget.config as StochasticOscillatorIndicatorConfig)?.period ??
      14;

  Widget _buildFieldTypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelField,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: _getCurrentField(),
            items: IndicatorConfig.supportedFieldTypes.keys
                .map<DropdownMenuItem<String>>(
                    (String fieldType) => DropdownMenuItem<String>(
                          value: fieldType,
                          child: Text(
                            '$fieldType',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ))
                .toList(),
            onChanged: (String newField) => setState(
              () {
                _field = newField;
                updateIndicator();
              },
            ),
          )
        ],
      );

  String _getCurrentField() =>
      _field ??
      (widget.config as StochasticOscillatorIndicatorConfig)?.fieldType ??
      'close';

  Widget _buildOverBoughtPriceField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelOverBoughtPrice,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _getCurrentOverBoughtPrice().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _overBoughtPrice = double.tryParse(text);
                } else {
                  _overBoughtPrice = 80;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  double _getCurrentOverBoughtPrice() =>
      _overBoughtPrice ??
      (widget.config as StochasticOscillatorIndicatorConfig)?.overBoughtPrice ??
      80;

  Widget _buildOverSoldPriceField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelOverSoldPrice,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _getCurrentOverSoldPrice().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _overSoldPrice = double.tryParse(text);
                } else {
                  _overSoldPrice = 20;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  double _getCurrentOverSoldPrice() =>
      _overSoldPrice ??
      (widget.config as StochasticOscillatorIndicatorConfig)?.overSoldPrice ??
      20;
}
