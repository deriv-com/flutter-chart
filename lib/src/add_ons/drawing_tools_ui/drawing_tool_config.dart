import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:flutter/material.dart';

/// Drawing tools config
@immutable
abstract class DrawingToolConfig extends AddOnConfig {
  /// Initializes
  const DrawingToolConfig({bool isOverlay = true})
      : super(isOverlay: isOverlay);

  // TODO(maryia-binary): Add logics for drawing tools UI
}
