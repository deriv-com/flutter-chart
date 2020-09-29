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
  int shiftedEpoch = epoch;
  if (pxShift > 0) {
    for (final gap in gaps) {
      if (gap.contains(shiftedEpoch)) {
        shiftedEpoch = gap.rightEpoch;
      } else if (shiftedEpoch < gap.leftEpoch &&
          gap.leftEpoch - epoch < pxShift * msPerPx) {
        shiftedEpoch += gap.msWidth;
      }
    }
  } else {
    int i = gaps
        .lastIndexWhere((gap) => gap.isBefore(epoch) || gap.contains(epoch));

    if (i >= 0 && gaps[i].contains(epoch)) {
      epoch = gaps[i].leftEpoch;
      i--;
    }

    double pxToGap(TimeRange gap) => (epoch - gap.rightEpoch) / msPerPx;

    while (i >= 0) {
      final distance = pxToGap(gaps[i]);

      if (pxShift.abs() >= distance.abs()) {
        epoch = gaps[i].leftEpoch;
        pxShift += distance;
      }
      i--;
    }

    return epoch + (pxShift * msPerPx).round();
  }
  return shiftedEpoch + (pxShift * msPerPx).round();
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

int canvasXToEpoch({
  @required double x,
  @required int rightBoundEpoch,
  @required double canvasWidth,
  @required double msPerPx,
}) {
  return rightBoundEpoch - pxToMs(canvasWidth - x, msPerPx: msPerPx);
}
