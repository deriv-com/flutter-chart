import 'package:flutter/material.dart';
import 'package:deriv_chart/generated/l10n.dart';

/// A widget that provides localization to the chart widget tree.
class LocalizationProvider extends InheritedWidget {
  /// Creates a new instance of [LocalizationProvider].
  const LocalizationProvider({
    required this.localization,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  /// The localization instance to provide.
  final ChartLocalization localization;

  /// Returns the [ChartLocalization] instance from the nearest
  /// [LocalizationProvider] ancestor.
  static ChartLocalization of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<LocalizationProvider>();
    if (provider != null) {
      return provider.localization;
    }

    // Fallback to Localizations if provider not found
    final localization =
        Localizations.of<ChartLocalization>(context, ChartLocalization);
    if (localization != null) {
      return localization;
    }

    // If neither is available, create a new instance
    return ChartLocalization();
  }

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) {
    return localization != oldWidget.localization;
  }
}
