import 'package:deriv_chart/src/models/time_range.dart';
import 'package:meta/meta.dart';

double msToPx(int ms, {@required double msPerPx}) {
  return ms / msPerPx;
}

int pxToMs(double px, {@required double msPerPx}) {
  return (px * msPerPx).round();
}

int shiftEpochByPx({
  @required int epoch,
  @required double pxShift,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  if (gaps.isNotEmpty && gaps.first.contains(epoch)) {
    epoch = gaps.first.rightEpoch;
  }
  return epoch + (pxShift * msPerPx).round();
}

double timeRangePxWidth({
  @required TimeRange range,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  double overlap = 0;

  for (final gap in gaps) {
    overlap += gap.overlap(range);
  }

  return (range.msWidth - overlap) / msPerPx;
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
