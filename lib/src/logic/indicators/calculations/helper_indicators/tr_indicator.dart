import 'dart:math';

import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// True range indicator.
class TRIndicator extends CachedIndicator {
  /// Initializes a true range indicator.
  TRIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick calculate(int index) {
    final double tickSize = entries[index].high - entries[index].low;

    final double highMinusClose =
        index == 0 ? 0 : entries[index].high - entries[index].close;
    final double closeMinusLow =
        index == 0 ? 0 : entries[index].close - entries[index].low;

    return Tick(
      epoch: getEpochOfIndex(index),
      quote: max(
        tickSize.abs(),
        max(
          highMinusClose.abs(),
          closeMinusLow.abs(),
        ),
      ),
    );
  }
}
