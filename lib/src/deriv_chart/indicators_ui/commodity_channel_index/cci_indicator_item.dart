import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/commodity_channel_index/cci_indicator_config.dart';

import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

/// Commodity Channel Index indicator item in the list of indicator which
/// provides this indicators options menu.
class CCIIndicatorItem extends IndicatorItem {
  /// Initializes
  const CCIIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'CCI',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      CCIIndicatorItemState();
}

/// CCIItem State class
class CCIIndicatorItemState extends IndicatorItemState<CCIIndicatorConfig> {
  int _period;
  double _overBoughtPrice;
  double _overSoldPrice;

  @override
  CCIIndicatorConfig createIndicatorConfig() => CCIIndicatorConfig(
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
                  _period = 20;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  int _getCurrentPeriod() => _period ?? getConfig()?.period ?? 20;

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
      _overBoughtPrice ?? getConfig()?.overBoughtPrice ?? 100;

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
      _overSoldPrice ?? getConfig()?.overSoldPrice ?? -100;
}
