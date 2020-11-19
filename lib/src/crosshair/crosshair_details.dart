import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CrosshairDetails extends StatelessWidget {
  const CrosshairDetails({
    Key key,
    @required this.mainSeries,
    @required this.crosshairTick,
    @required this.pipSize,
  }) : super(key: key);

  final DataSeries mainSeries;
  final Tick crosshairTick;
  final int pipSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.yellow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          mainSeries.getCrossHairInfo(crosshairTick, pipSize),
          SizedBox(height: 2),
          _buildTimeLabel(),
        ],
      ),
    );
  }

  Widget _buildTimeLabel() {
    final time =
        DateTime.fromMillisecondsSinceEpoch(crosshairTick.epoch, isUtc: true);
    final timeLabel = DateFormat('dd MMM yy HH:mm:ss').format(time);
    return _buildLabel(timeLabel);
  }

  // TODO(Ramin): Add style for cross-hair when design updated
  Widget _buildLabel(String label) {
    return  Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white70,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
    );
  }
}
