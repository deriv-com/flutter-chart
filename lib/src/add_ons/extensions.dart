import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

import 'indicators_ui/indicator_config.dart';
import 'repository.dart';

/// Extension on Repository<IndicatorConfig>.
extension AddOnsRepositoryIndicatorConfigExtension
    on Repository<IndicatorConfig> {
  // TODO(Ramin): Later will do this will be internally handled inside the
  // repository. When Web can update.
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

/// Extension on Repository<IndicatorConfig>.
extension AddOnsRepositoryDrawingToolConfigExtension
    on Repository<DrawingToolConfig> {
  /// Increase and Gets the next number for a new indicator.
  int getNumberForNewAddOn(DrawingToolConfig addOn) {
    final Iterable<DrawingToolConfig> drawingToolsOfSameType = items.where(
        (DrawingToolConfig item) => item.runtimeType == addOn.runtimeType);

    if (drawingToolsOfSameType.isNotEmpty) {
      final int postFixNumber = drawingToolsOfSameType
              .map<int>((DrawingToolConfig item) => item.number)
              .reduce(max) +
          1;

      return postFixNumber;
    }

    return 0;
  }
}
