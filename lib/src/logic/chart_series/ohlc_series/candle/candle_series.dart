import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/ohlc_series/candle/candle_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/ohlc_series/ohlc_type_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

import '../../data_series.dart';

/// CandleStick series
class CandleSeries extends OHLCTypeSeries {
  /// Initializes
  CandleSeries(
    List<Candle> entries, {
    String id,
    CandleStyle style,
  }) : super(entries, id, style: style);

  @override
  SeriesPainter<DataSeries<Candle>> createPainter() => CandlePainter(this);
}
