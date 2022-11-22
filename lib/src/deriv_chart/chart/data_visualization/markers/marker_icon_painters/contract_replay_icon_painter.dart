import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'marker_icon_painter.dart';

/// Icon painter for Contract replay
class ContractReplayIconPainter extends MarkerIconPainter {
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

    _drawBarriers(canvas, size, markerGroup, epochToX, quoteToY);

    for (final Marker marker in markerGroup.markers) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

      _drawMarker(canvas, marker, center, markerGroup.style);
    }

    canvas.restore();
  }

  void _drawBarriers(Canvas canvas, Size size, MarkerGroup markerGroup,
      EpochToX epochToX, QuoteToY quoteToY) {
    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};

    for (final Marker marker in markerGroup.markers) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

      if (marker.markerType != null) {
        points[marker.markerType!] = center;
      }
    }
    final Paint paint = Paint()
      ..color = const Color(0xFF999999)
      ..strokeWidth = 2;

    final Offset? _startTickOffset = points[MarkerType.start];
    final Offset? _exitTickOffset = points[MarkerType.exit];

    if (_startTickOffset != null) {
      canvas.drawLine(Offset(_startTickOffset.dx, 10),
          Offset(_startTickOffset.dx, size.height - 10), paint);
    }

    if (_exitTickOffset != null) {
      paintVerticalDashedLine(
        canvas,
        _exitTickOffset.dx,
        10,
        size.height - 10,
        const Color(0xFF999999),
        2,
        dashWidth: 6,
      );
    }
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
      case MarkerType.entry:
        _paintEntryMarker(canvas, anchor);
        break;
      // case MarkerType.end:
      //   _paintIcon(
      //       canvas, Icons.flag_rounded, anchor - const Offset(5, 20), style);
      //   break;
      case MarkerType.exit:
        _paintExitMarker(canvas, anchor, marker);
        break;
      // case MarkerType.current:
      //   canvas.drawCircle(
      //     anchor,
      //     2,
      //     paint,
      //   );
      //   break;
      default:
        break;
    }
  }

  void _paintEntryMarker(Canvas canvas, Offset anchor) {
    final Paint innerPaint = Paint()..color = const Color(0xFFFF444F);

    canvas.drawCircle(
      anchor,
      10,
      innerPaint,
    );

    final Paint borderPaint = Paint()..color = Colors.white;

    canvas.drawCircle(
      anchor,
      5,
      borderPaint,
    );
  }

  void _paintExitMarker(Canvas canvas, Offset anchor, Marker marker) {
    final Paint innerPaint = Paint()..color = Colors.white;

    canvas.drawCircle(
      anchor,
      10,
      innerPaint,
    );

    final Paint borderPaint = Paint()
      ..color = const Color(0xFF999999)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      anchor,
      10,
      borderPaint,
    );

    if (marker.text != null) {
      final TextSpan span = TextSpan(
        text: marker.text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w400,
          background: Paint()
            ..strokeWidth = 14
            ..color = const Color(0xFF4BB4B3)
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round,
        ),
      );
      final TextPainter painter = TextPainter(textDirection: TextDirection.ltr)
        ..text = span
        ..layout();

      final Offset textOffset =
          anchor - Offset(painter.width / 2, painter.height + 25);

      painter.paint(
        canvas,
        textOffset,
      );

      _paintExitTimeText(
          canvas, anchor - Offset(0, painter.height + 25), marker.epoch);
    }
  }

  void _paintExitTimeText(Canvas canvas, Offset anchor, int epoch) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch);
    final String time = DateFormat('HH:mm:ss').format(date.toUtc());

    final TextSpan icon = TextSpan(
      text: String.fromCharCode(Icons.access_time.codePoint),
      style: TextStyle(
        fontSize: 10,
        fontFamily: Icons.access_time.fontFamily,
      ),
    );

    final TextSpan span = TextSpan(
      text: time,
      style: const TextStyle(
        fontSize: 10,
      ),
    );

    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
    )
      ..text = TextSpan(children: <TextSpan>[icon, span])
      ..layout();

    painter.paint(
      canvas,
      anchor - Offset(painter.width / 2, painter.height + 10),
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
