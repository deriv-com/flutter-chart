import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_flutter_chart/src/logic/quote_grid.dart';

void main() {
  group('gridQuotes should', () {
    test('exclude quote on the top edge of canvas (y == 0)', () {
      expect(
        gridQuotes(
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
        gridQuotes(
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
        gridQuotes(
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
        gridQuotes(
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
        gridQuotes(
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
        gridQuotes(
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
        gridQuotes(
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

  group('quotePerPx should', () {
    test('calculate correct ratio with round parameters', () {
      expect(
        quotePerPx(
          topBoundQuote: 100,
          bottomBoundQuote: 0,
          yTopBound: 0,
          yBottomBound: 100,
        ),
        equals(1),
      );
    });
    test('calculate correct ratio with fractional parameters', () {
      expect(
        quotePerPx(
          topBoundQuote: 123.4823,
          bottomBoundQuote: 103.9823,
          yTopBound: 783,
          yBottomBound: 978,
        ),
        equals(0.1),
      );
    });
  });
}
