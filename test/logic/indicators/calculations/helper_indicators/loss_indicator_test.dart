import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/loss_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Tick> ticks;

  setUpAll(() {
    ticks = const <Tick>[
      Candle.noParam(02, 79.523, 79.526, 79.536, 79.522),
      Candle.noParam(03, 79.525, 79.529, 79.534, 79.522),
      Candle.noParam(04, 79.528, 79.532, 79.532, 79.518),
      Candle.noParam(05, 79.533, 79.525, 79.539, 79.518),
      Candle.noParam(06, 79.525, 79.514, 79.528, 79.505),
      Candle.noParam(07, 79.515, 79.510, 79.516, 79.507),
      Candle.noParam(08, 79.509, 79.507, 79.512, 79.503),
      Candle.noParam(09, 79.507, 79.518, 79.520, 79.504),
      Candle.noParam(10, 79.517, 79.507, 79.523, 79.507),
    ];
  });
  group('Loss Indicator test', () {
    test(
        'Loss Indicator should calculate the correct value from the given closed value indicator ticks.',
        () {
      final CloseValueIndicator closeValueIndicator =
          CloseValueIndicator(ticks);

      final LossIndicator lossIndicator =
          LossIndicator.fromIndicator(closeValueIndicator);

      expect(lossIndicator.getValue(0).quote, 0);
      expect(lossIndicator.getValue(1).quote, 0);
      expect(lossIndicator.getValue(2).quote, 0);
      expect(roundDouble(lossIndicator.getValue(3).quote, 3), 0.007);
    });
  });
}
