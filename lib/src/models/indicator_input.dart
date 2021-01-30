import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Indicator's input
class IndicatorInput implements DataInput {
  /// Initializes
  IndicatorInput(this.entries);

  @override
  final List<Tick> entries;

  @override
  Result createResult(int index, double value) =>
      Tick(epoch: _getEpochForIndex(index), quote: value);

  int _getEpochForIndex(int index) => entries[index].epoch;
}
