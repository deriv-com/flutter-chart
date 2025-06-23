import 'package:flutter/foundation.dart';

/// Notifier class for notifying about interaction events.
class InteractionNotifier extends ChangeNotifier {
  /// Notifies listeners about changes.
  void notify() {
    notifyListeners();
  }
}
