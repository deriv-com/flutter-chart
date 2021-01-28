import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_base_line_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ichimoku/ichimoku_conversion_line_indicator.dart';
import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:flutter/foundation.dart';

/// An `indicator` to calculate average of the given [conversionLineIndicator] and [baseLineIndicator].
class IchimokuSpanAIndicator extends CachedIndicator {
  /// Initializes an [IchimokuSpanAIndicator].
  IchimokuSpanAIndicator(
    List<OHLC> entries, {
    @required this.conversionLineIndicator,
    @required this.baseLineIndicator,
  }) : super(entries);

  @override
  Tick calculate(int index) {
    final double spanAQuote = (conversionLineIndicator.getValue(index).quote +
            baseLineIndicator.getValue(index).quote) /
        2;
    return Tick(epoch: getEpochOfIndex(index), quote: spanAQuote);
  }

  /// The [IchimokuConversionLineIndicator] to caclculate the spanA from.
  final IchimokuConversionLineIndicator conversionLineIndicator;

  /// The [IchimokuBaseLineIndicator] to caclculate the spanA from.
  final IchimokuBaseLineIndicator baseLineIndicator;
}
