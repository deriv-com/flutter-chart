import 'package:deriv_technical_analysis/src/models/models.dart';

/// Indicators input data
abstract class DataInput {
  /// Input entries
  List<OHLC> get entries;

  /// Creates [Result] entry from given [epoch] and [value].
  Result createResultOf(int epoch, double value);
}

/// Indicator's input implementation.
class Input implements DataInput {
  /// Initializes
  Input(this.entries);

  @override
  final List<OHLC> entries;

  @override
  Result createResultOf(int epoch, double value) => ResultEntry(epoch, value);
}
