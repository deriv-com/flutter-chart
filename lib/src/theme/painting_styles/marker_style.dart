import 'package:flutter/material.dart';

import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';

import 'entry_exit_marker_style.dart';

/// Defines the style of markers.
class MarkerStyle extends ChartPaintingStyle {
  /// Creates marker style.
  const MarkerStyle({
    this.upColor = const Color(0xFF00C390),
    this.downColor = const Color(0xFFDE0040),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.radius = 12.0,
    this.activeMarkerText = const TextStyle(
      color: Colors.black,
      fontSize: 10,
      height: 1.4,
    ),
    this.textLeftPadding = 2.0,
    this.textRightPadding = 4.0,
    this.entryMarkerStyle = const EntryExitMarkerStyle(),
    this.exitMarkerStyle = const EntryExitMarkerStyle(
      color: Color(0xFF00A79E),
      borderColor: Color(0xFFFFFFFF),
    ),
  });

  /// Color of marker pointing up.
  final Color upColor;

  /// Color of marker pointing down.
  final Color downColor;

  /// Background Color of marker.
  final Color backgroundColor;

  /// Radius of a single marker.
  final double radius;

  /// Active marker text style.
  final TextStyle activeMarkerText;

  /// Active marker text left padding.
  final double textLeftPadding;

  /// Active marker text right padding.
  final double textRightPadding;

  /// Style of an entry tick marker.
  final EntryExitMarkerStyle entryMarkerStyle;

  /// Style of an exit tick marker.
  final EntryExitMarkerStyle exitMarkerStyle;
}
