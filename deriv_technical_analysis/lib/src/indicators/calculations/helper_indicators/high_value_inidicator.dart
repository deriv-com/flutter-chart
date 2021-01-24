import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../indicator.dart';

/// A helper indicator to get the high value of a list of [OHLC]
class HighValueIndicator<T extends Result> extends Indicator<T> {
  /// Initializes
  HighValueIndicator(DataInput input) : super(input);

  @override
  T getValue(int index) =>
      createResultOf(epoch: getEpochOfIndex(index), quote: entries[index].high);
}
