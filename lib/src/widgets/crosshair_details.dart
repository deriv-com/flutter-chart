import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/candle.dart';
import '../models/chart_style.dart';

class CrosshairDetails extends StatelessWidget {
  const CrosshairDetails({
    Key key,
    @required this.crosshairCandle,
    @required this.style,
    @required this.pipSize,
  }) : super(key: key);

  final Candle crosshairCandle;
  final ChartStyle style;
  final int pipSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.35,
          colors: [Color(0xFF0E0E0E), Colors.transparent],
        ),
      ),
      child: Column(
        children: <Widget>[
          style == ChartStyle.candles
              ? _buildCandleStyleDetails()
              : _buildLineStyleDetails(),
          SizedBox(height: 2),
          _buildTimeLabel(),
        ],
      ),
    );
  }

  Widget _buildCandleStyleDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildLabelValue('O', crosshairCandle.open),
            _buildLabelValue('C', crosshairCandle.close),
          ],
        ),
        SizedBox(width: 16),
        Column(
          children: <Widget>[
            _buildLabelValue('H', crosshairCandle.high),
            _buildLabelValue('L', crosshairCandle.low),
          ],
        ),
      ],
    );
  }

  Widget _buildLineStyleDetails() {
    return _buildValue(crosshairCandle.close, fontSize: 16);
  }

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
    final time = DateTime.fromMillisecondsSinceEpoch(crosshairCandle.epoch);
    final timeLabel = DateFormat('dd MMM yy HH:mm:ss').format(time);
    return _buildLabel(timeLabel);
  }

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