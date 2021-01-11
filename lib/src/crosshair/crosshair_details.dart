import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CrosshairDetails extends StatelessWidget {
  const CrosshairDetails({
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.pipSize,
    Key key,
  }) : super(key: key);

  final DataSeries<Tick> mainSeries;
  final Tick crosshairTick;
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
