import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'models/tick.dart';
import 'logic/convertion.dart';

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

    final gridLineQuotes = _calcGridLineQuotes();
    final gridLineEpochs = _calcGridLineEpochs();
    _paintTimeGridLines(gridLineEpochs);
    _paintQuoteGridLines(gridLineQuotes);

    _paintLine();

    _paintTimestamps(gridLineEpochs);
    _paintQuotes(gridLineQuotes);
    _paintArrow(currentTick: animatedCurrentTick);
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

  List<double> _calcGridLineQuotes() {
    final pixelToQuote = (topBoundQuote - bottomBoundQuote) /
        (size.height - topPadding - bottomPadding);
    final topEdgeQuote = topBoundQuote + topPadding * pixelToQuote;
    final bottomEdgeQuote = bottomBoundQuote - bottomPadding * pixelToQuote;
    final gridLineQuotes = <double>[];
    for (var q = topEdgeQuote - topEdgeQuote % quoteGridInterval;
        q > bottomEdgeQuote;
        q -= quoteGridInterval) {
      if (q < topEdgeQuote) gridLineQuotes.add(q);
    }
    return gridLineQuotes;
  }

  List<int> _calcGridLineEpochs() {
    final firstRight =
        (rightBoundEpoch - rightBoundEpoch % timeGridInterval).toInt();
    final leftBoundEpoch =
        rightBoundEpoch - pxToMs(size.width, msPerPx: msPerPx);
    final epochs = <int>[];
    for (int epoch = firstRight;
        epoch > leftBoundEpoch;
        epoch -= timeGridInterval) {
      epochs.add(epoch);
    }
    return epochs;
  }

  void _paintQuoteGridLines(List<double> gridLineQuotes) {
    gridLineQuotes.forEach((quote) {
      final y = _quoteToY(quote);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()..color = Colors.white12,
      );
    });
  }

  void _paintTimeGridLines(List<int> gridLineEpochs) {
    gridLineEpochs.forEach((epoch) {
      final x = _epochToX(epoch);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()..color = Colors.white12,
      );
    });
  }

  void _paintQuotes(List<double> gridLineQuotes) {
    gridLineQuotes.forEach((quote) {
      _paintQuote(quote);
    });
  }

  void _paintTimestamps(List<int> gridLineEpochs) {
    gridLineEpochs.forEach((epoch) {
      _paintTimestamp(epoch);
    });
  }

  void _paintTimestamp(int epoch) {
    final time = DateTime.fromMillisecondsSinceEpoch(epoch);
    final label = DateFormat('Hms').format(time);
    TextSpan span = TextSpan(
      style: TextStyle(
        color: Colors.white30,
        fontSize: 12,
      ),
      text: label,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(_epochToX(epoch) - tp.width / 2, size.height - tp.height - 4),
    );
  }

  void _paintQuote(double quote) {
    TextSpan span = TextSpan(
      style: TextStyle(
        color: Colors.white30,
        fontSize: 12,
      ),
      text: '${quote.toStringAsFixed(2)}',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: quoteLabelsAreaWidth, maxWidth: quoteLabelsAreaWidth);
    final y = _quoteToY(quote);
    tp.paint(canvas, Offset(size.width - quoteLabelsAreaWidth, y - 6));
  }

  void _paintArrow({Tick currentTick}) {
    final offset = _toCanvasOffset(currentTick);
    canvas.drawCircle(offset, 3, Paint()..color = coralColor);
    canvas.drawLine(
      Offset(0, offset.dy),
      Offset(size.width, offset.dy),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 1,
    );
    _paintArrowHead(y: offset.dy, quote: currentTick.quote);
  }

  void _paintArrowHead({double y, double quote}) {
    final triangleWidth = 8;
    final height = 24;

    final path = Path();
    path.moveTo(size.width - quoteLabelsAreaWidth - triangleWidth, y);
    path.lineTo(size.width - quoteLabelsAreaWidth, y - height / 2);
    path.lineTo(size.width, y - height / 2);
    path.lineTo(size.width, y + height / 2);
    path.lineTo(size.width - quoteLabelsAreaWidth, y + height / 2);
    path.lineTo(size.width - quoteLabelsAreaWidth - triangleWidth, y);
    canvas.drawPath(
      path,
      Paint()
        ..color = coralColor
        ..style = PaintingStyle.fill,
    );

    TextSpan span = TextSpan(
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      text: '${quote.toStringAsFixed(2)}',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: quoteLabelsAreaWidth, maxWidth: quoteLabelsAreaWidth);
    tp.paint(
      canvas,
      Offset(size.width - quoteLabelsAreaWidth, y - 6),
    );
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
