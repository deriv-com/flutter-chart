import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/quote_grid.dart';

void main() {
  group('gridQuotes should', () {
    test('exclude quote on the top edge of canvas (y == 0)', () {
      final YAxisModel yAxisModel = YAxisModel(
          topBoundQuote: 10,
          bottomBoundQuote: 8,
          yTopBound: 180,
          yBottomBound: 60,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 10);
      expect(
        yAxisModel.gridQuotes(),
        isNot(contains(10)),
      );
    });
    test('exclude quote on the bottom edge of canvas (y == canvasHeight)', () {
      final YAxisModel yAxisModel = YAxisModel(
          topBoundQuote: 10,
          bottomBoundQuote: 8,
          yTopBound: 180,
          yBottomBound: 60,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 10);
      expect(
        yAxisModel.gridQuotes(),
        isNot(contains(8)),
      );
    });
    test(
        'return quotes within canvas excluding edges (y >= 0 and y <= canvasHeight)',
        () {
      YAxisModel yAxisModel = YAxisModel(
          topBoundQuote: 10,
          bottomBoundQuote: 8,
          yTopBound: 60,
          yBottomBound: 180,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 0);
      expect(
        yAxisModel.gridQuotes(),
        equals(const <double>[9]),
      );
      yAxisModel = YAxisModel(
          topBoundQuote: 8,
          bottomBoundQuote: 5,
          yTopBound: 0,
          yBottomBound: 180,
          canvasHeight: 100,
          topPadding: 20,
          bottomPadding: 50);
      expect(
        yAxisModel.gridQuotes(),
        equals(const <double>[9, 8, 7, 6, 5, 4, 3, 2, 1]),
      );
    });
    test('return quotes divisible by [quoteGridInterval]', () {
      YAxisModel yAxisModel = YAxisModel(
          topBoundQuote: 11,
          bottomBoundQuote: 5,
          yTopBound: 0,
          yBottomBound: 180,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 0);
      expect(
        yAxisModel.gridQuotes(),
        equals(const <double>[10, 8, 6]),
      );
      yAxisModel = YAxisModel(
          topBoundQuote: 182.32,
          bottomBoundQuote: 179.99,
          yTopBound: 0,
          yBottomBound: 279.6,
          canvasHeight: 100,
          topPadding: 0,
          bottomPadding: 0);
      expect(
        yAxisModel.gridQuotes(),
        equals(const <double>[182, 181.5, 181, 180.5, 180]),
      );

      yAxisModel = YAxisModel(
          topBoundQuote: 100.5,
          bottomBoundQuote: 100,
          yTopBound: 0,
          yBottomBound: 120,
          canvasHeight: 100,
          topPadding: 1,
          bottomPadding: 1);
      expect(
        yAxisModel.gridQuotes(),
        equals(const <double>[100.5, 100.25, 100]),
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
