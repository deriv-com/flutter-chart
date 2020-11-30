import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'bollinger_bands_indicator_config.dart';

/// Moving average indicator
class BollingerBandsIndicatorItem extends IndicatorItem {
  /// Initializes
  BollingerBandsIndicatorItem({
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
  IndicatorItemState createIndicatorItemState() =>
      BollingerBandsIndicatorItemState();
}

/// BollingerBandsIndicatorItem State class
class BollingerBandsIndicatorItemState
    extends IndicatorItemState<BollingerBandsIndicatorConfig> {
  MovingAverageType _type;
  int _period;
  double _standardDeviation;

  @override
  BollingerBandsIndicatorConfig createIndicatorConfig() =>
      BollingerBandsIndicatorConfig(
        (List<Tick> ticks) => BollingerBandSeries(ticks,
            period: _period,
            movingAverageType: _type,
            standardDeviationFactor: _standardDeviation),
        period: _period,
        movingAverageType: _type,
        standardDeviation: _standardDeviation,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _type = _getCurrentType();
    _period = _getCurrentPeriod();
    _standardDeviation = _getCurrentStandardDeviation();
  }

  @override
  Widget getIndicatorOptions() => Column(
        children: [
          Row(
            children: <Widget>[
              const Text('Type: ', style: const TextStyle(fontSize: 12)),
              DropdownButton<MovingAverageType>(
                value: _getCurrentType(),
                items: MovingAverageType.values
                    .map<DropdownMenuItem<MovingAverageType>>(
                        (MovingAverageType type) =>
                            DropdownMenuItem<MovingAverageType>(
                              value: type,
                              child: Text(
                                '${getEnumValue(type)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ))
                    .toList(),
                onChanged: (MovingAverageType newType) => setState(
                  () {
                    _type = newType;
                    widget.onAddIndicator
                        ?.call(getIndicatorKey(), createIndicatorConfig());
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const Text('Period: ', style: const TextStyle(fontSize: 12)),
              SizedBox(
                width: 20,
                child: TextFormField(
                  style: const TextStyle(fontSize: 12),
                  initialValue: _getCurrentPeriod().toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (String text) {
                    if (text.isNotEmpty) {
                      _period = int.tryParse(text);
                    } else {
                      _period = 15;
                    }
                    widget.onAddIndicator
                        ?.call(getIndicatorKey(), createIndicatorConfig());
                  },
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              const Text('Standard Deviation: ',
                  style: const TextStyle(fontSize: 12)),
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
                    widget.onAddIndicator
                        ?.call(getIndicatorKey(), createIndicatorConfig());
                  },
                ),
              )
            ],
          ),
        ],
      );

  MovingAverageType _getCurrentType() =>
      getConfig()?.movingAverageType ?? MovingAverageType.simple;

  int _getCurrentPeriod() => getConfig()?.period ?? 15;

  double _getCurrentStandardDeviation() => getConfig()?.standardDeviation ?? 2;
}
