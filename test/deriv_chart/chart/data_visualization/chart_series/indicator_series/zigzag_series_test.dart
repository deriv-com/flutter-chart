import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZigZagSeries visible entries', () {
    // Epochs deliberately start well after 0 so a visible window can sit
    // entirely to the left of the data.
    late IndicatorInput input;

    setUp(() {
      input = IndicatorInput(
        const <Tick>[
          Tick(epoch: 5000, quote: 1),
          Tick(epoch: 6000, quote: 3),
          Tick(epoch: 7000, quote: 2),
          Tick(epoch: 8000, quote: 4),
        ],
        1000,
      );
    });

    test('is empty when the visible window is entirely before the data', () {
      // Reproduces a granularity switch: the x-axis still holds the previous
      // interval's epochs, so the window has no overlap with the new series
      // and the upper index search returns its -1 sentinel.
      final ZigZagSeries series = ZigZagSeries(input)..update(1000, 2000);

      expect(series.visibleEntries.isEmpty, true);
    });

    test('is empty when the visible window is entirely after the data', () {
      final ZigZagSeries series = ZigZagSeries(input)..update(20000, 30000);

      expect(series.visibleEntries.isEmpty, true);
    });

    test('is empty when the visible window is before a single-entry series',
        () {
      // The narrowest case, and the one seen in production: with one entry the
      // out-of-range read is `entries[-2]`.
      final ZigZagSeries series = ZigZagSeries(
        IndicatorInput(const <Tick>[Tick(epoch: 5000, quote: 1)], 1000),
      )..update(1000, 2000);

      expect(series.visibleEntries.isEmpty, true);
    });

    test('returns entries when the visible window overlaps the data', () {
      final ZigZagSeries series = ZigZagSeries(input)..update(5000, 8000);

      expect(series.visibleEntries.isEmpty, false);
    });
  });
}
