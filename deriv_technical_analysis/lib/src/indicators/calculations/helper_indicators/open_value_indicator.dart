import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';

import '../../indicator.dart';

/// A helper indicator to get the open value of a list of [DataInput]
class OpenValueIndicator<T extends Result> extends Indicator<T> {
  /// Initializes
  OpenValueIndicator(DataInput input) : super(input);

  @override
  T getValue(int index) =>
      createResultOf(epoch: getEpochOfIndex(index), quote: entries[index].open);
}
