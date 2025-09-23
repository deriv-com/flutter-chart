import 'package:deriv_chart/src/theme/quill_icons.dart';
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
    this.lineProfitColor = const Color(0xFF008832),
    this.lineLossColor = const Color(0xFFE6190E),
    this.lineDefaultColor = const Color(0xFFCED0D6),
    this.radius = 12.0,
    this.activeMarkerText = const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    this.textLeftPadding = 8.0,
    this.textRightPadding = 16.0,
    this.entryMarkerStyle = const EntryExitMarkerStyle(),
    this.exitMarkerStyle = const EntryExitMarkerStyle(
      color: Color(0xFF00A79E),
      borderColor: Color(0xFFFFFFFF),
    ),
    this.markerLabelTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    this.startTimeIcon = QuillIcons.stopwatch,
    this.endTimeIcon = QuillIcons.flag_checkered,
  });

  /// Color of marker pointing up.
  final Color upColor;

  /// Color of marker pointing down.
  final Color downColor;

  /// Background Color of marker.
  final Color backgroundColor;

  /// Color of line when the marker is profit.
  final Color lineProfitColor;

  /// Color of line when the marker is loss.
  final Color lineLossColor;

  /// Color of line for its default state.
  final Color lineDefaultColor;

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

  /// Icon of the start time vertical line.
  final IconData startTimeIcon;

  /// Icon of the end time vertical line.
  final IconData endTimeIcon;

  /// Style of the marker label.
  final TextStyle markerLabelTextStyle;
}
