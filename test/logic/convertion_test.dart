import 'package:flutter_test/flutter_test.dart';

import 'package:chart_attempt/logic/convertion.dart';

void main() {
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

  group('epochToCanvasX should return', () {
    test('[canvasWidth] when [epoch == rightBoundEpoch]', () {
      expect(
        epochToCanvasX(
          epoch: 123456789,
          rightBoundEpoch: 123456789,
          canvasWidth: 1234,
          msPerPx: 0.12345,
        ),
        equals(1234),
      );
    });
    test('0 when [epoch == rightBoundEpoch - canvasWidth * msPerPx]', () {
      expect(
        epochToCanvasX(
          epoch: 512,
          rightBoundEpoch: 1024,
          canvasWidth: 1024,
          msPerPx: 0.5,
        ),
        equals(0),
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
}
