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
    int leftEpoch,
    int rightEpoch,
  ) : super(series, visibleEntries, leftEpoch, rightEpoch);

  @override
  void onPaint({Canvas canvas, Size size, Candle prevLastEntry}) {
    // TODO(ramin): paint line chart
  }
}
