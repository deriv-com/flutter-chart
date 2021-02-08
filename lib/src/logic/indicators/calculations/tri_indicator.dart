import 'dart:math';

import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// True range indicator.
class TRIIndicator extends CachedIndicator {
  /// Initializes a true range indicator.
  TRIIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick calculate(int index) {
    final double ts = entries[index].high - entries[index].low;

    final double ys =
        index == 0 ? 0 : entries[index].high - entries[index].close;
    final double yst =
        index == 0 ? 0 : entries[index].close - entries[index].low;

    return max(
      ts.abs(),
      max(
        ys.abs(),
        yst.abs(),
      ),
    );
  }
}
