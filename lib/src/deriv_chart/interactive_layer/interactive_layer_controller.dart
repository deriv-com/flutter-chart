import 'dart:ui';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:flutter/foundation.dart';

import 'interactive_layer_states/interactive_adding_tool_state.dart';
import 'interactive_layer_states/interactive_state.dart';

/// A controller similar to [ListView.scrollController] to control interactive
/// layer from outside in addition to get some information from internal
/// states of layer to outside.
///
/// This controller acts as the bridge between outside of the chart component
/// and interactive layer.
class InteractiveLayerController extends ChangeNotifier {
  /// Creates an instance of [InteractiveLayerController].
  ///
  /// [floatingMenuInitialPosition] is the initial position of the floating
  /// menu that appears when a drawing is selected.
  /// Once it appears on this initial position, it can be moved by the user
  /// and the internal [floatingMenuPosition] will be updated accordingly.
  InteractiveLayerController({
    Offset floatingMenuInitialPosition = Offset.zero,
  }) : floatingMenuPosition = floatingMenuInitialPosition;

  /// The current state of the interactive layer.
  late InteractiveState _currentState;

  /// Current state of the interactive layer.
  InteractiveState get currentState => _currentState;

  /// The current position of the floating menu.
  Offset floatingMenuPosition;

  /// The callback to be called when the user cancels adding a drawing tool.
  VoidCallback? onCancelAdding;

  /// The callback to be called when a new drawing tool going to be added.
  Function(DrawingToolConfig)? onAddNewTool;

  /// Sets the current state of the interactive layer and notifies listeners.
  set currentState(InteractiveState state) {
    _currentState = state;
    notifyListeners();
  }

  /// Cancels the adding of a drawing tool if we're in
  /// [InteractiveAddingToolState].
  ///
  /// Otherwise will throw ...
  void cancelAdding() {
    if (_currentState is InteractiveAddingToolState) {
      onCancelAdding?.call();
    } else {
      throw StateError(
        'Cannot cancel adding tool when not in InteractiveAddingToolState',
      );
    }
  }

  /// Updates the [InteractiveLayer]'s internal state to start adding the
  /// [config] to the chart.
  void startAddingNewTool(DrawingToolConfig config) =>
      onAddNewTool?.call(config);
}
