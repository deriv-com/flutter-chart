import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/cached_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/ma_env/ma_env_lower_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/ma_env/ma_env_shift_typs.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/ma_env/ma_env_upper_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Moving Average Envelope', () {
    List<MockTick> ticks;
    setUpAll(() {
      ticks = const <MockTick>[
        MockTick(epoch: 1, quote: 1),
        MockTick(epoch: 2, quote: 2),
        MockTick(epoch: 3, quote: 3),
        MockTick(epoch: 4, quote: 4),
        MockTick(epoch: 5, quote: 3),
        MockTick(epoch: 6, quote: 4),
        MockTick(epoch: 7, quote: 5),
        MockTick(epoch: 8, quote: 4),
        MockTick(epoch: 9, quote: 3),
        MockTick(epoch: 10, quote: 3),
        MockTick(epoch: 11, quote: 4),
        MockTick(epoch: 12, quote: 3),
        MockTick(epoch: 13, quote: 2),
      ];
    });

    test(
        'Moving Average Envelope Upper Indicator calculates the correct result',
        () {
      final Indicator<MockResult> closePrice =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final CachedIndicator<MockResult> smaIndicator =
          SMAIndicator<MockResult>(closePrice, 10);

      final MAEnvUpperIndicator<MockResult> maEnvUpperIndicator =
          MAEnvUpperIndicator<MockResult>(
        smaIndicator,
        ShiftType.point,
        5,
      );

      expect(maEnvUpperIndicator.getValue(0).quote, 6);
      expect(maEnvUpperIndicator.getValue(1).quote, 6.5);
      expect(roundDouble(maEnvUpperIndicator.getValue(2).quote, 3), 7);
      expect(roundDouble(maEnvUpperIndicator.getValue(3).quote, 3), 7.5);
      expect(roundDouble(maEnvUpperIndicator.getValue(4).quote, 4), 7.6);
      expect(roundDouble(maEnvUpperIndicator.getValue(5).quote, 4), 7.8333);
      expect(roundDouble(maEnvUpperIndicator.getValue(6).quote, 3), 8.143);
      expect(roundDouble(maEnvUpperIndicator.getValue(7).quote, 4), 8.25);
    });

    test(
        'Moving Average Envelope Lower Indicator calculates the correct result',
        () {
      final Indicator<MockResult> closePrice =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final CachedIndicator<MockResult> smaIndicator =
          SMAIndicator<MockResult>(closePrice, 10);

      final MAEnvLowerIndicator<MockResult> maEnvLowerIndicator =
          MAEnvLowerIndicator<MockResult>(
        smaIndicator,
        ShiftType.point,
        5,
      );

      expect(maEnvLowerIndicator.getValue(0).quote, -4);
      expect(maEnvLowerIndicator.getValue(1).quote, -3.5);
      expect(maEnvLowerIndicator.getValue(2).quote, -3);
      expect(maEnvLowerIndicator.getValue(3).quote, -2.5);
      expect(maEnvLowerIndicator.getValue(4).quote, -2.4);
    });
  });
}
