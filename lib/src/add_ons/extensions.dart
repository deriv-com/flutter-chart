import 'dart:math';

import 'indicators_ui/indicator_config.dart';
import 'repository.dart';

/// Extension on Repository<IndicatorConfig>.
extension AddOnsRepositoryIndicatorConfigExtension
    on Repository<IndicatorConfig> {
  /// Gets the next number for a new indicator.
  int getNumberForNewAddOn(IndicatorConfig addOn) {
    final Iterable<IndicatorConfig> indicatorsOfSameType = items
        .where((IndicatorConfig item) => item.runtimeType == addOn.runtimeType);

    if (indicatorsOfSameType.isNotEmpty) {
      final int postFixNumber = indicatorsOfSameType
              .map<int>((IndicatorConfig item) => item.number)
              .reduce(max) +
          1;

      return postFixNumber;
    }

    return 0;
  }
}
