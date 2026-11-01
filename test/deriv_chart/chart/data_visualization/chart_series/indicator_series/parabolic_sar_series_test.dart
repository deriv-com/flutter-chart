import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/parabolic_sar_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/parabolic_sar/parabolic_sar_series.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

const int _granularity = 60000;

const List<Candle> _candles = <Candle>[
  Candle.noParam(60000, 10, 11, 12, 9),
  Candle.noParam(120000, 11, 13, 14, 10),
  Candle.noParam(180000, 13, 15, 16, 12),
  Candle.noParam(240000, 15, 14, 16, 13),
  Candle.noParam(300000, 14, 11, 15, 10),
  Candle.noParam(360000, 11, 9, 12, 8),
  Candle.noParam(420000, 9, 10, 11, 8),
  Candle.noParam(480000, 10, 13, 14, 9),
];

const ParabolicSAROptions _options = ParabolicSAROptions(0.02, 0.2);

ParabolicSARSeries _seriesOf(List<Candle> candles) =>
    ParabolicSARSeries(IndicatorInput(candles, _granularity), _options);

/// PSAR values calculated from scratch for the given [candles] by the
/// library's own indicator, which keeps no state between calculations.
List<double> _expectedValuesOf(List<Candle> candles) =>
    ParabolicSarIndicator<Tick>(IndicatorInput(candles, _granularity))
        .calculateValues()
        .map((Tick tick) => tick.quote)
        .toList();

void _expectValues(ParabolicSARSeries series, List<Candle> candles) {
  final List<double> actual =
      series.entries!.map((Tick tick) => tick.quote).toList();
  final List<double> expected = _expectedValuesOf(candles);

  expect(actual.length, expected.length);
  for (int i = 0; i < expected.length; i++) {
    if (expected[i].isNaN) {
      expect(actual[i].isNaN, isTrue, reason: 'index $i');
    } else {
      expect(actual[i], closeTo(expected[i], 1e-9), reason: 'index $i');
    }
  }
}

void main() {
  group('ParabolicSARSeries', () {
    test('initializes with a single candle', () {
      final List<Candle> candles = _candles.sublist(0, 1);
      final ParabolicSARSeries series = _seriesOf(candles)..didUpdate(null);

      expect(series.entries, hasLength(1));
      expect(series.entries!.first.quote.isNaN, isTrue);
    });

    test('initializes with two candles', () {
      final List<Candle> candles = _candles.sublist(0, 2);
      final ParabolicSARSeries series = _seriesOf(candles)..didUpdate(null);

      // Uptrend detected on the second candle: SAR sits on its low.
      expect(series.entries, hasLength(2));
      expect(series.entries![1].quote, candles[1].low);
    });

    test('keeps results correct while growing one candle at a time', () {
      ParabolicSARSeries series = _seriesOf(_candles.sublist(0, 1))
        ..didUpdate(null);

      for (int length = 2; length <= _candles.length; length++) {
        final List<Candle> candles = _candles.sublist(0, length);
        final ParabolicSARSeries newSeries = _seriesOf(candles)
          ..didUpdate(series);

        _expectValues(newSeries, candles);
        series = newSeries;
      }
    });

    test('keeps results correct when the last candle updates', () {
      ParabolicSARSeries series = _seriesOf(_candles.sublist(0, 1))
        ..didUpdate(null);

      for (int length = 1; length <= _candles.length; length++) {
        final Candle lastCandle = _candles[length - 1];

        // The live candle moves before it closes on its final values.
        for (final Candle candle in <Candle>[
          lastCandle.copyWith(
            high: lastCandle.high + 1,
            close: lastCandle.close + 0.5,
          ),
          lastCandle.copyWith(
            low: lastCandle.low - 1,
            close: lastCandle.close - 0.5,
          ),
          lastCandle,
        ]) {
          final List<Candle> candles = <Candle>[
            ..._candles.sublist(0, length - 1),
            candle,
          ];
          final ParabolicSARSeries newSeries = _seriesOf(candles)
            ..didUpdate(series);

          _expectValues(newSeries, candles);
          series = newSeries;
        }
      }
    });
  });
}
