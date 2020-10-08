import 'package:deriv_chart/src/models/time_range.dart';
import 'package:meta/meta.dart';

double msToPx(int ms, {@required double msPerPx}) {
  return ms / msPerPx;
}

/// Returns index of the gap in the given list, that either contains the given [epoch] or is to the left/right to it.
int indexOfNearestGap(List<TimeRange> gaps, int epoch) {
  int left = 0, right = gaps.length - 1;
  while (left < right) {
    final int mid = (left + right) ~/ 2;

    if (gaps[mid].isAfter(epoch)) {
      right = mid;
    } else if (gaps[mid].isBefore(epoch)) {
      left = mid + 1;
    } else {
      return mid;
    }
  }
  return right;
}

/// Returns resulting epoch when given [epoch] is shifted by [pxShift] on x-axis, skipping time gaps.
int shiftEpochByPx({
  @required int epoch,
  @required double pxShift,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  if (pxShift == 0) return epoch;
  if (gaps.isEmpty) return epoch + (pxShift * msPerPx).round();

  int shiftedEpoch = epoch;
  double remainingPxShift = pxShift;
  int i = indexOfNearestGap(gaps, epoch);

  if (pxShift.isNegative) {
    if (gaps[i].contains(epoch)) {
      // Move to gap edge if initially inside a gap.
      shiftedEpoch = gaps[i].leftEpoch;
      i--;
    } else if (gaps[i].isAfter(epoch)) {
      // Start with a gap in the direction of movement.
      i--;
    }
    while (i >= 0 && remainingPxShift < 0) {
      final TimeRange gap = gaps[i];
      final int msToGap = gap.rightEpoch - shiftedEpoch;
      final double pxToGap = msToGap / msPerPx;
      if (remainingPxShift <= pxToGap) {
        // jump the gap
        remainingPxShift -= pxToGap;
        shiftedEpoch = gap.leftEpoch;
      } else {
        // gap is too far
        break;
      }
      i--;
    }
  } else {
    if (gaps[i].contains(epoch)) {
      // Move to gap edge if initially inside a gap.
      shiftedEpoch = gaps[i].rightEpoch;
      i++;
    } else if (gaps[i].isBefore(epoch)) {
      // Start with a gap in the direction of movement.
      i++;
    }
    while (i < gaps.length && remainingPxShift > 0) {
      final TimeRange gap = gaps[i];
      final int msToGap = gap.leftEpoch - shiftedEpoch;
      final double pxToGap = msToGap / msPerPx;
      if (remainingPxShift >= pxToGap) {
        // jump the gap
        remainingPxShift -= pxToGap;
        shiftedEpoch = gap.rightEpoch;
      } else {
        // gap is too far
        break;
      }
      i++;
    }
  }
  return shiftedEpoch + (remainingPxShift * msPerPx).round();
}

/// Returns pixel width of the time range minus the time gaps, which have 0 width on x-axis.
double timeRangePxWidth({
  @required TimeRange range,
  @required double msPerPx,
  @required List<TimeRange> gaps,
}) {
  double overlap = 0;

  for (final TimeRange gap in gaps) {
    overlap += gap.overlap(range)?.msWidth ?? 0;
  }

  return (range.msWidth - overlap) / msPerPx;
}

/// Returns canvas y-coordinate of the given quote/value.
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
