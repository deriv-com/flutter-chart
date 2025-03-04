import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/web_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_end_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_start_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_vertical_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Tick contract painter
class TickMarkerIconPainter extends MarkerGroupIconPainter {
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

    for (final WebMarker marker in markerGroup.markers) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

      if (marker.markerType != null && marker.markerType != MarkerType.tick) {
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

    _drawBarriers(
        canvas, size, points, markerGroup.style, opacity, painterProps);

    for (final WebMarker marker in markerGroup.markers) {
      final Offset center = points[marker.markerType!] ??
          Offset(
            epochToX(marker.epoch),
            quoteToY(marker.quote),
          );

      if (marker.markerType == MarkerType.entry &&
          points[MarkerType.entryTick] != null) {
        continue;
      }

      _drawMarker(canvas, size, theme, marker, center, markerGroup.style,
          painterProps.zoom, opacity);
    }
  }

  void _drawBarriers(Canvas canvas, Size size, Map<MarkerType, Offset> points,
      MarkerStyle style, double opacity, PainterProps painterProps) {
    final Color color = style.backgroundColor.withOpacity(opacity);
    final Paint paint = Paint()..color = color;
    final Offset? _entryOffset = points[MarkerType.entry];
    final Offset? _entryTickOffset = points[MarkerType.entryTick];
    final Offset? _startOffset = points[MarkerType.start];
    final Offset? _latestOffset = points[MarkerType.latestTickBarrier];
    final Offset? _endOffset = points[MarkerType.end];
    final Offset? _exitOffset = points[MarkerType.exit];

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      if (_entryOffset != null && _startOffset != null) {
        paintHorizontalDashedLine(
          canvas,
          _startOffset.dx,
          _entryOffset.dx,
          _startOffset.dy,
          color,
          1,
          dashWidth: 1,
          dashSpace: 1,
        );
      }

      if (_entryOffset != null &&
          (_latestOffset != null || _endOffset != null)) {
        final double dx = (_latestOffset?.dx ?? _endOffset?.dx)!;
        final double dy = (_latestOffset?.dy ?? _endOffset?.dy)!;

        canvas.drawLine(_entryOffset, Offset(dx, dy), paint);
      }

      if (_entryOffset != null && _entryTickOffset != null) {
        paintVerticalLine(
          canvas,
          _entryOffset,
          _entryTickOffset,
          color,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }

      if (_exitOffset != null && _endOffset != null) {
        paintVerticalLine(
          canvas,
          _exitOffset,
          _endOffset,
          color,
          1,
          dashWidth: 2,
          dashSpace: 2,
        );
      }
    });
  }

  void _drawMarker(Canvas canvas, Size size, ChartTheme theme, WebMarker marker,
      Offset anchor, MarkerStyle style, double zoom, double opacity) {
    final Color color = style.backgroundColor.withOpacity(opacity);

    final Paint paint = Paint()..color = color;

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      switch (marker.markerType) {
        case MarkerType.activeStart:
          paintStartLine(canvas, size, marker, anchor, style, zoom);
          break;
        case MarkerType.start:
          _drawStartPoint(
              canvas, size, theme, marker, anchor, style, zoom, opacity);
          break;
        case MarkerType.entry:
        case MarkerType.entryTick:
          _drawEntryPoint(canvas, theme, anchor, color, zoom, opacity);
          break;
        case MarkerType.end:
          paintEndMarker(canvas, theme, anchor - Offset(1, 20 * zoom),
              style.backgroundColor, zoom);
          break;
        case MarkerType.exit:
          canvas.drawCircle(
            anchor,
            3 * zoom,
            paint,
          );
          break;
        case MarkerType.tick:
          final Paint paint = Paint()..color = theme.base01Color;
          _drawTickPoint(canvas, anchor, paint, zoom);
          break;
        case MarkerType.latestTick:
          _drawTickPoint(canvas, anchor, paint, zoom);
          break;
        default:
          break;
      }
    });
  }

  void _drawTickPoint(Canvas canvas, Offset anchor, Paint paint, double zoom) {
    canvas.drawCircle(
      anchor,
      1.5 * zoom,
      paint,
    );
  }

  void _drawEntryPoint(Canvas canvas, ChartTheme theme, Offset anchor,
      Color color, double zoom, double opacity) {
    final Paint paint = Paint()
      ..color = theme.base08Color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final double radius = 3 * zoom;
    canvas.drawCircle(
      anchor,
      radius,
      paint,
    );
    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      anchor,
      radius,
      strokePaint,
    );
  }

  void _drawStartPoint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    WebMarker marker,
    Offset anchor,
    MarkerStyle style,
    double zoom,
    double opacity,
  ) {
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
        color: (marker.color ?? style.backgroundColor).withOpacity(opacity),
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
