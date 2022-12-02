import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_icon_painter.dart';

/// Icon painter for Multipliers trade type
class TickMarkerIconPainter extends MarkerIconPainter {
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

      _drawMarker(canvas, size, marker, center, markerGroup.style);
    }

    _drawBarriers(canvas, points, markerGroup.style);

    canvas.restore();
  }

  void _drawBarriers(
      Canvas canvas, Map<MarkerType, Offset> points, MarkerStyle style) {
    final Paint paint = Paint()..color = style.backgroundColor;
    final Offset? _entryTickOffset = points[MarkerType.entry];
    final Offset? _startTickOffset =
        points[MarkerType.start] ?? points[MarkerType.activeStart];
    final Offset? _currentTickOffset = points[MarkerType.current];
    final Offset? _endTickOffset = points[MarkerType.end];
    final Offset? _exitTickOffset = points[MarkerType.exit];

    if (_entryTickOffset != null) {
      paintHorizontalDashedLine(
        canvas,
        _startTickOffset!.dx,
        _entryTickOffset.dx,
        _startTickOffset.dy,
        style.backgroundColor,
        1,
        dashWidth: 1,
        dashSpace: 1,
      );
    }

    if (_entryTickOffset != null &&
        (_currentTickOffset != null || _endTickOffset != null)) {
      canvas.drawLine(
          _entryTickOffset!, _currentTickOffset ?? _endTickOffset!, paint);
    }

    if (_exitTickOffset != null) {
      final Offset? _topOffset = _exitTickOffset.dy < _endTickOffset!.dy
          ? _exitTickOffset
          : _endTickOffset;
      final Offset? _bottomOffset = _exitTickOffset.dy > _endTickOffset.dy
          ? _exitTickOffset
          : _endTickOffset;

      paintVerticalDashedLine(
        canvas,
        _exitTickOffset.dx,
        _topOffset!.dy,
        _bottomOffset!.dy,
        style.backgroundColor,
        1,
        dashWidth: 2,
        dashSpace: 2,
      );
    }
  }

  void _drawMarker(Canvas canvas, Size size, Marker marker, Offset anchor,
      MarkerStyle style) {
    final Paint paint = Paint()..color = style.backgroundColor;
    switch (marker.markerType) {
      case MarkerType.activeStart:
      case MarkerType.start:
        _drawStartPoint(canvas, size, marker, anchor, style);
        break;
      case MarkerType.entry:
        canvas.drawCircle(
          anchor,
          2,
          paint,
        );
        break;
      case MarkerType.end:
        _paintEndIcon(canvas, anchor - const Offset(1, 20), style);
        break;
      case MarkerType.exit:
        canvas.drawCircle(
          anchor,
          2,
          paint,
        );
        break;
      case MarkerType.current:
        canvas.drawCircle(
          anchor,
          2,
          paint,
        );
        break;
      default:
        break;
    }
  }

  void _drawStartPoint(Canvas canvas, Size size, Marker marker, Offset anchor,
      MarkerStyle style) {
    _paintIcon(canvas, Icons.location_on, anchor - const Offset(10, 20), style);

    if (marker.markerType == MarkerType.activeStart) {
      paintVerticalDashedLine(
        canvas,
        anchor.dx,
        10,
        size.height - 10,
        style.backgroundColor,
        1,
        dashWidth: 6,
      );

      if (marker.text != null) {
        final TextStyle textStyle = TextStyle(
          color: style.backgroundColor,
          fontSize: style.activeMarkerText.fontSize,
          fontWeight: FontWeight.bold,
        );

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
    }
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

  void _paintEndIcon(Canvas canvas, Offset center, MarkerStyle style) {
    canvas
      ..save()
      ..translate(
        center.dx,
        center.dy,
      )
      ..scale(1);

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(1);

    // This path was generated with http://demo.qunee.com/svg2canvas/.
    final Path path = Path()
      ..moveTo(2, 2)
      ..lineTo(18, 2)
      ..lineTo(18, 12)
      ..lineTo(2, 12)
      ..close();

    final Path flagPath = Path()
      ..moveTo(2, 0)
      ..lineTo(2, 1)
      ..lineTo(19, 1)
      ..lineTo(19, 12)
      ..lineTo(2, 12)
      ..lineTo(2, 20)
      ..lineTo(1, 20)
      ..lineTo(1, 0)
      ..lineTo(2, 0)
      ..close()
      ..moveTo(18, 8)
      ..lineTo(15, 8)
      ..lineTo(15, 11)
      ..lineTo(18, 11)
      ..lineTo(18, 8)
      ..close()
      ..moveTo(12, 8)
      ..lineTo(9, 8)
      ..lineTo(9, 11)
      ..lineTo(12, 11)
      ..lineTo(12, 8)
      ..close()
      ..moveTo(6, 8)
      ..lineTo(3, 8)
      ..lineTo(3, 11)
      ..lineTo(6, 11)
      ..lineTo(6, 8)
      ..close()
      ..moveTo(15, 5)
      ..lineTo(12, 5)
      ..lineTo(12, 8)
      ..lineTo(15, 8)
      ..lineTo(15, 5)
      ..close()
      ..moveTo(9, 5)
      ..lineTo(6, 5)
      ..lineTo(6, 8)
      ..lineTo(9, 8)
      ..lineTo(9, 5)
      ..close()
      ..moveTo(6, 2)
      ..lineTo(3, 2)
      ..lineTo(3, 5)
      ..lineTo(6, 5)
      ..lineTo(6, 2)
      ..close()
      ..moveTo(18, 2)
      ..lineTo(15, 2)
      ..lineTo(15, 5)
      ..lineTo(18, 5)
      ..lineTo(18, 2)
      ..close()
      ..moveTo(12, 2)
      ..lineTo(9, 2)
      ..lineTo(9, 5)
      ..lineTo(12, 5)
      ..lineTo(12, 2)
      ..close()
      ..fillType = PathFillType.evenOdd;

    final Paint flagPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = style.backgroundColor.withOpacity(1);

    canvas
      ..drawPath(path, paint)
      ..drawPath(flagPath, flagPaint)
      ..restore();
  }
}
