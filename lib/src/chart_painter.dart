import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'models/tick.dart';

import 'logic/conversion.dart';
import 'logic/grid.dart';

import 'paint/paint_grid.dart';
import 'paint/paint_arrow.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.ticks,
    this.animatedCurrentTick,
    this.endsWithCurrentTick,
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

  final lineColor = Paint()
    ..color = Colors.white.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final coralColor = Color(0xFFFF444F);

  final List<Tick> ticks;
  final Tick animatedCurrentTick;
  final bool endsWithCurrentTick;

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
    if (ticks.length < 2) return;
    this.canvas = canvas;
    this.size = size;

    if (endsWithCurrentTick) {
      ticks.removeLast();
      ticks.add(animatedCurrentTick);
    }

    _painGrid();
    _paintLine();
    _paintCurrentTickDot();
    _paintArrow();
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
      quoteLabels:
          gridLineQuotes.map((quote) => quote.toStringAsFixed(2)).toList(),
      xCoords: gridLineEpochs.map((epoch) => _epochToX(epoch)).toList(),
      yCoords: gridLineQuotes.map((quote) => _quoteToY(quote)).toList(),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    );
  }

  void _paintLine() {
    Path path = Path();
    final firstPoint = _toCanvasOffset(ticks.first);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    ticks.skip(1).forEach((tick) {
      final point = _toCanvasOffset(tick);
      path.lineTo(point.dx, point.dy);
    });

    canvas.drawPath(path, lineColor);

    _paintLineArea(linePath: path);
  }

  void _paintLineArea({Path linePath}) {
    linePath.lineTo(
      _epochToX(ticks.last.epoch),
      size.height,
    );
    linePath.lineTo(0, size.height);
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.01),
          ],
        ),
    );
  }

  void _paintCurrentTickDot() {
    final offset = _toCanvasOffset(animatedCurrentTick);
    canvas.drawCircle(offset, 3, Paint()..color = coralColor);
  }

  void _paintArrow() {
    paintArrow(
      canvas,
      size,
      centerY: _quoteToY(animatedCurrentTick.quote),
      quoteLabel: animatedCurrentTick.quote.toStringAsFixed(2),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    );
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
