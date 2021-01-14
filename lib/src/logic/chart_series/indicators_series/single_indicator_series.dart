import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/foundation.dart';

import '../data_series.dart';

/// Function to get a [DataPainter] object to paint the data.
typedef DataPainterCreator = DataPainter<DataSeries<Tick>> Function(
  Series series,
);

/// Single indicator series.
///
/// Can be used to make indicators by providing two functions for making the of this
/// series painter and the indicator that will calculate the result from [inputIndicator]
///
/// Another approach for making single series indicators would be extending [AbstractSingleIndicatorSeries].
/// And implement `createPainter` and `initializeIndicator` methods.
class SingleIndicatorSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  ///
  /// [inputIndicator]  The indicator that returned indicator from [indicatorCreator]
  ///                   will calculate the its results on.
  /// [options]         The options of indicator.
  SingleIndicatorSeries({
    @required this.painterCreator,
    @required this.indicatorCreator,
    @required Indicator inputIndicator,
    @required IndicatorOptions options,
    String id,
  }) : super(inputIndicator, id, options);

  /// Function which will be called to get the painter object of this class.
  final DataPainterCreator painterCreator;

  /// Function which will be called to get the indicator that will eventually calculate the result.
  final CachedIndicator Function() indicatorCreator;

  @override
  SeriesPainter<Series> createPainter() => painterCreator?.call(this);

  @override
  CachedIndicator initializeIndicator() => indicatorCreator?.call();
}
