import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/chart_date_utils.dart';
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
    required this.crosshairVariant,
    this.pipSize = 4,
    Key? key,
  }) : super(key: key);

  /// The chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// The basic data entry of a crosshair.
  final Tick crosshairTick;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  /// The variant of the crosshair to be used.
  /// This is used to determine the type of crosshair to display.
  /// The default is [CrosshairVariant.smallScreen].
  /// [CrosshairVariant.largeScreen] is mostly for web.
  final CrosshairVariant crosshairVariant;

  @override
  Widget build(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: theme.crosshairInformationBoxContainerGlassBackgroundBlur,
            sigmaY: theme.crosshairInformationBoxContainerGlassBackgroundBlur),
        child: Container(
          decoration: BoxDecoration(
            color: theme.crosshairInformationBoxContainerGlassColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildCrosshairHeader(context),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.margin08, vertical: Dimens.margin04),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      mainSeries.getCrossHairInfo(crosshairTick, pipSize,
                          context.watch<ChartTheme>(), crosshairVariant),
                      _buildTimeLabel(context, crosshairVariant),
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

  Widget _buildTimeLabel(
      BuildContext context, CrosshairVariant crosshairVariant) {
    final String date = ChartDateUtils.formatDate(crosshairTick.epoch);
    final String time =
        ChartDateUtils.formatTimeWithSeconds(crosshairTick.epoch);
    final ChartTheme theme = context.watch<ChartTheme>();
    final style = theme.crosshairInformationBoxTimeLabelStyle.copyWith(
      color: theme.crosshairInformationBoxTextSubtle,
    );
    if (crosshairVariant == CrosshairVariant.smallScreen) {
      return Text(
        '$date $time',
        textAlign: TextAlign.center,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.visible,
        softWrap: false,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          date,
          textAlign: TextAlign.center,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        ),
        const SizedBox(width: 8),
        Text(
          time,
          textAlign: TextAlign.center,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        ),
      ],
    );
  }

  Widget _buildCrosshairHeader(BuildContext context) {
    final ChartTheme theme = context.watch<ChartTheme>();
    final double percentageChange = getPercentageChange();
    final String percentChangeLabel =
        '${percentageChange.toStringAsFixed(pipSize)}%';

    final Color color = percentageChange >= 0
        ? theme.crosshairInformationBoxTextProfit
        : theme.crosshairInformationBoxTextLoss;
    return Container(
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text(
        '$percentChangeLabel',
        style: theme.crosshairInformationBoxTitleStyle.copyWith(
          color: theme.crosshairInformationBoxTextStatic,
        ),
      ),
    );
  }

  /// Calculates the percentage change between the current tick and the previous tick.
  ///
  /// Returns 0 if there's no previous tick or if the previous tick's close value is 0.
  /// Uses the closest previous tick found by the findClosestPreviousTick function
  /// if no previousTick is explicitly provided.
  double getPercentageChange() {
    final previousTick = findClosestPreviousTick(
        crosshairTick, mainSeries.visibleEntries.entries);

    final double prevClose = previousTick?.close ?? 0;
    // If there's no previous tick or its close value is 0, return 0 to avoid division by zero
    // and to indicate no change.
    // The previous tick can legitimately be null in cases such as when the crosshair is on the first tick
    // or when there are no previous ticks available in the data series.
    if (prevClose == 0) {
      return 0;
    }

    final double change = crosshairTick.close - prevClose;
    return (change / prevClose) * 100;
  }
}
