import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/quote_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Weighted Moving Average', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = <Tick>[
        Tick(epoch: 1, quote: 1.0),
        Tick(epoch: 1, quote: 2.0),
        Tick(epoch: 1, quote: 3.0),
        Tick(epoch: 1, quote: 4.0),
        Tick(epoch: 1, quote: 5.0),
        Tick(epoch: 1, quote: 6.0),
      ];
    });

    test('WMA', () {
      WMAIndicator wmaIndicator = new WMAIndicator(QuoteIndicator(ticks), 3);

      expect(wmaIndicator.getValue(0).quote, 1);
      expect(roundDouble(wmaIndicator.getValue(1).quote, 4), 1.6667);
      expect(roundDouble(wmaIndicator.getValue(2).quote, 4), 2.3333);
      expect(roundDouble(wmaIndicator.getValue(3).quote, 4), 3.3333);
      expect(roundDouble(wmaIndicator.getValue(4).quote, 4), 4.3333);
      expect(roundDouble(wmaIndicator.getValue(5).quote, 4), 5.3333);
    });
  });
}
