import 'dart:ui';

import 'package:flutter/foundation.dart';

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

  /// Sets the current state of the interactive layer and notifies listeners.
  set currentState(InteractiveState state) {
    _currentState = state;
    notifyListeners();
  }
}
