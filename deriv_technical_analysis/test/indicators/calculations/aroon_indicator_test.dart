import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/arron/aroon_down_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/arron/aroon_oscillator_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/arron/aroon_up_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Aroon Indicator', () {
    List<MockOHLC> candles;

    setUpAll(() {
      candles = const <MockOHLC>[
        MockOHLC(0, 168.28, 169.64, 169.87, 167.15),
        MockOHLC(1, 168.84, 168.71, 169.36, 168.2),
        MockOHLC(2, 168.88, 167.74, 169.29, 166.41),
        MockOHLC(3, 168, 166.32, 168.38, 166.18),
        MockOHLC(4, 166.89, 167.24, 167.7, 166.33),
        MockOHLC(5, 165.25, 168.05, 168.43, 165),
        MockOHLC(6, 168.17, 169.92, 170.18, 167.63),
        MockOHLC(7, 170.42, 171.97, 172.15, 170.06),
        MockOHLC(8, 172.41, 172.02, 172.92, 171.31),
        MockOHLC(9, 171.2, 170.72, 172.39, 169.55),
        MockOHLC(10, 170.91, 172.09, 172.48, 169.57),
        MockOHLC(11, 171.8, 173.21, 173.31, 170.27),
        MockOHLC(12, 173.09, 170.95, 173.49, 170.8),
        MockOHLC(13, 172.41, 173.51, 173.89, 172.2),
        MockOHLC(14, 173.87, 172.96, 174.17, 175),
        MockOHLC(15, 173, 173.05, 173.17, 172.06),
        MockOHLC(16, 172.26, 170.96, 172.28, 170.5),
        MockOHLC(17, 170.88, 171.64, 172.34, 170.26),
        MockOHLC(18, 171.85, 170.01, 172.07, 169.34),
        MockOHLC(19, 170.75, 172.52, 172.56, 170.36),
      ];
    });
    test('Aroon Down Indicator calculates the correct result', () {
      const int period = 5;
      final LowValueIndicator<MockResult> lowValueIndicator =
          LowValueIndicator<MockResult>(MockInput(candles));

      final AroonDownIndicator<MockResult> aroonDownIndicator =
          AroonDownIndicator<MockResult>.fromIndicator(
              lowValueIndicator, period);

      expect(aroonDownIndicator.getValue(19).quote, 80);
      expect(aroonDownIndicator.getValue(18).quote, 100);
      expect(aroonDownIndicator.getValue(17).quote, 100);
      expect(aroonDownIndicator.getValue(16).quote, 0);
      expect(aroonDownIndicator.getValue(15).quote, 0);
      expect(aroonDownIndicator.getValue(14).quote, 0);
      expect(aroonDownIndicator.getValue(13).quote, 20);
      expect(aroonDownIndicator.getValue(12).quote, 40);
      expect(aroonDownIndicator.getValue(11).quote, 0);
      expect(aroonDownIndicator.getValue(10).quote, 0);
      expect(aroonDownIndicator.getValue(9).quote, 20);
      expect(aroonDownIndicator.getValue(8).quote, 40);
      expect(aroonDownIndicator.getValue(7).quote, 60);
      expect(aroonDownIndicator.getValue(6).quote, 80);
      expect(aroonDownIndicator.getValue(5).quote, 100);
    });

    test('Aroon Up Indicator calculates the correct result', () {
      const int period = 5;
      final HighValueIndicator<MockResult> highValueIndicator =
          HighValueIndicator<MockResult>(MockInput(candles));

      final AroonUpIndicator<MockResult> aroonUpIndicator =
          AroonUpIndicator<MockResult>.fromIndicator(
              highValueIndicator, period);

      expect(aroonUpIndicator.getValue(19).quote, 0);
      expect(aroonUpIndicator.getValue(18).quote, 20);
      expect(aroonUpIndicator.getValue(17).quote, 40);
      expect(aroonUpIndicator.getValue(16).quote, 60);
      expect(aroonUpIndicator.getValue(15).quote, 80);
      expect(aroonUpIndicator.getValue(14).quote, 100);
      expect(aroonUpIndicator.getValue(13).quote, 100);
      expect(aroonUpIndicator.getValue(12).quote, 100);
      expect(aroonUpIndicator.getValue(11).quote, 100);
      expect(aroonUpIndicator.getValue(10).quote, 60);
      expect(aroonUpIndicator.getValue(9).quote, 80);
      expect(aroonUpIndicator.getValue(8).quote, 100);
      expect(aroonUpIndicator.getValue(7).quote, 100);
      expect(aroonUpIndicator.getValue(6).quote, 100);
      expect(aroonUpIndicator.getValue(5).quote, 0);
    });

    test('Aroon Oscillator Indicator calculates the correct result', () {
      final AroonOscillatorIndicator<MockResult> aroonOscillatorIndicator =
          AroonOscillatorIndicator<MockResult>.fromIndicator(MockInput(candles),
              period: 5);

      expect(aroonOscillatorIndicator.getValue(19).quote, 80);
      expect(aroonOscillatorIndicator.getValue(18).quote, 80);
      expect(aroonOscillatorIndicator.getValue(17).quote, 60);
      expect(aroonOscillatorIndicator.getValue(16).quote, -60);
    });
  });
}
