import 'package:meta/meta.dart';

class CandlePainting {
  final double xCenter;
  final double yHigh;
  final double yLow;
  final double yOpen;
  final double yClose;
  final double width;

  CandlePainting({
    @required this.xCenter,
    @required this.yHigh,
    @required this.yLow,
    @required this.yOpen,
    @required this.yClose,
    @required this.width,
  });
}
