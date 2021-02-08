import 'package:deriv_technical_analysis/src/models/models.dart';

/// Indicators input data.
abstract class IndicatorDataInput {
  /// Input entries.
  List<IndicatorOHLC> get entries;

  /// Creates [IndicatorResult] entry from given [index] and [value].
  ///
  /// User of this package has the option to implement this interface and [IndicatorResult]
  /// in its own way and get a list of results in any [IndicatorResult] implementation needed.
  IndicatorResult createResult(int index, double value);
}
