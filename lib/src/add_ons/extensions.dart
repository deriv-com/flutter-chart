import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';

import 'drawing_tools_ui/drawing_tool_config.dart';
import 'repository.dart';

/// Extension on Repository<AddOnConfig>.
extension AddOnsRepositoryConfigExtension on Repository<AddOnConfig> {
  // TODO(Ramin): Later will do this will be internally handled inside the
  // repository. When Web can update.
  /// Gets the next number for a new indicator or drawing tool.
  int getNumberForNewAddOn(AddOnConfig addOn) {
    final Iterable<AddOnConfig> addOnOfSameType = items
        .where((AddOnConfig item) => item.runtimeType == addOn.runtimeType);

    if (addOnOfSameType.isNotEmpty) {
      final int postFixNumber = addOnOfSameType
              .map<int>((AddOnConfig item) => item.number)
              .reduce(max) +
          1;

      return postFixNumber;
    }

    return 0;
  }
}

/// Extension on Repository<DrawingToolsConfig>.
extension AddOnsRepositoryDrawingToolConfigExtension
    on Repository<DrawingToolConfig> {
  /// Update numbers for renamed list of drawing tools.
  void updateSequenceNumbers(
    DrawingToolConfig config,
    int index,
  ) {
    for (int i = index; i < items.length; i++) {
      DrawingToolConfig toolConfig = items[i];
      if (toolConfig.number != 0 &&
          toolConfig.runtimeType == config.runtimeType) {
        toolConfig = toolConfig.copyWith(
          number: toolConfig.number - 1,
        );
        updateAt(i, toolConfig);
      }
    }
  }
}
