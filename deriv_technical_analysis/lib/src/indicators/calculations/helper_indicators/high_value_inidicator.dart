import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../indicator.dart';

/// A helper indicator to get the high value of a list of [IndicatorOHLC]
class HighValueIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  HighValueIndicator(IndicatorDataInput input) : super(input);

  @override
  T getValue(int index) => createResult(
        index: index,
        quote: entries[index].high,
      );
}
