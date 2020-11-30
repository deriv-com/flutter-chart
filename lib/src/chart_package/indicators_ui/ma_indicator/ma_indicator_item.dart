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
  MAIndicatorItem({
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
  IndicatorItemState createIndicatorItemState() => MAIndicatorItemState();
}

/// MAIndicatorItem State class
class MAIndicatorItemState extends IndicatorItemState<MAIndicatorConfig> {
  MovingAverageType _type;
  int _period;

  @override
  MAIndicatorConfig createIndicatorConfig() => MAIndicatorConfig(
        (List<Tick> ticks) => MASeries(
          ticks,
          period: _period,
          type: _type,
          style: const LineStyle(
              color: Colors.yellowAccent, hasArea: false, thickness: 0.6),
        ),
        period: _period,
        type: _type,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _type = _getCurrentType();
    _period = _getCurrentPeriod();
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
          )
        ],
      );

  MovingAverageType _getCurrentType() =>
      getConfig()?.type ?? MovingAverageType.simple;

  int _getCurrentPeriod() => getConfig()?.period ?? 15;
}
