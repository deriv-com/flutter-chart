import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/min_max_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MinMaxCalculator', () {
    test('calculates min/max on initial entries', () {
      final MinMaxCalculator<Tick> calculator = MinMaxCalculator<Tick>()
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

    test('keeps min/max if new entries are the same', () {
      final List<Tick> testEntries = <Tick>[
        const Tick(epoch: 123, quote: 10),
        const Tick(epoch: 133, quote: 8),
        const Tick(epoch: 143, quote: 13),
        const Tick(epoch: 153, quote: 192),
        const Tick(epoch: 163, quote: 9),
      ];

      final MinMaxCalculator<Tick> calculator = MinMaxCalculator<Tick>()
        ..updateVisibleEntries(testEntries);

      expect(calculator.min, 8);
      expect(calculator.max, 192);

      calculator.updateVisibleEntries(testEntries);

      expect(calculator.min, 8);
      expect(calculator.max, 192);
    });

    test('updates min if new entries are scrolled forward by 1', () {
      final MinMaxCalculator<Tick> calculator = MinMaxCalculator<Tick>()
        ..updateVisibleEntries(<Tick>[
          const Tick(epoch: 123, quote: 11),
          const Tick(epoch: 124, quote: 39),
          const Tick(epoch: 125, quote: 45),
          const Tick(epoch: 126, quote: 5),
          const Tick(epoch: 127, quote: 23),
        ]);

      expect(calculator.min, 5);
      expect(calculator.max, 45);

      calculator.updateVisibleEntries(<Tick>[
        const Tick(epoch: 124, quote: 39),
        const Tick(epoch: 125, quote: 45),
        const Tick(epoch: 126, quote: 5),
        const Tick(epoch: 127, quote: 23),
        const Tick(epoch: 128, quote: 3),
      ]);

      expect(calculator.min, 3);
      expect(calculator.max, 45);
    });

    test('updates max if new entries are scrolled forward by 1', () {
      final MinMaxCalculator<Tick> calculator = MinMaxCalculator<Tick>()
        ..updateVisibleEntries(<Tick>[
          const Tick(epoch: 123, quote: 11),
          const Tick(epoch: 124, quote: 39),
          const Tick(epoch: 125, quote: 45),
          const Tick(epoch: 126, quote: 5),
          const Tick(epoch: 127, quote: 23),
        ]);

      expect(calculator.min, 5);
      expect(calculator.max, 45);

      calculator.updateVisibleEntries(<Tick>[
        const Tick(epoch: 124, quote: 39),
        const Tick(epoch: 125, quote: 45),
        const Tick(epoch: 126, quote: 5),
        const Tick(epoch: 127, quote: 23),
        const Tick(epoch: 128, quote: 49),
      ]);

      expect(calculator.min, 5);
      expect(calculator.max, 49);
    });
  });
}
