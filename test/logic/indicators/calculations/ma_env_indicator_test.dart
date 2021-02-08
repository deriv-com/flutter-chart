import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/ma_env_options.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_lower_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_shift_typs.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Moving Average Envelope', () {
    List<Tick> ticks;
    setUpAll(() {
      ticks = <Tick>[
        const Tick(epoch: 1, quote: 1),
        const Tick(epoch: 2, quote: 2),
        const Tick(epoch: 3, quote: 3),
        const Tick(epoch: 4, quote: 4),
        const Tick(epoch: 5, quote: 3),
        const Tick(epoch: 6, quote: 4),
        const Tick(epoch: 7, quote: 5),
        const Tick(epoch: 8, quote: 4),
        const Tick(epoch: 9, quote: 3),
        const Tick(epoch: 10, quote: 3),
        const Tick(epoch: 11, quote: 4),
        const Tick(epoch: 12, quote: 3),
        const Tick(epoch: 13, quote: 2),
      ];
    });

    test(
        'Moving Average Envelope Upper Indicator calculates the correct result',
        () {
      const MAEnvOptions maEnvOptions = MAEnvOptions(
          shift: 5,
          shiftType: ShiftType.point,
          period: 10,
          movingAverageType: MovingAverageType.simple);

      final Indicator closePrice = CloseValueIndicator(ticks);
      final CachedIndicator smaIndicator =
          MASeries.getMAIndicator(closePrice, maEnvOptions);

      final MAEnvUpperIndicator maEnvUpperIndicator = MAEnvUpperIndicator(
        smaIndicator,
        maEnvOptions.shiftType,
        maEnvOptions.shift,
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
      const MAEnvOptions maEnvOptions = MAEnvOptions(
          shift: 5,
          shiftType: ShiftType.point,
          period: 10,
          movingAverageType: MovingAverageType.simple);

      final Indicator closePrice = CloseValueIndicator(ticks);
      final CachedIndicator smaIndicator =
          MASeries.getMAIndicator(closePrice, maEnvOptions);

      MAEnvLowerIndicator maEnvLowerIndicator = MAEnvLowerIndicator(
        smaIndicator,
        maEnvOptions.shiftType,
        maEnvOptions.shift,
      );

      expect(maEnvLowerIndicator.getValue(0).quote, 1);
      expect(maEnvLowerIndicator.getValue(1).quote, 2.5);
      expect(maEnvLowerIndicator.getValue(1).quote, 2.5);
      expect(maEnvLowerIndicator.getValue(1).quote, 2.5);
      expect(maEnvLowerIndicator.getValue(1).quote, 2.5);
    });
  });
}
