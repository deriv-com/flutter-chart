import 'dart:ui';

import 'package:deriv_chart/src/components/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The details to show on a crosshair.
class CrosshairDetails extends StatelessWidget {
  /// Initializes the details to show on a crosshair.
  const CrosshairDetails({
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.pipSize,
    Key key,
  }) : super(key: key);

  /// The chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// The basic data entry of a crosshair.
  final Tick crosshairTick;

  /// Number of decimal digits when showing prices.
  final int pipSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFF323738),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTimeLabel(context),
            const SizedBox(height: 5),
            mainSeries.getCrossHairInfo(
                crosshairTick, pipSize, context.watch<ChartTheme>()),
          ],
        ),
      );

  Widget _buildTimeLabel(BuildContext context) {
    final DateTime time =
        DateTime.fromMillisecondsSinceEpoch(crosshairTick.epoch, isUtc: true);
    final String timeLabel = DateFormat('dd MMM yyy - HH:mm:ss').format(time);
    return Text(
      timeLabel,
      style: context.watch<ChartTheme>().overLine,
    );
  }
}
