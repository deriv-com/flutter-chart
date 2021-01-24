import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// Indicator's input
class IndicatorInput implements DataInput {
  /// Initializes
  IndicatorInput(this._entries);

  final List<OHLC> _entries;

  @override
  List<OHLC> get entries => _entries;

  @override
  Result createResultOf(int epoch, double value) =>
      Tick(epoch: epoch, quote: value);
}
