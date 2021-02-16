import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/positive_dm_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Tick> ticks;

  setUpAll(() {
    ticks = const <Tick>[
      Candle(epoch: 01, high: 80.859, low: 80.850, open: 80.858, close: 80.857),
      Candle(epoch: 02, high: 80.860, low: 80.850, open: 80.858, close: 80.855),
      Candle(epoch: 03, high: 80.861, low: 80.846, open: 80.855, close: 80.858),
      Candle(epoch: 04, high: 80.868, low: 80.855, open: 80.860, close: 80.863),
      Candle(epoch: 05, high: 80.886, low: 80.863, open: 80.864, close: 80.877),
      Candle(epoch: 06, high: 80.886, low: 80.877, open: 80.879, close: 80.886),
      Candle(epoch: 07, high: 80.896, low: 80.883, open: 80.883, close: 80.892),
      Candle(epoch: 08, high: 80.899, low: 80.889, open: 80.891, close: 80.899),
      Candle(epoch: 09, high: 80.899, low: 80.888, open: 80.898, close: 80.890),
      Candle(epoch: 10, high: 80.893, low: 80.888, open: 80.891, close: 80.893),
      Candle(epoch: 11, high: 80.899, low: 80.892, open: 80.892, close: 80.898),
      Candle(epoch: 12, high: 80.902, low: 80.895, open: 80.898, close: 80.895),
      Candle(epoch: 13, high: 80.902, low: 80.894, open: 80.894, close: 80.901),
      Candle(epoch: 14, high: 80.903, low: 80.894, open: 80.901, close: 80.896),
      Candle(epoch: 15, high: 80.898, low: 80.892, open: 80.897, close: 80.895),
      Candle(epoch: 16, high: 80.898, low: 80.891, open: 80.897, close: 80.892),
      Candle(epoch: 17, high: 80.898, low: 08.887, open: 80.892, close: 80.897),
      Candle(epoch: 18, high: 80.922, low: 80.893, open: 80.895, close: 80.921),
    ];
  });

  group('Positive DM Indicator.', () {
    test(
        'Positive DM Inicator should calculate the correct result from the given candles.',
        () {
      final PositiveDMIndicator positiveDMIndicator =
          PositiveDMIndicator(ticks);

      expect(positiveDMIndicator.getValue(0).quote, 0);
      expect(roundDouble(positiveDMIndicator.getValue(1).quote, 3), 0.001);
      expect(positiveDMIndicator.getValue(2).quote, 0);
      expect(roundDouble(positiveDMIndicator.getValue(3).quote, 3), 0.007);
    });
  });
}
