import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/candle.dart';

class CrosshairCandleDetails extends StatelessWidget {
  const CrosshairCandleDetails({
    Key key,
    @required this.crosshairCandle,
    @required this.pipSize,
  }) : super(key: key);

  final Candle crosshairCandle;
  final int pipSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 0.5,
          colors: [Color(0xFF0E0E0E), Colors.transparent],
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
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
          ),
          SizedBox(height: 8),
          _buildTimeLabel(),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
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

  Text _buildValue(double value) {
    return Text(
      value.toStringAsFixed(pipSize),
      style: TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
