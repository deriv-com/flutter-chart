import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';

import '../../indicator.dart';

/// A helper indicator to get the [(H + L) / 2] value of a list of [Tick]
class HL2Indicator<T extends Result> extends Indicator<T> {
  /// Initializes
  HL2Indicator(DataInput input) : super(input);

  @override
  T getValue(int index) {
    final OHLC entry = entries[index];
    return createResult(index: index, quote: (entry.high + entry.low) / 2);
  }
}
