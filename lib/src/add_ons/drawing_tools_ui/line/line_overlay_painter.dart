import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_overlay_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// LineOverlayPainterMobile is a subclass of [DrawingToolOverlayPainter] used
/// to draw the overlay attributes of the line drawing tool on mobile platforms.
class LineOverlayPainterMobile extends DrawingToolOverlayPainter {
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
    required DrawingToolConfig config,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
    // Cast config as LineDrawingToolConfig
    config as LineDrawingToolConfig;

    final startPoint = config.edgePoints.first;
    final endPoint = config.edgePoints.last;

    final double startQuoteY = quoteToY(startPoint.quote);
    final double endQuoteY = quoteToY(endPoint.quote);
    final double startEpochX = epochToX(startPoint.epoch);
    final double endEpochX = epochToX(endPoint.epoch);

    final OverlayStyle style = config.overlayStyle ??
        OverlayStyle(
          color: config.lineStyle.color,
          textStyle: config.overlayStyle?.textStyle
                  .copyWith(color: config.lineStyle.color) ??
              TextStyles.caption2,
        );

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
    OverlayStyle style,
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
    drawLabelWithBackground(
        canvas, startQuoteArea, labelPaint, startQuotePainter);
    drawLabelWithBackground(canvas, endQuoteArea, labelPaint, endQuotePainter);
  }

  void _drawEpochLabelsAndBarriers(
    Canvas canvas,
    Size size,
    OverlayStyle style,
    Paint labelPaint,
    Paint barrierPaint,
    double startEpochX,
    double endEpochX,
    int startEpoch,
    int endEpoch,
  ) {
    final String startEpochLabel = formatEpochToDateTime(startEpoch);
    final String endEpochLabel = formatEpochToDateTime(endEpoch);

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

/// LineOverlayPainterWeb is a subclass of [DrawingToolOverlayPainter] used
/// to draw the overlay attributes of the line drawing tool on web.
class LineOverlayPainterWeb extends DrawingToolOverlayPainter {
  /// Creates an instance of LineOverlayPainterWeb.
  LineOverlayPainterWeb(
    super.config,
    super.quoteToY,
    super.epochToX,
    super.chartConfig,
  );

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required DrawingToolConfig config,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
    // Not implemented for web.
  }
}
