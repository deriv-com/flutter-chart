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
    for (final Marker marker in series.visibleEntries) {
      final Offset anchor = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );
      if (marker.direction == MarkerDirection.up) {
        _drawUpMarker(canvas, anchor);
      } else {
        _drawDownMarker(canvas, anchor);
      }
    }
  }

  void _drawUpMarker(Canvas canvas, Offset anchor) {
    final MarkerStyle style = series.style;

    canvas
      ..drawLine(
        anchor,
        anchor + Offset(0, -6),
        Paint()
          ..color = style.upColor
          ..strokeWidth = 1.5,
      )
      ..drawCircle(
        anchor + Offset(0, -18),
        12,
        Paint()..color = style.upColor,
      )
      ..drawCircle(
        anchor + Offset(0, -18),
        10,
        Paint()..color = Colors.black.withOpacity(0.32),
      )
      ..drawCircle(
        anchor,
        3,
        Paint()..color = style.upColor,
      )
      ..drawCircle(
        anchor,
        1.5,
        Paint()..color = Colors.black,
      );
  }

  void _drawDownMarker(Canvas canvas, Offset anchor) {
    final MarkerStyle style = series.style;

    canvas
      ..drawLine(
        anchor,
        anchor + Offset(0, 6),
        Paint()
          ..color = style.downColor
          ..strokeWidth = 1.5,
      )
      ..drawCircle(
        anchor + Offset(0, 18),
        12,
        Paint()..color = style.downColor,
      )
      ..drawCircle(
        anchor + Offset(0, 18),
        10,
        Paint()..color = Colors.black.withOpacity(0.32),
      )
      ..drawCircle(
        anchor,
        3,
        Paint()..color = style.downColor,
      )
      ..drawCircle(
        anchor,
        1.5,
        Paint()..color = Colors.black,
      );
  }
}
