import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'models/tick.dart';

import 'logic/conversion.dart';
import 'logic/grid.dart';

import 'paint/paint_arrow.dart';
import 'paint/paint_grid.dart';
import 'paint/paint_line.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.ticks,
    this.animatedCurrentTick,
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

  final List<Tick> ticks;
  final Tick animatedCurrentTick;

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
    paintLine(
      canvas,
      size,
      xCoords: ticks.map((tick) => _epochToX(tick.epoch)).toList(),
      yCoords: ticks.map((tick) => _quoteToY(tick.quote)).toList(),
    );
  }

  void _paintCurrentTickDot() {
    final offset = _toCanvasOffset(animatedCurrentTick);
    canvas.drawCircle(offset, 3, Paint()..color = Color(0xFFFF444F));
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
