import 'package:flutter/material.dart';

class XAxisModel extends ChangeNotifier {
  /// Max distance between [rightBoundEpoch] and [nowEpoch] in pixels.
  /// Limits panning to the right.
  static const double maxCurrentTickOffset = 150;

  static const int maxIntervalWidth = 80;

  static const int defaultIntervalWidth = 20;

  static const int minIntervalWidth = 4;
}
