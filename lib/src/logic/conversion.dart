import 'dart:math';
import 'package:meta/meta.dart';

double msToPx(int ms, {@required double msPerPx}) {
  return ms / msPerPx;
}

int pxToMs(double px, {@required double msPerPx}) {
  return (px * msPerPx).round();
}

class TimeRange {
  TimeRange(this.leftEpoch, this.rightEpoch);

  final int leftEpoch;
  final int rightEpoch;

  int overlap(TimeRange other) =>
      min(other.rightEpoch, rightEpoch) - max(other.leftEpoch, leftEpoch);
}

int shiftEpochByPx({
  @required int epoch,
  @required double pxShift,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {}

double pxBetween({
  @required int leftEpoch,
  @required int rightEpoch,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  double overlap = 0;
  final range = TimeRange(leftEpoch, rightEpoch);

  gaps.forEach((TimeRange gap) {
    overlap += gap.overlap(range);
  });

  return (rightEpoch - leftEpoch - overlap) / msPerPx;
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
