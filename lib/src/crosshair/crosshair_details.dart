import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
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

  final BaseSeries mainSeries;
  final Tick crosshairTick;
  final int pipSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.35,
          // TODO(Ramin): Add style for cross-hair when design updated
          colors: [Color(0xFF0E0E0E), Colors.transparent],
        ),
      ),
      child: Column(
        children: <Widget>[
          mainSeries.getCrossHairInfo(crosshairTick),
          SizedBox(height: 2),
          _buildTimeLabel(),
        ],
      ),
    );
  }

  Text _buildTimeLabel() {
    final time = DateTime.fromMillisecondsSinceEpoch(crosshairTick.epoch);
    final timeLabel = DateFormat('dd MMM yy HH:mm:ss').format(time);
    return _buildLabel(timeLabel);
  }

  // TODO(Ramin): Add style for cross-hair when design updated
  Text _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: Colors.white70,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
