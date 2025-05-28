import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart_date_utils.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/core/crosshair_details.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/line/large_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// An abstract implementation of CrosshairBehaviour optimized for large screens.
///
/// This class provides an enhanced crosshair behaviour suitable for desktop, web,
/// and other large screen devices. It extends the CrosshairBehaviour class with
/// adaptations that take advantage of the additional screen real estate.
///
/// Key characteristics of the large screen behaviour:
/// - More detailed information displays
/// - Enhanced visual elements for better readability
/// - Optimized positioning for mouse interactions
/// - Richer crosshair experience with additional visual cues
abstract class LargeScreenCrosshairBehaviour<T extends Tick>
    extends CrosshairBehaviour<T> {
  @override
  Widget getCrossHairInfo(
      {required DataSeries<T> mainSeries,
      required T crosshairTick,
      required int pipSize,
      required ChartTheme theme}) {
    return mainSeries.getDetailedCrossHairInfo(
        crosshairTick: crosshairTick, pipSize: pipSize, theme: theme);
  }

  @override
  Widget createTimeLabel(
      {required String dateText,
      required TextStyle style,
      String timeText = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dateText,
          textAlign: TextAlign.center,
          style: style,
        ),
        const SizedBox(width: 8),
        Text(
          timeText,
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }

  @override
  Widget createCrosshairLabel(
      {required Widget content,
      required Offset translationOffset,
      double? topOffset,
      double? rightOffset,
      double? bottomOffset,
      double? leftOffset,
      EdgeInsetsGeometry? containerPadding =
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      Decoration? decoration}) {
    return Positioned(
      top: topOffset,
      right: rightOffset,
      bottom: bottomOffset,
      left: leftOffset,
      child: FractionalTranslation(
        translation: translationOffset,
        child: Container(
          padding: containerPadding,
          decoration: decoration,
          child: content,
        ),
      ),
    );
  }

  /// Calculates the optimal vertical position for the crosshair details box.
  ///
  /// In Flutter canvas, the coordinate system has (0,0) at the top-left corner,
  /// with y-values increasing downward. This method calculates a position that
  /// places the details box above the cursor with appropriate spacing.
  ///
  /// The calculation works as follows:
  /// 1. Start with the cursor's Y position
  /// 2. Subtract the height of the details box (100px) to position it above the cursor
  /// 3. Subtract an additional gap (120px) to create space between the cursor and the box
  /// 4. Ensure the box doesn't go too close to the top edge by using max(10, result)
  ///
  /// This ensures the details box is visible and well-positioned relative to the cursor,
  /// while preventing it from being rendered partially off-screen at the top.
  ///
  /// Parameters:
  /// - [cursorY]: The Y-coordinate of the cursor on the canvas
  ///
  /// Returns:
  /// The Y-coordinate (top position) where the details box should be rendered.
  /// The value is guaranteed to be at least 10 pixels from the top of the canvas.
  @override
  double calculateDetailsPosition({required double cursorY}) {
    // Additional vertical gap between the cursor and the details box
    // This ensures the box doesn't overlap with or crowd the cursor
    const double gap = 120;

    // Calculate position and ensure it's at least 10px from the top edge
    // This prevents the box from being rendered partially off-screen
    return max(10, cursorY - detailsBoxHeight - gap);
  }

  @override
  Widget createCrosshairDetails(
      {required T crosshairTick,
      required Duration animationDuration,
      required DataSeries<T> mainSeries,
      required ChartTheme theme,
      required Widget crosshairHeader,
      double? width,
      double? topOffset,
      double? rightOffset,
      double? bottomOffset,
      double? leftOffset,
      AlignmentGeometry alignment = Alignment.center,
      int pipSize = 4,
      double cursorY = 0}) {
    final style = theme.crosshairInformationBoxTimeLabelStyle.copyWith(
      color: theme.crosshairInformationBoxTextSubtle,
    );
    return AnimatedPositioned(
      duration: animationDuration,
      // Position the details above the cursor with a gap
      // Use cursorY which is the cursor's Y position
      // Subtract the height of the details box plus a gap
      top: topOffset ?? calculateDetailsPosition(cursorY: cursorY),
      bottom: bottomOffset,
      width: width,
      left: leftOffset,
      child: Align(
        alignment: alignment,
        child: CrosshairDetails(
          mainSeries: mainSeries,
          crosshairTick: crosshairTick,
          pipSize: pipSize,
          crosshairHeader: crosshairHeader,
          crosshairInfo: getCrossHairInfo(
              mainSeries: mainSeries,
              crosshairTick: crosshairTick,
              pipSize: pipSize,
              theme: theme),
          crosshairTimeLabel: createTimeLabel(
            dateText: ChartDateUtils.formatDate(crosshairTick.epoch),
            style: style,
            timeText: ChartDateUtils.formatTimeWithSeconds(crosshairTick.epoch),
          ),
        ),
      ),
    );
  }

  @override
  CustomPainter createLinePainter({
    required ChartTheme theme,
    double cursorY = 0,
  }) {
    return LargeScreenCrosshairLinePainter(
      theme: theme,
      cursorY: cursorY,
    );
  }
}
