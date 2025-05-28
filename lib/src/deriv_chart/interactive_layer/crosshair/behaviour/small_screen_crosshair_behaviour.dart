import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart_date_utils.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/behaviour/crosshair_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/core/crosshair_details.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/painters/line/small_screen_crosshair_line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

/// An abstract implementation of CrosshairBehaviour optimized for small screens.
///
/// This class provides a simplified crosshair behaviour suitable for mobile devices
/// and other small screens. It implements the CrosshairBehaviour interface with
/// adaptations that work better on limited screen real estate.
///
/// Key characteristics of the small screen behaviour:
/// - Minimalist visual elements to avoid cluttering the small screen
/// - Simplified positioning of information elements
/// - Optimized touch interactions for smaller displays
abstract class SmallScreenCrosshairBehaviour<T extends Tick>
    implements CrosshairBehaviour<T> {
  /// The height of the crosshair details box in logical pixels.
  ///
  /// For OHLC series on large screens, this is set to 100 pixels, and is used to calculate the position of the information box from the crosshair lines.
  @override
  double get detailsBoxHeight => 50;

  @override
  Widget getCrossHairInfo(
      {required DataSeries<T> mainSeries,
      required T crosshairTick,
      required int pipSize,
      required ChartTheme theme}) {
    return mainSeries.getCrossHairInfo(crosshairTick, pipSize, theme);
  }

  @override
  Widget createTimeLabel(
      {required String dateText,
      required TextStyle style,
      String timeText = ''}) {
    return Text(
      '$dateText $timeText',
      textAlign: TextAlign.center,
      style: style,
    );
  }

  @override
  CustomPainter createLinePainter({
    required ChartTheme theme,
    double cursorY = 0,
  }) {
    return SmallScreenCrosshairLinePainter(
      theme: theme,
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
    return const SizedBox.shrink();
  }

  @override
  double calculateDetailsPosition({required double cursorY}) {
    return 8;
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
}
