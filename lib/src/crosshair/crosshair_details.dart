import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CrosshairDetails extends StatelessWidget {
  CrosshairDetails({
    Key key,
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.pipSize,
  }) : super(key: key);

  final DataSeries mainSeries;
  final Tick crosshairTick;
  final int pipSize;
  ChartTheme _theme;

  @override
  Widget build(BuildContext context) {
    _theme = context.watch<ChartTheme>();
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF323738),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTimeLabel(context),
          SizedBox(height: 5),
          mainSeries.getCrossHairInfo(crosshairTick, pipSize, _theme),
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
      style: _theme.overLine,
    );
  }
}
