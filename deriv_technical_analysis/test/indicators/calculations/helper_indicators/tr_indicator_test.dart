import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/tr_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Tick> ticks;

  setUpAll(() {
    ticks = const <Tick>[
      Candle.noParam(00, 79.537, 79.532, 79.540, 79.529),
      Candle.noParam(01, 79.532, 79.524, 79.536, 79.522),
      Candle.noParam(02, 79.523, 79.526, 79.536, 79.522),
      Candle.noParam(03, 79.525, 79.529, 79.534, 79.522),
      Candle.noParam(04, 79.528, 79.532, 79.532, 79.518),
      Candle.noParam(05, 79.533, 79.525, 79.539, 79.518),
    ];
  });

  group('TR Indicator test', () {
    test(
        'TR Indicator should calculate the currect result from the given ticks.',
        () {
      final TRIndicator trIndicator = TRIndicator(ticks);

      expect(roundDouble(trIndicator.getValue(0).quote, 3), 0.011);
      expect(roundDouble(trIndicator.getValue(1).quote, 3), 0.014);
      expect(roundDouble(trIndicator.getValue(2).quote, 3), 0.014);
      expect(roundDouble(trIndicator.getValue(3).quote, 3), 0.012);
      expect(roundDouble(trIndicator.getValue(4).quote, 3), 0.014);
      expect(roundDouble(trIndicator.getValue(5).quote, 3), 0.021);
    });
  });
}
