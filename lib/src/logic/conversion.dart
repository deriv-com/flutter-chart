import 'package:deriv_chart/src/models/time_range.dart';
import 'package:meta/meta.dart';

double msToPx(int ms, {@required double msPerPx}) {
  return ms / msPerPx;
}

int pxToMs(double px, {@required double msPerPx}) {
  return (px * msPerPx).round();
}

int _indexOfNearestGap(List<TimeRange> gaps, int epoch) {
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
  int i = _indexOfNearestGap(gaps, epoch);

  if (pxShift.isNegative) {
    // Move to gap edge if initially inside a gap.
    if (gaps[i].contains(epoch)) {
      shiftedEpoch = gaps[i].leftEpoch;
      i--;
    } else if (gaps[i].isAfter(epoch)) {
      i--;
    }
    while (i >= 0 && remainingPxShift < 0) {
      final TimeRange gap = gaps[i];
      final int msToGap = gap.rightEpoch - shiftedEpoch;
      final double pxToGap = msToGap / msPerPx;
      if (remainingPxShift <= pxToGap) {
        remainingPxShift -= pxToGap;
        shiftedEpoch = gap.leftEpoch;
      } else {
        break;
      }
      i--;
    }
  } else {
    // Move to gap edge if initially inside a gap.
    if (gaps[i].contains(epoch)) {
      shiftedEpoch = gaps[i].rightEpoch;
      i++;
    } else if (gaps[i].isBefore(epoch)) {
      i++;
    }
    while (i < gaps.length && remainingPxShift > 0) {
      final TimeRange gap = gaps[i];
      final int msToGap = gap.leftEpoch - shiftedEpoch;
      final double pxToGap = msToGap / msPerPx;
      if (remainingPxShift >= pxToGap) {
        remainingPxShift -= pxToGap;
        shiftedEpoch = gap.rightEpoch;
      } else {
        break;
      }
      i++;
    }
  }
  return shiftedEpoch + (remainingPxShift * msPerPx).round();
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
