import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/min_max_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MinMaxCalculator', () {
    test('calculates min/max on initial entries', () {
      final calculator = MinMaxCalculator<Tick>();

      calculator.updateVisibleEntries(<Tick>[
        const Tick(epoch: 123, quote: 10),
        const Tick(epoch: 192, quote: 13),
      ]);

      expect(calculator.min, 10);
      expect(calculator.max, 13);
    });
  });
}
