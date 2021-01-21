import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import 'indicator_config.dart';

/// A function which takes list of ticks and creates the indicator [Series].
typedef IndicatorBuilder = Series Function(List<Tick> ticks);

/// A function which takes list of ticks and creates an Indicator on it.
typedef FieldIndicatorBuilder = Indicator Function(
  List<Tick> ticks,
);

/// Callback to call whenever an indicator was added with the [key] and [indicatorConfig].
typedef OnAddIndicator = Function(String key, IndicatorConfig indicatorConfig);
