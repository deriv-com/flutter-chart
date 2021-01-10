import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The details to show on a crasshair.
class CrosshairDetails extends StatelessWidget {
  /// Initializes the details to show on a crasshair.
  const CrosshairDetails({
    Key key,
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.pipSize,
  }) : super(key: key);

  /// The main data series for the crosshair.
  final DataSeries mainSeries;

  /// The tick that the crosshair is in.
  final Tick crosshairTick;

  /// The size of the crosshair's pip.
  final int pipSize;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }

  Widget _buildTimeLabel(BuildContext context) {
    final time =
        DateTime.fromMillisecondsSinceEpoch(crosshairTick.epoch, isUtc: true);
    final timeLabel = DateFormat('dd MMM yyy - HH:mm:ss').format(time);
    return Text(
      timeLabel,
      style: context.watch<ChartTheme>().overLine,
    );
  }
}
