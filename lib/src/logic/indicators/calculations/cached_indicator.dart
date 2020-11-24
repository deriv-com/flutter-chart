import 'dart:math';

import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import 'abstract_indicator.dart';

/// Handling a level of caching
abstract class CachedIndicator<T extends Tick> extends AbstractIndicator<T> {
  CachedIndicator(List<T> candles) : super(candles);

  /// Initializes from another [Indicator]
  CachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.entries);

  /// Should always be the index of the last result in the results list. I.E. the
  /// last calculated result.
  @protected
  int highestResultIndex = -1;

  /// List of cached result.
  final List<Tick> results = <Tick>[];

  @override
  Tick getValue(int index) {
    // Caching buffer size is the length of entries for now.
    final int removedEntriesCount = 0;
    final int maximumResultCount = entries.length;

    double result;
    if (index < removedEntriesCount) {
      // Result already removed from cache
      increaseLengthTo(removedEntriesCount, maximumResultCount);
      highestResultIndex = removedEntriesCount;
      result = results[0].quote;
      if (result == null) {
        result = calculate(0).quote;
        results[0] = Tick(epoch: entries[index].epoch, quote: result);
      }
    } else {
      if (index == entries.length - 1) {
        // Don't cache result if last candle
        result = calculate(index).quote;
      } else {
        increaseLengthTo(index, maximumResultCount);
        if (index > highestResultIndex) {
          // Result not calculated yet
          highestResultIndex = index;
          result = calculate(index).quote;
          results[results.length - 1] =
              Tick(epoch: entries[index].epoch, quote: result);
        } else {
          // Result covered by current cache
          int resultInnerIndex =
              results.length - 1 - (highestResultIndex - index);
          result = results[resultInnerIndex].quote;
          if (result == null) {
            result = calculate(index).quote;
            results[resultInnerIndex] =
                Tick(epoch: entries[index].epoch, quote: result);
          }
        }
      }
    }
    return Tick(epoch: entries[index].epoch, quote: result);
  }

  /// Increases the size of cached results buffer.
  ///
  /// [index]     the index to increase length to
  /// [maxLength] the maximum length of the results buffer
  void increaseLengthTo(int index, int maxLength) {
    if (highestResultIndex > -1) {
      int newResultsCount = min(index - highestResultIndex, maxLength);
      if (newResultsCount == maxLength) {
        results.clear();
        results.addAll(List<Tick>(maxLength));
      } else if (newResultsCount > 0) {
        results.addAll(List<Tick>(newResultsCount));
        removeExceedingResults(maxLength);
      }
    } else {
      // First use of cache
      assert(results.isEmpty);
      results.addAll(List<Tick>(min(index + 1, maxLength)));
    }
  }

  /// Removes the N first results which exceed the maximum bar count. (i.e. keeps
  /// only the last maximumResultCount results)
  ///
  /// [maximumResultCount] the number of results to keep
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
