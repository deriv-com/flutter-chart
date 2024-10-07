import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// LineOverlayPainter is a subclass of CustomPainter responsible for
/// drawing barriers on a chart based on selected line points.
class LineOverlayPainter extends CustomPainter {
  /// Creates a LineBarrierPainter.
  LineOverlayPainter(
    this.config, {
    required this.quoteToY,
    required this.epochToX,
    required this.chartConfig,
  });

  /// Line drawing tool configuration.
  final LineDrawingToolConfig config;

  /// Quote to Y conversion function.
  final QuoteToY quoteToY;

  /// Epoch to X conversion function.
  final EpochToX epochToX;

  /// Padding between the labels and the barriers.
  final double padding = 12;

  /// Chart configuration.
  final ChartConfig chartConfig;

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = config.edgePoints.first;
    final endPoint = config.edgePoints.last;

    final double startQuoteY = quoteToY(startPoint.quote);
    final double endQuoteY = quoteToY(endPoint.quote);
    final double startEpochX = epochToX(startPoint.epoch);
    final double endEpochX = epochToX(endPoint.epoch);

    final HorizontalBarrierStyle style =
        HorizontalBarrierStyle(color: config.lineStyle.color);

    final Paint paint = Paint()
      ..color = style.color
      ..strokeWidth = 1.0;

    final Paint barrierPaint = Paint()
      ..color = style.color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Draw quote labels and barriers on the vertical axis
    _drawQuoteLabelsAndBarriers(canvas, size, style, paint, barrierPaint,
        startQuoteY, endQuoteY, startPoint, endPoint);

    // Draw epoch labels and barriers on the horizontal axis
    _drawEpochLabelsAndBarriers(canvas, size, style, paint, barrierPaint,
        startEpochX, endEpochX, startPoint.epoch, endPoint.epoch);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawQuoteLabelsAndBarriers(
    Canvas canvas,
    Size size,
    HorizontalBarrierStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startQuoteY,
    double endQuoteY,
    EdgePoint startPoint,
    EdgePoint endPoint,
  ) {
    final TextPainter startQuotePainter = makeTextPainter(
        startPoint.quote.toStringAsFixed(chartConfig.pipSize), style.textStyle);
    final TextPainter endQuotePainter = makeTextPainter(
        endPoint.quote.toStringAsFixed(chartConfig.pipSize), style.textStyle);

    final Rect startQuoteArea = Rect.fromCenter(
      center: Offset(
          size.width - padding - startQuotePainter.width / 2, startQuoteY),
      width: startQuotePainter.width + padding,
      height: style.labelHeight,
    );
    final Rect endQuoteArea = Rect.fromCenter(
      center:
          Offset(size.width - padding - endQuotePainter.width / 2, endQuoteY),
      width: endQuotePainter.width + padding,
      height: style.labelHeight,
    );

    // Draw horizontal barrier
    final Rect horizontalBarrierRect = Rect.fromPoints(
      Offset(size.width - startQuoteArea.width - padding / 2, startQuoteY),
      Offset(size.width, endQuoteY),
    );
    canvas.drawRect(horizontalBarrierRect, barrierPaint);

    // Draw labels with backgrounds
    _drawLabelWithBackground(
        canvas, startQuoteArea, labelPaint, startQuotePainter);
    _drawLabelWithBackground(canvas, endQuoteArea, labelPaint, endQuotePainter);
  }

  void _drawEpochLabelsAndBarriers(
    Canvas canvas,
    Size size,
    HorizontalBarrierStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startEpochX,
    double endEpochX,
    int startEpoch,
    int endEpoch,
  ) {
    final String startEpochLabel = _formatEpochToDateTime(startEpoch);
    final String endEpochLabel = _formatEpochToDateTime(endEpoch);

    final TextPainter startEpochPainter =
        makeTextPainter(startEpochLabel, style.textStyle);
    final TextPainter endEpochPainter =
        makeTextPainter(endEpochLabel, style.textStyle);

    final Rect startEpochArea = Rect.fromCenter(
      center: Offset(
          startEpochX, size.height - startEpochPainter.height - padding / 2),
      width: startEpochPainter.width + padding,
      height: style.labelHeight,
    );

    final Rect endEpochArea = Rect.fromCenter(
      center: Offset(
          endEpochX, size.height - startEpochPainter.height - padding / 2),
      width: startEpochPainter.width + padding,
      height: style.labelHeight,
    );

    // Draw vertical barrier
    final Rect verticalBarrierRect = Rect.fromPoints(
      Offset(startEpochX, size.height - startEpochArea.height - padding / 2),
      Offset(endEpochX, size.height - padding / 2),
    );
    canvas.drawRect(verticalBarrierRect, barrierPaint);

    // Draw labels with backgrounds
    _drawLabelWithBackground(
        canvas, startEpochArea, labelPaint, startEpochPainter);
    _drawLabelWithBackground(canvas, endEpochArea, labelPaint, endEpochPainter);
  }

  void _drawLabelWithBackground(
      Canvas canvas, Rect labelArea, Paint paint, TextPainter painter) {
    _paintLabelBackground(canvas, labelArea, paint);

    paintWithTextPainter(
      canvas,
      painter: painter,
      anchor: labelArea.center,
    );
  }

  /// Paints a background based on the given label area.
  void _paintLabelBackground(Canvas canvas, Rect rect, Paint paint,
      {double radius = 4}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)),
      paint,
    );
  }

  String _formatEpochToDateTime(int epochMillis) {
    // Create a DateTime instance from milliseconds in local time
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(epochMillis, isUtc: false);

    final String formattedDate =
        DateFormat('yy-MM-dd HH:mm:ss').format(dateTime);

    // Get the current timezone name
    final String timeZoneName = DateTime.now().timeZoneName;

    return '$formattedDate $timeZoneName';
  }
}
