import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'smi_indicator_config.dart';

/// SMI indicator item in the list of indicator which provide this
/// indicators options menu.
class SMIIndicatorItem extends IndicatorItem {
  /// Initializes
  const SMIIndicatorItem({
    Key key,
    SMIIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'SMI',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      SMIIndicatorItemState();
}

/// SMIItem State class
class SMIIndicatorItemState extends IndicatorItemState<SMIIndicatorConfig> {
  int _period;
  double _overboughtValue;
  double _oversoldValue;

  @override
  SMIIndicatorConfig createIndicatorConfig() => SMIIndicatorConfig(
        period: _currentPeriod,
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
      _period ?? (widget.config as SMIIndicatorConfig)?.period ?? 14;

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
                  _overboughtValue = double.tryParse(text);
                } else {
                  _overboughtValue = 80;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  double _getCurrentOverBoughtPrice() =>
      _overboughtValue ??
      (widget.config as SMIIndicatorConfig)?.overboughtValue ??
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
                  _oversoldValue = double.tryParse(text);
                } else {
                  _oversoldValue = 20;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  double _getCurrentOverSoldPrice() =>
      _oversoldValue ??
      (widget.config as SMIIndicatorConfig)?.oversoldValue ??
      20;
}
