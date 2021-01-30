import 'package:deriv_technical_analysis/src/models/models.dart';

/// Indicators input data.
abstract class DataInput {
  /// Input entries.
  List<OHLC> get entries;

  /// Creates [Result] entry from given [index] and [value].
  ///
  /// User of this package has the option to implement this interface and [Result]
  /// in its own way and get a list of results in any [Result] implementation needed.
  Result createResult(int index, double value);
}
