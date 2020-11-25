import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roundDouble function', () {
    test('Rounds to the ceiling', () {
      final double value = 2.6666883;

      expect(roundDouble(value, 4), 2.6667);
      expect(roundDouble(value, 3), 2.667);
    });

    test('Rounds to the floor', () {
      final double value = 2.6666233;

      expect(roundDouble(value, 4), 2.6666);
    });
  });
}