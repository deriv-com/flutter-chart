import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import 'indicator_config.dart';

/// A function which takes list of ticks and creates the indicator [Series].
typedef IndicatorBuilder = Series Function(List<Tick> ticks);

/// A function which takes list of ticks and creates an Indicator on it.
typedef FieldIndicatorBuilder = Indicator<Tick> Function(
  IndicatorInput indicatorInput,
);

/// Callback to add a new indicator with [indicatorConfig].
typedef OnAddIndicator = Function(IndicatorConfig indicatorConfig);
