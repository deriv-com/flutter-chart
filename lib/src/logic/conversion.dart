import 'package:meta/meta.dart';

double msToPx(int ms, {@required double msPerPx}) {
  return ms / msPerPx;
}

int pxToMs(double px, {@required double msPerPx}) {
  return (px * msPerPx).round();
}

double epochToCanvasX({
  @required int epoch,
  @required int rightBoundEpoch,
  @required double canvasWidth,
  @required double msPerPx,
}) {
  final pxFromRight = msToPx(rightBoundEpoch - epoch, msPerPx: msPerPx);
  return canvasWidth - pxFromRight;
}

double quoteToCanvasY({
  @required double quote,
  @required double topBoundQuote,
  @required double bottomBoundQuote,
  @required double canvasHeight,
  @required double topPadding,
  @required double bottomPadding,
}) {
  final drawingRange = canvasHeight - topPadding - bottomPadding;
  final quoteRange = topBoundQuote - bottomBoundQuote;

  if (quoteRange == 0) return topPadding + drawingRange / 2;

  final quoteToBottomBoundFraction = (quote - bottomBoundQuote) / quoteRange;
  final quoteToTopBoundFraction = 1 - quoteToBottomBoundFraction;

  final pxFromTopBound = quoteToTopBoundFraction * drawingRange;

  return topPadding + pxFromTopBound;
}

int canvasXToEpoch({
  @required double x,
  @required int rightBoundEpoch,
  @required double canvasWidth,
  @required double msPerPx,
}) {
  return rightBoundEpoch - pxToMs(canvasWidth - x, msPerPx: msPerPx);
}
