import 'package:deriv_chart/src/models/time_range.dart';
import 'package:meta/meta.dart';

double msToPx(int ms, {@required double msPerPx}) {
  return ms / msPerPx;
}

int pxToMs(double px, {@required double msPerPx}) {
  return (px * msPerPx).round();
}

int _indexOfContainingOrRightGap(List<TimeRange> gaps, int epoch) {
  return 0;
}

int shiftEpochByPx({
  @required int epoch,
  @required double pxShift,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  if (pxShift == 0) return epoch;

  int shiftedEpoch = epoch;
  double remainingPxShift = pxShift;
  int i = _indexOfContainingOrRightGap(gaps, epoch);

  if (pxShift.isNegative) {
    // Move to gap edge if initially inside a gap.
    if (gaps[i].contains(epoch)) {
      shiftedEpoch = gaps[i].leftEpoch;
      i--;
    }

    while (i >= 0 && remainingPxShift > 0) {
      gaps[i]; // jump the gap
      i--;
    }
  } else {
    // Move to gap edge if initially inside a gap.
    if (gaps[i].contains(epoch)) {
      shiftedEpoch = gaps[i].rightEpoch;
      i++;
    }

    while (i < gaps.length && remainingPxShift > 0) {
      gaps[i]; // jump the gap
      i++;
    }
  }

  return shiftedEpoch;
}

double timeRangePxWidth({
  @required TimeRange range,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  double overlap = 0;

  for (final gap in gaps) {
    overlap += gap.overlap(range)?.msWidth ?? 0;
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
