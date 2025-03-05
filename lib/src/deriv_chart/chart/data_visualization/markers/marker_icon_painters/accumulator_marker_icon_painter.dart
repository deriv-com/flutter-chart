import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/painter_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/tick_marker_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// Accumulator contract painter
class AccumulatorMarkerIconPainter extends TickMarkerIconPainter {
  /// Constructor
  AccumulatorMarkerIconPainter({this.fontSize});

  /// font size for web desktop / responsive
  final double? fontSize;

  Offset _getOffset(
    ChartMarker marker,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) =>
      Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );

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
    super.paintMarkerGroup(
      canvas,
      size,
      theme,
      markerGroup,
      epochToX,
      quoteToY,
      painterProps,
    );

    final Map<MarkerType, ChartMarker> markers = <MarkerType, ChartMarker>{};

    for (final ChartMarker marker in markerGroup.markers) {
      if (marker.markerType != null) {
        markers[marker.markerType!] = marker;
      }
    }

    final ChartMarker? lowMarker = markers[MarkerType.lowBarrier];
    final ChartMarker? highMarker = markers[MarkerType.highBarrier];
    final ChartMarker? endMarker = markers[MarkerType.end];

    final ChartMarker? previousTickMarker = markers[MarkerType.previousTick];

    if (lowMarker != null && highMarker != null) {
      final Offset lowOffset = _getOffset(lowMarker, epochToX, quoteToY);
      final Offset highOffset = _getOffset(highMarker, epochToX, quoteToY);

      final double endLeft = endMarker != null
          ? _getOffset(endMarker, epochToX, quoteToY).dx
          : size.width;

      _drawShadedBarriers(
        canvas: canvas,
        size: size,
        painterProps: painterProps,
        lowMarker: lowMarker,
        highMarker: highMarker,
        endLeft: endLeft,
        startLeft: lowOffset.dx,
        top: highOffset.dy,
        markerGroup: markerGroup,
        bottom: lowOffset.dy,
        previousTickMarker: previousTickMarker,
      );
    }
  }

  bool _hasPersistentBorders(MarkerGroup markerGroup) {
    return markerGroup.props.hasPersistentBorders;
  }

  void _drawShadedBarriers({
    required Canvas canvas,
    required Size size,
    required PainterProps painterProps,
    required ChartMarker lowMarker,
    required ChartMarker highMarker,
    required double endLeft,
    required double startLeft,
    required double top,
    required MarkerGroup markerGroup,
    required double bottom,
    ChartMarker? previousTickMarker,
  }) {
    final double endTop = size.height;

    final bool hasPersistentBorders = _hasPersistentBorders(markerGroup);

    final bool isTopVisible =
        top < endTop && (top >= 0 || !hasPersistentBorders);
    final bool isBottomVisible = bottom < endTop;
    // using 2 instead of 0 to distance the top barrier line
    // from the top of the chart and make it clearly visible:
    final double persistentTop = top < 0 && hasPersistentBorders ? 2 : endTop;
    final double displayedTop = isTopVisible ? top : persistentTop;
    final double displayedBottom = isBottomVisible ? bottom : endTop;
    final bool isStartLeftVisible = startLeft < endLeft;

    final double middleTop = bottom - (bottom - top).abs() / 2;

    final Color barrierColor = lowMarker.color ?? Colors.blue;
    final Paint paint = Paint()
      ..color = barrierColor
      ..style = PaintingStyle.fill;

    final Color shadeColor = barrierColor.withOpacity(0.08);

    if (!isStartLeftVisible) {
      return;
    }

    final TextStyle textStyle = TextStyle(
      color: barrierColor,
      fontSize: fontSize,
    );

    YAxisConfig.instance.yAxisClipping(canvas, size, () {
      if (previousTickMarker != null && previousTickMarker.color != null) {
        _drawPreviousTickBarrier(
          size,
          canvas,
          startLeft,
          endLeft,
          middleTop,
          previousTickMarker.color!,
          barrierColor,
        );
      }

      if (isTopVisible || hasPersistentBorders) {
        final Path path = Path()
          ..moveTo(startLeft + 2.5, displayedTop)
          ..lineTo(startLeft - 2.5, displayedTop)
          ..lineTo(startLeft, displayedTop + 4.5)
          ..lineTo(startLeft + 2.5, displayedTop)
          ..close();

        canvas.drawPath(path, paint);

        paintHorizontalDashedLine(
          canvas,
          startLeft - 2.5,
          endLeft,
          displayedTop,
          barrierColor,
          1.5,
          dashSpace: 0,
        );

        // draw difference between high barrier and previous spot price
        if (highMarker.text != null) {
          final TextPainter textPainter =
              makeTextPainter(highMarker.text!, textStyle);
          paintWithTextPainter(
            canvas,
            painter: textPainter,
            anchor: Offset(endLeft - YAxisConfig.instance.cachedLabelWidth! - 1,
                displayedTop - 10),
            anchorAlignment: Alignment.centerRight,
          );
        }
      }
      if (isBottomVisible || hasPersistentBorders) {
        final Path path = Path()
          ..moveTo(startLeft + 2.5, displayedBottom)
          ..lineTo(startLeft - 2.5, displayedBottom)
          ..lineTo(startLeft, displayedBottom - 4.5)
          ..lineTo(startLeft + 2.5, displayedBottom)
          ..close();

        canvas.drawPath(path, paint);

        paintHorizontalDashedLine(
          canvas,
          startLeft - 2.5,
          endLeft,
          displayedBottom,
          barrierColor,
          1.5,
          dashSpace: 0,
        );

        // draw difference between low barrier and previous spot price
        if (lowMarker.text != null) {
          final TextPainter textPainter =
              makeTextPainter(lowMarker.text!, textStyle);

          paintWithTextPainter(
            canvas,
            painter: textPainter,
            anchor: Offset(endLeft - YAxisConfig.instance.cachedLabelWidth! - 1,
                displayedBottom + 12),
            anchorAlignment: Alignment.centerRight,
          );
        }
      }

      final Paint rectPaint = Paint()..color = shadeColor;

      canvas.drawRect(
        Rect.fromLTRB(startLeft, displayedTop, endLeft, displayedBottom),
        rectPaint,
      );
    });
  }

  void _drawPreviousTickBarrier(
    Size size,
    Canvas canvas,
    double startX,
    double endX,
    double y,
    Color circleColor,
    Color barrierColor,
  ) {
    canvas.drawCircle(
      Offset(startX, y),
      1.5,
      Paint()..color = circleColor,
    );

    paintHorizontalDashedLine(
      canvas,
      startX,
      endX,
      y,
      barrierColor,
      1.5,
      dashWidth: 2,
      dashSpace: 4,
    );
  }
}
