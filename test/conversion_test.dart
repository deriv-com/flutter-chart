import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/conversion.dart';

void main() {
  group('timeRangePxWidth should return', () {
    test('0 when [leftEpoch == rightEpoch]', () {
      expect(
        timeRangePxWidth(
          range: TimeRange(0, 0),
          msPerPx: 1,
          gaps: [],
        ),
        equals(0),
      );
    });

    test('full distance when no gaps are given', () {
      expect(
        timeRangePxWidth(
          range: TimeRange(20, 100),
          msPerPx: 0.5,
          gaps: [],
        ),
        equals(160),
      );
      expect(
        timeRangePxWidth(
          range: TimeRange(20, 100),
          msPerPx: 1,
          gaps: [],
        ),
        equals(80),
      );
      expect(
        timeRangePxWidth(
          range: TimeRange(20, 100),
          msPerPx: 2,
          gaps: [],
        ),
        equals(40),
      );
    });

    test('full distance when gaps do not overlap with the epoch range', () {
      expect(
        timeRangePxWidth(
          range: TimeRange(1111, 2222),
          msPerPx: 0.5,
          gaps: [TimeRange(1000, 1100)],
        ),
        equals(2222),
      );
    });

    test('0 when gap covers the epoch range', () {
      expect(
        timeRangePxWidth(
          range: TimeRange(300, 400),
          msPerPx: 0.5,
          gaps: [TimeRange(250, 400)],
        ),
        equals(0),
      );
    });

    test('distance minus gap when one gap is in the middle of epoch range', () {
      expect(
        timeRangePxWidth(
          range: TimeRange(300, 400),
          msPerPx: 1,
          gaps: [TimeRange(350, 360)],
        ),
        equals(90),
      );
    });

    test('distance minus overlaps with gaps', () {
      expect(
        timeRangePxWidth(
          range: TimeRange(300, 400),
          msPerPx: 1,
          gaps: [TimeRange(250, 360), TimeRange(390, 1000)],
        ),
        equals(30),
      );
    });
  });

  group('msToPx should return', () {
    test('10 when [ms == 5] and [msPerPx == 0.5]', () {
      expect(
        msToPx(5, msPerPx: 0.5),
        equals(10),
      );
    });
  });

  group('pxToMs should return', () {
    test('32 when [px == 16] and [msPerPx == 2]', () {
      expect(
        pxToMs(16, msPerPx: 2),
        equals(32),
      );
    });
  });

  group('quoteToCanvasY should return', () {
    test('[topPadding] when [quote == topBoundQuote]', () {
      expect(
        quoteToCanvasY(
          quote: 1234.2345,
          topBoundQuote: 1234.2345,
          bottomBoundQuote: 123.439,
          canvasHeight: 10033,
          topPadding: 0,
          bottomPadding: 133,
        ),
        equals(0),
      );
      expect(
        quoteToCanvasY(
          quote: 1234.2345,
          topBoundQuote: 1234.2345,
          bottomBoundQuote: 123.439,
          canvasHeight: 10033,
          topPadding: 1234.34,
          bottomPadding: 133,
        ),
        equals(1234.34),
      );
    });
    test('[canvasHeight - bottomPadding] when [quote == bottomBoundQuote]', () {
      expect(
        quoteToCanvasY(
          quote: 89.2345,
          topBoundQuote: 102.2385,
          bottomBoundQuote: 89.2345,
          canvasHeight: 1024,
          topPadding: 123,
          bottomPadding: 0,
        ),
        equals(1024),
      );
      expect(
        quoteToCanvasY(
          quote: 89.2345,
          topBoundQuote: 102.2385,
          bottomBoundQuote: 89.2345,
          canvasHeight: 1024,
          topPadding: 123,
          bottomPadding: 24,
        ),
        equals(1000),
      );
    });
    test('middle of drawing range when [topBoundQuote == bottomBoundQuote]',
        () {
      expect(
        quoteToCanvasY(
          quote: 89.2345,
          topBoundQuote: 102.2385,
          bottomBoundQuote: 102.2385,
          canvasHeight: 1024,
          topPadding: 12,
          bottomPadding: 12,
        ),
        equals(512),
      );
    });
  });

  group('canvasXToEpoch should return', () {
    test('[rightBoundEpoch] when [x == canvasWidth]', () {
      expect(
        canvasXToEpoch(
          x: 784,
          rightBoundEpoch: 1234,
          canvasWidth: 784,
          msPerPx: 0.33,
        ),
        equals(1234),
      );
    });
    test('closest epoch when result is a fraction', () {
      expect(
        canvasXToEpoch(
          x: 99.6,
          rightBoundEpoch: 100,
          canvasWidth: 100,
          msPerPx: 1,
        ),
        equals(100),
      );
      expect(
        canvasXToEpoch(
          x: 52.3,
          rightBoundEpoch: 100,
          canvasWidth: 100,
          msPerPx: 1,
        ),
        equals(52),
      );
    });
  });
}
