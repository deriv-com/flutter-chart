import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import '../oscillator_lines/oscillator_lines_config.dart';
import '../widgets/field_widget.dart';
import 'williams_r_indicator_config.dart';

/// WilliamsR indicator item in the list of indicator which provide this
/// indicators options menu.
class WilliamsRIndicatorItem extends IndicatorItem {
  /// Initializes
  const WilliamsRIndicatorItem({
    Key? key,
    WilliamsRIndicatorConfig config = const WilliamsRIndicatorConfig(),
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'WilliamsR',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      WilliamsRIndicatorItemState();
}

/// WilliamsRItem State class
class WilliamsRIndicatorItemState
    extends IndicatorItemState<WilliamsRIndicatorConfig> {
  int? _period;
  double? _overBoughtPrice;
  double? _overSoldPrice;
  bool? _showZones;

  @override
  WilliamsRIndicatorConfig createIndicatorConfig() => WilliamsRIndicatorConfig(
      period: _currentPeriod,
      showZones: _currentShowZones,
      oscillatorLimits: OscillatorLinesConfig(
        overboughtValue: _currentOverBoughtPrice,
        oversoldValue: _currentOverSoldPrice,
      ));

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
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

  Widget _buildPeriodField() => FieldWidget(
        initialValue: _currentPeriod.toString(),
        label: ChartLocalization.of(context).labelPeriod,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _period = int.tryParse(text);
          } else {
            _period = 14;
          }
          updateIndicator();
        },
      );

  int get _currentPeriod =>
      _period ?? (widget.config as WilliamsRIndicatorConfig).period;

  Widget _buildOverBoughtPriceField() => FieldWidget(
        initialValue: _currentOverBoughtPrice.toString(),
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overBoughtPrice = double.tryParse(text);
          } else {
            _overBoughtPrice = -20;
          }
          updateIndicator();
        },
      );

  double get _currentOverBoughtPrice =>
      _overBoughtPrice ??
      (widget.config as WilliamsRIndicatorConfig)
          .oscillatorLimits
          .overboughtValue;

  Widget _buildOverSoldPriceField() => FieldWidget(
        initialValue: _currentOverSoldPrice.toString(),
        label: ChartLocalization.of(context).labelOverSoldPrice,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overSoldPrice = double.tryParse(text);
          } else {
            _overSoldPrice = -80;
          }
          updateIndicator();
        },
      );

  double get _currentOverSoldPrice =>
      _overSoldPrice ??
      (widget.config as WilliamsRIndicatorConfig)
          .oscillatorLimits
          .oversoldValue;

  bool get _currentShowZones =>
      _showZones ?? (widget.config as WilliamsRIndicatorConfig).showZones;
}
