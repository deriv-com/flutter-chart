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

    _drawBarriers(canvas, points, markerGroup.style);

    canvas.restore();
  }

  void _drawBarriers(
      Canvas canvas, Map<MarkerType, Offset> points, MarkerStyle style) {
    final Paint paint = Paint()..color = style.backgroundColor;
    final Offset? _entryTickOffset = points[MarkerType.entry];
    final Offset? _startTickOffset = points[MarkerType.start];
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

    if (_currentTickOffset != null || _endTickOffset != null) {
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
        canvas.drawCircle(
          anchor,
          2,
          paint,
        );
        break;
      case MarkerType.end:
        _paintIcon(
            canvas, Icons.flag_rounded, anchor - const Offset(5, 20), style);
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
