import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/oscillator_line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/bop_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';

/// Balance of Power (BOP) indicator
class BOPIndicator<T extends Tick> extends CachedIndicator<T> {
  /// Initializes
  BOPIndicator(IndicatorDataInput input, {this.period = 14})
      : _input = input,
        super(input);

  /// Period for calculation
  final int period;

  final IndicatorDataInput _input;

  @override
  T calculate(int index) {
    final tick = _input.entries[index];

    // BOP = (Close - Open) / (High - Low)
    final double denominator = tick.high - tick.low;
    final double bop =
        denominator != 0 ? (tick.close - tick.open) / denominator : 0;

    return createResult(quote: bop, index: index);
  }
}

/// Balance of Power (BOP) series
class BOPSeries extends AbstractSingleIndicatorSeries {
  /// Initializes
  BOPSeries(
    this.indicatorInput, {
    required this.bopOptions,
    String? id,
  }) : super(
          CloseValueIndicator<Tick>(indicatorInput),
          id ?? 'BOP${bopOptions.period}',
          options: bopOptions,
          style: bopOptions.lineStyle,
          lastTickIndicatorStyle: bopOptions.lineStyle != null
              ? getLastIndicatorStyle(
                  bopOptions.lineStyle!.color,
                  showLastIndicator: bopOptions.showLastIndicator,
                )
              : null,
        );

  /// Balance of Power options
  final BOPOptions bopOptions;

  final IndicatorInput indicatorInput;

  @override
  SeriesPainter<Series> createPainter() => OscillatorLinePainter(
        this,
        secondaryHorizontalLines: <double>[0],
      );

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      BOPIndicator<Tick>(
        indicatorInput,
        period: bopOptions.period,
      );
}
