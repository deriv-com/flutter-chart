import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_base_line_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_conversion_line_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_lagging_span_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_span_a_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_span_b_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ichimoku Cloud Test', () {
    List<Tick> ticks;
    IchimokuConversionLineIndicator conversionLineIndicator;
    IchimokuBaseLineIndicator baseLineIndicator;

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
        Candle.noParam(21, 79.547, 79.547, 79.547, 79.538),
        Candle.noParam(22, 79.545, 79.544, 79.548, 79.543),
        Candle.noParam(23, 79.543, 79.545, 79.546, 79.541),
        Candle.noParam(24, 79.545, 79.564, 79.565, 79.543),
        Candle.noParam(25, 79.565, 79.562, 79.567, 79.560),
        Candle.noParam(26, 79.563, 79.559, 79.566, 79.559),
        Candle.noParam(27, 79.558, 79.560, 79.568, 79.554),
        Candle.noParam(28, 79.565, 79.573, 79.577, 79.562),
        Candle.noParam(29, 79.578, 79.583, 79.584, 79.568),
        Candle.noParam(30, 79.582, 79.589, 79.592, 79.582),
        Candle.noParam(31, 79.591, 79.590, 79.596, 79.588),
        Candle.noParam(32, 79.589, 79.586, 79.590, 79.582),
        Candle.noParam(33, 79.586, 79.557, 79.586, 79.552),
        Candle.noParam(34, 79.556, 79.555, 79.565, 79.555),
        Candle.noParam(35, 79.554, 79.555, 79.562, 79.549),
        Candle.noParam(36, 79.556, 79.544, 79.556, 79.540),
        Candle.noParam(37, 79.543, 79.536, 79.545, 79.523),
        Candle.noParam(38, 79.535, 79.532, 79.557, 79.531),
        Candle.noParam(39, 79.532, 79.515, 79.537, 79.510),
        Candle.noParam(40, 79.516, 79.492, 79.521, 79.490),
        Candle.noParam(41, 79.494, 79.420, 79.497, 79.416),
        Candle.noParam(42, 79.426, 79.437, 79.438, 79.416),
        Candle.noParam(43, 79.436, 79.459, 79.466, 79.435),
        Candle.noParam(44, 79.459, 79.457, 79.464, 79.449),
        Candle.noParam(45, 79.457, 79.469, 79.477, 79.454),
        Candle.noParam(46, 79.466, 79.471, 79.480, 79.463),
        Candle.noParam(47, 79.473, 79.481, 79.487, 79.470),
        Candle.noParam(48, 79.480, 79.462, 79.483, 79.457),
        Candle.noParam(49, 79.462, 79.455, 79.462, 79.451),
        Candle.noParam(50, 79.453, 79.456, 79.457, 79.448),
        Candle.noParam(51, 79.456, 79.446, 79.459, 79.434),
        Candle.noParam(52, 79.448, 79.439, 79.449, 79.429),
        Candle.noParam(53, 79.442, 79.425, 79.442, 79.420),
        Candle.noParam(54, 79.424, 79.416, 79.424, 79.412),
        Candle.noParam(55, 79.418, 79.405, 79.420, 79.401),
        Candle.noParam(56, 79.405, 79.386, 79.405, 79.385),
        Candle.noParam(57, 79.386, 79.413, 79.413, 79.385),
      ];

      conversionLineIndicator = IchimokuConversionLineIndicator(ticks);
      baseLineIndicator = IchimokuBaseLineIndicator(ticks);
    });

    test(
        "Ichimoku Lagging Span calculates the previous [period] of the given candle's closing value for the selected candle.",
        () {
      final IchimokuLaggingSpanIndicator laggingSpanIndicator =
          IchimokuLaggingSpanIndicator(ticks);

      expect(laggingSpanIndicator.getValue(3).quote, 79.529);
      expect(laggingSpanIndicator.getValue(4).quote, 79.532);
      expect(laggingSpanIndicator.getValue(5).quote, 79.525);
      expect(laggingSpanIndicator.getValue(6).quote, 79.514);
    });

    test(
        "Ichimoku Conversion Line calculates the previous [period]s(9 by default) average of the given candle's highest high and lowest low.",
        () {
      expect(conversionLineIndicator.getValue(26).quote, 79.5525);
      expect(conversionLineIndicator.getValue(27).quote, 79.553);
      expect(conversionLineIndicator.getValue(28).quote, 79.5575);
      expect(conversionLineIndicator.getValue(29).quote, 79.561);
      expect(
          roundDouble(conversionLineIndicator.getValue(30).quote, 4), 79.5665);
    });

    test(
        "Ichimoku Base Line calculates the previous [period]s(26 by default) average of the given candle's highest high and lowest low.",
        () {
      expect(baseLineIndicator.getValue(26).quote, 79.535);
      expect(baseLineIndicator.getValue(27).quote, 79.5355);
      expect(roundDouble(baseLineIndicator.getValue(28).quote, 2), 79.54);
      expect(baseLineIndicator.getValue(29).quote, 79.5435);
      expect(baseLineIndicator.getValue(30).quote, 79.5475);
    });

    test(
        "Ichimoku Span A calculates the average of the given candle's Conversion Line and Base Line.",
        () {
      final IchimokuSpanAIndicator spanAIndicator = IchimokuSpanAIndicator(
          ticks,
          conversionLineIndicator: conversionLineIndicator,
          baseLineIndicator: baseLineIndicator);
      expect(roundDouble(spanAIndicator.getValue(26).quote, 4), 79.5437);
      expect(roundDouble(spanAIndicator.getValue(27).quote, 4), 79.5443);
      expect(roundDouble(spanAIndicator.getValue(28).quote, 4), 79.5487);
      expect(roundDouble(spanAIndicator.getValue(29).quote, 4), 79.5523);
      expect(roundDouble(spanAIndicator.getValue(30).quote, 3), 79.557);
    });

    test(
        "Ichimoku Span B calculates the previous [period]s(52 by default) average of the given candle's highest high and lowest low.",
        () {
      final IchimokuSpanBIndicator spanAIndicator =
          IchimokuSpanBIndicator(ticks);

      expect(spanAIndicator.getValue(52).quote, 79.506);
      expect(spanAIndicator.getValue(53).quote, 79.506);
      expect(spanAIndicator.getValue(54).quote, 79.504);
      expect(spanAIndicator.getValue(55).quote, 79.4985);
      expect(spanAIndicator.getValue(56).quote, 79.4905);
    });
  });
}
