import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/min_max_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MinMaxCalculator', () {
    test('calculates min/max on initial entries', () {
      final MinMaxCalculator calculator = MinMaxCalculator<Tick>()
        ..updateVisibleEntries(<Tick>[
          const Tick(epoch: 123, quote: 10),
          const Tick(epoch: 133, quote: 8),
          const Tick(epoch: 143, quote: 13),
          const Tick(epoch: 153, quote: 192),
          const Tick(epoch: 163, quote: 9),
        ]);

      expect(calculator.min, 8);
      expect(calculator.max, 192);
    });
  });
}
