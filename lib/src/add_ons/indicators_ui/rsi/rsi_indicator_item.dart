import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/oscillator_limit.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'rsi_indicator_config.dart';

/// RSI indicator item in the list of indicator which provide this
/// indicators options menu.
class RSIIndicatorItem extends IndicatorItem {
  /// Initializes
  const RSIIndicatorItem({
    Key? key,
    RSIIndicatorConfig config = const RSIIndicatorConfig(),
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'RSI',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      RSIIndicatorItemState();
}

/// RSIItem State class
class RSIIndicatorItemState extends IndicatorItemState<RSIIndicatorConfig> {
  int? _period;
  double? _overBoughtPrice;
  double? _overSoldPrice;
  String? _field;
  LineStyle? _overboughtStyle;
  LineStyle? _oversoldStyle;
  bool? _showZones;

  @override
  RSIIndicatorConfig createIndicatorConfig() => RSIIndicatorConfig(
        period: _getCurrentPeriod(),
        oscillatorLinesConfig: OscillatorLinesConfig(
          overboughtValue: _getCurrentOverBoughtPrice(),
          oversoldValue: _getCurrentOverSoldPrice(),
          overboughtStyle: _currentOverboughtStyle,
          oversoldStyle: _currentOversoldStyle,
        ),
        fieldType: _getCurrentField(),
        showZones: _currentShowZones,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildFieldTypeMenu(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
          _buildShowZonesField(),
        ],
      );

  Widget _buildShowZonesField() => Row(
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
      _period ?? (widget.config as RSIIndicatorConfig).period;

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
            onChanged: (String? newField) => setState(
              () {
                _field = newField;
                updateIndicator();
              },
            ),
          )
        ],
      );

  String _getCurrentField() =>
      _field ?? (widget.config as RSIIndicatorConfig).fieldType;

  Widget _buildOverBoughtPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        value: _getCurrentOverBoughtPrice(),
        color: _currentOverboughtStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overBoughtPrice = double.tryParse(text);
          } else {
            _overBoughtPrice = 80;
          }
          updateIndicator();
        },
        onColorChanged: (Color selectedColor) {
          setState(() {
            _overboughtStyle =
                _currentOverboughtStyle.copyWith(color: selectedColor);
          });
          updateIndicator();
        },
      );

  double _getCurrentOverBoughtPrice() =>
      _overBoughtPrice ??
      (widget.config as RSIIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtValue;

  Widget _buildOverSoldPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverSoldPrice,
        value: _getCurrentOverSoldPrice(),
        color: _currentOversoldStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overSoldPrice = double.tryParse(text);
          } else {
            _overSoldPrice = 20;
          }
          updateIndicator();
        },
        onColorChanged: (Color selectedColor) {
          setState(() {
            _oversoldStyle =
                _currentOversoldStyle.copyWith(color: selectedColor);
          });
          updateIndicator();
        },
      );

  double _getCurrentOverSoldPrice() =>
      _overSoldPrice ??
      (widget.config as RSIIndicatorConfig).oscillatorLinesConfig.oversoldValue;

  LineStyle get _currentOverboughtStyle =>
      _overboughtStyle ??
      (widget.config as RSIIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtStyle;

  LineStyle get _currentOversoldStyle =>
      _oversoldStyle ??
      (widget.config as RSIIndicatorConfig).oscillatorLinesConfig.oversoldStyle;

  bool get _currentShowZones =>
      _showZones ?? (widget.config as RSIIndicatorConfig).showZones;
}
