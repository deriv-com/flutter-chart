import 'dart:math';

import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import 'abstract_indicator.dart';

/// Handling a level of caching
abstract class CachedIndicator extends AbstractIndicator {
  CachedIndicator(List<Candle> candles) : super(candles) {
    for (int i = 0; i < candles.length; i++) {
      // results.add(getValue(i));
      getValue(i);
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
  Tick getValue(int index) {
    if (candles == null) {
      // Series is null; the indicator doesn't need cache.
      // (e.g. simple computation of the value)
      // --> Calculating the value
      return calculate(index);
    }

    // Series is not null

    final int removedBarsCount = 0;
    final int maximumResultCount = candles.length;

    double result;
    if (index < removedBarsCount) {
      // Result already removed from cache
      print(
          "{}: result from bar {} already removed from cache, use {}-th instead");
      increaseLengthTo(removedBarsCount, maximumResultCount);
      highestResultIndex = removedBarsCount;
      result = results[0].quote;
      if (result == null) {
        // It should be "result = calculate(removedBarsCount);".
        // We use "result = calculate(0);" as a workaround
        // to fix issue #120 (https://github.com/mdeverdelhan/ta4j/issues/120).
        result = calculate(0).quote;
        results[0] = Tick(epoch: candles[index].epoch, quote: result);
      }
    } else {
      if (index == candles.length - 1) {
        // Don't cache result if last bar
        result = calculate(index).quote;
      } else {
        increaseLengthTo(index, maximumResultCount);
        if (index > highestResultIndex) {
          // Result not calculated yet
          highestResultIndex = index;
          result = calculate(index).quote;
          results[results.length - 1] =
              Tick(epoch: candles[index].epoch, quote: result);
        } else {
          // Result covered by current cache
          int resultInnerIndex =
              results.length - 1 - (highestResultIndex - index);
          result = results[resultInnerIndex].quote;
          if (result == null) {
            result = calculate(index).quote;
            results[resultInnerIndex] =
                Tick(epoch: candles[index].epoch, quote: result);
          }
        }
      }
    }
    return Tick(epoch: candles[index].epoch, quote: result);
  }

  /**
   * Increases the size of cached results buffer.
   *
   * @param index     the index to increase length to
   * @param maxLength the maximum length of the results buffer
   */
  void increaseLengthTo(int index, int maxLength) {
      if (highestResultIndex > -1) {
        int newResultsCount = min(index - highestResultIndex, maxLength);
        if (newResultsCount == maxLength) {
          results.clear();
          // results.addAll(Collections.nCopies(maxLength, null));
          results.addAll(List<Tick>(maxLength));
        } else if (newResultsCount > 0) {
          // results.addAll(Collections.nCopies(newResultsCount, null));
          results.addAll(List<Tick>(newResultsCount));
          removeExceedingResults(maxLength);
        }
      } else {
        // First use of cache
        // assert results.isEmpty() : "Cache results list should be empty";
        // results.addAll(Collections.nCopies(Math.min(index + 1, maxLength), null));
        results.addAll(List<Tick>(min(index + 1, maxLength)));
    }
  }

  /**
   * Removes the N first results which exceed the maximum bar count. (i.e. keeps
   * only the last maximumResultCount results)
   *
   * @param maximumResultCount the number of results to keep
   */
  void removeExceedingResults(int maximumResultCount) {
    int resultCount = results.length;
    if (resultCount > maximumResultCount) {
      // Removing old results
      final int nbResultsToRemove = resultCount - maximumResultCount;
      for (int i = 0; i < nbResultsToRemove; i++) {
        results.remove(0);
      }
    }
  }

  /// Calculates the value of this indicator for the give [index]
  Tick calculate(int index);
}
