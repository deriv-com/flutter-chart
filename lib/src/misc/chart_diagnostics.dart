import 'package:flutter/foundation.dart';

/// Diagnostics for the interactive layer / drawing tools sync.
///
/// Enabled only in debug builds. To trace a release-mode issue with
/// `flutter run --release` (where `debugPrint` output is still visible),
/// temporarily set this to `true`.
const bool kChartDiagnosticsEnabled = kDebugMode;

/// Logs [message] with a `[chart-diag]` prefix when diagnostics are enabled.
void chartDiag(String message) {
  if (kChartDiagnosticsEnabled) {
    debugPrint('[chart-diag] $message');
  }
}
