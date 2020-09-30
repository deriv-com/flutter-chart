import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/models/tick.dart';

void main() {
  group('findClosestToEpoch should', () {
    test('return null if list is empty', () {
      expect(
        findClosestToEpoch(100, []),
        equals(null),
      );
    });
    test('return tick with exact epoch if present', () {
      final tick100 = Tick(epoch: 100, quote: 0);
      final tick200 = Tick(epoch: 200, quote: 0);
      final tick300 = Tick(epoch: 300, quote: 0);

      expect(
        findClosestToEpoch(
          100,
          [tick100, tick200, tick300],
        ),
        equals(tick100),
      );
      expect(
        findClosestToEpoch(
          200,
          [tick100, tick200, tick300],
        ),
        equals(tick200),
      );
      expect(
        findClosestToEpoch(
          300,
          [tick100, tick200, tick300],
        ),
        equals(tick300),
      );
    });
    test('return tick with closest epoch if exact isn\'t present', () {
      final tick100 = Tick(epoch: 100, quote: 0);
      final tick110 = Tick(epoch: 110, quote: 0);
      final tick120 = Tick(epoch: 120, quote: 0);
      final tick130 = Tick(epoch: 130, quote: 0);
      final tick140 = Tick(epoch: 140, quote: 0);

      expect(
        findClosestToEpoch(
          101,
          [tick100, tick110, tick120, tick130, tick140],
        ),
        equals(tick100),
      );
    });
  });
}
