import 'package:deriv_chart/src/chart_package/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/chart_package/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_item.dart';
import 'bollinger_bands_indicator_config.dart';

/// Bollinger Bands indicator item
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
        (List<Tick> ticks) => BollingerBandSeries(ticks,
            period: period,
            movingAverageType: type,
            standardDeviationFactor: _standardDeviation),
        period: period,
        movingAverageType: type,
        standardDeviation: _standardDeviation,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _standardDeviation = _getCurrentStandardDeviation();
  }

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
          const Text('Standard Deviation: ', style: TextStyle(fontSize: 12)),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 12),
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
    return config?.standardDeviation ?? 2;
  }
}
