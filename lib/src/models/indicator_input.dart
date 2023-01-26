import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Indicator's input
class IndicatorInput implements IndicatorDataInput {
  /// Initializes
  IndicatorInput(this.entries, this.granularity, {this.id});

  @override
  final List<Tick> entries;

  /// The granularity of this [entries] data.
  final int granularity;

  /// The id passed to Indicator series.
  final String? id;

  @override
  IndicatorResult createResult(int index, double value) =>
      Tick(epoch: _getEpochForIndex(index), quote: value);

  int _getEpochForIndex(int index) => entries[index].epoch;
}
