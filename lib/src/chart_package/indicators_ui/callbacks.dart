import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'indicator_config.dart';

/// Callback which takes chart's list of ticks and creates the indicator [Series].
typedef IndicatorBuilder = Series Function(List<Tick> ticks);

/// Callback to call whenever an indicator was added with the [key] and [indicatorConfig].
typedef OnAddIndicator = Function(String key, IndicatorConfig indicatorConfig);
