import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/rsi/rsi_indicator_config.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
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
        period: _getCurrentPeriod(),
        overBoughtPrice: _getCurrentOverBoughtPrice(),
        overSoldPrice: _getCurrentOverSoldPrice(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
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
      _period ?? (widget.config as WilliamsRIndicatorConfig)?.period ?? 14;

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
                  _overBoughtPrice = -20;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  double _getCurrentOverBoughtPrice() =>
      _overBoughtPrice ??
      (widget.config as WilliamsRIndicatorConfig)?.overBoughtPrice ??
      -20;

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
                  _overSoldPrice = -80;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  double _getCurrentOverSoldPrice() =>
      _overSoldPrice ??
      (widget.config as WilliamsRIndicatorConfig)?.overSoldPrice ??
      -80;
}
