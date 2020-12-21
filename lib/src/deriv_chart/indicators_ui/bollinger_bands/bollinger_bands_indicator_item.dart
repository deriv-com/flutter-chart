import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'bollinger_bands_indicator_config.dart';

/// Bollinger Bands indicator item in the list of indicator which provide this
/// indicators options menu.
class BollingerBandsIndicatorItem extends IndicatorItem {
  /// Initializes
  const BollingerBandsIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Bollinger Bands',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      BollingerBandsIndicatorItemState();
}

/// BollingerBandsIndicatorItem State class
class BollingerBandsIndicatorItemState extends MAIndicatorItemState {
  double _standardDeviation;

  @override
  BollingerBandsIndicatorConfig createIndicatorConfig() =>
      BollingerBandsIndicatorConfig(
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        standardDeviation: _getCurrentStandardDeviation(),
        fieldType: getCurrentField(),
        feildIndicatorBuilder: filedIndicatorBuilders,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildMATypeMenu(),
          Row(
            children: <Widget>[
              buildPeriodField(),
              const SizedBox(width: 10),
              buildFieldTypeMenu()
            ],
          ),
          _buildSDMenu(),
        ],
      );

  Widget _buildSDMenu() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelStandardDeviation,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _getCurrentStandardDeviation().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _standardDeviation = double.tryParse(text);
                } else {
                  _standardDeviation = 2;
                }
                updateIndicator();
              },
            ),
          )
        ],
      );

  double _getCurrentStandardDeviation() {
    final BollingerBandsIndicatorConfig config = getConfig();
    return _standardDeviation ?? config?.standardDeviation ?? 2;
  }
}
