import 'package:deriv_chart/src/logic/chart_series/candle_series/candle_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/candle_series/candle_type_series.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';

/// CandleStick series
class CandleSeries extends OHLCTypeSeries {
  /// Initializes
  CandleSeries(
    List<Candle> entries, {
    String id,
    CandleStyle style,
  }) : super(entries, id, style: style ?? const CandleStyle());

  @override
  void createRenderable() => rendererable = CandleRenderable(this);
}
