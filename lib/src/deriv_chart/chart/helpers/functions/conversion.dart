import 'package:deriv_chart/src/deriv_chart/chart/x_axis/gaps/helpers.dart';
import 'package:deriv_chart/src/models/time_range.dart';

/// Returns resulting epoch when given [epoch] is shifted by [pxShift]
/// on x-axis, skipping time gaps.
int shiftEpochByPx({
  required int epoch,
  required double pxShift,
  required double msPerPx,
  required List<TimeRange> gaps,
}) {
  if (pxShift == 0) {
    return epoch;
  }
  if (gaps.isEmpty) {
    return epoch + (pxShift * msPerPx).round();
  }

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

/// Returns canvas y-coordinate of the given quote/value.
double quoteToCanvasY({
  required double quote,
  required double topBoundQuote,
  required double bottomBoundQuote,
  required double canvasHeight,
  required double topPadding,
  required double bottomPadding,
}) {
  final double drawingRange = canvasHeight - topPadding - bottomPadding;
  final double quoteRange = topBoundQuote - bottomBoundQuote;

  if (quoteRange == 0) {
    return topPadding + drawingRange / 2;
  }

  final double quoteToBottomBoundFraction =
      (quote - bottomBoundQuote) / quoteRange;
  final double quoteToTopBoundFraction = 1 - quoteToBottomBoundFraction;

  final double pxFromTopBound = quoteToTopBoundFraction * drawingRange;

  return topPadding + pxFromTopBound;
}

/// Returns quote based on the y-coordinate.
double quoteFromCanvasY({
  required double y,
  required double topBoundQuote,
  required double bottomBoundQuote,
  required double canvasHeight,
  required double topPadding,
  required double bottomPadding,
}) {
  final double drawingRange = canvasHeight - topPadding - bottomPadding;
  final double quoteRange = topBoundQuote - bottomBoundQuote;

  final double yTopBound = topPadding;

  if (quoteRange == 0) {
    return topBoundQuote;
  }

  final double yToTopBoundFraction = (y - yTopBound) / drawingRange;

  final double quoteFromTopBound = yToTopBoundFraction * quoteRange;

  return topBoundQuote - quoteFromTopBound;
}
