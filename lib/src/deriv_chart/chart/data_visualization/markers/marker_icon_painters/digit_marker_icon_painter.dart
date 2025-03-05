import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_end_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Digits contract painter
class DigitMarkerIconPainter extends MarkerGroupIconPainter {
  /// Initialize
  DigitMarkerIconPainter({this.pipSize = 4});

  /// PipSize
  int pipSize;

  @override
  void paintMarkerGroup(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    MarkerGroup markerGroup,
    EpochToX epochToX,
    QuoteToY quoteToY,
    PainterProps painterProps,
  ) {
    final Map<MarkerType, Offset> points = <MarkerType, Offset>{};

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

      if (marker.markerType != null) {
        points[marker.markerType!] = center;
      }
    }

    final Offset? startPoint = points[MarkerType.start];
    final Offset? exitPoint = points[MarkerType.exit];
    final Offset? endPoint = points[MarkerType.end];

    double opacity = 1;

    if (startPoint != null && (endPoint != null || exitPoint != null)) {
      opacity = calculateOpacity(startPoint.dx, exitPoint?.dx);
    }

    for (final ChartMarker marker in markerGroup.markers) {
      final Offset center = points[marker.markerType!]!;
      YAxisConfig.instance.yAxisClipping(canvas, size, () {
        _drawMarker(canvas, size, theme, marker, center, markerGroup.style,
            painterProps.zoom, opacity);
      });
    }
  }

  void _drawMarker(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      ChartMarker marker,
      Offset anchor,
      MarkerStyle style,
      double zoom,
      double opacity) {
    switch (marker.markerType) {
      case MarkerType.activeStart:
        paintStartLine(canvas, size, marker, anchor, style, zoom);
        break;

      case MarkerType.start:
        _drawStartPoint(
            canvas, size, theme, marker, anchor, style, zoom, opacity);
        break;

      case MarkerType.exit:
        final Paint paint = Paint()..color = style.backgroundColor;

        paintEndMarker(canvas, theme, anchor - Offset(1, 20 * zoom + 5),
            style.backgroundColor, zoom);

        final Color fontColor = theme.base08Color;
        _drawTick(canvas, marker, anchor, style, paint, fontColor, zoom);
        break;
      case MarkerType.tick:
        final Paint paint = Paint()
          ..color = style.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        final Color fontColor = style.backgroundColor;
        _drawTick(canvas, marker, anchor, style, paint, fontColor, zoom);
        break;
      default:
        break;
    }
  }

  void _drawTick(Canvas canvas, Marker marker, Offset anchor, MarkerStyle style,
      Paint paint, Color fontColor, double zoom) {
    canvas
      ..drawCircle(
        anchor,
        8 * zoom,
        Paint()..color = Colors.white,
      )
      ..drawCircle(
        anchor,
        8 * zoom,
        paint,
      );

    final String lastChar =
        marker.quote.toStringAsFixed(pipSize).characters.last;
    final TextSpan span = TextSpan(
      text: lastChar,
      style: TextStyle(
        fontSize: 10 * zoom,
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

  void _drawStartPoint(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      ChartMarker marker,
      Offset anchor,
      MarkerStyle style,
      double zoom,
      double opacity) {
    if (marker.quote != 0) {
      paintStartMarker(
        canvas,
        anchor - Offset(20 * zoom / 2, 20 * zoom),
        style.backgroundColor.withOpacity(opacity),
        20 * zoom,
      );
    }

    if (marker.text != null) {
      final TextStyle textStyle = TextStyle(
        color: style.backgroundColor.withOpacity(opacity),
        fontSize: style.activeMarkerText.fontSize! * zoom,
        fontWeight: FontWeight.bold,
        backgroundColor: theme.base08Color.withOpacity(opacity),
      );

      final TextPainter textPainter = makeTextPainter(marker.text!, textStyle);

      final Offset iconShift =
          Offset(textPainter.width / 2, 20 * zoom + textPainter.height);

      paintWithTextPainter(
        canvas,
        painter: textPainter,
        anchor: anchor - iconShift,
        anchorAlignment: Alignment.centerLeft,
      );
    }
  }
}
