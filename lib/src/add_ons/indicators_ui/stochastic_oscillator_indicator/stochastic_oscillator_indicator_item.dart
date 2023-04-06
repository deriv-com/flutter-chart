import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:flutter/material.dart';

/// Stochastic Oscillator indicator item in the list of indicator which provide
/// this indicators options menu.
class StochasticOscillatorIndicatorItem extends IndicatorItem {
  /// Initializes
  const StochasticOscillatorIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    StochasticOscillatorIndicatorConfig config =
        const StochasticOscillatorIndicatorConfig(),
  }) : super(
          key: key,
          title: 'Stochastic Oscillator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      StochasticOscillatorIndicatorItemState();
}

/// StochasticOscillatorIndicatorItemState class
class StochasticOscillatorIndicatorItemState
    extends IndicatorItemState<StochasticOscillatorIndicatorConfig> {
  int? _period;
  double? _overBoughtPrice;
  double? _overSoldPrice;
  String? _field;
  bool? _isSmooth;
  bool? _showZones;

  @override
  StochasticOscillatorIndicatorConfig createIndicatorConfig() =>
      StochasticOscillatorIndicatorConfig(
        period: _currentPeriod,
        overBoughtPrice: _currentOverBoughtPrice,
        overSoldPrice: _currentOverSoldPrice,
        fieldType: _currentField,
        isSmooth: _currentIsSmooth,
        showZones: _currentShowZones,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildFieldTypeMenu(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
          buildIsSmoothField(),
          buildShowZonesField(),
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
              initialValue: _currentPeriod.toString(),
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

  int get _currentPeriod =>
      _period ?? (widget.config as StochasticOscillatorIndicatorConfig).period;

  Widget _buildFieldTypeMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelField,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: _currentField,
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
            onChanged: (String? newField) => setState(
              () {
                _field = newField;
                updateIndicator();
              },
            ),
          )
        ],
      );

  String get _currentField =>
      _field ??
      (widget.config as StochasticOscillatorIndicatorConfig).fieldType;

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
              initialValue: _currentOverBoughtPrice.toString(),
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

  double get _currentOverBoughtPrice =>
      _overBoughtPrice ??
      (widget.config as StochasticOscillatorIndicatorConfig).overBoughtPrice;

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
              initialValue: _currentOverSoldPrice.toString(),
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

  double get _currentOverSoldPrice =>
      _overSoldPrice ??
      (widget.config as StochasticOscillatorIndicatorConfig).overSoldPrice;

  /// Builds is Smooth option
  @protected
  Widget buildIsSmoothField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelIsSmooth,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _currentIsSmooth,
            onChanged: (bool value) {
              setState(() {
                _isSmooth = value;
              });
              updateIndicator();
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      );

  bool get _currentIsSmooth =>
      _isSmooth ??
      (widget.config as StochasticOscillatorIndicatorConfig).isSmooth;

  /// Builds buildShowZones option
  @protected
  Widget buildShowZonesField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelShowZones,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _currentShowZones,
            onChanged: (bool value) {
              setState(() {
                _showZones = value;
              });
              updateIndicator();
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      );

  bool get _currentShowZones =>
      _showZones ??
      (widget.config as StochasticOscillatorIndicatorConfig).showZones;
}
