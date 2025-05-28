import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/theme/dimens.dart';

/// The details to show on a crosshair.
class CrosshairDetails extends StatelessWidget {
  /// Initializes the details to show on a crosshair.
  const CrosshairDetails({
    required this.mainSeries,
    required this.crosshairTick,
    required this.crosshairHeader,
    required this.crosshairInfo,
    required this.crosshairTimeLabel,
    this.pipSize = 4,
    Key? key,
  }) : super(key: key);

  /// The chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// The basic data entry of a crosshair.
  ///
  /// This represents the tick data at the position where the crosshair is currently located.
  /// It contains information such as price, time, and other relevant data for that point.
  final Tick crosshairTick;

  /// Number of decimal digits when showing prices.
  ///
  /// This determines the precision of price values displayed in the crosshair details.
  /// For example, a pipSize of 4 would display prices like "1234.5678".
  final int pipSize;

  /// The widget to display as the header of the crosshair details box.
  ///
  /// This is typically a container showing the percentage change from the previous tick,
  /// often with color coding to indicate positive or negative change.
  final Widget crosshairHeader;

  /// The widget that displays the price information for the crosshair position.
  ///
  /// For line charts, this typically shows just the price value.
  /// For OHLC charts, this shows open, high, low, and close values.
  final Widget crosshairInfo;

  /// The widget that displays the time information for the crosshair position.
  ///
  /// This typically shows the date and time of the tick at the crosshair position.
  final Widget crosshairTimeLabel;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: theme.crosshairInformationBoxContainerGlassBackgroundBlur,
            sigmaY: theme.crosshairInformationBoxContainerGlassBackgroundBlur),
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: theme.crosshairInformationBoxContainerGlassColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                crosshairHeader,
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.margin08, vertical: Dimens.margin04),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      crosshairInfo,
                      crosshairTimeLabel,
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
