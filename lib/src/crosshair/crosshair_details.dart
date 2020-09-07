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

//  Widget _buildCandleStyleDetails() {
//    return Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//      children: <Widget>[
//        Column(
//          children: <Widget>[
//            _buildLabelValue('O', crosshairTick.open),
//            _buildLabelValue('C', crosshairTick.close),
//          ],
//        ),
//        SizedBox(width: 16),
//        Column(
//          children: <Widget>[
//            _buildLabelValue('H', crosshairTick.high),
//            _buildLabelValue('L', crosshairTick.low),
//          ],
//        ),
//      ],
//    );
//  }
//
//  Widget _buildLineStyleDetails() {
//    return _buildValue(crosshairTick.close, fontSize: 16);
//  }

  Widget _buildLabelValue(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          _buildLabel(label),
          SizedBox(width: 4),
          _buildValue(value),
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

  // TODO(Ramin): Add style for cross-hair when design updated
  Text _buildValue(double value, {double fontSize = 12}) {
    return Text(
      value.toStringAsFixed(pipSize),
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
