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
    series.tapAreas = <Rect>[];

    for (final Marker marker in series.visibleEntries) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );
      final Offset anchor = center;

      _drawMarker(canvas, center, anchor, marker.direction);

      // Update marker tap area.
      series.tapAreas.add(Rect.fromCenter(
        center: center,
        width: 24,
        height: 24,
      ));
    }
  }

  void _drawMarker(
      Canvas canvas, Offset center, Offset anchor, MarkerDirection direction) {
    final MarkerStyle style = series.style;
    final Color color =
        direction == MarkerDirection.up ? style.upColor : style.downColor;
    final double dir = direction == MarkerDirection.up ? 1 : -1;

    canvas
      ..drawLine(
        anchor,
        center,
        Paint()
          ..color = color
          ..strokeWidth = 1.5,
      )
      ..drawCircle(
        anchor,
        3,
        Paint()..color = color,
      )
      ..drawCircle(
        anchor,
        1.5,
        Paint()..color = Colors.black,
      )
      ..drawCircle(
        center,
        12,
        Paint()..color = color,
      )
      ..drawCircle(
        center,
        10,
        Paint()..color = Colors.black.withOpacity(0.32),
      );
    _drawArrow(canvas, center, const Size(12, 12), dir);
  }

  void _drawArrow(Canvas canvas, Offset center, Size size, double dir) {
    final Path path = Path();
    canvas
      ..save()
      ..translate(
        center.dx - size.width / 2,
        center.dy - (size.height / 2) * dir,
      )
      // 16x16 is original svg size
      ..scale(
        size.width / 16,
        size.height / 16 * dir,
      );

    // This path was generated with http://demo.qunee.com/svg2canvas/.
    path
      ..moveTo(9.41, 1.70999)
      ..cubicTo(9.22425, 1.52403, 9.00368, 1.37652, 8.76088, 1.27587)
      ..cubicTo(8.51808, 1.17522, 8.25783, 1.12341, 7.995, 1.12341)
      ..cubicTo(7.73217, 1.12341, 7.47192, 1.17522, 7.22912, 1.27587)
      ..cubicTo(6.98632, 1.37652, 6.76575, 1.52403, 6.58, 1.70999)
      ..lineTo(3, 5.24999)
      ..cubicTo(3.3743, 5.61946, 3.87907, 5.82662, 4.405, 5.82662)
      ..cubicTo(4.93093, 5.82662, 5.4357, 5.61946, 5.81, 5.24999)
      ..lineTo(7, 4.12999)
      ..lineTo(7, 15)
      ..lineTo(9, 14)
      ..lineTo(9, 4.12999)
      ..lineTo(10.13, 5.25999)
      ..cubicTo(10.5047, 5.63249, 11.0116, 5.84157, 11.54, 5.84157)
      ..cubicTo(12.0684, 5.84157, 12.5753, 5.63249, 12.95, 5.25999)
      ..lineTo(9.41, 1.70999);

    canvas
      ..drawPath(path, Paint()..color = Colors.white)
      ..restore();
  }
}
