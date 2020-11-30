import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
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

  @override
  IndicatorConfig createIndicatorConfig() => MAIndicatorConfig(
        (List<Tick> ticks) => MASeries(ticks, period: 15, type: _type),
        period: 15,
        type: _type,
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _type = _getCurrentType();
  }

  @override
  Widget getIndicatorOptions() => Row(
        children: [
          DropdownButton<MovingAverageType>(
            value: _getCurrentType(),
            items: MovingAverageType.values
                .map<DropdownMenuItem<MovingAverageType>>(
                    (MovingAverageType type) =>
                        DropdownMenuItem<MovingAverageType>(
                          value: type,
                          child: Text('${type.toString()}'),
                        ))
                .toList(),
            onChanged: (MovingAverageType newType) => setState(
              () {
                _type = newType;
                widget.onAddIndicator
                    ?.call(getIndicatorKey(), createIndicatorConfig());
              },
            ),
          )
        ],
      );

  MovingAverageType _getCurrentType() =>
      getConfig()?.type ?? MovingAverageType.simple;
}
