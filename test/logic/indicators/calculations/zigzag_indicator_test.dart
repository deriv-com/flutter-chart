import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zigzag_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZigZag Indicator', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Candle(epoch: 1, close: 64.75, low: 63.6, high: 65),
        Candle(epoch: 2, close: 65.79, low: 63.6, high: 68),
        Candle(epoch: 3, close: 64.73, low: 63.2, high: 65),
        Candle(epoch: 4, close: 64.73, low: 63.6, high: 67.1),
        Candle(epoch: 5, close: 65.55, low: 64.2, high: 66.3),
        Candle(epoch: 6, close: 66.59, low: 63.6, high: 65),
        Candle(epoch: 7, close: 63.61, low: 62.5, high: 65),
        Candle(epoch: 8, close: 63.65, low: 62.6, high: 65),
        Candle(epoch: 9, close: 62.15, low: 61, high: 65),
        Candle(epoch: 10, close: 63.37, low: 60.6, high: 65),
        Candle(epoch: 11, close: 61.33, low: 60, high: 65),
        Candle(epoch: 12, close: 62.51, low: 61.8, high: 65.9),
      ];
    });

    test('ZigZagIndicator calculates the correct results', () {
      final ZigZagIndicator indicator = ZigZagIndicator(ticks, 1);

      expect(indicator.getValue(0).quote.isNaN, true);
      expect(indicator.getValue(1).quote, 65.79);
      expect(indicator.getValue(2).quote.isNaN, true);
      expect(indicator.getValue(3).quote.isNaN, true);
      expect(indicator.getValue(5).quote, 65);
      expect(indicator.getValue(7).quote.isNaN, true);
      expect(indicator.getValue(10).quote, 60);
      expect(indicator.getValue(11).quote, 62.51);
    });
  });
}
