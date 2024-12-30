import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_tool_label_painter.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Line drawing tool label painter.
abstract class LineDrawingToolLabelPainter extends DrawingToolLabelPainter {
  /// Creates a LineDrawingToolLabelPainter.
  LineDrawingToolLabelPainter(
    this.lineDrawingToolConfig, {
    required this.startPoint,
    required this.endPoint,
  }) : super(lineDrawingToolConfig);

  /// Line drawing tool config.
  late final dynamic lineDrawingToolConfig;

  /// Start point.
  final Point startPoint;

  /// End point.
  final Point endPoint;
}

/// Line drawing tool label painter for mobile platforms.
class MobileLineDrawingToolLabelPainter extends LineDrawingToolLabelPainter {
  /// Creates a MobileLineDrawingToolLabelPainter.
  MobileLineDrawingToolLabelPainter(
    super.lineDrawingToolConfig, {
    required super.startPoint,
    required super.endPoint,
  }) {
    _style = lineDrawingToolConfig.overlayStyle ??
        OverlayStyle(
          color: lineDrawingToolConfig.lineStyle.color,
          textStyle: lineDrawingToolConfig.overlayStyle?.textStyle
                  .copyWith(color: lineDrawingToolConfig.lineStyle.color) ??
              TextStyles.caption2,
        );

    _paint = Paint()
      ..color = _style.color
      ..strokeWidth = 1.0;

    _barrierPaint = Paint()
      ..color = _style.color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
  }

  /// Padding between the labels and the barriers.
  final double padding = 12;

  /// The overlay style.
  late final OverlayStyle _style;

  /// The paint.
  late final Paint _paint;

  /// The barrier paint.
  late final Paint _barrierPaint;

  @override
  void paint(
    Canvas canvas,
    Size size,
    ChartConfig chartConfig,
    int Function(double x) epochFromX,
    double Function(double y) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
  ) {
    final double startQuoteY = startPoint.y;
    final double endQuoteY = endPoint.y;
    final double startEpochX = startPoint.x;
    final double endEpochX = endPoint.x;

    final double startQuote = quoteFromY(startPoint.y);
    final double endQuote = quoteFromY(endPoint.y);
    final int startEpoch = epochFromX(startPoint.x);
    final int endEpoch = epochFromX(endPoint.x);

    // Draw quote labels and barriers on the vertical axis
    _drawQuoteLabelsAndBarriers(canvas, size, chartConfig, _style, _paint,
        _barrierPaint, startQuoteY, endQuoteY, startQuote, endQuote);

    // Draw epoch labels and barriers on the horizontal axis
    _drawEpochLabelsAndBarriers(canvas, size, chartConfig, _style, _paint,
        _barrierPaint, startEpochX, endEpochX, startEpoch, endEpoch);
  }

  void _drawQuoteLabelsAndBarriers(
    Canvas canvas,
    Size size,
    ChartConfig chartConfig,
    OverlayStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startQuoteY,
    double endQuoteY,
    double startQuote,
    double endQuote,
  ) {
    final TextPainter startQuotePainter = makeTextPainter(
        startQuote.toStringAsFixed(chartConfig.pipSize), style.textStyle);
    final TextPainter endQuotePainter = makeTextPainter(
        endQuote.toStringAsFixed(chartConfig.pipSize), style.textStyle);

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
    drawLabelWithBackground(
        canvas, startQuoteArea, labelPaint, startQuotePainter);
    drawLabelWithBackground(canvas, endQuoteArea, labelPaint, endQuotePainter);
  }

  void _drawEpochLabelsAndBarriers(
    Canvas canvas,
    Size size,
    ChartConfig chartConfig,
    OverlayStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startEpochX,
    double endEpochX,
    int startEpoch,
    int endEpoch,
  ) {
    final String startEpochLabel = formatEpochToGMTDateTime(startEpoch);
    final String endEpochLabel = formatEpochToGMTDateTime(endEpoch);

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
    drawLabelWithBackground(
        canvas, startEpochArea, labelPaint, startEpochPainter);
    drawLabelWithBackground(canvas, endEpochArea, labelPaint, endEpochPainter);
  }
}

/// Line drawing tool label painter for web platforms.
class WebLineDrawingToolLabelPainter extends LineDrawingToolLabelPainter {
  /// Creates a WebLineDrawingToolLabelPainter.
  WebLineDrawingToolLabelPainter(
    super.lineDrawingToolConfig, {
    required super.startPoint,
    required super.endPoint,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
    ChartConfig chartConfig,
    int Function(double x) epochFromX,
    double Function(double y) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
  ) {}
}
