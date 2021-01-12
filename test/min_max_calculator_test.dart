import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/min_max_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MinMaxCalculator', () {
    test('initial', () {
      final List<Tick> ticks = <Tick>[
        const Tick(epoch: 123, quote: 10),
        const Tick(epoch: 192, quote: 13),
      ];

      final calculator = MinMaxCalculator<Tick>();
    });
  });
}
