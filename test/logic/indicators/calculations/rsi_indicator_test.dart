import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/rsi_indicator.dart';
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
      Candle.noParam(06, 79.525, 79.514, 79.528, 79.505),
      Candle.noParam(07, 79.515, 79.510, 79.516, 79.507),
      Candle.noParam(08, 79.509, 79.507, 79.512, 79.503),
      Candle.noParam(09, 79.507, 79.518, 79.520, 79.504),
      Candle.noParam(10, 79.517, 79.507, 79.523, 79.507),
      Candle.noParam(11, 79.510, 79.509, 79.515, 79.505),
      Candle.noParam(12, 79.508, 79.513, 79.518, 79.508),
      Candle.noParam(13, 79.513, 79.526, 79.526, 79.513),
      Candle.noParam(14, 79.526, 79.526, 79.527, 79.521),
      Candle.noParam(15, 79.526, 79.544, 79.547, 79.525),
      Candle.noParam(16, 79.546, 79.545, 79.547, 79.533),
      Candle.noParam(17, 79.545, 79.556, 79.559, 79.538),
      Candle.noParam(18, 79.557, 79.554, 79.562, 79.544),
      Candle.noParam(19, 79.555, 79.549, 79.559, 79.548),
      Candle.noParam(20, 79.550, 79.548, 79.554, 79.545),
    ];
  });

  group('Relative Strength Index Indicator test.', () {
    test(
        'Relative Strength Index should calculate the correct results from the given closed value indicator ticks.',
        () {
      final CloseValueIndicator closeValueIndicator =
          CloseValueIndicator(ticks);
      final RSIIndicator rsiIndicator =
          RSIIndicator.fromIndicator(closeValueIndicator, 14);

      expect(rsiIndicator.getValue(0).quote, 0);
      expect(roundDouble(rsiIndicator.getValue(14).quote, 2), 52.88);
      expect(roundDouble(rsiIndicator.getValue(15).quote, 2), 65.42);
      expect(roundDouble(rsiIndicator.getValue(16).quote, 2), 65.96);
      expect(roundDouble(rsiIndicator.getValue(17).quote, 2), 71.28);
    });
  });
}
