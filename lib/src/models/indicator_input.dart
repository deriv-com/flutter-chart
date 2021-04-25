import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Indicator's input
class IndicatorInput implements IndicatorDataInput {
  /// Initializes
  IndicatorInput(this.entries, this.granularity);

  @override
  final List<Tick> entries;

  /// The granularity of this [entries] data.
  final int granularity;

  @override
  IndicatorResult createResult(int index, double value) =>
      Tick(epoch: _getEpochForIndex(index), quote: value);

  int _getEpochForIndex(int index) => entries[index].epoch;
}
