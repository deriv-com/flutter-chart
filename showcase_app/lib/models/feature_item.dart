import 'package:flutter/material.dart';

/// Model class for a feature item in the showcase app.
class FeatureItem {

  /// Initialize a feature item.
  const FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.screen,
  });
  /// The title of the feature.
  final String title;

  /// The description of the feature.
  final String description;

  /// The icon to display for the feature.
  final IconData icon;

  /// The screen widget to navigate to when the feature is selected.
  final Widget screen;
}
