import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';

/// Base class of all indicators.
///
/// Holds common functionalities of indicators like getting epoch for an index or handling indicator's offset.
abstract class Indicator<T extends Result> {
  /// Initializes
  Indicator(this.input);

  /// [DataInput] to calculate indicator values on.
  final DataInput input;

  /// The entries of the [input]
  List<OHLC> get entries => input.entries;

  /// Value of the indicator for the given [index].
  T getValue(int index);

  /// Creates a [Result] entry.
  ///
  /// Uses [createResult] is implemented inside [DataInput]. An implementation of
  /// [DataInput] can be passed to this [Indicator] class which can instantiate ans return
  /// an object of class which implements [Result].
  T createResult({int index, double quote}) => input.createResult(index, quote);
}
