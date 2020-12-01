import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ma_indicator_config.dart';

/// Moving average indicator
class MAIndicatorItem extends IndicatorItem {
  /// Initializes
  const MAIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Moving Average',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MAIndicatorItemState();
}

/// MAIndicatorItem State class
class MAIndicatorItemState extends IndicatorItemState<MAIndicatorConfig> {
  /// MA type
  @protected
  MovingAverageType type;
  
  /// MA period
  @protected
  int period;

  @override
  MAIndicatorConfig createIndicatorConfig() => MAIndicatorConfig(
        (List<Tick> ticks) => MASeries(
          ticks,
          period: period,
          type: type,
          style: const LineStyle(color: Colors.yellowAccent, thickness: 0.6),
        ),
        period: period,
        type: type,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    type = getCurrentType();
    period = getCurrentPeriod();
  }

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Type: ', style: TextStyle(fontSize: 12)),
              DropdownButton<MovingAverageType>(
                value: getCurrentType(),
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
                    type = newType;
                    updateIndicator();
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              const Text('Period: ', style: TextStyle(fontSize: 12)),
              SizedBox(
                width: 20,
                child: TextFormField(
                  style: const TextStyle(fontSize: 12),
                  initialValue: getCurrentPeriod().toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (String text) {
                    if (text.isNotEmpty) {
                      period = int.tryParse(text);
                    } else {
                      period = 15;
                    }
                    updateIndicator();
                  },
                ),
              )
            ],
          )
        ],
      );

  /// Gets Indicator current type.
  @protected
  MovingAverageType getCurrentType() =>
      getConfig()?.type ?? MovingAverageType.simple;

  /// Gets Indicator current period.
  @protected
  int getCurrentPeriod() => getConfig()?.period ?? 50;
}
