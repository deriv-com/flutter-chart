import 'package:flutter/material.dart';

class XAxisModel extends ChangeNotifier {
  /// Max distance between [rightBoundEpoch] and [nowEpoch] in pixels.
  /// Limits panning to the right.
  static const double maxCurrentTickOffset = 150;
}
