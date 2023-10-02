import 'dart:async';
import 'package:flutter/material.dart';

/// A utility class for implementing debouncing of function calls.
class Debounce {
  /// Creates a [Debounce] instance.
  ///
  /// The [delay] parameter determines the duration of the debounce window.
  Debounce({
    this.delay = const Duration(milliseconds: 1000),
  });

  /// The duration of the debounce.
  /// Default debounce duration is 1000 milliseconds (1 second)
  final Duration delay;

  /// The function to be executed after the debounce window.
  VoidCallback? action;

  /// Internal timer to manage the debounce window.
  Timer? _timer;

  /// Runs the provided [action] function after the debounce window.
  ///
  /// If another call to [run] is made before the debounce window completes,
  /// the previous timer is canceled and a new timer is started.
  void run(VoidCallback action) {
    /// Cancel the previous timer if it exists
    if (_timer != null) {
      _timer!.cancel();
    }

    /// Start a new timer with the specified [delay] and [action]
    _timer = Timer(
      delay,
      action,
    );
  }
}
