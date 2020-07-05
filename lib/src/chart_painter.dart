import 'package:deriv_chart/src/models/candle_painting.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'models/tick.dart';
import 'models/candle.dart';
import 'models/chart_style.dart';

import 'logic/conversion.dart';
import 'logic/time_grid.dart';
import 'logic/quote_grid.dart';

import 'paint/paint_current_tick_label.dart';
import 'paint/paint_candles.dart';
import 'paint/paint_grid.dart';
import 'paint/paint_line.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.candles,
    this.animatedCurrentTick,
    this.blinkAnimationProgress,
    this.loadingAnimationProgress,
    this.pipSize,
    this.style,
    this.msPerPx,
    this.rightBoundEpoch,
    this.topBoundQuote,
    this.bottomBoundQuote,
    this.quoteGridInterval,
    this.timeGridInterval,
    this.quoteLabelsAreaWidth,
    this.topPadding,
    this.bottomPadding,
  });

  final List<Candle> candles;
  final Tick animatedCurrentTick;
  final double blinkAnimationProgress;
  final double loadingAnimationProgress;
  final int pipSize;
  final ChartStyle style;

  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  final double msPerPx;

  /// Epoch at x = size.width.
  final int rightBoundEpoch;

  /// Quote at y = [topPadding].
  final double topBoundQuote;

  /// Quote at y = size.height - [bottomPadding].
  final double bottomBoundQuote;

  /// Difference between two consecutive quote labels.
  final double quoteGridInterval;

  /// Difference between two consecutive time labels in milliseconds.
  final int timeGridInterval;

  /// Width of the area where quote labels and current tick arrow are painted.
  final double quoteLabelsAreaWidth;

  /// Distance between top edge and [topBoundQuote] in pixels.
  final double topPadding;

  /// Distance between bottom edge and [bottomBoundQuote] in pixels.
  final double bottomPadding;

  Canvas canvas;
  Size size;

  Offset _toCanvasOffset(Tick tick) {
    return Offset(
      _epochToX(tick.epoch),
      _quoteToY(tick.quote),
    );
  }

  double _epochToX(int epoch) {
    return epochToCanvasX(
      epoch: epoch,
      rightBoundEpoch: rightBoundEpoch,
      canvasWidth: size.width,
      msPerPx: msPerPx,
    );
  }

  double _quoteToY(double quote) {
    return quoteToCanvasY(
      quote: quote,
      topBoundQuote: topBoundQuote,
      bottomBoundQuote: bottomBoundQuote,
      canvasHeight: size.height,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 2) return;

    this.canvas = canvas;
    this.size = size;

    _paintLoading();
    _painGrid();

    if (style == ChartStyle.candles) {
      _paintCandles();
    } else {
      _paintLine();
    }

    if (animatedCurrentTick != null) {
      final currentTickVisible = animatedCurrentTick.epoch <= rightBoundEpoch;
      if (currentTickVisible) {
        _paintCurrentTickDot();
      }

      _paintArrow();
    }

    // _paintNow(); // for testing
  }

  void _paintNow() {
    final x = _epochToX(DateTime.now().millisecondsSinceEpoch);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()..color = Colors.yellow,
    );
  }

  void _painGrid() {
    final gridLineQuotes = gridQuotes(
      quoteGridInterval: quoteGridInterval,
      topBoundQuote: topBoundQuote,
      bottomBoundQuote: bottomBoundQuote,
      canvasHeight: size.height,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );
    final leftBoundEpoch =
        rightBoundEpoch - pxToMs(size.width, msPerPx: msPerPx);
    final gridLineEpochs = gridEpochs(
      timeGridInterval: timeGridInterval,
      leftBoundEpoch: leftBoundEpoch,
      rightBoundEpoch: rightBoundEpoch,
    );
    paintGrid(
      canvas,
      size,
      timeLabels: gridLineEpochs.map((epoch) {
        final time = DateTime.fromMillisecondsSinceEpoch(epoch);
        return DateFormat('Hms').format(time);
      }).toList(),
      quoteLabels: gridLineQuotes
          .map((quote) => quote.toStringAsFixed(pipSize))
          .toList(),
      xCoords: gridLineEpochs.map((epoch) => _epochToX(epoch)).toList(),
      yCoords: gridLineQuotes.map((quote) => _quoteToY(quote)).toList(),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    );
  }

  void _paintLine() {
    paintLine(
      canvas,
      size,
      xCoords: candles.map((candle) => _epochToX(candle.epoch)).toList(),
      yCoords: candles.map((candle) => _quoteToY(candle.close)).toList(),
    );
  }

  void _paintCandles() {
    final granularity = candles[1].epoch - candles[0].epoch;
    final candleWidth = msToPx(granularity, msPerPx: msPerPx) * 0.6;

    final candlePaintings = candles.map((candle) {
      return CandlePainting(
        width: candleWidth,
        xCenter: _epochToX(candle.epoch),
        yHigh: _quoteToY(candle.high),
        yLow: _quoteToY(candle.low),
        yOpen: _quoteToY(candle.open),
        yClose: _quoteToY(candle.close),
      );
    }).toList();

    paintCandles(canvas, candlePaintings);
  }

  void _paintCurrentTickDot() {
    paintCurrentTickDot(
      canvas,
      center: _toCanvasOffset(animatedCurrentTick),
      animationProgress: blinkAnimationProgress,
    );
  }

  void _paintArrow() {
    paintCurrentTickLabel(
      canvas,
      size,
      centerY: _quoteToY(animatedCurrentTick.quote),
      quoteLabel: animatedCurrentTick.quote.toStringAsFixed(pipSize),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    );
  }

  final _loadingPaint = Paint()
    ..color = Colors.white12
    ..style = PaintingStyle.fill;

  void _paintLoading() {
    if (rightBoundEpoch - pxToMs(size.width, msPerPx: msPerPx) <
            candles.first.epoch ||
        candles.length <= 2) {
      final firstEpochX = _epochToX(candles.first.epoch);
      final invisibleRectWidth = size.height - firstEpochX;

      double xPosConvert(double x) => x - invisibleRectWidth;

      final barWidth = size.height * 0.01;
      _loadingPaint.strokeWidth = barWidth;

      int numberOfBars = (size.height ~/ (2 * barWidth));

      double barX = 0;
      for (int i = 0; i < numberOfBars; i++) {
        final xBeforeConversion =
            (barX + (loadingAnimationProgress * size.height)) % size.height;

        final xPos = xPosConvert(xBeforeConversion);
        canvas.drawLine(
            Offset(xPos, size.height),
            Offset(firstEpochX, size.height - (firstEpochX - xPos)),
            _loadingPaint);

        final mirrorX = xPosConvert(firstEpochX - xPos);
        canvas.drawLine(Offset(0, mirrorX), Offset(mirrorX, 0), _loadingPaint);
        barX += 2 * barWidth;
      }
    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
