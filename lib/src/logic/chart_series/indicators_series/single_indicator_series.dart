import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/foundation.dart';

import '../data_series.dart';

/// Function to get a [DataPainter] object to paint the data.
typedef DataPainterCreator = DataPainter<DataSeries<Tick>> Function(
  Series series,
);

/// Single indicator series.
///
/// Can be used to make indicators series with a single [Indicator] by providing two functions,
/// [painterCreator]    for making the [SeriesPainter] of this series and
/// [indicatorCreator]  the indicator that will calculate the result from [inputIndicator]
///
/// Another approach for making single series indicators would be extending [AbstractSingleIndicatorSeries].
/// And implementing `createPainter` and `initializeIndicator` methods.
class SingleIndicatorSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  ///
  /// [inputIndicator]  The indicator that returned indicator from [indicatorCreator]
  ///                   will calculate the its results on.
  /// [options]         The options of indicator.
  SingleIndicatorSeries({
    @required this.painterCreator,
    @required this.indicatorCreator,
    @required Indicator<Tick> inputIndicator,
    @required IndicatorOptions options,
    String id,
  }) : super(inputIndicator, id, options);

  /// Function which will be called to get the painter object of this class.
  final DataPainterCreator painterCreator;

  /// Function which will be called to get the indicator that will eventually calculate the result.
  final CachedIndicator<Tick> Function() indicatorCreator;

  @override
  SeriesPainter<Series> createPainter() => painterCreator?.call(this);

  @override
  CachedIndicator<Tick> initializeIndicator() => indicatorCreator?.call();
}
