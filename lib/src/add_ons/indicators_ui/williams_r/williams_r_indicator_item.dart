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
    Key key,
    WilliamsRIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
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
  int _period;
  double _overBoughtPrice;
  double _overSoldPrice;

  @override
  WilliamsRIndicatorConfig createIndicatorConfig() => WilliamsRIndicatorConfig(
      period: _getCurrentPeriod,
      oscillatorLimits: OscillatorLinesConfig(
        overBoughtPrice: _getCurrentOverBoughtPrice,
        overSoldPrice: _getCurrentOverSoldPrice,
      ));

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
        ],
      );

  Widget _buildPeriodField() => FieldWidget(
        initialValue: '14',
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

  int get _getCurrentPeriod =>
      _period ?? (widget.config as WilliamsRIndicatorConfig)?.period ?? 14;

  Widget _buildOverBoughtPriceField() => FieldWidget(
        initialValue: _getCurrentOverBoughtPrice.toString(),
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

  double get _getCurrentOverBoughtPrice =>
      _overBoughtPrice ??
      (widget.config as WilliamsRIndicatorConfig)
          ?.oscillatorLimits
          ?.overBoughtPrice ??
      -20;

  Widget _buildOverSoldPriceField() => FieldWidget(
        initialValue: _getCurrentOverSoldPrice.toString(),
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

  double get _getCurrentOverSoldPrice =>
      _overSoldPrice ??
      (widget.config as WilliamsRIndicatorConfig)
          ?.oscillatorLimits
          ?.overSoldPrice ??
      -80;
}
