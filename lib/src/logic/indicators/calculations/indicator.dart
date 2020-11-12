/// An indicator
abstract class Indicator {
  /// Value of the indicator for the given [index].
  double getValue(int index);
}

/// Bass class of all indicators.
abstract class AbstractIndicator implements Indicator {}

/// Handling a level of caching
abstract class CachedIndicator extends AbstractIndicator {
  /// List of cached result.
  final List<double> results = <double>[];

  @override
  // TODO(Ramin): Add caching logic.
  double getValue(int index) => calculate(index);

  /// Calculates the value of this indicator for the give [index]
  double calculate(int index);
}
