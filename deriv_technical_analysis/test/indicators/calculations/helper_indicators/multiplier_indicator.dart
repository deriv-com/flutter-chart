import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/low_value_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/multiplier_indicator.dart';
import 'package:deriv_technical_analysis/src/models/candle.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing multiplier indicators', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Candle(epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        Candle(epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        Candle(epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
      ];
    });

    test('MultiplierIndicator calculates the correct results', () {
      final LowValueIndicator lowValueIndicator = LowValueIndicator(ticks);
      final MultiplierIndicator indicator =
          MultiplierIndicator(lowValueIndicator, 0.2);

      expect(roundDouble(indicator.getValue(0).quote, 4), 12.6);
      expect(roundDouble(indicator.getValue(1).quote, 4), 14.624);
      expect(roundDouble(indicator.getValue(2).quote, 4), 14.666);
    });
  });
}
