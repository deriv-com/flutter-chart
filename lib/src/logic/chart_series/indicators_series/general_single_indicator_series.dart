import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/cupertino.dart';

typedef DataPainterCreator = DataPainter Function(Series series);
typedef IndicatorCreator = CachedIndicator Function();

class GeneralSingleIndicatorSeries extends SingleIndicatorSeries {
  GeneralSingleIndicatorSeries({
    @required this.painterCreator,
    @required this.indicatorCreator,
    @required Indicator<Tick> inputIndicator,
    @required IndicatorOptions options,
    String id,
  }) : super(inputIndicator, id, options);

  final DataPainterCreator painterCreator;
  final IndicatorCreator indicatorCreator;

  @override
  SeriesPainter<Series> createPainter() => painterCreator?.call(this);

  @override
  CachedIndicator<Tick> initializeIndicator() => indicatorCreator?.call();
}
