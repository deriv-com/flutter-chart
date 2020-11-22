import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import 'abstract_indicator.dart';

/// Handling a level of caching
abstract class CachedIndicator extends AbstractIndicator {
  CachedIndicator(List<Candle> candles) : super(candles) {
    for (int i = 0; i < candles.length; i++) {
      results.add(getValue(i));
    }
  }

  CachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.candles);

  /// Should always be the index of the last result in the results list. I.E. the
  /// last calculated result.
  @protected
  int highestResultIndex = -1;

  /// List of cached result.
  final List<Tick> results = <Tick>[];

  @override
  // TODO(Ramin): Add caching logic if we it someday.
  Tick getValue(int index) {
    final Tick result = calculate(index);
    highestResultIndex = index;
    return calculate(index);
  }

  /// Calculates the value of this indicator for the give [index]
  Tick calculate(int index);
}
