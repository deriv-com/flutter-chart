import 'package:flutter/material.dart';

/// ScrollToNow callback
typedef OnScrollToNow = Function(bool);

/// Chart widget's controller
class ChartController extends ChangeNotifier {
  OnScrollToNow _onScrollToNow;

  /// Registers a listener for
  // ignore: avoid_setters_without_getters
  set scrollToNowListener(OnScrollToNow listener) => _onScrollToNow = listener;

  /// Scroll chart visible area to the newest data.
  void scrollToNow({bool animate}) => _onScrollToNow?.call(animate);
}
