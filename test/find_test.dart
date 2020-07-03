import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/candle.dart';

void main() {
  group('findClosestToEpoch should', () {
    test('return null if list is empty', () {
      expect(
        findClosestToEpoch(100, []),
        equals(null),
      );
    });
    test('return candle with exact epoch if present', () {
      final candle100 = Candle.tick(epoch: 100, quote: 0);
      final candle200 = Candle.tick(epoch: 200, quote: 0);
      final candle300 = Candle.tick(epoch: 300, quote: 0);

      expect(
        findClosestToEpoch(
          100,
          [candle100, candle200, candle300],
        ),
        equals(candle100),
      );
      expect(
        findClosestToEpoch(
          200,
          [candle100, candle200, candle300],
        ),
        equals(candle200),
      );
      expect(
        findClosestToEpoch(
          300,
          [candle100, candle200, candle300],
        ),
        equals(candle300),
      );
    });
  });
}
