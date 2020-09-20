import 'package:flutter/material.dart';

/// Chart widget's controller
class ChartController extends ChangeNotifier {
  VoidCallback _onScrollToNow;

  /// Registers a listener for
  // ignore: avoid_setters_without_getters
  set scrollToNowListener(VoidCallback listener) => _onScrollToNow = listener;

  /// Scroll chart visible area to the newest data.
  void scrollToNow() => _onScrollToNow?.call();
}
