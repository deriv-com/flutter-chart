import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_flutter_chart/src/logic/grid.dart';

void main() {
  group('calcGridLineQuotes should', () {
    test('exclude quote on the top edge of canvas (y == 0)', () {
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 1,
          topBoundQuote: 10,
          bottomBoundQuote: 8,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 10,
        ),
        isNot(contains(10)),
      );
    });
    test('exclude quote on the bottom edge of canvas (y == canvasHeight)', () {
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 1,
          topBoundQuote: 10,
          bottomBoundQuote: 8,
          canvasHeight: 100,
          topPadding: 10,
          bottomPadding: 0,
        ),
        isNot(contains(8)),
      );
    });
    test(
        'return quotes within canvas excluding edges (y >= 0 and y <= canvasHeight)',
        () {
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 1,
          topBoundQuote: 10,
          bottomBoundQuote: 8,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 0,
        ),
        equals([9]),
      );
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 1,
          topBoundQuote: 8,
          bottomBoundQuote: 5,
          canvasHeight: 100,
          topPadding: 20,
          bottomPadding: 50,
        ),
        equals([9, 8, 7, 6, 5, 4, 3, 2, 1]),
      );
    });
    test('return quotes divisible by [quoteGridInterval]', () {
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 2,
          topBoundQuote: 11,
          bottomBoundQuote: 5,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 0,
        ),
        equals([10, 8, 6]),
      );
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 0.5,
          topBoundQuote: 182.32,
          bottomBoundQuote: 179.99,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 0,
        ),
        equals([182, 181.5, 181, 180.5, 180]),
      );
      expect(
        calcGridLineQuotes(
          quoteGridInterval: 0.25,
          topBoundQuote: 100.5,
          bottomBoundQuote: 100,
          canvasHeight: 100,
          topPadding: 1,
          bottomPadding: 1,
        ),
        equals([100.5, 100.25, 100]),
      );
    });
  });

  group('calcGridLineEpochs should', () {
    test('include epoch on the right edge', () {
      expect(
        calcGridLineEpochs(
          timeGridInterval: 1000,
          rightBoundEpoch: 10000,
          canvasWidth: 100,
          msPerPx: 10,
        ),
        contains(10000),
      );
    });
    test('include epoch on the left edge', () {
      expect(
        calcGridLineEpochs(
          timeGridInterval: 100,
          rightBoundEpoch: 1000,
          canvasWidth: 100,
          msPerPx: 1,
        ),
        contains(900),
      );
    });
    test('return epochs within canvas, divisible by [timeGridInterval]', () {
      expect(
        calcGridLineEpochs(
          timeGridInterval: 100,
          rightBoundEpoch: 1000,
          canvasWidth: 300,
          msPerPx: 1,
        ),
        equals([1000, 900, 800, 700]),
      );
      expect(
        calcGridLineEpochs(
          timeGridInterval: 100,
          rightBoundEpoch: 999,
          canvasWidth: 300,
          msPerPx: 1,
        ),
        equals([900, 800, 700]),
      );
    });
  });
}
