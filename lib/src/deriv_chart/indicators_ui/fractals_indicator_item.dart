

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/callbacks.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/indicator_item.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/fractals_series/fractals_series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';


/// Rainbow indicator item in the list of indicator which provide this
/// indicators options menu.
class FractalsIndicatorItem extends IndicatorItem {
  /// Initializes
  const FractalsIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Fractals Indicator',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      FractalsIndicatorItemState();
}

/// Rainbow IndicatorItem State class
class FractalsIndicatorItemState extends IndicatorItemState<IndicatorConfig> {
  @override
  IndicatorConfig createIndicatorConfig() =>const FractalsIndicatorConfig();

  @override
  Widget getIndicatorOptions()=>Container();




}

/// Rainbow Indicator Config
class FractalsIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const FractalsIndicatorConfig() : super();


  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      FractalSeries(indicatorInput);

}