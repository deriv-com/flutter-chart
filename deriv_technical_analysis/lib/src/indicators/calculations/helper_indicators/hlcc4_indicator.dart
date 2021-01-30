import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../indicator.dart';

/// A helper indicator to get the [(H + L+ 2* C) / 4] value of a list of [OHLC]
class HLCC4Indicator<T extends Result> extends Indicator<T> {
  /// Initializes
  HLCC4Indicator(DataInput input) : super(input);

  @override
  T getValue(int index) {
    final OHLC entry = entries[index];
    return createResult(
      index: index,
      quote: (entry.high + entry.low + 2 * entry.close) / 4,
    );
  }
}
