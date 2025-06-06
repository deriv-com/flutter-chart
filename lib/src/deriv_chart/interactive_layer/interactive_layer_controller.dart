import 'dart:ui';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/foundation.dart';

import 'interactable_drawings/interactable_drawing.dart';
import 'interactive_layer_states/interactive_state.dart';

/// A controller similar to [ListView.scrollController] to control interactive
/// layer from outside in addition to get some information from internal
/// states of layer to outside.
///
/// This controller acts as the bridge between outside of the chart component
/// and interactive layer.
class InteractiveLayerController extends ChangeNotifier {
  /// The current state of the interactive layer.
  late InteractiveState _currentState;

  /// Current state of the interactive layer.
  InteractiveState get currentState => _currentState;

  /// The current position of the floating menu.
  Offset floatingMenuPosition = Offset.zero;

  /// The current state of the interactive layer.
  set currentState(InteractiveState state) {
    _currentState = state;
    notifyListeners();
  }

  InteractableDrawing<DrawingToolConfig>? _selectedDrawing;

  /// The current selected drawing of the [InteractiveLayer].
  InteractableDrawing<DrawingToolConfig>? get selectedDrawing =>
      _selectedDrawing;

  /// Sets the selected drawing of the [InteractiveLayer].
  set selectedDrawing(
    InteractableDrawing<DrawingToolConfig>? drawing,
  ) {
    _selectedDrawing = drawing;
    notifyListeners();
  }
}
