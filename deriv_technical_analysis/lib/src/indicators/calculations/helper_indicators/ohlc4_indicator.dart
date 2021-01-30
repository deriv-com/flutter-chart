import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

/// A helper indicator to get the [(O+ H + L+ C) / 4] value of a list of [OHLC]
class OHLC4Indicator<T extends Result> extends Indicator<T> {
  /// Initializes
  OHLC4Indicator(DataInput input) : super(input);

  @override
  T getValue(int index) {
    final OHLC entry = entries[index];
    return createResult(
      index: index,
      quote: (entry.open + entry.high + entry.low + entry.close) / 4,
    );
  }
}
