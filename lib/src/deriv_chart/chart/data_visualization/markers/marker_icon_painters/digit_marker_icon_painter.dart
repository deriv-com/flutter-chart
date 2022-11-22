import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_icon_painter.dart';

/// Icon painter for Multipliers trade type
class DigitMarkerIconPainter extends MarkerIconPainter {
  @override
  void paintMarker(
    Canvas canvas,
    Offset center,
    Offset anchor,
    MarkerDirection direction,
    MarkerStyle style,
  ) {}

  @override
  void paintMarkerGroup(
    Canvas canvas,
    Size size,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    canvas.save();

    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};

    for (final Marker marker in markerGroup.markers) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

      if (marker.markerType != null) {
        points[marker.markerType!] = center;
      }

      _drawMarker(canvas, marker, center, markerGroup.style);
    }

    canvas.restore();
  }

  void _drawMarker(
      Canvas canvas, Marker marker, Offset anchor, MarkerStyle style) {
    final Paint paint = Paint()..color = style.backgroundColor;
    switch (marker.markerType) {
      case MarkerType.start:
        _paintIcon(
            canvas, Icons.location_on, anchor - const Offset(10, 20), style);

        if (marker.text != null) {
          final TextStyle textStyle = TextStyle(color: style.backgroundColor);

          final TextPainter textPainter =
              makeTextPainter(marker.text!, textStyle);

          final Offset iconShift =
              Offset(textPainter.width / 2, 20 + textPainter.height);

          paintWithTextPainter(
            canvas,
            painter: textPainter,
            anchor: anchor - iconShift,
            anchorAlignment: Alignment.centerLeft,
          );
        }
        break;

      case MarkerType.exit:
        final Paint paint = Paint()..color = style.backgroundColor;

        _paintIcon(
          canvas,
          Icons.flag_rounded,
          anchor - const Offset(5, 20 + 4),
          style,
        );
        const Color fontColor = Colors.white;
        _drawTick(canvas, marker, anchor, style, paint, fontColor);
        break;
      case MarkerType.current:
        final Paint paint = Paint()
          ..color = style.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        final Color fontColor = style.backgroundColor;
        _drawTick(canvas, marker, anchor, style, paint, fontColor);
        break;
      default:
        break;
    }
  }

  void _drawTick(Canvas canvas, Marker marker, Offset anchor, MarkerStyle style,
      Paint paint, Color fontColor) {
    canvas
      ..drawCircle(
        anchor,
        8,
        Paint()..color = Colors.white,
      )
      ..drawCircle(
        anchor,
        8,
        paint,
      );

    final String lastChar = marker.quote.toString().characters.last;
    final TextSpan span = TextSpan(
      text: lastChar,
      style: TextStyle(
        fontSize: 12,
        color: fontColor,
        fontWeight: FontWeight.bold,
      ),
    );

    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = span
      ..layout();

    painter.paint(
      canvas,
      anchor - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _paintIcon(
      Canvas canvas, IconData icon, Offset offset, MarkerStyle style) {
    const double iconSize = 20;
    const double innerIconSize = iconSize;

    TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: innerIconSize,
          fontFamily: icon.fontFamily,
          color: style.backgroundColor,
        ),
      )
      ..layout()
      ..paint(
        canvas,
        offset,
      );
  }
}
