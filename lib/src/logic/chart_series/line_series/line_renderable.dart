import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/base_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/candle.dart';

/// Line renderable
class LineRenderable extends BaseRendererable {
  /// Initializes
  LineRenderable(
    BaseSeries series,
    List<Candle> visibleEntries,
    Candle prevLastCandle,
  ) : super(series, visibleEntries, prevLastCandle);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
  }) {
    // TODO(ramin): paint line chart
  }
}
