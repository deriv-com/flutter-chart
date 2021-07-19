import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

import '../../data_series.dart';
import '../../series_painter.dart';
import '../ohlc_type_series.dart';
import 'candle_painter.dart';

/// CandleStick series
class CandleSeries extends OHLCTypeSeries {
  /// Initializes
  CandleSeries(
    List<Candle> entries, {
    String? id,
    CandleStyle? style,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  }) : super(
          entries,
          id ?? 'CandleSeries',
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  @override
  SeriesPainter<DataSeries<Candle>> createPainter() => CandlePainter(this);
}
