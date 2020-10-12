import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import 'marker_series.dart';

/// A [DataPainter] for painting [MarkerPainter] data.
class MarkerPainter extends DataPainter<MarkerSeries> {
  /// Initializes
  MarkerPainter(MarkerSeries series) : super(series);

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final MarkerStyle style = series.style;

    for (final Marker marker in series.visibleEntries) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );
      canvas.drawCircle(
        center,
        5,
        Paint()..color = style.color,
      );
    }
  }
}
