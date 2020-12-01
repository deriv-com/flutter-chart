import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Zero-lag Exponential Moving Average', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = <Tick>[
        Tick(epoch: 1, quote: 10),
        Tick(epoch: 1, quote: 15),
        Tick(epoch: 1, quote: 20),
        Tick(epoch: 1, quote: 18),
        Tick(epoch: 1, quote: 17),
        Tick(epoch: 1, quote: 18),
        Tick(epoch: 1, quote: 15),
        Tick(epoch: 1, quote: 12),
        Tick(epoch: 1, quote: 10),
        Tick(epoch: 1, quote: 8),
        Tick(epoch: 1, quote: 5),
        Tick(epoch: 1, quote: 2),
      ];
    });

    test('ZELMA', () {
      ZLEMAIndicator indicator = ZLEMAIndicator(CloseValueIndicator(ticks), 10);

      expect(roundDouble(indicator.results[9].quote, 3), 11.909);
      expect(roundDouble(indicator.results[10].quote, 4), 8.8347);
      expect(roundDouble(indicator.results[11].quote, 4), 5.7739);
    });
  });
}
