import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/widgets/localization_provider.dart';
import 'package:flutter/material.dart';

/// Build context extensions.
extension ContextExtension on BuildContext {
  /// Returns [ChartLocalization] of context.
  ChartLocalization get localization => LocalizationProvider.of(this);
}
