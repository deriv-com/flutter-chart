import 'dart:ui';

import 'package:flutter/material.dart';

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
      color: Color(0xFF0E0E0E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildLabelValue('O', crosshairCandle.open, pipSize),
          _buildLabelValue('H', crosshairCandle.high, pipSize),
          _buildLabelValue('L', crosshairCandle.low, pipSize),
          _buildLabelValue('C', crosshairCandle.close, pipSize),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, double value, int pipSize) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(width: 4),
        Text(
          value.toStringAsFixed(pipSize),
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
