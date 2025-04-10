import 'package:deriv_chart/generated/l10n.dart';
import 'package:flutter/material.dart';

/// Build context extensions.
extension ContextExtension on BuildContext {
  /// Returns [ChartLocalization] of context.
  ChartLocalization get localization => ChartLocalization.of(this);
}

/// This class is to supplement deprecated_member_use for value
/// value converted RGBA into a 32 bit integer
/// Will be removed in the next stable flutter version
/// https://github.com/flutter/flutter/issues/160184#issuecomment-2560184639
extension ColorEx on Color {
  /// Converts a double value to an 8-bit integer.
  static int floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  int get toInt32 {
    return floatToInt8(a) << 24 |
        floatToInt8(r) << 16 |
        floatToInt8(g) << 8 |
        floatToInt8(b) << 0;
  }
}
