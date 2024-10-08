import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// BaseLineOverlayPainter is an abstract class that provides common methods
/// for painting barriers on a chart based on selected line points.
abstract class BaseLineOverlayPainter extends CustomPainter {
  /// Creates a BaseLineOverlayPainter.
  BaseLineOverlayPainter(
    this.config,
    this.quoteToY,
    this.epochToX,
    this.chartConfig,
  );

  /// Line drawing tool configuration.
  final LineDrawingToolConfig config;

  /// Quote to Y conversion function.
  final QuoteToY quoteToY;

  /// Epoch to X conversion function.
  final EpochToX epochToX;

  /// Padding between the labels and the barriers.
  final ChartConfig chartConfig;

  // Common methods can be declared here
  void _drawLabelWithBackground(
      Canvas canvas, Rect labelArea, Paint paint, TextPainter painter) {
    _drawLabelBackground(canvas, labelArea, paint);
    paintWithTextPainter(canvas, painter: painter, anchor: labelArea.center);
  }

  void _drawLabelBackground(Canvas canvas, Rect rect, Paint paint,
      {double radius = 4}) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)), paint);
  }

  String _formatEpochToDateTime(int epochMillis) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    return '${DateFormat('yy-MM-dd HH:mm:ss').format(dateTime)} ${dateTime.timeZoneName}';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    onPaint(
      canvas: canvas,
      size: size,
      config: config,
      epochToX: epochToX,
      quoteToY: quoteToY,
    );
  }

  /// Abstract method to be implemented by subclasses.
  void onPaint({
    required Canvas canvas,
    required Size size,
    required LineDrawingToolConfig config,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  });
}

/// LineOverlayPainterMobile is a subclass of BaseLineOverlayPainter used for
/// mobile platforms.
class LineOverlayPainterMobile extends BaseLineOverlayPainter {
  /// Creates an instance of LineOverlayPainterMobile.
  LineOverlayPainterMobile(
    super.config,
    super.quoteToY,
    super.epochToX,
    super.chartConfig,
  );

  /// Padding between the labels and the barriers.
  final double padding = 12;

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required LineDrawingToolConfig config,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
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
}
