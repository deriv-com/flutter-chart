import 'dart:math';

import 'package:deriv_chart/src/logic/indicators/calculations/abstract_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'cached_indicator.dart';

abstract class RecursiveCachedIndicator<T extends Tick>
    extends CachedIndicator<T> {
   /// The recursion threshold for which an iterative calculation is executed.
  static const int RECURSION_THRESHOLD = 50;

  /// Initializes
  RecursiveCachedIndicator(List<T> candles) : super(candles);

  /// Initializes from another [Indicator]
  RecursiveCachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.entries);

  // @override
  // Tick getValue(int index) {
  //   if (entries != null) {
  //     final int endIndex = entries.length - 1;
  //     if (index <= endIndex) {
  //       final int removedEntriesCount = 0;
  //       int startIndex = max(removedEntriesCount, highestResultIndex);
  //       if (index - startIndex > RECURSION_THRESHOLD) {
  //         // Too many un-calculated values; the risk for a StackOverflowError becomes high.
  //         // Calculating the previous values iteratively
  //         for (int prevIdx = startIndex; prevIdx < index; prevIdx++) {
  //           super.getValue(prevIdx);
  //         }
  //       }
  //     }
  //   }
  //
  //   return super.getValue(index);
  // }
}
