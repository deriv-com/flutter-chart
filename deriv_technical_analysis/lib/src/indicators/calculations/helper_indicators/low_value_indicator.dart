import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../indicator.dart';

/// A helper indicator to get the low value of a list of [OHLC]
class LowValueIndicator<T extends Result> extends Indicator<T> {
  /// Initializes
  LowValueIndicator(DataInput input) : super(input);

  @override
  T getValue(int index) =>
      createResultOf(epoch: getEpochOfIndex(index), quote: entries[index].low);
}
